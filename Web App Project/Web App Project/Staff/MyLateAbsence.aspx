<%@ Page Title="" Language="C#"
    MasterPageFile="~/Staff/Site.Mobile.Master"
    AutoEventWireup="true"
    CodeBehind="MyLateAbsence.aspx.cs"
    Inherits="Web_App_Project.MyLateAbsence" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .la-table th {
        font-size: 11px; font-weight: 700; letter-spacing: .06em; color: #9ca3af;
        text-transform: uppercase; border-bottom: 1px solid #f3f4f6; padding: 10px 14px;
    }
    .la-table td { font-size: 13px; padding: 12px 14px; vertical-align: middle; border-bottom: 1px solid #f9fafb; }
    .la-table tbody tr:hover { background: #fafafa; }
    .ref-text { font-size: 11px; color: #6b7280; font-family: monospace; }
    .detail-text { color: #374151; }

    .badge-late     { background:#fef3c7; color:#d97706; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-leave    { background:#fce7f3; color:#be185d; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-recorded { background:#f3f4f6; color:#6b7280; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-pending  { background:#fef9c3; color:#a16207; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-approved { background:#dcfce7; color:#15803d; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-rejected { background:#fee2e2; color:#b91c1c; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .reason-muted   { color: #9ca3af; font-style: italic; font-size: 12px; }
    .badge-absence  { background:#fef2f2; color:#dc2626; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .badge-paid     { background:#d1fae5; color:#065f46; font-size:11px; padding:3px 10px; border-radius:20px; font-weight:600; }
    .paid-bar-bg    { background:#e5e7eb; border-radius:99px; height:6px; margin-top:6px; }
    .paid-bar-fill  { background:#10b981; border-radius:99px; height:6px; }
</style>
</asp:Content>

<asp:Content ID="ContentTitle" ContentPlaceHolderID="PageTitle" runat="server">
    My Late / Absence
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== PAGE HEADER ===== -->
    <div class="d-flex justify-content-between align-items-start mb-3">
        <div>
            <h4 class="fw-bold mb-0">My Late / Absence</h4>
            <p class="text-muted small mb-0">Your late arrivals and leave applications</p>
        </div>
        <asp:Button ID="btnApplyLeave" runat="server"
            Text="+ Apply Leave"
            CssClass="btn btn-primary btn-sm"
            OnClick="btnApplyLeave_Click" />
    </div>

    <!-- ===== STAT CARDS ===== -->
    <div class="row g-3 mb-3">

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#fef3c7;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#9200;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Late This Month</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblLateCount" runat="server" Text="0" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#fef2f2;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#128683;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Absent This Month</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblAbsenceCount" runat="server" Text="0" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#d1fae5;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#128203;
                    </div>
                    <div style="flex:1">
                        <p class="text-muted small mb-0">Paid Leave This Month</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblPaidLeaveUsed" runat="server" Text="0" /> <small class="text-muted fw-normal" style="font-size:13px;">/ 3</small>
                        </h5>
                        <div class="paid-bar-bg">
                            <asp:Panel ID="pnlPaidBar" runat="server" CssClass="paid-bar-fill" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Feedback -->
    <asp:Label ID="lblMessage" runat="server" CssClass="d-none" />

    <!-- ===== APPLY LEAVE FORM ===== -->
    <asp:Panel ID="pnlLeaveForm" runat="server" Visible="false"
        CssClass="card border-0 shadow-sm rounded-3 p-4 mb-3">
        <h6 class="fw-bold mb-3">New Leave Application</h6>
        <div class="row g-3">
            <div class="col-md-4">
                <label class="form-label small fw-semibold">Leave Date <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtLeaveDate" runat="server"
                    TextMode="Date" CssClass="form-control form-control-sm" />
                <div class="form-text text-muted" style="font-size:11px;">Must be at least 1 day in advance</div>
            </div>
            <div class="col-md-4">
                <label class="form-label small fw-semibold">Leave Type <span class="text-danger">*</span></label>
                <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="form-select form-select-sm">
                    <asp:ListItem Value="Full" Text="Full Day" />
                    <asp:ListItem Value="Half" Text="Half Day" />
                    <asp:ListItem Value="Paid" Text="Paid Leave (auto-approved)" />
                </asp:DropDownList>
            </div>
            <div class="col-12">
                <label class="form-label small fw-semibold">Reason <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtLeaveReason" runat="server"
                    TextMode="MultiLine" Rows="3"
                    CssClass="form-control form-control-sm"
                    placeholder="State the reason for your leave..." />
            </div>
            <div class="col-12 d-flex gap-2">
                <asp:Button ID="btnSubmitLeave" runat="server"
                    Text="Submit Application"
                    CssClass="btn btn-primary btn-sm"
                    OnClick="btnSubmitLeave_Click" />
                <asp:Button ID="btnCancelLeave" runat="server"
                    Text="Cancel"
                    CssClass="btn btn-outline-secondary btn-sm"
                    OnClick="btnCancelLeave_Click"
                    CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

    <!-- ===== ADD/EDIT REASON FOR LATE ===== -->
    <asp:Panel ID="pnlEditReason" runat="server" Visible="false"
        CssClass="card border-0 shadow-sm rounded-3 p-4 mb-3">
        <h6 class="fw-bold mb-3">Reason for Late Arrival</h6>
        <asp:HiddenField ID="hdnEditRecordID" runat="server" Value="0" />
        <div class="row g-3">
            <div class="col-12">
                <label class="form-label small fw-semibold">Reason <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtLateReason" runat="server"
                    TextMode="MultiLine" Rows="2"
                    CssClass="form-control form-control-sm"
                    placeholder="e.g. Traffic jam on the highway..." />
            </div>
            <div class="col-12 d-flex gap-2">
                <asp:Button ID="btnSaveReason" runat="server"
                    Text="Save Reason"
                    CssClass="btn btn-primary btn-sm"
                    OnClick="btnSaveReason_Click" />
                <asp:Button ID="btnCancelReason" runat="server"
                    Text="Cancel"
                    CssClass="btn btn-outline-secondary btn-sm"
                    OnClick="btnCancelReason_Click"
                    CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>

    <!-- ===== RECORDS TABLE ===== -->
    <div class="card border-0 shadow-sm rounded-3 p-3">
        <h6 class="fw-bold mb-3">My Records</h6>
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
                            <%# string.IsNullOrEmpty(Eval("Reason").ToString())
                                ? "<span class='reason-muted'>—</span>"
                                : System.Web.HttpUtility.HtmlEncode(Eval("Reason").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="STATUS">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("Status").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="">
                        <ItemTemplate>
                            <%-- Edit Reason: Late records only --%>
                            <asp:LinkButton ID="lbEditReason" runat="server"
                                CommandName="EditReason"
                                CommandArgument='<%# Eval("RecordID") %>'
                                CssClass="btn btn-outline-secondary btn-sm me-1"
                                Visible='<%# Eval("RecordType").ToString() == "Late" %>'
                                Text='<%# string.IsNullOrEmpty(Eval("Reason").ToString()) ? "Add Reason" : "Edit Reason" %>' />
                            <%-- Delete: Leave + Pending only --%>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandName="DeleteLeave"
                                CommandArgument='<%# Eval("RecordID") %>'
                                CssClass="btn btn-outline-danger btn-sm"
                                Visible='<%# (Eval("RecordType").ToString().StartsWith("Leave") && Eval("Status").ToString() == "Pending") || Eval("RecordType").ToString() == "Leave-Paid" %>'
                                OnClientClick="return confirm('Delete this leave application?');"
                                Text="Delete" />
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
            </asp:GridView>
        </div>
    </div>

</asp:Content>
