using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;

namespace Web_App_Project
{
    public partial class StaffDashboard : Page
    {
        string connStr = ConfigurationManager
                        .ConnectionStrings["AttendanceDBConnectionString"]
                        .ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffID"] == null)
            {
                Response.Redirect("~/auth/login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblWelcomeName.Text = Session["StaffName"]?.ToString();
                lblTodayDate.Text   = DateTime.Now.ToString("dddd, d MMMM yyyy");
                LoadClockStatus();
                LoadQuickStats();
            }
        }

        // ===== CLOCK STATUS =====
        private void LoadClockStatus()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    @"SELECT CheckIn, CheckOut FROM Attendance
                      WHERE StaffID = @id AND AttendDate = CAST(GETDATE() AS date)",
                    conn);
                cmd.Parameters.AddWithValue("@id", staffID);

                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read())
                    {
                        // No record today — not clocked in
                        lblClockStatus.Text   = "Not Clocked In";
                        lblClockSince.Visible = false;
                        btnClockIn.Visible    = true;
                        btnClockOut.Visible   = false;
                    }
                    else if (r["CheckOut"] == DBNull.Value)
                    {
                        // Clocked in, not yet clocked out
                        string checkIn = ((TimeSpan)r["CheckIn"]).ToString(@"hh\:mm");
                        lblClockStatus.Text   = "Clocked In";
                        lblClockSince.Text    = "Since " + checkIn + " · " + Session["Department"];
                        lblClockSince.Visible = true;
                        btnClockIn.Visible    = false;
                        btnClockOut.Visible   = true;
                    }
                    else
                    {
                        // Fully clocked out for today
                        string checkIn  = ((TimeSpan)r["CheckIn"]).ToString(@"hh\:mm");
                        string checkOut = ((TimeSpan)r["CheckOut"]).ToString(@"hh\:mm");
                        lblClockStatus.Text   = "Clocked Out";
                        lblClockSince.Text    = "Today " + checkIn + " → " + checkOut;
                        lblClockSince.Visible = true;
                        btnClockIn.Visible    = false;
                        btnClockOut.Visible   = false;
                    }
                }
            }
        }

        // ===== QUICK STAT CARDS =====
        private void LoadQuickStats()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand cmdPresent = new SqlCommand(
                    @"SELECT COUNT(*) FROM Attendance
                      WHERE StaffID = @id
                        AND MONTH(AttendDate) = MONTH(GETDATE())
                        AND YEAR(AttendDate)  = YEAR(GETDATE())",
                    conn);
                cmdPresent.Parameters.AddWithValue("@id", staffID);
                lblDaysPresent.Text = cmdPresent.ExecuteScalar().ToString();

                SqlCommand cmdOTPending = new SqlCommand(
                    "SELECT COUNT(*) FROM Overtime WHERE StaffID = @id AND Status = 'Pending'",
                    conn);
                cmdOTPending.Parameters.AddWithValue("@id", staffID);
                lblPendingOT.Text = cmdOTPending.ExecuteScalar().ToString();

                SqlCommand cmdPaidLeave = new SqlCommand(
                    @"SELECT COUNT(*) FROM LateAbsence
                      WHERE StaffID = @id AND RecordType = 'Leave-Paid'
                        AND MONTH(RecordDate) = MONTH(GETDATE())
                        AND YEAR(RecordDate)  = YEAR(GETDATE())",
                    conn);
                cmdPaidLeave.Parameters.AddWithValue("@id", staffID);
                int usedPaid = Convert.ToInt32(cmdPaidLeave.ExecuteScalar());
                lblPaidLeave.Text = usedPaid + " / 3 days";
            }
        }

        // ===== CLOCK IN =====
        protected void btnClockIn_Click(object sender, EventArgs e)
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);
            DateTime now = DateTime.Now;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Guard: only one record per day
                SqlCommand check = new SqlCommand(
                    "SELECT COUNT(*) FROM Attendance WHERE StaffID = @id AND AttendDate = CAST(GETDATE() AS date)",
                    conn);
                check.Parameters.AddWithValue("@id", staffID);
                if ((int)check.ExecuteScalar() > 0) { LoadClockStatus(); return; }

                SqlCommand cmd = new SqlCommand(
                    "INSERT INTO Attendance (StaffID, AttendDate, CheckIn) VALUES (@id, CAST(GETDATE() AS date), CAST(GETDATE() AS time(0)))",
                    conn);
                cmd.Parameters.AddWithValue("@id", staffID);
                cmd.ExecuteNonQuery();

                // Auto-detect late: after 08:01 AM
                TimeSpan cutoff = new TimeSpan(8, 1, 0);
                if (now.TimeOfDay > cutoff)
                {
                    SqlCommand lateCheck = new SqlCommand(
                        "SELECT COUNT(*) FROM LateAbsence WHERE StaffID = @id AND RecordDate = CAST(GETDATE() AS date) AND RecordType = 'Late'",
                        conn);
                    lateCheck.Parameters.AddWithValue("@id", staffID);
                    if ((int)lateCheck.ExecuteScalar() == 0)
                    {
                        SqlCommand lateCmd = new SqlCommand(
                            "INSERT INTO LateAbsence (StaffID, RecordType, RecordDate, ArrivalTime, Status) VALUES (@id, 'Late', CAST(GETDATE() AS date), CAST(GETDATE() AS time(0)), 'Recorded')",
                            conn);
                        lateCmd.Parameters.AddWithValue("@id", staffID);
                        lateCmd.ExecuteNonQuery();
                    }
                }
            }

            LoadClockStatus();
        }

        // ===== CLOCK OUT =====
        protected void btnClockOut_Click(object sender, EventArgs e)
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    @"UPDATE Attendance SET CheckOut = CAST(GETDATE() AS time(0))
                      WHERE StaffID = @id AND AttendDate = CAST(GETDATE() AS date) AND CheckOut IS NULL",
                    conn);
                cmd.Parameters.AddWithValue("@id", staffID);
                cmd.ExecuteNonQuery();
            }

            LoadClockStatus();
        }
    }
}
