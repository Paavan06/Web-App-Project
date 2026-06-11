
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="Web_App_Project.Register" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Registration</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="../style.css" rel="stylesheet">
</head>
<body>
<form id="form1" runat="server">
<div class="container-fluid min-vh-100">
  <div class="row min-vh-100">

    <!-- LEFT PANEL -->
    <div class="col-md-5 left-panel d-flex flex-column justify-content-between p-4">
      <div class="d-flex align-items-center gap-3">
        <div class="brand-logo">MJ</div>
        <div>
          <p class="text-white fw-bold mb-0">Maju Jaya Agrotech</p>
          <small class="text-secondary">Supplies Sdn. Bhd.</small>
        </div>
      </div>
      <div>
        <h2 class="text-white fw-bold">Create your staff account</h2>
        <p class="text-secondary mb-4">
          Register to access your attendance, overtime and leave records.
          New accounts are reviewed by HR before activation.
        </p>
        <div class="d-flex align-items-center gap-2 mb-3">
          <span class="feature-icon text-success">&#128737;</span>
          <span class="text-light small">Secure, HR-approved access</span>
        </div>
        <div class="d-flex align-items-center gap-2 mb-3">
          <span class="feature-icon text-success">&#128196;</span>
          <span class="text-light small">Manage your own records</span>
        </div>
        <div class="d-flex align-items-center gap-2">
          <span class="feature-icon text-success">&#128276;</span>
          <span class="text-light small">Email notification on approval</span>
        </div>
      </div>
      <small class="text-secondary">Reg. No. 201801023456 (1234567-A)</small>
    </div>

    <!-- RIGHT PANEL -->
    <div class="col-md-7 bg-white p-4 overflow-auto">
      <div class="mx-auto" style="max-width: 580px;">

        <a href="Login.aspx" class="text-muted text-decoration-none small">
          &#8592; Back to Sign in
        </a>

        <h2 class="fw-bold mt-2 mb-0">Staff Registration</h2>
        <p class="text-muted small mb-3">Fill in your details to request an account.</p>

        <!-- PERSONAL DETAILS -->
        <p class="section-label">PERSONAL DETAILS</p>

        <div class="mb-3">
          <label class="form-label small fw-semibold">Full name (as per NRIC)</label>
          <div class="input-group">
            <span class="input-group-text">&#128100;</span>
            <asp:TextBox ID="txtFullName" runat="server"
              CssClass="form-control form-control-sm"
              placeholder="e.g. Ahmad bin Hassan">
            </asp:TextBox>
          </div>
        </div>

        <div class="row g-2 mb-3">
          <div class="col-md-6">
            <label class="form-label small fw-semibold">NRIC</label>
            <div class="input-group">
              <span class="input-group-text">&#128196;</span>
              <asp:TextBox ID="txtNRIC" runat="server"
                CssClass="form-control form-control-sm"
                placeholder="000000-00-0000">
              </asp:TextBox>
            </div>
          </div>
          <div class="col-md-6">
            <label class="form-label small fw-semibold">Gender</label>
            <asp:DropDownList ID="ddlGender" runat="server"
              CssClass="form-select form-select-sm">
              <asp:ListItem Value="">Select...</asp:ListItem>
              <asp:ListItem Value="Male">Male</asp:ListItem>
              <asp:ListItem Value="Female">Female</asp:ListItem>
            </asp:DropDownList>
          </div>
        </div>

        <div class="row g-2 mb-3">
          <div class="col-md-6">
            <label class="form-label small fw-semibold">Email</label>
            <div class="input-group">
              <span class="input-group-text">&#9993;</span>
              <asp:TextBox ID="txtEmail" runat="server"
                CssClass="form-control form-control-sm"
                placeholder="name@majujaya.com.my">
              </asp:TextBox>
            </div>
          </div>
          <div class="col-md-6">
            <label class="form-label small fw-semibold">Phone</label>
            <div class="input-group">
              <span class="input-group-text">&#128222;</span>
              <asp:TextBox ID="txtPhone" runat="server"
                CssClass="form-control form-control-sm"
                placeholder="012-345 6789">
              </asp:TextBox>
            </div>
          </div>
        </div>

        <!-- EMPLOYMENT -->
        <p class="section-label">EMPLOYMENT</p>

        <div class="row g-2 mb-3">
          <div class="col-md-6">
            <label class="form-label small fw-semibold">Department</label>
            <asp:DropDownList ID="ddlDepartment" runat="server"
              CssClass="form-select form-select-sm">
              <asp:ListItem Value="">Select...</asp:ListItem>
              <asp:ListItem>Staff Attendance</asp:ListItem>
              <asp:ListItem>HR</asp:ListItem>
              <asp:ListItem>Finance</asp:ListItem>
              <asp:ListItem>IT</asp:ListItem>
              <asp:ListItem>Operations</asp:ListItem>
            </asp:DropDownList>
          </div>
          <div class="col-md-6">
            <label class="form-label small fw-semibold">Position</label>
            <div class="input-group">
              <span class="input-group-text">&#128188;</span>
              <asp:TextBox ID="txtPosition" runat="server"
                CssClass="form-control form-control-sm"
                placeholder="e.g. Warehouse Staff">
              </asp:TextBox>
            </div>
          </div>
        </div>

        <!-- ACCOUNT -->
        <p class="section-label">ACCOUNT</p>

        <div class="mb-3">
          <label class="form-label small fw-semibold">Username</label>
          <div class="input-group">
            <span class="input-group-text">@</span>
            <asp:TextBox ID="txtUsername" runat="server"
              CssClass="form-control form-control-sm"
              placeholder="Choose a username">
            </asp:TextBox>
          </div>
        </div>

        <div class="row g-2 mb-3">
          <div class="col-md-6">
            <label class="form-label small fw-semibold">Password</label>
            <div class="input-group">
              <span class="input-group-text">&#128274;</span>
              <asp:TextBox ID="txtPassword" runat="server"
                CssClass="form-control form-control-sm"
                TextMode="Password"
                placeholder="Min. 8 characters">
              </asp:TextBox>
            </div>
          </div>
          <div class="col-md-6">
            <label class="form-label small fw-semibold">Confirm password</label>
            <div class="input-group">
              <span class="input-group-text">&#128274;</span>
              <asp:TextBox ID="txtConfirmPassword" runat="server"
                CssClass="form-control form-control-sm"
                TextMode="Password"
                placeholder="Re-enter password">
              </asp:TextBox>
            </div>
          </div>
        </div>

        <!-- Error message -->
        <asp:Label ID="lblMessage" runat="server"
          CssClass="text-danger small d-block mb-2">
        </asp:Label>

        <!-- Checkbox -->
        <div class="form-check mb-3">
          <input class="form-check-input" type="checkbox" id="chkAgree">
          <label class="form-check-label small text-muted" for="chkAgree">
            I confirm the information is accurate and accept the
            <a href="#" class="text-primary">company policy</a>.
          </label>
        </div>

        <!-- Submit button -->
        <asp:Button ID="btnRegister" runat="server"
          Text="Create account"
          CssClass="btn btn-primary w-100 py-2"
          OnClientClick="return validateForm()"
          OnClick="btnRegister_Click">
        </asp:Button>

      </div>
    </div>

  </div>
</div>
</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function validateForm() {
    const name = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
    const nric = document.getElementById('<%= txtNRIC.ClientID %>').value.trim();
    const email = document.getElementById('<%= txtEmail.ClientID %>').value.trim();
    const phone = document.getElementById('<%= txtPhone.ClientID %>').value.trim();
    const username = document.getElementById('<%= txtUsername.ClientID %>').value.trim();
    const password = document.getElementById('<%= txtPassword.ClientID %>').value;
    const confirm = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
    const agreed = document.getElementById('chkAgree').checked;

    if (!name || !nric || !email || !phone || !username || !password || !confirm) {
        alert('Please fill in all fields.');
        return false;
    }
    if (password.length < 8) {
        alert('Password must be at least 8 characters.');
        return false;
    }
    if (password !== confirm) {
        alert('Passwords do not match.');
        return false;
    }
    if (!agreed) {
        alert('Please accept the company policy.');
        return false;
    }
    return true;
}
</script>
</body>
</html>