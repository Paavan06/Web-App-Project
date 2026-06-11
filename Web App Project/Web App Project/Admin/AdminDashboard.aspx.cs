using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;

namespace Web_App_Project.Admin
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager
                        .ConnectionStrings["AttendanceDBConnectionString"]
                        .ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"]?.ToString() != "Admin")
            {
                Response.Redirect("~/auth/login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblTodayDate.Text = DateTime.Today.ToString("dddd, d MMMM yyyy");
                LoadDashboardStats();
                LoadWeeklyChart();
            }
        }

        private void LoadDashboardStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Total Staff
                int totalStaff = Convert.ToInt32(
                    new SqlCommand("SELECT COUNT(*) FROM Staff", conn).ExecuteScalar());
                lblTotalStaff.Text = totalStaff.ToString();

                // New this quarter (uses CreatedAt column — defaults to 0 if column absent)
                try
                {
                    int newQtr = Convert.ToInt32(new SqlCommand(
                        @"SELECT COUNT(*) FROM Staff
                          WHERE CreatedAt >= DATEADD(quarter, DATEDIFF(quarter, 0, GETDATE()), 0)", conn)
                        .ExecuteScalar());
                    lblNewThisQuarter.Text = newQtr.ToString();
                }
                catch { lblNewThisQuarter.Text = "0"; }

                // Present / Late / Absent counts for today
                string attendSql = @"
                    SELECT
                        SUM(CASE WHEN sub.TodayStatus = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
                        SUM(CASE WHEN sub.TodayStatus = 'Late'    THEN 1 ELSE 0 END) AS LateCount,
                        SUM(CASE WHEN sub.TodayStatus = 'Absent'  THEN 1 ELSE 0 END) AS AbsentCount
                    FROM (
                        SELECT
                            CASE
                                WHEN la.RecordID IS NOT NULL               THEN 'On Leave'
                                WHEN a.StaffID   IS NULL                   THEN 'Absent'
                                WHEN CAST(a.CheckIn AS time) <= '08:01:00' THEN 'Present'
                                ELSE 'Late'
                            END AS TodayStatus
                        FROM Staff s
                        LEFT JOIN Attendance a
                            ON s.StaffID = a.StaffID
                            AND a.AttendDate = CAST(GETDATE() AS date)
                        LEFT JOIN LateAbsence la
                            ON s.StaffID = la.StaffID
                            AND la.RecordDate = CAST(GETDATE() AS date)
                            AND la.RecordType LIKE 'Leave%'
                            AND la.Status IN ('Approved', 'Pending')
                    ) sub";

                using (SqlDataReader dr = new SqlCommand(attendSql, conn).ExecuteReader())
                {
                    if (dr.Read())
                    {
                        int present = dr["PresentCount"] == DBNull.Value ? 0 : Convert.ToInt32(dr["PresentCount"]);
                        int late    = dr["LateCount"]    == DBNull.Value ? 0 : Convert.ToInt32(dr["LateCount"]);
                        int absent  = dr["AbsentCount"]  == DBNull.Value ? 0 : Convert.ToInt32(dr["AbsentCount"]);

                        lblPresentToday.Text = present.ToString();

                        int pct = totalStaff > 0 ? (present * 100 / totalStaff) : 0;
                        lblAttendancePct.Text = pct + "%";

                        lblLateAbsent.Text       = (late + absent).ToString();
                        lblLateAbsentDetail.Text = late + " late · " + absent + " away";
                    }
                }

                // OT Pending
                int otPending = Convert.ToInt32(new SqlCommand(
                    "SELECT COUNT(*) FROM Overtime WHERE Status = 'Pending'", conn).ExecuteScalar());
                lblOTPending.Text = otPending.ToString();
            }
        }

        private void LoadWeeklyChart()
        {
            DateTime today = DateTime.Today;

            // Monday of the current week (handles Sunday edge case)
            int diff      = (int)today.DayOfWeek == 0 ? 6 : (int)today.DayOfWeek - 1;
            DateTime monday   = today.AddDays(-diff);
            DateTime saturday = monday.AddDays(5);

            int[] counts    = new int[6]; // index 0=Mon … 5=Sat
            int totalPresent = 0;
            int daysElapsed  = 0;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                int totalStaff = Convert.ToInt32(
                    new SqlCommand("SELECT COUNT(*) FROM Staff", conn).ExecuteScalar());

                // Present count per day for Mon–Sat
                SqlCommand cmdWeek = new SqlCommand(
                    @"SELECT AttendDate, COUNT(DISTINCT StaffID) AS Cnt
                      FROM Attendance
                      WHERE AttendDate >= @start AND AttendDate <= @end
                      GROUP BY AttendDate", conn);
                cmdWeek.Parameters.AddWithValue("@start", monday);
                cmdWeek.Parameters.AddWithValue("@end",   saturday);

                using (SqlDataReader dr = cmdWeek.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        DateTime d   = Convert.ToDateTime(dr["AttendDate"]);
                        int      cnt = Convert.ToInt32(dr["Cnt"]);
                        int      idx = (int)d.DayOfWeek - 1; // Mon=0 … Sat=5
                        if (idx >= 0 && idx <= 5)
                        {
                            counts[idx]  = cnt;
                            totalPresent += cnt;
                        }
                    }
                }

                // Elapsed days in the week up to today (Mon–Sat only)
                for (DateTime d = monday; d <= today && d <= saturday; d = d.AddDays(1))
                    daysElapsed++;

                int avgPct = (daysElapsed > 0 && totalStaff > 0)
                    ? totalPresent * 100 / (daysElapsed * totalStaff)
                    : 0;
                lblAvgAttendance.Text = avgPct + "%";

                // Total OT hours this week
                SqlCommand cmdOT = new SqlCommand(
                    @"SELECT ISNULL(SUM(OTHours), 0) FROM Overtime
                      WHERE OTDate >= @start AND OTDate <= @end
                        AND Status = 'Approved'", conn);
                cmdOT.Parameters.AddWithValue("@start", monday);
                cmdOT.Parameters.AddWithValue("@end",   saturday);
                decimal weekOT = Convert.ToDecimal(cmdOT.ExecuteScalar());
                lblAvgOT.Text = weekOT.ToString("0.#") + " hrs";
            }

            // Build Chart.js initialisation script
            string data   = string.Join(",", counts);
            string script = string.Format(@"
(function(){{
    var ctx = document.getElementById('weeklyChart').getContext('2d');
    new Chart(ctx, {{
        type: 'bar',
        data: {{
            labels: ['Mon','Tue','Wed','Thu','Fri','Sat'],
            datasets: [{{
                data: [{0}],
                backgroundColor: '#2563eb',
                borderRadius: 6,
                barThickness: 36,
                maxBarThickness: 48
            }}]
        }},
        options: {{
            responsive: true,
            plugins: {{
                legend: {{ display: false }},
                tooltip: {{ callbacks: {{
                    label: function(c) {{ return c.parsed.y + ' staff'; }}
                }} }}
            }},
            scales: {{
                y: {{
                    beginAtZero: true,
                    ticks: {{ stepSize: 1, precision: 0 }},
                    grid:  {{ color: '#f3f4f6' }},
                    border: {{ display: false }}
                }},
                x: {{ grid: {{ display: false }} }}
            }}
        }}
    }});
}})();", data);

            ScriptManager.RegisterStartupScript(this, GetType(), "weeklyChart", script, true);
        }
    }
}
