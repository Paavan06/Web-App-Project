using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Web_App_Project.Admin
{
    public partial class AdminAttendance : Page
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
                LoadStats();
                LoadAttendance();
            }
        }

        // ===== STAT CARDS =====
        private void LoadStats()
        {
            string sql = @"
                SELECT
                    SUM(CASE WHEN sub.TodayStatus = 'Present'  THEN 1 ELSE 0 END) AS PresentCount,
                    SUM(CASE WHEN sub.TodayStatus = 'Late'     THEN 1 ELSE 0 END) AS LateCount,
                    SUM(CASE WHEN sub.TodayStatus = 'Absent'   THEN 1 ELSE 0 END) AS AbsentCount
                FROM (
                    SELECT
                        CASE
                            WHEN la.RecordID IS NOT NULL         THEN 'On Leave'
                            WHEN a.StaffID IS NULL               THEN 'Absent'
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

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        lblPresentCount.Text = dr["PresentCount"] == DBNull.Value ? "0" : dr["PresentCount"].ToString();
                        lblLateCount.Text    = dr["LateCount"]    == DBNull.Value ? "0" : dr["LateCount"].ToString();
                        lblAbsentCount.Text  = dr["AbsentCount"]  == DBNull.Value ? "0" : dr["AbsentCount"].ToString();
                    }
                }
            }
        }

        // ===== LOAD GRID =====
        private void LoadAttendance()
        {
            string sql = @"
                SELECT
                    s.StaffName,
                    s.Department,
                    CAST(GETDATE() AS date) AS AttendDate,
                    ISNULL(CONVERT(varchar(5), a.CheckIn,  108), '—') AS CheckInTime,
                    ISNULL(CONVERT(varchar(5), a.CheckOut, 108), '—') AS CheckOutTime,
                    CASE
                        WHEN a.CheckOut IS NOT NULL
                        THEN CAST(DATEDIFF(minute, a.CheckIn, a.CheckOut) / 60 AS VARCHAR)
                             + 'h ' + CAST(DATEDIFF(minute, a.CheckIn, a.CheckOut) % 60 AS VARCHAR) + 'm'
                        WHEN a.CheckIn IS NOT NULL THEN 'In progress'
                        ELSE '—'
                    END AS WorkHours,
                    CASE
                        WHEN la.RecordID IS NOT NULL              THEN 'On Leave'
                        WHEN a.StaffID IS NULL                    THEN 'Absent'
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
                ORDER BY
                    CASE WHEN a.CheckIn IS NOT NULL THEN 0 ELSE 1 END,
                    a.CheckIn ASC,
                    s.StaffName ASC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvAttendance.DataSource = dt;
                gvAttendance.DataBind();
            }
        }

        // ===== HELPERS =====
        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new char[]{' '}, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1)
                return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        protected string GetAvatarColor(string name)
        {
            string[] colors = { "#4f46e5", "#0891b2", "#059669", "#d97706",
                                 "#dc2626", "#7c3aed", "#db2777", "#0284c7" };
            int idx = 0;
            foreach (char c in (name ?? "")) idx += (int)c;
            return colors[Math.Abs(idx) % colors.Length];
        }

        protected string FormatWorkHours(string wh)
        {
            if (wh == "In progress" || wh == "—") return wh;
            return "≈ " + wh;
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Present":  return "<span class='badge-present'>Present</span>";
                case "Late":     return "<span class='badge-late'>Late</span>";
                case "Absent":   return "<span class='badge-absence'>Absent</span>";
                case "On Leave": return "<span class='badge-leave'>On Leave</span>";
                default:         return "<span>—</span>";
            }
        }
    }
}
