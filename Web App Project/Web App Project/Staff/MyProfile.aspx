<%@ Page Title="" Language="C#"
    MasterPageFile="~/Staff/Site.Mobile.Master"
    AutoEventWireup="true"
    CodeBehind="MyProfile.aspx.cs"
    Inherits="Web_App_Project.MyProfile" %>


<asp:Content ID="Content1"
    ContentPlaceHolderID="HeadContent"
    runat="server">
<style>
    .attd-card { border-radius: 14px; }

    .attd-seal-wrapper {
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 10px 0 6px;
    }

    /* 16-spiked starburst seal */
    .attd-seal {
        width: 130px;
        height: 130px;
        display: flex;
        align-items: center;
        justify-content: center;
        clip-path: polygon(
            50% 0%,  59% 6%,  69% 4%,  75% 13%, 85% 15%, 87% 25%,
            96% 31%, 94% 41%, 100% 50%, 94% 59%, 96% 69%, 87% 75%,
            85% 85%, 75% 87%, 69% 96%, 59% 94%, 50% 100%, 41% 94%,
            31% 96%, 25% 87%, 15% 85%, 13% 75%, 4% 69%,  6% 59%,
            0% 50%,  6% 41%,  4% 31%,  13% 25%, 15% 15%, 25% 13%,
            31% 4%,  41% 6%
        );
    }
    .attd-seal-bad       { background: #dc2626; }
    .attd-seal-good      { background: #f59e0b; }
    .attd-seal-excellent { background: #16a34a; }

    .attd-pct    { font-size: 26px; font-weight: 800; color: #fff; line-height: 1; display: block; }
    .attd-rating { font-size: 10px; font-weight: 700; color: rgba(255,255,255,.9);
                   text-transform: uppercase; letter-spacing: .06em; display: block; margin-top: 2px; }
</style>
</asp:Content>

<asp:Content ID="Content2"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <%-- YOUR PAGE CONTENT GOES HERE --%>
    <asp:Label ID="lblMessage" runat="server" CssClass="d-none"></asp:Label>

    <div class="row g-3">

        <!-- LEFT CARD — Avatar + basic info -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-3 p-4 text-center">

                <!-- Avatar circle with initials -->
                <div class="avatar-circle mx-auto mb-3">
                    <asp:Label ID="lblInitials" runat="server" Text="AB"></asp:Label>
                </div>

                <h6 class="fw-bold mb-0">
                    <asp:Label ID="lblFullName" runat="server"></asp:Label>
                </h6>
                <p class="text-muted small mb-2">
                    <asp:Label ID="lblPosition" runat="server"></asp:Label>
                </p>
                <span class="badge bg-primary px-3 py-1 mb-3">Staff</span>

                <hr>

                <div class="d-flex justify-content-around">
                    <div>
                        <p class="text-muted mb-0" style="font-size: 10px">Department</p>
                        <strong style="font-size: 13px">
                            <asp:Label ID="lblDeptLeft" runat="server"></asp:Label>
                        </strong>
                    </div>
                    <div>
                        <p class="text-muted mb-0" style="font-size: 10px">Since</p>
                        <strong style="font-size: 13px">
                            <asp:Label ID="lblSince" runat="server"></asp:Label>
                        </strong>
                    </div>
                </div>
            </div>

            <!-- ===== ATTENDANCE SCORE CARD ===== -->
            <div class="card border-0 shadow-sm rounded-3 p-3 text-center mt-3 attd-card">
                <p class="text-muted fw-semibold mb-0" style="font-size:10px;letter-spacing:.06em">ATTENDANCE SCORE</p>
                <div class="attd-seal-wrapper">
                    <div id="attdSeal" runat="server" class="attd-seal attd-seal-good">
                        <div>
                            <span class="attd-pct">
                                <asp:Label ID="lblAttdScore" runat="server" Text="0%" />
                            </span>
                            <span class="attd-rating">
                                <asp:Label ID="lblAttdRating" runat="server" Text="—" />
                            </span>
                        </div>
                    </div>
                </div>
                <p class="text-muted mb-0" style="font-size:11px">This month's attendance</p>
            </div>
        </div>

        <!-- RIGHT CARD — Personal information -->
        <div class="col-md-9">
            <div class="card border-0 shadow-sm rounded-3 p-4">

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="fw-bold mb-0">Personal Information</h6>
                    <div>
                        <!-- VIEW MODE: Edit button -->
                        <asp:Button ID="btnEdit" runat="server"
                            Text="✏ Edit"
                            CssClass="btn btn-sm btn-outline-secondary"
                            OnClick="btnEdit_Click"></asp:Button>

                        <!-- EDIT MODE: Save + Cancel buttons -->
                        <asp:Button ID="btnSave" runat="server"
                            Text="Save changes"
                            CssClass="btn btn-sm btn-primary me-1"
                            OnClick="btnSave_Click"
                            Visible="false"></asp:Button>
                        <asp:Button ID="btnCancel" runat="server"
                            Text="Cancel"
                            CssClass="btn btn-sm btn-outline-secondary"
                            OnClick="btnCancel_Click"
                            Visible="false"></asp:Button>
                    </div>
                </div>

                <!-- INFO FIELDS -->
                <div class="row g-0">

                    <!-- Full Name -->
                    <div class="col-md-6 border-bottom py-3 pe-3">
                        <p class="text-muted mb-1" style="font-size: 11px">Full Name</p>
                        <!-- VIEW -->
                        <asp:Label ID="vFullName" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                        <!-- EDIT -->
                        <asp:TextBox ID="iFullName" runat="server"
                            CssClass="form-control form-control-sm"
                            Visible="false">
                    </asp:TextBox>
                    </div>

                    <!-- Employee ID — not editable -->
                    <div class="col-md-6 border-bottom py-3 ps-3">
                        <p class="text-muted mb-1" style="font-size: 11px">Employee ID</p>
                        <asp:Label ID="vStaffID" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                    </div>

                    <!-- Email -->
                    <div class="col-md-6 border-bottom py-3 pe-3">
                        <p class="text-muted mb-1" style="font-size: 11px">Email</p>
                        <asp:Label ID="vEmail" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                        <asp:TextBox ID="iEmail" runat="server"
                            CssClass="form-control form-control-sm"
                            Visible="false">
                    </asp:TextBox>
                    </div>

                    <!-- Phone -->
                    <div class="col-md-6 border-bottom py-3 ps-3">
                        <p class="text-muted mb-1" style="font-size: 11px">Phone</p>
                        <asp:Label ID="vPhone" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                        <asp:TextBox ID="iPhone" runat="server"
                            CssClass="form-control form-control-sm"
                            Visible="false">
                    </asp:TextBox>
                    </div>

                    <!-- NRIC -->
                    <div class="col-md-6 border-bottom py-3 pe-3">
                        <p class="text-muted mb-1" style="font-size: 11px">NRIC</p>
                        <asp:Label ID="vNRIC" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                        <asp:TextBox ID="iNRIC" runat="server"
                            CssClass="form-control form-control-sm"
                            Visible="false">
                    </asp:TextBox>
                    </div>

                    <!-- Gender -->
                    <div class="col-md-6 border-bottom py-3 ps-3">
                        <p class="text-muted mb-1" style="font-size: 11px">Gender</p>
                        <asp:Label ID="vGender" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                        <asp:DropDownList ID="iGender" runat="server"
                            CssClass="form-select form-select-sm"
                            Visible="false">
                            <asp:ListItem Value="Male">Male</asp:ListItem>
                            <asp:ListItem Value="Female">Female</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <!-- Department -->
                    <div class="col-md-6 py-3 pe-3">
                        <p class="text-muted mb-1" style="font-size: 11px">Department</p>
                        <asp:Label ID="vDepartment" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                        <asp:TextBox ID="iDepartment" runat="server"
                            CssClass="form-control form-control-sm"
                            Visible="false">
                    </asp:TextBox>
                    </div>

                    <!-- Date Joined — not editable -->
                    <div class="col-md-6 py-3 ps-3">
                        <p class="text-muted mb-1" style="font-size: 11px">Date Joined</p>
                        <asp:Label ID="vCreatedAt" runat="server"
                            CssClass="fw-semibold" Style="font-size: 13px">
                    </asp:Label>
                    </div>

                </div>
            </div>
        </div>

    </div>

    <!-- Add avatar style -->
    <style>
        .avatar-circle {
            width: 80px;
            height: 80px;
            background-color: #1d5fbf;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 26px;
            font-weight: bold;
        }
    </style>

</asp:Content>