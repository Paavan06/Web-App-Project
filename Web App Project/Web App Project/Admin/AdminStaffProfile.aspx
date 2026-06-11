<%@ Page Title="" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminStaffProfile.aspx.cs" Inherits="Web_App_Project.Admin.AdminStaffProfile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .attd-badge {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 999px;
        font-size: 11px;
        font-weight: 600;
        color: #fff;
        vertical-align: middle;
    }
    .attd-badge-bad       { background: #dc2626; }
    .attd-badge-good      { background: #f59e0b; }
    .attd-badge-excellent { background: #16a34a; }
</style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="PageTitle" runat="server">
    Staff Profile
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Header row -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h5 class="fw-bold mb-0">Staff List</h5>
        <span class="badge bg-primary px-3 py-2" style="font-size:13px">
            Total: <asp:Label ID="lblCount" runat="server" Text="0"></asp:Label>
        </span>
    </div>

    <!-- Alert message -->
    <asp:Label ID="lblMessage" runat="server" CssClass="d-none"></asp:Label>

    <!-- Staff table -->
    <div class="card border-0 shadow-sm">
        <div class="card-body p-0">
            <asp:GridView ID="gvStaff" runat="server"
                CssClass="table table-hover mb-0"
                AutoGenerateColumns="false"
                GridLines="None"
                OnRowCommand="gvStaff_RowCommand"
                EmptyDataText="No staff records found.">
                <HeaderStyle CssClass="table-light fw-semibold" />
                <Columns>
                    <asp:BoundField DataField="EmpID"      HeaderText="Employee ID" />
                    <asp:BoundField DataField="StaffName"  HeaderText="Full Name" />
                    <asp:BoundField DataField="Department" HeaderText="Department" />
                    <asp:BoundField DataField="Position"   HeaderText="Position" />
                    <asp:BoundField DataField="Email"      HeaderText="Email" />
                    <asp:TemplateField HeaderText="Att. Score">
                        <ItemTemplate>
                            <%# GetAttdScoreBadge(Eval("attdScr")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnDelete" runat="server"
                                CommandName="DeleteStaff"
                                CommandArgument='<%# Eval("StaffID") %>'
                                CssClass="btn btn-sm btn-outline-danger">
                                &#128465; Delete
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- Hidden field holds the StaffID pending deletion -->
    <asp:HiddenField ID="hdnDeleteId" runat="server" />

    <!-- Confirm Delete Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <h6 class="modal-title fw-bold text-danger">&#9888; Confirm Delete</h6>
                </div>
                <div class="modal-body pt-2">
                    <p class="mb-1">Are you sure you want to delete this staff member?</p>
                    <small class="text-muted">This will permanently remove the record from the database.</small>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-sm btn-outline-secondary"
                        data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnConfirmDelete" runat="server"
                        Text="Delete"
                        CssClass="btn btn-sm btn-danger"
                        OnClick="btnConfirmDelete_Click" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        function showDeleteModal() {
            var modal = new bootstrap.Modal(document.getElementById('deleteModal'));
            modal.show();
        }
    </script>
</asp:Content>
