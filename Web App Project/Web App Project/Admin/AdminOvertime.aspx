<%@ Page Title="" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master"
    AutoEventWireup="true" CodeBehind="AdminOvertime.aspx.cs"
    Inherits="Web_App_Project.Admin.AdminOvertime" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .stat-icon {
        width: 46px; height: 46px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center; font-size: 20px;
        flex-shrink: 0;
    }
    .stat-label {
        font-size: 10px; font-weight: 700; letter-spacing: .07em; color: #9ca3af; text-transform: uppercase;
    }
    .stat-value { font-size: 28px; font-weight: 700; line-height: 1.1; color: #111827; }
    .stat-sub   { font-size: 11px; color: #9ca3af; margin-top: 2px; }

    .ot-table th {
        font-size: 11px; font-weight: 600; letter-spacing: .06em;
        color: #9ca3af; text-transform: uppercase; border-bottom: 1px solid #f3f4f6;
        padding: 10px 12px;
    }
    .ot-table td { font-size: 13px; padding: 12px 12px; vertical-align: middle; border-bottom: 1px solid #f9fafb; }
    .ot-table tbody tr:hover { background: #fafafa; }

    .staff-name  { font-weight: 600; color: #111827; font-size: 13px; }
    .staff-dept  { font-size: 11px; color: #9ca3af; }
    .ref-badge   { font-size: 11px; color: #6b7280; font-family: monospace; }
    .hours-val   { font-weight: 700; font-size: 14px; color: #111827; }

    .badge-approved { background: #dcfce7; color: #15803d; font-size: 11px; padding: 4px 10px; border-radius: 20px; font-weight: 600; }
    .badge-pending  { background: #fef9c3; color: #a16207; font-size: 11px; padding: 4px 10px; border-radius: 20px; font-weight: 600; }
    .badge-rejected { background: #fee2e2; color: #b91c1c; font-size: 11px; padding: 4px 10px; border-radius: 20px; font-weight: 600; }

    .btn-approve { background:#16a34a; color:#fff; border:none; border-radius:7px; width:30px; height:30px; font-size:14px; cursor:pointer; }
    .btn-approve:hover { background:#15803d; }
    .btn-reject  { background:#dc2626; color:#fff; border:none; border-radius:7px; width:30px; height:30px; font-size:14px; cursor:pointer; }
    .btn-reject:hover  { background:#b91c1c; }

    .search-wrap { position:relative; }
    .search-wrap input { padding-left: 32px; border-radius: 8px; border: 1px solid #e5e7eb;
                         font-size: 13px; width: 220px; height: 34px; outline:none; }
    .search-wrap input:focus { border-color: #1d5fbf; box-shadow: 0 0 0 2px rgba(29,95,191,.1); }
    .search-icon { position:absolute; left:10px; top:50%; transform:translateY(-50%); color:#9ca3af; font-size:14px; pointer-events:none; }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="PageTitle" runat="server">
    Overtime Record
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== PAGE HEADER ===== -->
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h4 class="fw-bold mb-0">Overtime Records</h4>
            <p class="text-muted small mb-0">Review and approve staff overtime claims</p>
        </div>
    </div>

    <!-- Feedback Message -->
    <asp:Label ID="lblMessage" runat="server" CssClass="d-none" />

    <!-- ===== STAT CARDS ===== -->
    <div class="row g-3 mb-4">

        <!-- Total Hours -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#eff6ff;">&#128336;</div>
                    <div>
                        <p class="stat-label mb-1">Total Hours</p>
                        <div class="stat-value">
                            <asp:Label ID="lblTotalHours" runat="server" Text="0" /> h
                        </div>
                        <p class="stat-sub mb-0">All records</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Pending -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#fefce8;">&#9203;</div>
                    <div>
                        <p class="stat-label mb-1">Pending</p>
                        <div class="stat-value">
                            <asp:Label ID="lblPendingCount" runat="server" Text="0" />
                        </div>
                        <p class="stat-sub mb-0">Awaiting approval</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Est. OT Pay -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon" style="background:#f0fdf4;">&#128178;</div>
                    <div>
                        <p class="stat-label mb-1">Est. OT Pay</p>
                        <div class="stat-value">
                            RM <asp:Label ID="lblEstPay" runat="server" Text="0" />
                        </div>
                        <p class="stat-sub mb-0">@ RM18 / hour</p>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- ===== OVERTIME LOG TABLE ===== -->
    <div class="card border-0 shadow-sm rounded-3 p-3">

        <!-- Table Header -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="fw-bold mb-0">Overtime Log</h6>
            <div class="search-wrap">
                <span class="search-icon">&#128269;</span>
                <input type="text" id="txtSearch" placeholder="Search..." oninput="filterTable()" />
            </div>
        </div>

        <!-- Grid -->
        <div class="table-responsive">
            <asp:GridView ID="gvOvertime" runat="server"
                CssClass="table ot-table mb-0 w-100"
                AutoGenerateColumns="false"
                GridLines="None"
                EmptyDataText="No overtime records found."
                EmptyDataRowStyle-CssClass="text-center text-muted small py-4"
                OnRowCommand="gvOvertime_RowCommand">
                <HeaderStyle CssClass="table-header" />
                <Columns>

                    <asp:TemplateField HeaderText="REF">
                        <ItemTemplate>
                            <span class="ref-badge"><%# Eval("RefNo") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="STAFF">
                        <ItemTemplate>
                            <div class="staff-name"><%# Eval("StaffName") %></div>
                            <div class="staff-dept"><%# Eval("Department") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="DATE">
                        <ItemTemplate>
                            <%# Convert.ToDateTime(Eval("OTDate")).ToString("yyyy-MM-dd") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="HOURS">
                        <ItemTemplate>
                            <span class="hours-val"><%# Eval("OTHours") %> h</span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="Reason" HeaderText="REASON" />

                    <asp:TemplateField HeaderText="STATUS">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="ACTION">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbApprove" runat="server"
                                CommandName="ApproveOT"
                                CommandArgument='<%# Eval("OvertimeID") %>'
                                CssClass="btn-approve me-1"
                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                OnClientClick="return confirm('Approve this overtime request?');"
                                ToolTip="Approve"
                                Text="&#10003;" />
                            <asp:LinkButton ID="lbReject" runat="server"
                                CommandName="RejectOT"
                                CommandArgument='<%# Eval("OvertimeID") %>'
                                CssClass="btn-reject"
                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                OnClientClick="return confirm('Reject this overtime request?');"
                                ToolTip="Reject"
                                Text="&#10007;" />
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
<script>
function filterTable() {
    var filter = document.getElementById('txtSearch').value.toLowerCase();
    var rows = document.querySelectorAll('#<%= gvOvertime.ClientID %> tr:not(:first-child)');
    rows.forEach(function (row) {
        row.style.display = row.textContent.toLowerCase().includes(filter) ? '' : 'none';
    });
}
</script>
</asp:Content>
