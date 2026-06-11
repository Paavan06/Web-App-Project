<%@ Page Title="" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true" CodeBehind="AdminLateAbsence.aspx.cs"
    Inherits="Web_App_Project.Admin.AdminLateAbsence" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .stat-label { font-size:10px; font-weight:700; letter-spacing:.07em; color:#9ca3af; text-transform:uppercase; }
    .stat-value { font-size:28px; font-weight:700; line-height:1.1; color:#111827; }
    .stat-sub   { font-size:11px; color:#9ca3af; margin-top:2px; }
    .stat-icon  { width:46px; height:46px; border-radius:12px; display:flex; align-items:center;
                  justify-content:center; font-size:20px; flex-shrink:0; }

    .la-table th {
        font-size:11px; font-weight:700; letter-spacing:.06em; color:#9ca3af;
        text-transform:uppercase; border-bottom:1px solid #f3f4f6; padding:10px 12px;
    }
    .la-table td { font-size:13px; padding:12px 12px; vertical-align:middle; border-bottom:1px solid #f9fafb; }
    .la-table tbody tr:hover { background:#fafafa; }

    .ref-text    { font-size:11px; color:#6b7280; font-family:monospace; }
    .staff-name  { font-weight:600; color:#111827; font-size:13px; }
    .staff-dept  { font-size:11px; color:#9ca3af; }
    .detail-text { color:#374151; }
    .reason-text { color:#6b7280; font-size:12px; }

    .badge-late     { background:#fef3c7; color:#d97706;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-absence  { background:#fef2f2; color:#dc2626;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-leave    { background:#fce7f3; color:#be185d;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-paid     { background:#d1fae5; color:#065f46;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-recorded { background:#f3f4f6; color:#6b7280;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-pending  { background:#fef9c3; color:#a16207;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-approved { background:#dcfce7; color:#15803d;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-rejected { background:#fee2e2; color:#b91c1c;  font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }

    .btn-approve { background:#16a34a; color:#fff; border:none; border-radius:7px; width:30px; height:30px; font-size:14px; cursor:pointer; }
    .btn-approve:hover { background:#15803d; }
    .btn-reject  { background:#dc2626; color:#fff; border:none; border-radius:7px; width:30px; height:30px; font-size:14px; cursor:pointer; }
    .btn-reject:hover  { background:#b91c1c; }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="PageTitle" runat="server">
    Late / Absence
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== PAGE HEADER ===== -->
    <div class="mb-4">
        <h4 class="fw-bold mb-0">Late / Absence Records</h4>
        <p class="text-muted small mb-0">Monitor staff late arrivals, absences and leave applications</p>
    </div>

    <!-- Feedback -->
    <asp:Label ID="lblMessage" runat="server" CssClass="d-none" />

    <!-- ===== STAT CARDS ===== -->
    <div class="row g-3 mb-4">

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#fef3c7;">&#9200;</div>
                    <div>
                        <p class="stat-label mb-1">Late This Month</p>
                        <div class="stat-value"><asp:Label ID="lblLateCount" runat="server" Text="0" /></div>
                        <p class="stat-sub mb-0">Late check-ins recorded</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#fef2f2;">&#128683;</div>
                    <div>
                        <p class="stat-label mb-1">Absent This Month</p>
                        <div class="stat-value"><asp:Label ID="lblAbsenceCount" runat="server" Text="0" /></div>
                        <p class="stat-sub mb-0">No check-in recorded</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#fefce8;">&#9203;</div>
                    <div>
                        <p class="stat-label mb-1">Pending Approval</p>
                        <div class="stat-value"><asp:Label ID="lblPendingCount" runat="server" Text="0" /></div>
                        <p class="stat-sub mb-0">Leave applications awaiting</p>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- ===== RECORDS TABLE ===== -->
    <div class="card border-0 shadow-sm rounded-3 p-3">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="fw-bold mb-0">All Records</h6>
            <asp:DropDownList ID="ddlFilter" runat="server"
                CssClass="form-select form-select-sm"
                Style="width:170px"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                <asp:ListItem Value="">All Types</asp:ListItem>
                <asp:ListItem Value="Late">Late</asp:ListItem>
                <asp:ListItem Value="Absence">Absence</asp:ListItem>
                <asp:ListItem Value="Leave-Full">Leave — Full Day</asp:ListItem>
                <asp:ListItem Value="Leave-Half">Leave — Half Day</asp:ListItem>
                <asp:ListItem Value="Leave-Paid">Paid Leave</asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="table-responsive">
            <asp:GridView ID="gvRecords" runat="server"
                CssClass="table la-table mb-0 w-100"
                AutoGenerateColumns="false"
                GridLines="None"
                EmptyDataText="No records found."
                EmptyDataRowStyle-CssClass="text-center text-muted small py-4"
                OnRowCommand="gvRecords_RowCommand">
                <Columns>

                    <asp:TemplateField HeaderText="REF">
                        <ItemTemplate>
                            <span class="ref-text"><%# Eval("RefNo") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="STAFF">
                        <ItemTemplate>
                            <div class="staff-name"><%# Eval("StaffName") %></div>
                            <div class="staff-dept"><%# Eval("Department") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="RecordDate" HeaderText="DATE"
                        DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="false" />

                    <asp:TemplateField HeaderText="TYPE">
                        <ItemTemplate>
                            <%# GetTypeBadge(Eval("RecordType").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="DETAIL">
                        <ItemTemplate>
                            <span class="detail-text"><%# Eval("Detail") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="REASON">
                        <ItemTemplate>
                            <span class="reason-text"><%# Eval("Reason") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="STATUS">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="ACTION">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbApprove" runat="server"
                                CommandName="ApproveLA"
                                CommandArgument='<%# Eval("RecordID") %>'
                                CssClass="btn-approve me-1"
                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                OnClientClick="return confirm('Approve this leave request?');"
                                ToolTip="Approve" Text="&#10003;" />
                            <asp:LinkButton ID="lbReject" runat="server"
                                CommandName="RejectLA"
                                CommandArgument='<%# Eval("RecordID") %>'
                                CssClass="btn-reject"
                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                OnClientClick="return confirm('Reject this leave request?');"
                                ToolTip="Reject" Text="&#10007;" />
                            <asp:Label ID="lblDash" runat="server"
                                Visible='<%# Eval("Status").ToString() != "Pending" %>'
                                Text="&#8212;" CssClass="text-muted" />
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
            </asp:GridView>
        </div>

    </div>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>
