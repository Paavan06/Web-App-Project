using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;

namespace Web_App_Project
{
    public partial class MyProfile : Page
    {
        string connStr = ConfigurationManager
                        .ConnectionStrings["AttendanceDBConnectionString"]
                        .ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StaffID"] == null)
            {
                Response.Redirect("~/auth/login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                EnsureAttdScrColumn();
                LoadProfile();
            }
        }

        // Add attdScr column to Staff table if it doesn't exist yet
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

        private void LoadAttendanceScore(SqlConnection conn, int staffID)
        {
            // Count working days (Mon–Fri) from 1st of month up to today
            DateTime today      = DateTime.Today;
            DateTime firstOfMonth = new DateTime(today.Year, today.Month, 1);
            int totalWorkingDays = 0;
            for (DateTime d = firstOfMonth; d <= today; d = d.AddDays(1))
            {
                if (d.DayOfWeek != DayOfWeek.Saturday && d.DayOfWeek != DayOfWeek.Sunday)
                    totalWorkingDays++;
            }

            // Count days staff was present this month
            SqlCommand cmdPresent = new SqlCommand(
                @"SELECT COUNT(*) FROM Attendance
                  WHERE StaffID = @id
                    AND AttendDate >= @start
                    AND AttendDate <= @today", conn);
            cmdPresent.Parameters.AddWithValue("@id", staffID);
            cmdPresent.Parameters.AddWithValue("@start", firstOfMonth);
            cmdPresent.Parameters.AddWithValue("@today", today);
            int daysPresent = Convert.ToInt32(cmdPresent.ExecuteScalar());

            // Calculate score
            decimal score = totalWorkingDays > 0
                ? Math.Min(100, Math.Round((decimal)daysPresent / totalWorkingDays * 100, 1))
                : 0;

            // Persist to attdScr column
            SqlCommand cmdUpdate = new SqlCommand(
                "UPDATE Staff SET attdScr = @score WHERE StaffID = @id", conn);
            cmdUpdate.Parameters.AddWithValue("@score", score);
            cmdUpdate.Parameters.AddWithValue("@id", staffID);
            cmdUpdate.ExecuteNonQuery();

            // Determine rating
            string ratingClass, ratingLabel;
            if (score < 30)      { ratingClass = "bad";       ratingLabel = "Bad"; }
            else if (score < 60) { ratingClass = "good";      ratingLabel = "Good"; }
            else                 { ratingClass = "excellent";  ratingLabel = "Excellent"; }

            // Update UI
            lblAttdScore.Text  = (int)score + "%";
            lblAttdRating.Text = ratingLabel;
            attdSeal.Attributes["class"] = "attd-seal attd-seal-" + ratingClass;
        }

        private void LoadProfile()
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                LoadAttendanceScore(conn, staffID);

                string sql = @"SELECT StaffID, StaffName, NRIC, Gender,
                                      Email, PhoneNum, Department,
                                      Position, CreatedAt
                               FROM Staff
                               WHERE StaffID = @id";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", staffID);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string name = reader["StaffName"].ToString();
                        string dept = reader["Department"].ToString();

                        // Generate initials from name
                        string[] parts = name.Split(' ');
                        string initials = parts.Length >= 2
                            ? parts[0].Substring(0, 1) + parts[1].Substring(0, 1)
                            : name.Substring(0, 2);

                        // Left card
                        lblInitials.Text = initials.ToUpper();
                        lblFullName.Text = name;
                        lblPosition.Text = reader["Position"].ToString();
                        lblDeptLeft.Text = dept;
                        lblSince.Text = Convert.ToDateTime(
                                             reader["CreatedAt"]).Year.ToString();

                        // Right card — VIEW labels
                        vStaffID.Text = "EMP" + reader["StaffID"].ToString().PadLeft(3, '0');
                        vFullName.Text = name;
                        vEmail.Text = reader["Email"].ToString();
                        vPhone.Text = reader["PhoneNum"].ToString();
                        vNRIC.Text = reader["NRIC"].ToString();
                        vGender.Text = reader["Gender"].ToString();
                        vDepartment.Text = dept;
                        vCreatedAt.Text = Convert.ToDateTime(
                                            reader["CreatedAt"]).ToString("yyyy-MM-dd");

                        // Right card — EDIT inputs (pre-fill)
                        iFullName.Text = name;
                        iEmail.Text = reader["Email"].ToString();
                        iPhone.Text = reader["PhoneNum"].ToString();
                        iNRIC.Text = reader["NRIC"].ToString();
                        iGender.SelectedValue = reader["Gender"].ToString();
                        iDepartment.Text = dept;
                    }
                }
            }
        }

        // Edit button clicked — show input fields
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            SetEditMode(true);
        }

        // Cancel button clicked — go back to view
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            LoadProfile();
            SetEditMode(false);
        }

        // Save button clicked — update database
        protected void btnSave_Click(object sender, EventArgs e)
        {
            int staffID = Convert.ToInt32(Session["StaffID"]);

            string fullName = iFullName.Text.Trim();
            string email = iEmail.Text.Trim();
            string phone = iPhone.Text.Trim();
            string nric = iNRIC.Text.Trim();
            string gender = iGender.SelectedValue;
            string dept = iDepartment.Text.Trim();

            // Basic validation
            if (string.IsNullOrEmpty(fullName) ||
                string.IsNullOrEmpty(email) ||
                string.IsNullOrEmpty(phone))
            {
                lblMessage.Text = "Please fill in all required fields.";
                lblMessage.CssClass = "alert alert-danger small d-block mb-3";
                SetEditMode(true);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    string sql = @"UPDATE Staff SET
                                    StaffName  = @name,
                                    Email      = @email,
                                    PhoneNum   = @phone,
                                    NRIC       = @nric,
                                    Gender     = @gender,
                                    Department = @dept
                                   WHERE StaffID = @id";

                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@name", fullName);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@phone", phone);
                    cmd.Parameters.AddWithValue("@nric", nric);
                    cmd.Parameters.AddWithValue("@gender", gender);
                    cmd.Parameters.AddWithValue("@dept", dept);
                    cmd.Parameters.AddWithValue("@id", staffID);
                    cmd.ExecuteNonQuery();
                }

                // Update session name
                Session["StaffName"] = fullName;

                // Show success
                lblMessage.Text = "✓ Profile updated successfully!";
                lblMessage.CssClass = "alert alert-success small d-block mb-3";

                // Reload fresh data
                LoadProfile();
                SetEditMode(false);
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.CssClass = "alert alert-danger small d-block mb-3";
                SetEditMode(true);
            }
        }

        // Helper — toggle between view and edit mode
        private void SetEditMode(bool isEditing)
        {
            // Buttons
            btnEdit.Visible = !isEditing;
            btnSave.Visible = isEditing;
            btnCancel.Visible = isEditing;

            // VIEW labels — hide when editing
            vFullName.Visible = !isEditing;
            vEmail.Visible = !isEditing;
            vPhone.Visible = !isEditing;
            vNRIC.Visible = !isEditing;
            vGender.Visible = !isEditing;
            vDepartment.Visible = !isEditing;

            // EDIT inputs — show when editing
            iFullName.Visible = isEditing;
            iEmail.Visible = isEditing;
            iPhone.Visible = isEditing;
            iNRIC.Visible = isEditing;
            iGender.Visible = isEditing;
            iDepartment.Visible = isEditing;
        }
    }
}