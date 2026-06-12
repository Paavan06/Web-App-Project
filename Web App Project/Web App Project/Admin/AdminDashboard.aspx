<%@ Page Title="" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Web_App_Project.Admin.AdminDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        .dash-card { border-radius: 14px; }
        .dash-icon-box {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }
        .dash-icon-blue   { background: #dbeafe; color: #2563eb; }
        .dash-icon-green  { background: #dcfce7; color: #16a34a; }
        .dash-icon-yellow { background: #fef9c3; color: #ca8a04; }
        .dash-icon-red    { background: #fee2e2; color: #dc2626; }
        .dash-card-label  { font-size: 11px; letter-spacing: .06em; font-weight: 600; }
        .dash-card-num    { font-size: 2rem; font-weight: 700; line-height: 1.1; }
        .dash-card-sub    { font-size: 12px; }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageTitle" runat="server">
    Dashboard
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h4 class="fw-bold mb-0">Dashboard</h4>
            <p class="text-muted small mb-0">
                <asp:Label ID="lblTodayDate" runat="server" Text=""></asp:Label>
                &middot; Overview of today's workforce activity
            </p>
        </div>
        <a href="../auth/Register.aspx" class="btn btn-primary">
            <i class="bi bi-person-plus-fill me-1"></i> Add Staff
        </a>
    </div>

    <div class="row g-3 mb-4">

        <!-- 1. Total Staff -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm p-3 dash-card">
                <div class="d-flex align-items-center gap-3">
                    <div class="dash-icon-box dash-icon-blue">
                        <i class="bi bi-people-fill"></i>
                    </div>
                    <div>
                        <p class="text-muted dash-card-label mb-0">TOTAL STAFF</p>
                        <div class="dash-card-num">
                            <asp:Label ID="lblTotalStaff" runat="server" Text="—"></asp:Label>
                        </div>
                        <small class="text-muted dash-card-sub">
                            <span class="text-success fw-semibold">&#8593;
                                <asp:Label ID="lblNewThisQuarter" runat="server" Text="0"></asp:Label>
                            </span> new this quarter
                        </small>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Present Today -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm p-3 dash-card">
                <div class="d-flex align-items-center gap-3">
                    <div class="dash-icon-box dash-icon-green">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <div>
                        <p class="text-muted dash-card-label mb-0">PRESENT TODAY</p>
                        <div class="dash-card-num">
                            <asp:Label ID="lblPresentToday" runat="server" Text="—"></asp:Label>
                        </div>
                        <small class="text-muted dash-card-sub">
                            <asp:Label ID="lblAttendancePct" runat="server" Text="0%"></asp:Label> attendance
                        </small>
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. OT Pending -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm p-3 dash-card">
                <div class="d-flex align-items-center gap-3">
                    <div class="dash-icon-box dash-icon-yellow">
                        <i class="bi bi-clock-fill"></i>
                    </div>
                    <div>
                        <p class="text-muted dash-card-label mb-0">OT PENDING</p>
                        <div class="dash-card-num">
                            <asp:Label ID="lblOTPending" runat="server" Text="—"></asp:Label>
                        </div>
                        <small class="text-muted dash-card-sub">Awaiting approval</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. Late / Absent -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm p-3 dash-card">
                <div class="d-flex align-items-center gap-3">
                    <div class="dash-icon-box dash-icon-red">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                    </div>
                    <div>
                        <p class="text-muted dash-card-label mb-0">LATE / ABSENT</p>
                        <div class="dash-card-num">
                            <asp:Label ID="lblLateAbsent" runat="server" Text="—"></asp:Label>
                        </div>
                        <small class="text-muted dash-card-sub">
                            <span class="text-danger fw-semibold">&#8595;</span>
                            <asp:Label ID="lblLateAbsentDetail" runat="server" Text="0 late · 0 away"></asp:Label>
                        </small>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Weekly Attendance Chart -->
    <div class="card border-0 shadow-sm p-4 dash-card">
        <div class="d-flex justify-content-between align-items-start mb-3">
            <div>
                <h6 class="fw-bold mb-0">Weekly Attendance</h6>
                <p class="text-muted small mb-0">Present staff per day</p>
            </div>
        </div>
        <canvas id="weeklyChart" height="90"></canvas>
        <hr class="my-3">
        <div class="d-flex justify-content-between align-items-center py-1">
            <span class="text-muted small">Avg. attendance</span>
            <span class="fw-bold">
                <asp:Label ID="lblAvgAttendance" runat="server" Text="0%" />
            </span>
        </div>
        <div class="d-flex justify-content-between align-items-center py-1">
            <span class="text-muted small">Avg. OT / week</span>
            <span class="fw-bold">
                <asp:Label ID="lblAvgOT" runat="server" Text="0 hrs" />
            </span>
        </div>
    </div>

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>
