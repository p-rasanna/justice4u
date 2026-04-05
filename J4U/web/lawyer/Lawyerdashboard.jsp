<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("lname");
if (email == null) { response.sendRedirect("${pageContext.request.contextPath}/auth/Login.jsp"); return; }
  int tC=0, pA=0, uH=0, uM=0;
  try (Connection con = DatabaseConfig.getConnection()) {
    try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM casetb c JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? AND c.flag>=1")){
      p.setString(1,email);
      try(ResultSet r = p.executeQuery()){ if(r.next()) tC=r.getInt(1); }
    }
    try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM casetb c LEFT JOIN allotlawyer al ON al.cid=c.cid WHERE c.flag=0 AND (al.lname=? OR al.lname IS NULL)")){
      p.setString(1,email);
      try(ResultSet r = p.executeQuery()){ if(r.next()) pA=r.getInt(1); }
    }
    try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM hearings h JOIN allotlawyer al ON al.cid=h.case_id WHERE al.lname=? AND h.hearing_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)")){
      p.setString(1,email);
      try(ResultSet r = p.executeQuery()){ if(r.next()) uH=r.getInt(1); }
    }
    try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_email=? AND is_read=0 AND type='message'")){
      p.setString(1,email);
      try(ResultSet r = p.executeQuery()){ if(r.next()) uM=r.getInt(1); }
    }
