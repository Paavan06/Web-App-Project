using System;
using System.Web;
using System.Web.UI;

namespace Web_App_Project
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/auth/login.aspx", false);
        }
    }
}
