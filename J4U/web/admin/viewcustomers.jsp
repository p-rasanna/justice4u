<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String adminEmail=(String)session.getAttribute("aname"); 
    if(adminEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
    String msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Manage Clients"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_topbar.jsp" />
        <jsp:include page="../shared/_sidebar.jsp" />
        
        <main class="app-main">
            <!-- Content Header -->
            <div class="app-content-header">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-sm-6">
                            <h3 class="mb-0 text-serif">Client Directory</h3>
                        </div>
                        <div class="col-sm-6 text-end">
                            <ol class="breadcrumb float-sm-end">
                                <li class="breadcrumb-item"><a href="admindashboard.jsp" class="text-gold">Dashboard</a></li>
                                <li class="breadcrumb-item active" aria-current="page">Clients</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Body -->
            <div class="app-content">
                <div class="container-fluid">
                    <% if(msg!=null){ %>
                    <div class="alert alert-warning alert-dismissible fade show shadow-sm border-0 mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        <%=msg%>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <% } %>

                    <div class="card shadow-sm">
                        <div class="card-header border-0 bg-transparent">
                            <h3 class="card-title text-serif"><i class="bi bi-person-lines-fill text-gold me-2"></i> Registered Accounts</h3>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light text-secondary small text-uppercase">
                                        <tr>
                                            <th class="ps-4">ID</th>
                                            <th>Client Details</th>
                                            <th>Mobile</th>
                                            <th>Status</th>
                                            <th class="text-end pe-4">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        try(Connection con=DatabaseConfig.getConnection()){
                                            PreparedStatement ps=con.prepareStatement("SELECT cid, cname, email, mobno, verification_status FROM cust_reg ORDER BY cid DESC");
                                            ResultSet rs=ps.executeQuery(); boolean none=true;
                                            while(rs.next()){ 
                                                none=false; 
                                                String st=rs.getString("verification_status");
                                                String badgeClass = "bg-warning-subtle text-warning border-warning";
                                                String icon = "bi-clock-history";
                                                
                                                if("APPROVED".equals(st)||"VERIFIED".equals(st)){ 
                                                    badgeClass = "bg-success-subtle text-success border-success"; 
                                                    icon = "bi-check-circle-fill"; 
                                                }
                                                else if("REJECTED".equals(st)){ 
                                                    badgeClass = "bg-danger-subtle text-danger border-danger"; 
                                                    icon = "bi-x-circle-fill"; 
                                                }
                                                int id = rs.getInt(1);
                                                String email = rs.getString(3);
                                        %>
                                        <tr>
                                            <td class="ps-4 text-secondary">#<%=id%></td>
                                            <td>
                                                <div class="fw-bold"><%=rs.getString(2)%></div>
                                                <div class="small text-muted"><%=email%></div>
                                            </td>
                                            <td class="small"><%=rs.getString(4)%></td>
                                            <td>
                                                <span class="badge border <%=badgeClass%> py-1 px-2">
                                                    <i class="bi <%=icon%> me-1"></i> <%=st%>
                                                </span>
                                            </td>
                                            <td class="text-end pe-4">
                                                <div class="btn-group">
                                                    <% if("PENDING".equals(st)){ %>
                                                        <a href="user_action.jsp?type=client&action=approve&id=<%=id%>" class="btn btn-sm btn-gold px-3">Approve</a>
                                                        <a href="user_action.jsp?type=client&action=reject&id=<%=id%>" class="btn btn-sm btn-outline-danger ms-2">Reject</a>
                                                    <% } else if("APPROVED".equals(st)||"VERIFIED".equals(st)){ %>
                                                        <a href="allotlawyer.jsp?cemail=<%=email%>" class="btn btn-sm btn-outline-gold">
                                                            <i class="bi bi-person-plus me-1"></i> Allot Lawyer
                                                        </a>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } if(none){ %>
                                        <tr>
                                            <td colspan="5" class="text-center py-5 text-muted">
                                                <i class="bi bi-people fs-1 d-block mb-2 opacity-25"></i>
                                                No registered clients found.
                                            </td>
                                        </tr>
                                        <% } } catch(Exception e){} %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent border-0 py-3">
                            <nav aria-label="Page navigation">
                                <ul class="pagination pagination-sm mb-0 justify-content-end">
                                    <li class="page-item disabled"><a class="page-link" href="#">Previous</a></li>
                                    <li class="page-item active" aria-current="page"><a class="page-link" href="#">1</a></li>
                                    <li class="page-item"><a class="page-link" href="#">Next</a></li>
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        
        <jsp:include page="../shared/_footer.jsp" />
    </div>
</body>
</html>


