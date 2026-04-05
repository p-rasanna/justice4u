<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  if(session.getAttribute("aname")==null){response.sendRedirect("../auth/Login.jsp");return;}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Pending Cases"/>
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
              <h3 class="mb-0 text-serif">Case Allocation</h3>
            </div>
            <div class="col-sm-6 text-end">
              <ol class="breadcrumb float-sm-end">
                <li class="breadcrumb-item"><a href="admindashboard.jsp" class="text-gold">Dashboard</a></li>
                <li class="breadcrumb-item active" aria-current="page">Allocations</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
      <div class="app-content">
        <div class="container-fluid">
          <div class="card shadow-sm">
            <div class="card-header border-0 bg-transparent">
              <h3 class="card-title text-serif"><i class="bi bi-journal-text text-gold me-2"></i> Pending Case Allocations</h3>
            </div>
            <div class="card-body p-0">
              <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                  <thead class="table-light text-secondary small text-uppercase">
                    <tr>
                      <th class="ps-4">ID</th>
                      <th>Client/Name</th>
                      <th>Case Title</th>
                      <th>Court Type</th>
                      <th>City</th>
                      <th>Date</th>
                      <th class="text-end pe-4">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%
                      boolean hC=false;
                      try(Connection con=DatabaseConfig.getConnection()){
                        String sql="SELECT cid, cname, title, cdate, court_type, city FROM casetb WHERE status='PENDING' ORDER BY cid DESC";
                        try(PreparedStatement ps=con.prepareStatement(sql); ResultSet rs=ps.executeQuery()){
                          while(rs.next()){
                            hC=true; String cId=rs.getString("cid");
                            String clientName = rs.getString("cname");
                    %>
                    <tr>
                      <td class="ps-4 text-secondary">#<%=cId%></td>
                      <td class="fw-bold"><%=clientName%></td>
                      <td class="text-dark"><%=rs.getString("title")%></td>
                      <td>
                        <span class="badge bg-gold-light text-gold border border-gold">
                          <%=rs.getString("court_type")%>
                        </span>
                      </td>
                      <td><%=rs.getString("city")%></td>
                      <td class="small text-muted"><%=rs.getString("cdate")%></td>
                      <td class="text-end pe-4">
                        <a href="allotlawyer.jsp?id=<%=cId%>&cemail=<%=clientName%>" class="btn btn-sm btn-gold px-3">
                          <i class="bi bi-person-check me-1"></i> Allot
                        </a>
                      </td>
                    </tr>
                    <% } } catch(Exception ignored){
                      try(PreparedStatement ps=con.prepareStatement("SELECT cid, name as cname, title, curdate as cdate, courttype as court_type, city FROM casetb WHERE status='PENDING' ORDER BY cid DESC"); ResultSet rs=ps.executeQuery()){
                        while(rs.next()){
                          hC=true; String cId=rs.getString("cid");
                          String clientName = rs.getString("cname");
                    %>
                    <tr>
                      <td class="ps-4 text-secondary">#<%=cId%></td>
                      <td class="fw-bold"><%=clientName%></td>
                      <td class="text-dark"><%=rs.getString("title")%></td>
                      <td>
                        <span class="badge bg-gold-light text-gold border border-gold">
                          <%=rs.getString("court_type")%>
                        </span>
                      </td>
                      <td><%=rs.getString("city")%></td>
                      <td class="small text-muted"><%=rs.getString("cdate")%></td>
                      <td class="text-end pe-4">
                        <a href="allotlawyer.jsp?id=<%=cId%>&cemail=<%=clientName%>" class="btn btn-sm btn-gold px-3">
                          <i class="bi bi-person-check me-1"></i> Allot
                        </a>
                      </td>
                    </tr>
                    <% } } } } catch(Exception e){} if(!hC){ %>
                    <tr>
                      <td colspan="7" class="text-center py-5 text-muted">
                        <i class="bi bi-check-circle fs-1 d-block mb-2 opacity-25"></i>
                        No pending cases to allot.
                      </td>
                    </tr>
                    <% } %>
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