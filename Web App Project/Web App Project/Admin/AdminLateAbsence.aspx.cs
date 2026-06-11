using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Web_App_Project.Admin
{
    public partial class AdminLateAbsence : Page
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
                LoadRecords("");
            }
        }

        // ===== STAT CARDS =====
        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand cmdLate = new SqlCommand(
                    @"SELECT COUNT(*) FROM LateAbsence
                      WHERE RecordType = 'Late'
                        AND MONTH(RecordDate) = MONTH(GETDATE())
                        AND YEAR(RecordDate)  = YEAR(GETDATE())", conn);
                lblLateCount.Text = cmdLate.ExecuteScalar().ToString();

                SqlCommand cmdAbsence = new SqlCommand(
                    @"SELECT COUNT(*) FROM LateAbsence
                      WHERE RecordType = 'Absence'
                        AND MONTH(RecordDate) = MONTH(GETDATE())
                        AND YEAR(RecordDate)  = YEAR(GETDATE())", conn);
                lblAbsenceCount.Text = cmdAbsence.ExecuteScalar().ToString();

                SqlCommand cmdPending = new SqlCommand(
                    @"SELECT COUNT(*) FROM LateAbsence
                      WHERE Status = 'Pending'
                        AND MONTH(RecordDate) = MONTH(GETDATE())
                        AND YEAR(RecordDate)  = YEAR(GETDATE())", conn);
                lblPendingCount.Text = cmdPending.ExecuteScalar().ToString();
            }
        }

        // ===== LOAD GRID =====
        private void LoadRecords(string filter)
        {
            string sql = @"
                SELECT
                    la.RecordID,
                    'LA-' + CAST(YEAR(la.RecordDate) AS VARCHAR) + '-'
                        + RIGHT('000' + CAST(la.RecordID AS VARCHAR), 3) AS RefNo,
                    s.StaffName,
                    s.Department,
                    la.RecordDate,
                    la.RecordType,
                    CASE
                        WHEN la.RecordType = 'Late' AND la.ArrivalTime IS NOT NULL
                        THEN 'Arrived ' + CONVERT(varchar(5), la.ArrivalTime, 108)
                             + ' (+' + CAST(DATEDIFF(minute, '08:01:00', la.ArrivalTime) AS VARCHAR) + ' min)'
                        WHEN la.RecordType = 'Late'   THEN 'Late arrival'
                        WHEN la.RecordType = 'Absence' THEN 'Did not check in'
                        WHEN la.RecordType = 'Leave-Half' THEN 'Half day'
                        WHEN la.RecordType = 'Leave-Paid' THEN 'Full day (Paid)'
                        ELSE 'Full day'
                    END AS Detail,
                    ISNULL(NULLIF(la.Reason, ''), '—') AS Reason,
                    la.Status
                FROM LateAbsence la
                INNER JOIN Staff s ON la.StaffID = s.StaffID";

            if (!string.IsNullOrEmpty(filter))
                sql += " WHERE la.RecordType = @filter";

            sql += " ORDER BY la.RecordDate DESC, la.RecordID DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                if (!string.IsNullOrEmpty(filter))
                    cmd.Parameters.AddWithValue("@filter", filter);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvRecords.DataSource = dt;
                gvRecords.DataBind();
            }
        }

        // ===== FILTER =====
        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRecords(ddlFilter.SelectedValue);
        }

        // ===== APPROVE / REJECT =====
        protected void gvRecords_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ApproveLA" && e.CommandName != "RejectLA")
                return;

            int recordID  = Convert.ToInt32(e.CommandArgument);
            string status = e.CommandName == "ApproveLA" ? "Approved" : "Rejected";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(
                        "UPDATE LateAbsence SET Status = @status WHERE RecordID = @id AND Status = 'Pending'",
                        conn);
                    cmd.Parameters.AddWithValue("@status", status);
                    cmd.Parameters.AddWithValue("@id", recordID);
                    int rows = cmd.ExecuteNonQuery();

                    if (rows == 0)
                    {
                        ShowMessage("This request has already been reviewed.", false);
                        return;
                    }
                }

                ShowMessage(status == "Approved"
                    ? "Leave request approved."
                    : "Leave request rejected.", true);

                LoadStats();
                LoadRecords(ddlFilter.SelectedValue);
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ===== BADGE HELPERS =====
        protected string GetTypeBadge(string type)
        {
            switch (type)
            {
                case "Late":        return "<span class='badge-late'>Late</span>";
                case "Absence":     return "<span class='badge-absence'>Absent</span>";
                case "Leave-Paid":  return "<span class='badge-paid'>Paid Leave</span>";
                case "Leave-Half":  return "<span class='badge-leave'>Leave (Half Day)</span>";
                default:            return "<span class='badge-leave'>Leave (Full Day)</span>";
            }
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='badge-approved'>Approved</span>";
                case "Rejected": return "<span class='badge-rejected'>Rejected</span>";
                case "Pending":  return "<span class='badge-pending'>Pending</span>";
                default:         return "<span class='badge-recorded'>Recorded</span>";
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
