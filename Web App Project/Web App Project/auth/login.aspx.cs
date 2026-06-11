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
    public partial class login : System.Web.UI.Page
    {
        string connStr = ConfigurationManager
                         .ConnectionStrings["AttendanceDBConnectionString"]
                         .ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] != null)
            {
                if (Session["UserRole"].ToString() == "Admin")
                    Response.Redirect("~/Admin/AdminDashboard.aspx");
                else
                    Response.Redirect("~/Staff/StaffDashboard.aspx");
            }

            // Show success message if coming from Register page
            if (Request.QueryString["msg"] == "registered")
            {
                lblMessage.Text = "Registration successful! Please wait for HR approval.";
                lblMessage.CssClass = "text-success small d-block text-center mb-2";
            }
        }
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();
            string role = hdnRole.Value;

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblMessage.Text = "Please enter username and password.";
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    if (role == "Admin")
                    {
                        // --- ADMIN TABLE ---
                        string sql = "SELECT COUNT(*) FROM Admin WHERE Username=@user AND Password=@pass";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@user", username);
                            cmd.Parameters.AddWithValue("@pass", password);
                            if ((int)cmd.ExecuteScalar() == 0)
                            {
                                lblMessage.Text = "Invalid admin credentials.";
                                return;
                            }
                        }
                        Session["UserRole"] = "Admin";
                        Session["Username"] = username;
                        Response.Redirect("~/Admin/AdminDashboard.aspx", false);
                    }
                    else
                    {
                        // --- STAFF TABLE ---
                        string sql = @"SELECT StaffID, StaffName, Department, Position
                                       FROM Staff
                                       WHERE Username=@user AND Password=@pass";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@user", username);
                            cmd.Parameters.AddWithValue("@pass", password);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (!reader.Read())
                                {
                                    lblMessage.Text = "Invalid staff credentials.";
                                    return;
                                }
                                Session["UserRole"] = "Staff";
                                Session["Username"] = username;
                                Session["StaffID"] = reader["StaffID"].ToString();
                                Session["StaffName"] = reader["StaffName"].ToString();
                                Session["Department"] = reader["Department"].ToString();
                                Session["Position"] = reader["Position"].ToString();
                            }
                        }
                        Response.Redirect("~/Staff/StaffDashboard.aspx", false);
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "System error: " + ex.Message;
            }
        }
    }
}