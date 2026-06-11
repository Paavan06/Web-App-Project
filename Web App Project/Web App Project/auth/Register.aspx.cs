using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;

namespace Web_App_Project
{
    public partial class Register : System.Web.UI.Page
    {
        string connStr = ConfigurationManager
                         .ConnectionStrings["AttendanceDBConnectionString"]
                         .ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string nric = txtNRIC.Text.Trim();
            string gender = ddlGender.SelectedValue;
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string dept = ddlDepartment.SelectedValue;
            string position = txtPosition.Text.Trim();
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Check for duplicates before inserting
            string duplicateField = GetDuplicateField(username, nric, email);
            if (duplicateField != null)
            {
                lblMessage.Text = duplicateField + " is already registered. Please use a different one.";
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // ✅ Status is REMOVED — database uses DEFAULT 'Pending' automatically
                    string sql = @"INSERT INTO Staff 
                                    (StaffName, NRIC, Gender, Email, PhoneNum,
                                     Department, Position, Username, Password)
                                   VALUES 
                                    (@name, @nric, @gender, @email, @phone,
                                     @dept, @pos, @user, @pass)";

                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@name", fullName);
                    cmd.Parameters.AddWithValue("@nric", nric);
                    cmd.Parameters.AddWithValue("@gender", gender);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@phone", phone);
                    cmd.Parameters.AddWithValue("@dept", dept);
                    cmd.Parameters.AddWithValue("@pos", position);
                    cmd.Parameters.AddWithValue("@user", username);
                    cmd.Parameters.AddWithValue("@pass", password);
                    cmd.ExecuteNonQuery();
                }

                Response.Redirect("Login.aspx?msg=registered");
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Registration failed: " + ex.Message;
            }
        }

        private string GetDuplicateField(string username, string nric, string email)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"SELECT
                                  MAX(CASE WHEN Username = @user THEN 'Username' END),
                                  MAX(CASE WHEN NRIC     = @nric THEN 'NRIC'     END),
                                  MAX(CASE WHEN Email    = @email THEN 'Email'   END)
                               FROM Staff
                               WHERE Username = @user OR NRIC = @nric OR Email = @email";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@user",  username);
                    cmd.Parameters.AddWithValue("@nric",  nric);
                    cmd.Parameters.AddWithValue("@email", email);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (!reader.IsDBNull(0)) return reader.GetString(0);
                            if (!reader.IsDBNull(1)) return reader.GetString(1);
                            if (!reader.IsDBNull(2)) return reader.GetString(2);
                        }
                    }
                }
            }
            return null;
        }
    }
}