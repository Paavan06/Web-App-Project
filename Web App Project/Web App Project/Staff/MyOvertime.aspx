<%@ Page Title="" Language="C#"
    MasterPageFile="~/Staff/Site.Mobile.Master"
    AutoEventWireup="true"
    CodeBehind="MyOvertime.aspx.cs"
    Inherits="Web_App_Project.MyOvertime" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="ContentTitle" ContentPlaceHolderID="PageTitle" runat="server">
    My Overtime
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-start mb-3">
        <div>
            <h4 class="fw-bold mb-0">My Overtime</h4>
            <p class="text-muted small">Your overtime requests and approvals</p>
        </div>
        <asp:Button ID="btnShowForm" runat="server"
            Text="+ Request Overtime"
            CssClass="btn btn-primary btn-sm"
            OnClick="btnShowForm_Click" />
    </div>

    <!-- Feedback Message -->
    <asp:Label ID="lblMessage" runat="server" CssClass="d-none" />
    <asp:HiddenField ID="hdnEditID" runat="server" Value="0" />

    <!-- ===== STAT CARDS ===== -->
    <div class="row g-3 mb-3">

        <!-- Pending -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#fff3cd;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#9203;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Pending</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblPendingCount" runat="server" Text="0" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>

        <!-- Approved Hours This Month -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#d1e7dd;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#128336;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Approved Hrs (This Month)</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblApprovedHours" runat="server" Text="0" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>

        <!-- Total Requests -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <div class="d-flex align-items-center gap-3">
                    <div style="width:42px;height:42px;background:#cfe2ff;border-radius:10px;
                                display:flex;align-items:center;justify-content:center;font-size:18px;">
                        &#128203;
                    </div>
                    <div>
                        <p class="text-muted small mb-0">Total Requests</p>
                        <h5 class="fw-bold mb-0">
                            <asp:Label ID="lblTotalCount" runat="server" Text="0" />
                        </h5>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- ===== REQUEST FORM (hidden by default) ===== -->
    <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="card border-0 shadow-sm rounded-3 p-4 mb-3">
        <h6 class="fw-bold mb-3">
            <asp:Label ID="lblFormTitle" runat="server" Text="New Overtime Request" />
        </h6>
        <div class="row g-3">

            <div class="col-md-4">
                <label class="form-label small fw-semibold">Date <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtOTDate" runat="server"
                    TextMode="Date"
                    CssClass="form-control form-control-sm" />
            </div>

            <div class="col-md-4">
                <label class="form-label small fw-semibold">Hours <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtOTHours" runat="server"
                    TextMode="Number"
                    CssClass="form-control form-control-sm"
                    placeholder="e.g. 2.5" />
            </div>

            <div class="col-12">
                <label class="form-label small fw-semibold">Reason / Work Done <span class="text-danger">*</span></label>
                <asp:TextBox ID="txtReason" runat="server"
                    TextMode="MultiLine"
                    Rows="3"
                    CssClass="form-control form-control-sm"
                    placeholder="Describe the overtime work performed..." />
            </div>

            <div class="col-12 d-flex gap-2">
                <asp:Button ID="btnSubmit" runat="server"
                    Text="Submit Request"
                    CssClass="btn btn-primary btn-sm"
                    OnClick="btnSubmit_Click"
                    OnClientClick="return validateOTForm();" />
                <asp:Button ID="btnCancel" runat="server"
                    Text="Cancel"
                    CssClass="btn btn-outline-secondary btn-sm"
                    OnClick="btnCancel_Click"
                    CausesValidation="false" />
            </div>

        </div>
    </asp:Panel>

    <!-- ===== OVERTIME HISTORY TABLE ===== -->
    <div class="card border-0 shadow-sm rounded-3 p-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="fw-bold mb-0">Overtime History</h6>
            <div class="d-flex gap-2">
                <asp:DropDownList ID="ddlFilter" runat="server"
                    CssClass="form-select form-select-sm"
                    Style="width:130px"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                    <asp:ListItem Value="">All Status</asp:ListItem>
                    <asp:ListItem Value="Pending">Pending</asp:ListItem>
                    <asp:ListItem Value="Approved">Approved</asp:ListItem>
                    <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <asp:GridView ID="gvOvertime" runat="server"
            CssClass="table table-hover table-sm align-middle mb-0"
            AutoGenerateColumns="false"
            GridLines="None"
            EmptyDataText="No overtime records found."
            EmptyDataRowStyle-CssClass="text-center text-muted small"
            OnRowCommand="gvOvertime_RowCommand">
            <HeaderStyle CssClass="table-light small text-muted" />
            <Columns>

                <asp:BoundField DataField="OTDate" HeaderText="Date"
                    DataFormatString="{0:dd MMM yyyy}" HtmlEncode="false" />

                <asp:BoundField DataField="OTHours" HeaderText="Hours"
                    DataFormatString="{0:0.##}" HtmlEncode="false" />

                <asp:BoundField DataField="Reason" HeaderText="Reason" />

                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <%# GetStatusBadge(Eval("Status").ToString()) %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField DataField="OTRate" HeaderText="Rate (RM/hr)"
                    DataFormatString="{0:0.00}" HtmlEncode="false" />

                <asp:BoundField DataField="CreatedAt" HeaderText="Submitted"
                    DataFormatString="{0:dd MMM yyyy}" HtmlEncode="false" />

                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:LinkButton ID="lbEdit" runat="server"
                            CommandName="EditOT"
                            CommandArgument='<%# Eval("OvertimeID") %>'
                            CssClass="btn btn-outline-primary btn-sm me-1"
                            Visible='<%# Eval("Status").ToString() == "Pending" %>'
                            Text="Edit" />
                        <asp:LinkButton ID="lbDelete" runat="server"
                            CommandName="DeleteOT"
                            CommandArgument='<%# Eval("OvertimeID") %>'
                            CssClass="btn btn-outline-danger btn-sm"
                            Visible='<%# Eval("Status").ToString() == "Pending" %>'
                            Text="Delete"
                            OnClientClick="return confirm('Delete this overtime request?');" />
                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>
        </asp:GridView>

    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
<script>
function validateOTForm() {
    var date  = document.getElementById('<%= txtOTDate.ClientID %>').value;
    var hours = document.getElementById('<%= txtOTHours.ClientID %>').value;
    var reason = document.getElementById('<%= txtReason.ClientID %>').value.trim();

    if (date === '') {
        alert('Please select a date.'); return false;
    }
    if (hours === '' || isNaN(hours) || parseFloat(hours) <= 0) {
        alert('Please enter valid hours (e.g. 2.5).'); return false;
    }
    if (parseFloat(hours) > 12) {
        alert('Overtime cannot exceed 12 hours per day.'); return false;
    }
    if (reason === '') {
        alert('Please describe the overtime work.'); return false;
    }
    return true;
}
</script>
</asp:Content>
