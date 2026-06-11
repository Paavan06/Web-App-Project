using System;
using System.Web.UI;

namespace Web_App_Project
{
    public partial class Site_Mobile : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null)
            {
                Response.Redirect("~/auth/login.aspx");
                return;
            }

            if (Session["UserRole"].ToString() != "Staff")
            {
                Response.Redirect("~/Admin/AdminDashboard.aspx");
                return;
            }
        }
    }
}