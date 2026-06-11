<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="Web_App_Project.login" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - Staff System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="../style.css" rel="stylesheet">
</head>
<body>
<form id="form1" runat="server">

<div class="container-fluid min-vh-100">
    <div class="row min-vh-100">

        <!-- ===== LEFT PANEL ===== -->
        <div class="col-md-6 left-panel d-flex flex-column justify-content-between p-5">

            <!-- Logo / Brand -->
            <div class="d-flex align-items-center gap-3">
                <div class="brand-logo">MJ</div>
                <div>
                    <p class="text-white fw-bold mb-0">Maju Jaya Agrotech</p>
                    <small class="text-secondary">Supplies Sdn. Bhd.</small>
                </div>
            </div>

            <!-- Middle text -->
            <div>
                <h2 class="text-white fw-bold">Staff Management System</h2>
                <p class="text-secondary mb-4">
                    Manage staff profiles, daily attendance, overtime 
                    and absence records — all in one place.
                </p>

                <!-- Feature list -->
                <div class="d-flex align-items-center gap-2 mb-3">
                    <span class="feature-icon">&#128101;</span>
                    <span class="text-light">Staff profile management</span>
                </div>
                <div class="d-flex align-items-center gap-2 mb-3">
                    <span class="feature-icon">&#128197;</span>
                    <span class="text-light">Daily attendance tracking</span>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="feature-icon">&#128336;</span>
                    <span class="text-light">Overtime &amp; late records</span>
                </div>
            </div>

            <!-- Footer text -->
            <small class="text-secondary">Reg. No. 201801023456 (1234567-A)</small>

        </div>

        <!-- ===== RIGHT PANEL (FORM) ===== -->
        <div class="col-md-6 bg-white d-flex align-items-center justify-content-center">
            <div class="w-75">

                <h2 class="fw-bold mb-1">Sign in</h2>
                <p class="text-muted mb-2">Enter your credentials to access the system.</p>

                <!-- Role toggle -->
                <div class="btn-group w-100 mb-4" role="group">
                    <button type="button" id="btnRoleStaff"
                        class="btn btn-primary"
                        onclick="selectRole('Staff')">
                        &#128100; Staff
                    </button>
                    <button type="button" id="btnRoleAdmin"
                        class="btn btn-outline-primary"
                        onclick="selectRole('Admin')">
                        &#128737; Admin
                    </button>
                </div>
                <asp:HiddenField ID="hdnRole" runat="server" Value="Staff" />

                <!-- Username field -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">Username</label>
                    <div class="input-group">
                        <span class="input-group-text">
                            <i>&#128100;</i>
                        </span>
                        <asp:TextBox ID="txtUsername" runat="server" 
                            CssClass="form-control" 
                            placeholder="Enter username">
                        </asp:TextBox>
                    </div>
                </div>

                <!-- Password field -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">Password</label>
                    <div class="input-group">
                        <span class="input-group-text">
                            <i>&#128274;</i>
                        </span>
                        <asp:TextBox ID="txtPassword" runat="server" 
                            CssClass="form-control" 
                            TextMode="Password"
                            placeholder="Enter password">
                        </asp:TextBox>
                    </div>
                </div>

                <!-- Remember me + Forgot password -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="rememberMe">
                        <label class="form-check-label text-muted" for="rememberMe">
                            Remember me
                        </label>
                    </div>
                    <a href="#" class="text-primary text-decoration-none small">
                        Forgot password?
                    </a>
                </div>

                <!-- Sign in button -->
                <asp:Button ID="btnLogin" runat="server" 
                    Text="Sign in" 
                    CssClass="btn btn-primary w-100 py-2 mb-3"
                    OnClick="btnLogin_Click">
                </asp:Button>

                <!-- Error message -->
                <asp:Label ID="lblMessage" runat="server" 
                    CssClass="text-danger small d-block text-center mb-3">
                </asp:Label>

                <!-- Demo accounts box -->
                <div class="demo-box p-3">
                    <small class="text-muted text-uppercase fw-bold">
                        Demo accounts — click to fill
                    </small>
                    <div class="row mt-2 g-2">
                        <div class="col-6">
                            <div class="demo-admin p-2 rounded"
                                 onclick="fillDemo('admin','admin123','Admin')"
                                 style="cursor:pointer">
                                <small class="fw-bold text-primary d-block">
                                    Administrator
                                </small>
                                <small class="text-muted">admin / admin123</small>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="demo-staff p-2 rounded"
                                 onclick="fillDemo('ahmad','staff123','Staff')"
                                 style="cursor:pointer">
                                <small class="fw-bold text-success d-block">
                                    Staff
                                </small>
                                <small class="text-muted">ahmad / staff123</small>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function selectRole(role) {
        document.getElementById('<%= hdnRole.ClientID %>').value = role;
        if (role === 'Staff') {
            document.getElementById('btnRoleStaff').className = 'btn btn-primary';
            document.getElementById('btnRoleAdmin').className = 'btn btn-outline-primary';
        } else {
            document.getElementById('btnRoleStaff').className = 'btn btn-outline-primary';
            document.getElementById('btnRoleAdmin').className = 'btn btn-primary';
        }
    }

    function fillDemo(user, pass, role) {
        document.getElementById('<%= txtUsername.ClientID %>').value = user;
        document.getElementById('<%= txtPassword.ClientID %>').value = pass;
        selectRole(role);
    }
</script>

</form>
</body>
</html>