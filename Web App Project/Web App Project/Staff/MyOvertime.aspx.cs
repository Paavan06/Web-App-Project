using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Web_App_Project
{
    public partial class MyOvertime : Page
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
                LoadStats();
                LoadOvertime("");
            }
        }

        // ===== STAT CARDS =====
        private void LoadStats()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand cmdPending = new SqlCommand(
                    "SELECT COUNT(*) FROM Overtime WHERE StaffID = @id AND Status = 'Pending'",
                    conn);
                cmdPending.Parameters.AddWithValue("@id", staffID);
                lblPendingCount.Text = cmdPending.ExecuteScalar().ToString();

                SqlCommand cmdHours = new SqlCommand(
                    @"SELECT ISNULL(SUM(OTHours), 0) FROM Overtime
                      WHERE StaffID = @id AND Status = 'Approved'
                        AND MONTH(OTDate) = MONTH(GETDATE())
                        AND YEAR(OTDate)  = YEAR(GETDATE())",
                    conn);
                cmdHours.Parameters.AddWithValue("@id", staffID);
                decimal hrs = Convert.ToDecimal(cmdHours.ExecuteScalar());
                lblApprovedHours.Text = hrs.ToString("0.##") + " hrs";

                SqlCommand cmdTotal = new SqlCommand(
                    "SELECT COUNT(*) FROM Overtime WHERE StaffID = @id",
                    conn);
                cmdTotal.Parameters.AddWithValue("@id", staffID);
                lblTotalCount.Text = cmdTotal.ExecuteScalar().ToString();
            }
        }

        // ===== LOAD GRID =====
        private void LoadOvertime(string filter)
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            string sql = @"SELECT OvertimeID, OTDate, OTHours, Reason,
                                  Status, OTRate, CreatedAt
                           FROM Overtime
                           WHERE StaffID = @id";

            if (!string.IsNullOrEmpty(filter))
                sql += " AND Status = @status";

            sql += " ORDER BY CreatedAt DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", staffID);
                if (!string.IsNullOrEmpty(filter))
                    cmd.Parameters.AddWithValue("@status", filter);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvOvertime.DataSource = dt;
                gvOvertime.DataBind();
            }
        }

        // ===== SHOW FORM (new request) =====
        protected void btnShowForm_Click(object sender, EventArgs e)
        {
            hdnEditID.Value = "0";
            lblFormTitle.Text = "New Overtime Request";
            btnSubmit.Text = "Submit Request";
            ClearForm();
            pnlForm.Visible = true;
            btnShowForm.Visible = false;
            lblMessage.CssClass = "d-none";
        }

        // ===== CANCEL FORM =====
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            hdnEditID.Value = "0";
            pnlForm.Visible = false;
            btnShowForm.Visible = true;
            ClearForm();
            lblMessage.CssClass = "d-none";
        }

        // ===== GRID ROW COMMAND (Edit / Delete) =====
        protected void gvOvertime_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int otID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteOT")
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand(
                            "DELETE FROM Overtime WHERE OvertimeID = @id AND Status = 'Pending'",
                            conn);
                        cmd.Parameters.AddWithValue("@id", otID);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Overtime request deleted.", true);
                    LoadStats();
                    LoadOvertime(ddlFilter.SelectedValue);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "EditOT")
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(
                        "SELECT OTDate, OTHours, Reason FROM Overtime WHERE OvertimeID = @id AND Status = 'Pending'",
                        conn);
                    cmd.Parameters.AddWithValue("@id", otID);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            hdnEditID.Value   = otID.ToString();
                            txtOTDate.Text    = Convert.ToDateTime(r["OTDate"]).ToString("yyyy-MM-dd");
                            txtOTHours.Text   = r["OTHours"].ToString();
                            txtReason.Text    = r["Reason"].ToString();
                            lblFormTitle.Text = "Edit Overtime Request";
                            btnSubmit.Text    = "Update Request";
                            pnlForm.Visible   = true;
                            btnShowForm.Visible = false;
                            lblMessage.CssClass = "d-none";
                        }
                    }
                }
            }
        }

        // ===== SUBMIT REQUEST (INSERT or UPDATE) =====
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);
            int editID  = Convert.ToInt32(hdnEditID.Value);

            DateTime otDate;
            decimal otHours;

            if (!DateTime.TryParse(txtOTDate.Text.Trim(), out otDate))
            {
                ShowMessage("Please select a valid date.", false);
                return;
            }
            if (!decimal.TryParse(txtOTHours.Text.Trim(), out otHours) || otHours <= 0 || otHours > 12)
            {
                ShowMessage("Please enter valid hours between 0.5 and 12.", false);
                return;
            }
            if (string.IsNullOrWhiteSpace(txtReason.Text))
            {
                ShowMessage("Please describe the overtime work.", false);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Duplicate date check — exclude current record when editing
                    SqlCommand check = new SqlCommand(
                        @"SELECT COUNT(*) FROM Overtime
                          WHERE StaffID = @sid AND OTDate = @date AND OvertimeID <> @oid",
                        conn);
                    check.Parameters.AddWithValue("@sid", staffID);
                    check.Parameters.AddWithValue("@date", otDate);
                    check.Parameters.AddWithValue("@oid", editID);
                    if ((int)check.ExecuteScalar() > 0)
                    {
                        ShowMessage("You already have an overtime request for that date.", false);
                        return;
                    }

                    if (editID == 0)
                    {
                        // INSERT
                        SqlCommand cmd = new SqlCommand(
                            "INSERT INTO Overtime (StaffID, OTDate, OTHours, Reason) VALUES (@id, @date, @hours, @reason)",
                            conn);
                        cmd.Parameters.AddWithValue("@id", staffID);
                        cmd.Parameters.AddWithValue("@date", otDate);
                        cmd.Parameters.AddWithValue("@hours", otHours);
                        cmd.Parameters.AddWithValue("@reason", txtReason.Text.Trim());
                        cmd.ExecuteNonQuery();
                        ShowMessage("Overtime request submitted successfully.", true);
                    }
                    else
                    {
                        // UPDATE (only if still Pending)
                        SqlCommand cmd = new SqlCommand(
                            @"UPDATE Overtime SET OTDate = @date, OTHours = @hours, Reason = @reason
                              WHERE OvertimeID = @oid AND StaffID = @sid AND Status = 'Pending'",
                            conn);
                        cmd.Parameters.AddWithValue("@date", otDate);
                        cmd.Parameters.AddWithValue("@hours", otHours);
                        cmd.Parameters.AddWithValue("@reason", txtReason.Text.Trim());
                        cmd.Parameters.AddWithValue("@oid", editID);
                        cmd.Parameters.AddWithValue("@sid", staffID);
                        cmd.ExecuteNonQuery();
                        ShowMessage("Overtime request updated successfully.", true);
                    }
                }

                hdnEditID.Value = "0";
                pnlForm.Visible = false;
                btnShowForm.Visible = true;
                ClearForm();
                ddlFilter.SelectedIndex = 0;
                LoadStats();
                LoadOvertime("");
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ===== FILTER =====
        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadOvertime(ddlFilter.SelectedValue);
        }

        // ===== STATUS BADGE (called from GridView ItemTemplate) =====
        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='badge bg-success'>Approved</span>";
                case "Rejected": return "<span class='badge bg-danger'>Rejected</span>";
                default:         return "<span class='badge bg-warning text-dark'>Pending</span>";
            }
        }

        private void ClearForm()
        {
            txtOTDate.Text  = "";
            txtOTHours.Text = "";
            txtReason.Text  = "";
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
