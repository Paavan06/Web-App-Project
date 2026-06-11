<%@ Page Title="" Language="C#"
    MasterPageFile="~/Staff/Site.Mobile.Master"
    AutoEventWireup="true"
    CodeBehind="MyAttendance.aspx.cs"
    Inherits="Web_App_Project.MyAttendance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .att-table th {
        font-size: 11px; font-weight: 700; letter-spacing: .06em; color: #9ca3af;
        text-transform: uppercase; border-bottom: 1px solid #f3f4f6; padding: 10px 14px;
    }
    .att-table td { font-size: 13px; padding: 13px 14px; vertical-align: middle; border-bottom: 1px solid #f9fafb; }
    .att-table tbody tr:hover { background: #fafafa; }

    .checkin-val  { font-weight: 700; color: #111827; font-size: 14px; }
    .checkout-val { color: #0d9488; font-size: 14px; }
    .workhrs-val  { color: #6b7280; font-size: 13px; }

    .badge-present    { background:#dcfce7; color:#15803d; font-size:11px; padding:4px 12px; border-radius:20px; font-weight:600; }
    .badge-incomplete { background:#fef9c3; color:#a16207; font-size:11px; padding:4px 12px; border-radius:20px; font-weight:600; }

    .date-badge {
        background:#f4f6f9; border:1px solid #e5e7eb; border-radius:8px;
        padding:5px 12px; font-size:12px; color:#6b7280; font-weight:500;
        display:inline-flex; align-items:center; gap:6px;
    }
</style>
</asp:Content>

<asp:Content ID="ContentTitle" ContentPlaceHolderID="PageTitle" runat="server">
    My Attendance
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== PAGE HEADER ===== -->
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h4 class="fw-bold mb-0">My Attendance</h4>
            <p class="text-muted small mb-0">Your clock-in and clock-out history</p>
        </div>
        <span class="date-badge">
            &#128197; <asp:Label ID="lblDateBadge" runat="server" />
        </span>
    </div>

    <!-- ===== RECORDS CARD ===== -->
    <div class="card border-0 shadow-sm rounded-3 p-3">
        <h6 class="fw-bold mb-3">My Records</h6>

        <div class="table-responsive">
            <asp:GridView ID="gvAttendance" runat="server"
                CssClass="table att-table mb-0 w-100"
                AutoGenerateColumns="false"
                GridLines="None"
                EmptyDataText="No attendance records found."
                EmptyDataRowStyle-CssClass="text-center text-muted small py-4"
                OnRowCommand="gvAttendance_RowCommand">
                <HeaderStyle CssClass="table-header" />
                <Columns>

                    <asp:BoundField DataField="AttendDate" HeaderText="DATE"
                        DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="false" />

                    <asp:TemplateField HeaderText="CLOCK IN">
                        <ItemTemplate>
                            <span class="checkin-val"><%# Eval("ClockIn") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="CLOCK OUT">
                        <ItemTemplate>
                            <span class="checkout-val"><%# Eval("ClockOut") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="WORK HOURS">
                        <ItemTemplate>
                            <span class="workhrs-val"><%# Eval("WorkHours") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="STATUS">
                        <ItemTemplate>
                            <%# GetStatusBadge(Eval("DisplayStatus").ToString()) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbDelete" runat="server"
                                CommandName="DeleteAtt"
                                CommandArgument='<%# Eval("AttendanceID") %>'
                                CssClass="btn btn-outline-danger btn-sm"
                                Visible='<%# Convert.ToDateTime(Eval("AttendDate")).Date == DateTime.Today %>'
                                OnClientClick="return confirm('Delete today\'s attendance? You will be able to clock in again.');"
                                Text="Delete" />
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
            </asp:GridView>
        </div>
    </div>

</asp:Content>
