using System;
using System.Web.UI;

namespace Web_App_Project
{
    public partial class AdminMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Protect all admin pages
            // If not logged in at all
            if (Session["UserRole"] == null)
            {
                Response.Redirect("~/auth/login.aspx");
                return;
            }

            // If logged in but NOT admin — send to staff dashboard
            if (Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("~/Staff/StaffDashboard.aspx");
                return;
            }
        }
    }
}