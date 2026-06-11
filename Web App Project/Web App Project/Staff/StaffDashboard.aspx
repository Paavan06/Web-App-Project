<%@ Page Title="" Language="C#"
    MasterPageFile="~/Staff/Site.Mobile.Master"
    AutoEventWireup="true"
    CodeBehind="StaffDashboard.aspx.cs"
    Inherits="Web_App_Project.StaffDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .clock-widget {
        background: linear-gradient(135deg, #1a5caf 0%, #0d9488 100%);
        border-radius: 14px;
        padding: 20px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        color: white;
    }
    .clock-fp {
        width: 46px; height: 46px;
        background: rgba(255,255,255,0.18);
        border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; flex-shrink: 0; margin-right: 16px;
    }
    .clock-status-label { font-size: 11px; opacity: .75; margin-bottom: 2px; }
    .clock-status-main  { font-size: 22px; font-weight: 700; line-height: 1.1; }
    .clock-status-sub   { font-size: 12px; opacity: .75; margin-top: 3px; }

    .btn-clockin  { background:#fff; color:#1a5caf; font-weight:600; font-size:13px;
                    border:none; border-radius:8px; padding:8px 18px; cursor:pointer;
                    display:flex; align-items:center; gap:6px; white-space:nowrap; }
    .btn-clockin:hover { background:#e8f0fb; }
    .btn-clockout { background:transparent; color:#fff; font-weight:600; font-size:13px;
                    border:2px solid rgba(255,255,255,.6); border-radius:8px;
                    padding:8px 18px; cursor:pointer;
                    display:flex; align-items:center; gap:6px; white-space:nowrap; }
    .btn-clockout:hover { background:rgba(255,255,255,.15); }
</style>
</asp:Content>

<asp:Content ID="ContentTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Dashboard
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== WELCOME HEADER ===== -->
    <div class="mb-4">
        <h4 class="fw-bold mb-0">
            Welcome back, <span style="text-decoration:underline;">
                <asp:Label ID="lblWelcomeName" runat="server" />
            </span>
        </h4>
        <p class="text-muted small mb-0">
            <asp:Label ID="lblTodayDate" runat="server" /> &middot; Here is your activity at a glance
        </p>
    </div>

    <!-- ===== CLOCK WIDGET ===== -->
    <div class="clock-widget mb-4">
        <div class="d-flex align-items-center">
            <div class="clock-fp">&#128422;</div>
            <div>
                <div class="clock-status-label">You are currently</div>
                <div class="clock-status-main">
                    <asp:Label ID="lblClockStatus" runat="server" Text="Not Clocked In" />
                </div>
                <div class="clock-status-sub">
                    <asp:Label ID="lblClockSince" runat="server" Visible="false" />
                </div>
            </div>
        </div>
        <div>
            <asp:Button ID="btnClockIn" runat="server"
                Text="&#9654; Clock In"
                CssClass="btn-clockin"
                OnClick="btnClockIn_Click"
                Visible="false" />
            <asp:Button ID="btnClockOut" runat="server"
                Text="&#10132; Clock Out"
                CssClass="btn-clockout"
                OnClick="btnClockOut_Click"
                Visible="false" />
        </div>
    </div>

    <!-- ===== QUICK STAT CARDS ===== -->
    <div class="row g-3">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#eff6ff;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#128197;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Days Present</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblDaysPresent" runat="server" Text="0" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#fefce8;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#128336;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Pending OT</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblPendingOT" runat="server" Text="0" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#fdf4ff;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#127807;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Paid Leave This Month</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblPaidLeave" runat="server" Text="0 / 3 days" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
