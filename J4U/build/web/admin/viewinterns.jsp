<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String adminEmail=(String)session.getAttribute("aname");
  if(adminEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
  String msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Manage Interns"/>
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
              <h3 class="mb-0 text-serif">Intern Management</h3>
            </div>
            <div class="col-sm-6 text-end">
              <ol class="breadcrumb float-sm-end">
                <li class="breadcrumb-item"><a href="admindashboard.jsp" class="text-gold">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">Interns</li>
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
              <h3 class="card-title text-serif"><i class="bi bi-mortarboard-fill text-gold me-2"></i> Pending Intern Applications</h3>
            </div>
            <div class="card-body p-0">
              <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                  <thead class="table-light text-secondary small text-uppercase">
                    <tr>
                      <th class="ps-4">ID</th>
                      <th>Intern Details</th>
                      <th>Institution</th>
                      <th>Payment</th>
                      <th>Status</th>
                      <th class="text-end pe-4">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%
                    try(Connection con=DatabaseConfig.getConnection()){
                      PreparedStatement ps=con.prepareStatement("SELECT internid, name, email, cadd as institution, amt, flag FROM intern WHERE flag=0 ORDER BY internid DESC");
                      ResultSet rs=ps.executeQuery(); boolean none=true;
                      while(rs.next()){
                        none=false;
                        String pay=rs.getString(5);
                        int id = rs.getInt(1);
                    %>
                    <tr>
                      <td class="ps-4 text-secondary">#<%=id%></td>
                      <td>
                        <div class="fw-bold"><%=rs.getString(2)%></div>
                        <div class="small text-muted"><%=rs.getString(3)%></div>
                      </td>
                      <td class="small"><%=rs.getString(4)%></td>
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
                        <span class="text-warning small fw-bold">
                          <i class="bi bi-clock-history me-1"></i> Pending
                        </span>
                      </td>
                      <td class="text-end pe-4">
                        <div class="btn-group">
                          <a href="user_action.jsp?type=intern&action=approve&id=<%=id%>" class="btn btn-sm btn-gold px-3">Approve</a>
                          <a href="user_action.jsp?type=intern&action=reject&id=<%=id%>" class="btn btn-sm btn-outline-danger ms-2">Reject</a>
                        </div>
                      </td>
                    </tr>
                    <% } if(none){ %>
                    <tr>
                      <td colspan="6" class="text-center py-5 text-muted">
                        <i class="bi bi-mortarboard fs-1 d-block mb-2 opacity-25"></i>
                        No pending intern applications found.
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