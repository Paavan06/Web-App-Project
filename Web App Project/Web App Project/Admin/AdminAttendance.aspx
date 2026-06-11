<%@ Page Title="" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true" CodeBehind="AdminAttendance.aspx.cs"
    Inherits="Web_App_Project.Admin.AdminAttendance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .stat-label { font-size:10px; font-weight:700; letter-spacing:.07em; color:#9ca3af; text-transform:uppercase; }
    .stat-value { font-size:28px; font-weight:700; line-height:1.1; color:#111827; }
    .stat-sub   { font-size:11px; color:#9ca3af; margin-top:2px; }
    .stat-icon  { width:46px; height:46px; border-radius:12px; display:flex; align-items:center;
                  justify-content:center; font-size:20px; flex-shrink:0; }

    .att-table th {
        font-size:11px; font-weight:700; letter-spacing:.06em; color:#9ca3af;
        text-transform:uppercase; border-bottom:1px solid #f3f4f6; padding:10px 12px;
    }
    .att-table td { font-size:13px; padding:12px 12px; vertical-align:middle; border-bottom:1px solid #f9fafb; }
    .att-table tbody tr:hover { background:#fafafa; }

    .avatar-circle {
        width:40px; height:40px; border-radius:50%;
        display:flex; align-items:center; justify-content:center;
        font-size:13px; font-weight:700; color:#fff; flex-shrink:0;
    }
    .staff-name    { font-weight:600; color:#111827; font-size:13px; }
    .staff-dept    { font-size:11px; color:#9ca3af; }
    .checkin-time  { font-weight:700; color:#111827; }
    .checkout-time { color:#0d9488; }
    .workhours-text { color:#374151; }

    .badge-present { background:#dcfce7; color:#15803d; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-late    { background:#fef3c7; color:#d97706; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-absence { background:#fef2f2; color:#dc2626; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-leave   { background:#e0f2fe; color:#0369a1; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }

    .search-wrap { position:relative; }
    .search-icon { position:absolute; left:10px; top:50%; transform:translateY(-50%); color:#9ca3af; font-size:13px; }
    .search-box  { border:1px solid #e5e7eb; border-radius:8px; padding:6px 12px 6px 32px;
                   font-size:13px; outline:none; width:200px; }
    .search-box:focus { border-color:#6b7280; }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="PageTitle" runat="server">
    Daily Attendance
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== PAGE HEADER ===== -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-0">Attendance Log</h4>
            <p class="text-muted small mb-0">
                Today &mdash; <asp:Label ID="lblTodayDate" runat="server" />
            </p>
        </div>
    </div>

    <!-- ===== STAT CARDS ===== -->
    <div class="row g-3 mb-4">

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#dcfce7;">&#9989;</div>
                    <div>
                        <p class="stat-label mb-1">Present Today</p>
                        <div class="stat-value"><asp:Label ID="lblPresentCount" runat="server" Text="0" /></div>
                        <p class="stat-sub mb-0">On-time check-ins</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#fef3c7;">&#9200;</div>
                    <div>
                        <p class="stat-label mb-1">Late Today</p>
                        <div class="stat-value"><asp:Label ID="lblLateCount" runat="server" Text="0" /></div>
                        <p class="stat-sub mb-0">Checked in after 08:01</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#fef2f2;">&#128683;</div>
                    <div>
                        <p class="stat-label mb-1">Absent Today</p>
                        <div class="stat-value"><asp:Label ID="lblAbsentCount" runat="server" Text="0" /></div>
                        <p class="stat-sub mb-0">No check-in recorded</p>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- ===== TABLE CARD ===== -->
    <div class="card border-0 shadow-sm rounded-3 p-3">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="fw-bold mb-0">All Staff</h6>
            <div class="search-wrap">
                <span class="search-icon">&#128269;</span>
                <input type="text" id="txtSearch" class="search-box"
                       placeholder="Search staff..."
                       onkeyup="filterTable(this.value)" />
            </div>
        </div>

        <div class="table-responsive">
            <asp:GridView ID="gvAttendance" runat="server"
                CssClass="table att-table mb-0 w-100"
                AutoGenerateColumns="false"
                GridLines="None"
                EmptyDataText="No staff records found."
                EmptyDataRowStyle-CssClass="text-center text-muted small py-4">
                <Columns>

                    <asp:TemplateField HeaderText="STAFF">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-2">
                                <div class="avatar-circle"
                                     style="background:<%# GetAvatarColor(Eval("StaffName").ToString()) %>">
                                    <%# GetInitials(Eval("StaffName").ToString()) %>
                                </div>
                                <div>
                                    <div class="staff-name"><%# Eval("StaffName") %></div>
                                    <div class="staff-dept"><%# Eval("Department") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="AttendDate" HeaderText="DATE"
                        DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="false" />

                    <asp:TemplateField HeaderText="CLOCK IN">
                        <ItemTemplate>
                            <span class="checkin-time"><%# Eval("CheckInTime") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="CLOCK OUT">
                        <ItemTemplate>
                            <span class="checkout-time"><%# Eval("CheckOutTime") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="WORK HOURS">
                        <ItemTemplate>
                            <span class="workhours-text"><%# FormatWorkHours(Eval("WorkHours").ToString()) %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="STATUS">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("TodayStatus").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
            </asp:GridView>
        </div>

    </div>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    function filterTable(val) {
        val = val.toLowerCase();
        var tbl = document.getElementById('<%= gvAttendance.ClientID %>');
        if (!tbl) return;
        var rows = tbl.getElementsByTagName('tr');
        for (var i = 1; i < rows.length; i++) {
            var text = rows[i].textContent || rows[i].innerText;
            rows[i].style.display = text.toLowerCase().indexOf(val) > -1 ? '' : 'none';
        }
    }
</script>
</asp:Content>
