using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Web_App_Project
{
    public partial class MyLateAbsence : Page
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
                AutoInsertAbsences();
                LoadStats();
                LoadRecords();
            }
        }

        // ===== STAT CARDS =====
        private void LoadStats()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand cmdLate = new SqlCommand(
                    @"SELECT COUNT(*) FROM LateAbsence
                      WHERE StaffID = @id AND RecordType = 'Late'
                        AND MONTH(RecordDate) = MONTH(GETDATE())
                        AND YEAR(RecordDate)  = YEAR(GETDATE())", conn);
                cmdLate.Parameters.AddWithValue("@id", staffID);
                lblLateCount.Text = cmdLate.ExecuteScalar().ToString();

                SqlCommand cmdAbsence = new SqlCommand(
                    @"SELECT COUNT(*) FROM LateAbsence
                      WHERE StaffID = @id AND RecordType = 'Absence'
                        AND MONTH(RecordDate) = MONTH(GETDATE())
                        AND YEAR(RecordDate)  = YEAR(GETDATE())", conn);
                cmdAbsence.Parameters.AddWithValue("@id", staffID);
                lblAbsenceCount.Text = cmdAbsence.ExecuteScalar().ToString();

                SqlCommand cmdPaid = new SqlCommand(
                    @"SELECT COUNT(*) FROM LateAbsence
                      WHERE StaffID = @id AND RecordType = 'Leave-Paid'
                        AND MONTH(RecordDate) = MONTH(GETDATE())
                        AND YEAR(RecordDate)  = YEAR(GETDATE())", conn);
                cmdPaid.Parameters.AddWithValue("@id", staffID);
                int usedPaid = (int)cmdPaid.ExecuteScalar();
                lblPaidLeaveUsed.Text = usedPaid.ToString();

                // Progress bar width (0–100%)
                int pct = (usedPaid * 100) / 3;
                pnlPaidBar.Style["width"] = pct + "%";
            }
        }

        // ===== AUTO-INSERT ABSENCES =====
        private void AutoInsertAbsences()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            // Single batch SQL: checks last 30 weekdays for missing attendance
            // Skips dates that already have any LateAbsence record (Absence or Leave)
            string sql = @"
                ;WITH n AS (
                    SELECT 0 AS num UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                    UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
                    UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
                    UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19
                    UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23
                    UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27
                    UNION ALL SELECT 28 UNION ALL SELECT 29
                ),
                Dates AS (
                    SELECT CAST(DATEADD(day, -num - 1, CAST(GETDATE() AS date)) AS date) AS dt
                    FROM n
                )
                INSERT INTO LateAbsence (StaffID, RecordType, RecordDate, Status)
                SELECT @id, 'Absence', d.dt, 'Recorded'
                FROM Dates d
                WHERE DATENAME(WEEKDAY, d.dt) NOT IN ('Saturday', 'Sunday')
                  AND NOT EXISTS (
                      SELECT 1 FROM Attendance a
                      WHERE a.StaffID = @id AND a.AttendDate = d.dt
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM LateAbsence la
                      WHERE la.StaffID = @id AND la.RecordDate = d.dt
                  )";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", staffID);
                cmd.ExecuteNonQuery();
            }
        }

        // ===== LOAD GRID =====
        private void LoadRecords()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            string sql = @"
                SELECT
                    RecordID,
                    'LA-' + CAST(YEAR(RecordDate) AS VARCHAR) + '-'
                        + RIGHT('000' + CAST(RecordID AS VARCHAR), 3) AS RefNo,
                    RecordDate,
                    RecordType,
                    CASE
                        WHEN RecordType = 'Late' AND ArrivalTime IS NOT NULL
                        THEN 'Arrived ' + CONVERT(varchar(5), ArrivalTime, 108)
                             + ' (+' + CAST(DATEDIFF(minute, '08:01:00', ArrivalTime) AS VARCHAR) + ' min)'
                        WHEN RecordType = 'Late'
                        THEN 'Late arrival'
                        WHEN RecordType = 'Leave-Half'
                        THEN 'Half day'
                        WHEN RecordType = 'Leave-Paid'
                        THEN 'Full day (Paid)'
                        WHEN RecordType = 'Absence'
                        THEN 'Did not check in'
                        ELSE 'Full day'
                    END AS Detail,
                    ISNULL(Reason, '') AS Reason,
                    Status
                FROM LateAbsence
                WHERE StaffID = @id
                ORDER BY RecordDate DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", staffID);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvRecords.DataSource = dt;
                gvRecords.DataBind();
            }
        }

        // ===== SHOW LEAVE FORM =====
        protected void btnApplyLeave_Click(object sender, EventArgs e)
        {
            pnlLeaveForm.Visible   = true;
            pnlEditReason.Visible  = false;
            btnApplyLeave.Visible  = false;
            lblMessage.CssClass    = "d-none";
        }

        protected void btnCancelLeave_Click(object sender, EventArgs e)
        {
            pnlLeaveForm.Visible        = false;
            btnApplyLeave.Visible       = true;
            txtLeaveDate.Text           = "";
            txtLeaveReason.Text         = "";
            ddlLeaveType.SelectedIndex  = 0;
            lblMessage.CssClass         = "d-none";
        }

        // ===== SUBMIT LEAVE =====
        protected void btnSubmitLeave_Click(object sender, EventArgs e)
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            DateTime leaveDate;
            if (!DateTime.TryParse(txtLeaveDate.Text.Trim(), out leaveDate))
            {
                ShowMessage("Please select a valid date.", false); return;
            }
            if (leaveDate.Date <= DateTime.Today)
            {
                ShowMessage("Leave must be applied at least 1 day in advance.", false); return;
            }
            if (string.IsNullOrWhiteSpace(txtLeaveReason.Text))
            {
                ShowMessage("Please provide a reason for your leave.", false); return;
            }

            string recordType = "Leave-" + ddlLeaveType.SelectedValue; // Leave-Full / Leave-Half / Leave-Paid
            bool isPaid = recordType == "Leave-Paid";

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Paid leave: enforce 3/month cap
                    if (isPaid)
                    {
                        SqlCommand capCheck = new SqlCommand(
                            @"SELECT COUNT(*) FROM LateAbsence
                              WHERE StaffID = @id AND RecordType = 'Leave-Paid'
                                AND MONTH(RecordDate) = MONTH(GETDATE())
                                AND YEAR(RecordDate)  = YEAR(GETDATE())", conn);
                        capCheck.Parameters.AddWithValue("@id", staffID);
                        if ((int)capCheck.ExecuteScalar() >= 3)
                        {
                            ShowMessage("You have used all 3 paid leave days for this month.", false); return;
                        }
                    }

                    // No duplicate leave on the same date (any leave type)
                    SqlCommand check = new SqlCommand(
                        "SELECT COUNT(*) FROM LateAbsence WHERE StaffID = @id AND RecordDate = @date AND RecordType LIKE 'Leave%'",
                        conn);
                    check.Parameters.AddWithValue("@id", staffID);
                    check.Parameters.AddWithValue("@date", leaveDate);
                    if ((int)check.ExecuteScalar() > 0)
                    {
                        ShowMessage("You already have a leave application for that date.", false); return;
                    }

                    // Paid leave is auto-approved; others start as Pending
                    string status = isPaid ? "Approved" : "Pending";

                    SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO LateAbsence (StaffID, RecordType, RecordDate, Reason, Status)
                          VALUES (@id, @type, @date, @reason, @status)",
                        conn);
                    cmd.Parameters.AddWithValue("@id", staffID);
                    cmd.Parameters.AddWithValue("@type", recordType);
                    cmd.Parameters.AddWithValue("@date", leaveDate);
                    cmd.Parameters.AddWithValue("@reason", txtLeaveReason.Text.Trim());
                    cmd.Parameters.AddWithValue("@status", status);
                    cmd.ExecuteNonQuery();
                }

                ShowMessage(isPaid
                    ? "Paid leave applied and automatically approved."
                    : "Leave application submitted successfully.", true);
                pnlLeaveForm.Visible        = false;
                btnApplyLeave.Visible       = true;
                txtLeaveDate.Text           = "";
                txtLeaveReason.Text         = "";
                ddlLeaveType.SelectedIndex  = 0;
                LoadStats();
                LoadRecords();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ===== GRID ROW COMMAND =====
        protected void gvRecords_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int recordID = Convert.ToInt32(e.CommandArgument);
            int staffID  = Convert.ToInt32(Session["StaffID"]);

            if (e.CommandName == "DeleteLeave")
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand(
                            @"DELETE FROM LateAbsence
                              WHERE RecordID = @rid AND StaffID = @sid
                                AND (
                                    (RecordType LIKE 'Leave%' AND Status = 'Pending')
                                    OR RecordType = 'Leave-Paid'
                                )",
                            conn);
                        cmd.Parameters.AddWithValue("@rid", recordID);
                        cmd.Parameters.AddWithValue("@sid", staffID);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Leave application deleted.", true);
                    LoadStats();
                    LoadRecords();
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "EditReason")
            {
                // Load existing reason into the edit panel
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(
                        "SELECT Reason FROM LateAbsence WHERE RecordID = @rid AND StaffID = @sid AND RecordType = 'Late'",
                        conn);
                    cmd.Parameters.AddWithValue("@rid", recordID);
                    cmd.Parameters.AddWithValue("@sid", staffID);
                    object result = cmd.ExecuteScalar();
                    txtLateReason.Text    = result != null && result != DBNull.Value ? result.ToString() : "";
                    hdnEditRecordID.Value = recordID.ToString();
                }

                pnlEditReason.Visible  = true;
                pnlLeaveForm.Visible   = false;
                btnApplyLeave.Visible  = false;
                lblMessage.CssClass    = "d-none";
            }
        }

        // ===== SAVE LATE REASON =====
        protected void btnSaveReason_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtLateReason.Text))
            {
                ShowMessage("Please enter a reason.", false); return;
            }

            int recordID = Convert.ToInt32(hdnEditRecordID.Value);
            int staffID  = Convert.ToInt32(Session["StaffID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(
                        "UPDATE LateAbsence SET Reason = @reason WHERE RecordID = @rid AND StaffID = @sid AND RecordType = 'Late'",
                        conn);
                    cmd.Parameters.AddWithValue("@reason", txtLateReason.Text.Trim());
                    cmd.Parameters.AddWithValue("@rid", recordID);
                    cmd.Parameters.AddWithValue("@sid", staffID);
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Reason saved.", true);
                pnlEditReason.Visible  = false;
                btnApplyLeave.Visible  = true;
                hdnEditRecordID.Value  = "0";
                txtLateReason.Text     = "";
                LoadRecords();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnCancelReason_Click(object sender, EventArgs e)
        {
            pnlEditReason.Visible  = false;
            btnApplyLeave.Visible  = true;
            hdnEditRecordID.Value  = "0";
            txtLateReason.Text     = "";
            lblMessage.CssClass    = "d-none";
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
