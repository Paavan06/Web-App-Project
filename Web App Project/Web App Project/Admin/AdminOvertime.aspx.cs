using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Web_App_Project.Admin
{
    public partial class AdminOvertime : Page
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
                LoadStats();
                LoadOvertime();
            }
        }

        // ===== STAT CARDS =====
        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Total hours — all records
                SqlCommand cmdHours = new SqlCommand(
                    "SELECT ISNULL(SUM(OTHours), 0) FROM Overtime", conn);
                decimal totalHours = Convert.ToDecimal(cmdHours.ExecuteScalar());
                lblTotalHours.Text = totalHours.ToString("0.##");

                // Pending count
                SqlCommand cmdPending = new SqlCommand(
                    "SELECT COUNT(*) FROM Overtime WHERE Status = 'Pending'", conn);
                lblPendingCount.Text = cmdPending.ExecuteScalar().ToString();

                // Est. OT Pay — total hours * rate for all records
                SqlCommand cmdPay = new SqlCommand(
                    "SELECT ISNULL(SUM(OTHours * OTRate), 0) FROM Overtime", conn);
                decimal estPay = Convert.ToDecimal(cmdPay.ExecuteScalar());
                lblEstPay.Text = estPay.ToString("0");
            }
        }

        // ===== LOAD GRID =====
        private void LoadOvertime()
        {
            string sql = @"
                SELECT
                    o.OvertimeID,
                    'OT-' + CAST(YEAR(o.CreatedAt) AS VARCHAR) + '-'
                        + RIGHT('000' + CAST(o.OvertimeID AS VARCHAR), 3) AS RefNo,
                    s.StaffName,
                    s.Department,
                    o.OTDate,
                    o.OTHours,
                    o.Reason,
                    o.Status,
                    o.OTRate
                FROM Overtime o
                INNER JOIN Staff s ON o.StaffID = s.StaffID
                ORDER BY o.CreatedAt DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvOvertime.DataSource = dt;
                gvOvertime.DataBind();
            }
        }

        // ===== APPROVE / REJECT =====
        protected void gvOvertime_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ApproveOT" && e.CommandName != "RejectOT")
                return;

            int otID      = Convert.ToInt32(e.CommandArgument);
            string status = e.CommandName == "ApproveOT" ? "Approved" : "Rejected";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(
                        "UPDATE Overtime SET Status = @status WHERE OvertimeID = @id AND Status = 'Pending'",
                        conn);
                    cmd.Parameters.AddWithValue("@status", status);
                    cmd.Parameters.AddWithValue("@id", otID);
                    int rows = cmd.ExecuteNonQuery();

                    if (rows == 0)
                    {
                        ShowMessage("This request has already been reviewed.", false);
                        return;
                    }
                }

                ShowMessage(status == "Approved"
                    ? "Overtime request approved successfully."
                    : "Overtime request rejected.", true);

                LoadStats();
                LoadOvertime();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ===== STATUS BADGE =====
        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='badge-approved'>Approved</span>";
                case "Rejected": return "<span class='badge-rejected'>Rejected</span>";
                default:         return "<span class='badge-pending'>Pending</span>";
            }
        }

        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text     = text;
            lblMessage.CssClass = success
                ? "alert alert-success small d-block mb-3"
                : "alert alert-danger small d-block mb-3";
        }
    }
}
