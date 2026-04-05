<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String adminEmail=(String)session.getAttribute("aname");
  if(adminEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
  String msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Manage Lawyers"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="../shared/_topbar.jsp" />
    <jsp:include page="../shared/_sidebar.jsp" />
    <main class="app-main">
      <div class="app-content-header">
        <div class="container-fluid">
          <div class="row">
            <div class="col-sm-6">
              <h3 class="mb-0 text-serif">Lawyer Management</h3>
            </div>
            <div class="col-sm-6 text-end">
              <ol class="breadcrumb float-sm-end">
                <li class="breadcrumb-item"><a href="admindashboard.jsp" class="text-gold">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">Lawyers</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
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
              <h3 class="card-title text-serif"><i class="bi bi-briefcase-fill text-gold me-2"></i> Pending Lawyer Applications</h3>
            </div>
            <div class="card-body p-0">
              <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                  <thead class="table-light text-secondary small text-uppercase">
                    <tr>
                      <th class="ps-4">ID</th>
                      <th>Lawyer Name</th>
                      <th>Specialization</th>
                      <th>Payment</th>
                      <th>Documents</th>
                      <th class="text-end pe-4">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%
                    try(Connection con=DatabaseConfig.getConnection()){
                      PreparedStatement ps=con.prepareStatement("SELECT lid, name, email, specialization, amt, document_verification_status FROM lawyer_reg WHERE flag=0 ORDER BY lid DESC");
                      ResultSet rs=ps.executeQuery(); boolean none=true;
                      while(rs.next()){
                        none=false; String name=rs.getString(2), ds=rs.getString(6), pay=rs.getString(5);
                        int id = rs.getInt(1);
                    %>
                    <tr>
                      <td class="ps-4 text-secondary">#<%=id%></td>
                      <td>
                        <div class="fw-bold"><%=name%></div>
                        <div class="small text-muted"><%=rs.getString(3)%></div>
                      </td>
                      <td>
                        <span class="badge bg-gold-light text-gold py-1 px-2 border border-gold">
                          <%=rs.getString(4)%>
                        </span>
                      </td>
                      <td>
                        <% if(pay!=null && !pay.equals("0")){ %>
                          <span class="badge bg-success-subtle text-success border border-success">
                            <i class="bi bi-check2 me-1"></i> Paid
                          </span>
                        <% } else { %>
                          <span class="badge bg-secondary-subtle text-secondary border border-secondary">
                            Unpaid
                          </span>
                        <% } %>
                      </td>
                      <td>
                        <% if("VERIFIED".equals(ds)){ %>
                          <span class="text-success small fw-bold">
                            <i class="bi bi-patch-check-fill me-1"></i> Verified
                          </span>
                        <% } else { %>
                          <span class="text-warning small fw-bold">
                            <i class="bi bi-clock-history me-1"></i> Pending
                          </span>
                        <% } %>
                      </td>
                      <td class="text-end pe-4">
                        <div class="btn-group">
                          <% if("VERIFIED".equals(ds)){ %>
                            <a href="user_action.jsp?type=lawyer&action=approve&id=<%=id%>" class="btn btn-sm btn-gold px-3">Approve</a>
                          <% } else { %>
                            <a href="viewlawyerdocuments.jsp?id=<%=id%>" class="btn btn-sm btn-outline-dark">Review Docs</a>
                          <% } %>
                          <a href="user_action.jsp?type=lawyer&action=reject&id=<%=id%>" class="btn btn-sm btn-outline-danger ms-2">Reject</a>
                        </div>
                      </td>
                    </tr>
                    <% } if(none){ %>
                    <tr>
                      <td colspan="6" class="text-center py-5 text-muted">
                        <i class="bi bi-inbox fs-1 d-block mb-2 opacity-25"></i>
                        No pending lawyer applications found.
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