%>
<!DOCTYPE html>
<html lang="en">
<title>Lawyer Dashboard | Justice4U</title>
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Lawyer Dashboard"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="../shared/_topbar.jsp" />
    <jsp:include page="../shared/_sidebar.jsp" />
    <main class="app-main">
      <div class="app-content-header mb-4">
        <div class="container-fluid">
          <div class="row align-items-center">
            <div class="col-sm-6">
              <h2 class="mb-0 text-serif fw-bold">Attorney Portal</h2>
              <p class="text-muted small mb-0">Manage your active casework and procedural calendar</p>
            </div>
            <div class="col-sm-6 text-end d-none d-sm-block">
              <span class="badge badge-gold-subtle px-3 py-2">
                <i class="bi bi-person-workspace me-1"></i> Active Practice
              </span>
            </div>
          </div>
        </div>
      </div>
      <div class="app-content">
        <div class="container-fluid">
          <% if(request.getParameter("msg")!=null){ %>
            <div class="alert alert-success border-0 shadow-none small mb-4 py-3">
              <i class="bi bi-check-circle-fill me-2 text-success"></i>
              <%=request.getParameter("msg")%>
            </div>
          <% } %>
          <div class="row g-4 mb-5">
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Total Matters</div>
                <div class="h2 fw-bold mb-0 text-serif"><%=tC%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Pending Acceptance</div>
                <div class="h2 fw-bold mb-0 text-serif text-gold"><%=pA%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Upcoming Hearings</div>
                <div class="h2 fw-bold mb-0 text-serif text-primary"><%=uH%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">New Messages</div>
                <div class="h2 fw-bold mb-0 text-serif text-success"><%=uM%></div>
              </div>
            </div>
          </div>
          <div class="row g-4">
            <div class="col-lg-12">
              <div class="card border-0 bg-white mb-4">
                <div class="card-header bg-transparent border-0 py-4 px-4 d-flex align-items-center gap-2">
                  <i class="bi bi-shield-fill-check text-gold fs-5"></i>
                  <h5 class="card-title fw-bold mb-0 text-serif">Admin Assigned Cases</h5>
                  <span class="badge bg-secondary-subtle text-secondary ms-auto px-2 py-1" style="font-size:0.65rem;">Requires Your Acceptance</span>
                </div>
                <div class="card-body p-0">
                  <div class="table-responsive">
                    <table class="table align-middle mb-0">
                      <thead>
                        <tr>
                          <th class="ps-4">Matter Title</th>
                          <th>Client</th>
                          <th class="text-end pe-4">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                      <%
                        boolean adminCases=false;
                        try(PreparedStatement p = con.prepareStatement(
                          "SELECT c.cid, c.title, c.cname as client, c.curdate as cdate " +
                          "FROM casetb c " +
                          "JOIN allotlawyer al ON al.cid=c.cid " +
                          "WHERE c.flag=0 AND al.lname=? " +
                          "AND COALESCE(c.assignment_type,'ADMIN')='ADMIN' " +
                          "ORDER BY c.cid DESC"
                        )) {
                          p.setString(1,email);
                          try(ResultSet r=p.executeQuery()){
                            while(r.next()){
                              adminCases=true; int id=r.getInt("cid");
                      %>
                        <tr class="border-light">
                          <td class="ps-4">
                            <div class="fw-semibold text-dark"><%=r.getString("title")%></div>
                            <div class="text-muted small" style="font-size: 0.7rem;">#<%=id%> · <%=r.getString("cdate")%>
                              <span class="badge bg-secondary-subtle text-secondary ms-1" style="font-size:0.55rem;">Admin Routed</span>
                            </div>
                          </td>
                          <td><div class="small fw-medium text-dark"><%=r.getString("client")%></div></td>
                          <td class="text-end pe-4">
                            <div class="btn-group">
                              <a href="<%=request.getContextPath()%>/lawyer/accept_case.jsp?case_id=<%=id%>&action=accept" class="btn btn-sm btn-gold px-3">Accept</a>
                              <a href="<%=request.getContextPath()%>/lawyer/accept_case.jsp?case_id=<%=id%>&action=reject" class="btn btn-sm btn-link text-danger text-decoration-none small ms-2">Reject</a>
                            </div>
                          </td>
                        </tr>
                      <%
                            }
                          }
                        }
                        if(!adminCases){
                      %>
                        <tr>
                          <td colspan="3" class="text-center py-4 text-muted small opacity-50">
                            <i class="bi bi-shield-check fs-3 d-block mb-2"></i>
                            No admin-assigned cases pending.
                          </td>
                        </tr>
                      <% } %>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
              <div class="card border-0 bg-white mb-4">
                <div class="card-header bg-transparent border-0 py-4 px-4 d-flex align-items-center gap-2">
                  <i class="bi bi-person-raised-hand text-primary fs-5"></i>
                  <h5 class="card-title fw-bold mb-0 text-serif">Client Requests</h5>
                  <span class="badge bg-primary-subtle text-primary ms-auto px-2 py-1" style="font-size:0.65rem;">Client-Initiated</span>
                </div>
                <div class="card-body p-0">
                  <div class="table-responsive">
                    <table class="table align-middle mb-0">
                      <thead>
                        <tr>
                          <th class="ps-4">Matter Title</th>
                          <th>Client</th>
                          <th class="text-end pe-4">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                      <%
                        boolean clientReqs=false;
                        try(PreparedStatement p = con.prepareStatement(
                          "SELECT lr.request_id, c.cid, c.title, c.cname as client, c.curdate as cdate " +
                          "FROM lawyer_requests lr " +
                          "JOIN casetb c ON c.cid=lr.case_id " +
                          "WHERE lr.lawyer_email=? AND lr.status='PENDING' " +
                          "ORDER BY lr.created_at DESC"
                        )) {
                          p.setString(1,email);
                          try(ResultSet r=p.executeQuery()){
                            while(r.next()){
                              clientReqs=true;
                              int cid=r.getInt("cid");
                              int reqId=r.getInt("request_id");
                      %>
                        <tr class="border-light">
                          <td class="ps-4">
                            <div class="fw-semibold text-dark"><%=r.getString("title")%></div>
                            <div class="text-muted small" style="font-size: 0.7rem;">#<%=cid%> · <%=r.getString("cdate")%>
                              <span class="badge bg-primary-subtle text-primary ms-1" style="font-size:0.55rem;">Direct Request</span>
                            </div>
                          </td>
                          <td><div class="small fw-medium text-dark"><%=r.getString("client")%></div></td>
                          <td class="text-end pe-4">
                            <div class="btn-group">
                              <a href="<%=request.getContextPath()%>/lawyer/process_client_request.jsp?request_id=<%=reqId%>&action=accept" class="btn btn-sm btn-gold px-3">Accept</a>
                              <a href="<%=request.getContextPath()%>/lawyer/process_client_request.jsp?request_id=<%=reqId%>&action=reject" class="btn btn-sm btn-link text-danger text-decoration-none small ms-2">Reject</a>
                            </div>
                          </td>
                        </tr>
                      <%
                            }
                          }
                        }
                        if(!clientReqs){
                      %>
                        <tr>
                          <td colspan="3" class="text-center py-4 text-muted small opacity-50">
                            <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                            No client requests pending.
                          </td>
                        </tr>
                      <% } %>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
              <div class="card border-0 bg-white mt-4">
                <div class="card-header bg-transparent border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">
                    <i class="bi bi-mortarboard-fill text-gold me-2"></i>Intern Requests
                  </h5>
                </div>
                <div class="card-body p-0">
                  <div class="table-responsive">
                    <table class="table align-middle mb-0">
                      <thead>
                        <tr>
                          <th class="ps-4">Intern</th>
                          <th>Contact</th>
                          <th class="text-end pe-4">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                      <%
                        boolean iRB=false;
                        try(PreparedStatement p = con.prepareStatement(
                          "SELECT ila.id, i.name, i.email, i.mobno, ila.assigned_date " +
                          "FROM intern_lawyer_assignments ila " +
                          "JOIN intern i ON ila.intern_email=i.email " +
                          "WHERE ila.lawyer_email=? AND ila.status='PENDING' " +
                          "ORDER BY ila.assigned_date DESC"
                        )) {
                          p.setString(1,email);
                          try(ResultSet r=p.executeQuery()){
                            while(r.next()){
                              iRB=true;
                              int assignId=r.getInt("id");
                      %>
                        <tr class="border-light">
                          <td class="ps-4">
                            <div class="fw-semibold text-dark"><%=r.getString("name")%></div>
                            <div class="text-muted small" style="font-size: 0.7rem;">
                              Assigned <%=r.getString("assigned_date") != null ? r.getString("assigned_date").substring(0,10) : ""%>
                            </div>
                          </td>
                          <td>
                            <div class="small text-dark"><%=r.getString("email")%></div>
                            <div class="text-muted" style="font-size:0.65rem;"><%=r.getString("mobno") != null ? r.getString("mobno") : ""%></div>
                          </td>
                          <td class="text-end pe-4">
                            <div class="btn-group">
                              <a href="<%=request.getContextPath()%>/lawyer/intern_action.jsp?id=<%=assignId%>&action=accept" class="btn btn-sm btn-gold px-3">Accept</a>
                              <a href="<%=request.getContextPath()%>/lawyer/intern_action.jsp?id=<%=assignId%>&action=reject" class="btn btn-sm btn-link text-danger text-decoration-none small ms-2">Reject</a>
                            </div>
                          </td>
                        </tr>
                      <%
                            }
                          }
                        }
                        if(!iRB){
                      %>
                        <tr>
                          <td colspan="3" class="text-center py-4 text-muted small opacity-50">
                            <i class="bi bi-mortarboard fs-3 d-block mb-2"></i>
                            No pending intern requests.
                          </td>
                        </tr>
                      <% } %>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
    <jsp:include page="../shared/_footer.jsp" />
  </div>
</body>
</html>
<% } catch (Exception e) {
  e.printStackTrace();
  out.println("<div style='color:white;background:red;padding:20px;'><H3>JSP Execution Error:</H3>");
  out.println("<pre>" + e.toString() + "</pre></div>");
} %>