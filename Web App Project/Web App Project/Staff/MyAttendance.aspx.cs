using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;

namespace Web_App_Project
{
    public partial class MyAttendance : Page
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
                lblDateBadge.Text = DateTime.Now.ToString("d MMM yyyy");
                LoadAttendance();
            }
        }

        private void LoadAttendance()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            string sql = @"
                SELECT
                    AttendanceID,
                    AttendDate,
                    CONVERT(varchar(5), CheckIn,  108) AS ClockIn,
                    CASE WHEN CheckOut IS NULL
                         THEN '—'
                         ELSE CONVERT(varchar(5), CheckOut, 108)
                    END AS ClockOut,
                    CASE
                        WHEN CheckOut IS NOT NULL
                        THEN '≈ ' + CAST(DATEDIFF(minute, CheckIn, CheckOut) / 60 AS VARCHAR)
                             + 'h ' + CAST(DATEDIFF(minute, CheckIn, CheckOut) % 60 AS VARCHAR) + 'm'
                        ELSE '—'
                    END AS WorkHours,
                    CASE WHEN CheckOut IS NULL THEN 'Incomplete'
                         ELSE ISNULL(Status, 'Present')
                    END AS DisplayStatus
                FROM Attendance
                WHERE StaffID = @id
                ORDER BY AttendDate DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", staffID);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvAttendance.DataSource = dt;
                gvAttendance.DataBind();
            }
        }

        // ===== DELETE TODAY'S RECORD =====
        protected void gvAttendance_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DeleteAtt") return;

            int attendID = Convert.ToInt32(e.CommandArgument);
            int staffID  = Convert.ToInt32(Session["StaffID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                // Guard: only allow deleting today's own record
                SqlCommand cmd = new SqlCommand(
                    @"DELETE FROM Attendance
                      WHERE AttendanceID = @aid
                        AND StaffID = @sid
                        AND AttendDate = CAST(GETDATE() AS date)",
                    conn);
                cmd.Parameters.AddWithValue("@aid", attendID);
                cmd.Parameters.AddWithValue("@sid", staffID);
                cmd.ExecuteNonQuery();
            }

            LoadAttendance();
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Present":    return "<span class='badge-present'>Present</span>";
                case "Incomplete": return "<span class='badge-incomplete'>Incomplete</span>";
                default:           return "<span class='badge-present'>" + status + "</span>";
            }
        }
    }
}
