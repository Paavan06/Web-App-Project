using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Web_App_Project.Admin
{
    public partial class AdminStaffProfile : System.Web.UI.Page
    {
        string connStr = ConfigurationManager
                         .ConnectionStrings["AttendanceDBConnectionString"]
                         .ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                EnsureAttdScrColumn();
                UpdateAllAttdScores();
                LoadStaff();
            }
        }

        private void EnsureAttdScrColumn()
        {
            string sql = @"
                IF NOT EXISTS (
                    SELECT 1 FROM sys.columns
                    WHERE object_id = OBJECT_ID('Staff') AND name = 'attdScr'
                )
                ALTER TABLE Staff ADD attdScr DECIMAL(5,2) NULL";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                new SqlCommand(sql, conn).ExecuteNonQuery();
            }
        }

        private void UpdateAllAttdScores()
        {
            DateTime today        = DateTime.Today;
            DateTime firstOfMonth = new DateTime(today.Year, today.Month, 1);

            int workingDays = 0;
            for (DateTime d = firstOfMonth; d <= today; d = d.AddDays(1))
                if (d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday)
                    workingDays++;

            string sql = @"
                UPDATE Staff
                SET attdScr = (
                    SELECT CASE WHEN @wd > 0
                        THEN CAST(
                            CASE WHEN COUNT(*) * 100.0 / @wd > 100 THEN 100.0
                                 ELSE COUNT(*) * 100.0 / @wd
                            END AS DECIMAL(5,2))
                        ELSE 0 END
                    FROM Attendance a
                    WHERE a.StaffID = Staff.StaffID
                      AND a.AttendDate >= @start
                      AND a.AttendDate <= @today
                )";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@wd",    workingDays);
                cmd.Parameters.AddWithValue("@start", firstOfMonth);
                cmd.Parameters.AddWithValue("@today", today);
                cmd.ExecuteNonQuery();
            }
        }

        protected string GetAttdScoreBadge(object val)
        {
            if (val == null || val == DBNull.Value)
                return "<span class='text-muted'>—</span>";

            int score = (int)Convert.ToDecimal(val);
            string cls, label;
            if (score < 30)      { cls = "attd-badge-bad";       label = "Bad"; }
            else if (score < 60) { cls = "attd-badge-good";      label = "Good"; }
            else                 { cls = "attd-badge-excellent";  label = "Excellent"; }

            return string.Format(
                "<span class='fw-semibold me-1'>{0}%</span><span class='attd-badge {1}'>{2}</span>",
                score, cls, label);
        }

        private void LoadStaff()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"SELECT StaffID,
                                      'EMP' + RIGHT('000' + CAST(StaffID AS VARCHAR(10)), 3) AS EmpID,
                                      StaffName, Department, Position, Email,
                                      ISNULL(attdScr, 0) AS attdScr
                               FROM Staff
                               ORDER BY StaffID";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvStaff.DataSource = dt;
                gvStaff.DataBind();
                lblCount.Text = dt.Rows.Count.ToString();
            }
        }

        protected void gvStaff_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteStaff")
            {
                hdnDeleteId.Value = e.CommandArgument.ToString();
                LoadStaff();
                ScriptManager.RegisterStartupScript(this, GetType(),
                    "showModal", "showDeleteModal();", true);
            }
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            int staffId;
            if (!int.TryParse(hdnDeleteId.Value, out staffId))
                return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(
                        "DELETE FROM Staff WHERE StaffID = @id", conn);
                    cmd.Parameters.AddWithValue("@id", staffId);
                    cmd.ExecuteNonQuery();
                }

                hdnDeleteId.Value = "";
                lblMessage.Text = "Staff member deleted successfully.";
                lblMessage.CssClass = "alert alert-success small d-block mb-3";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.CssClass = "alert alert-danger small d-block mb-3";
            }

            LoadStaff();
        }

    }
}
