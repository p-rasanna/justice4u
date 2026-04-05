<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String iEmail=(String)session.getAttribute("iname");
  if(iEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
  String lawyerEmail=null, lawyerName=null;
  String assignStatus=null;
  java.util.List<String[]> cases=new java.util.ArrayList<>();
  try(Connection con=DatabaseConfig.getConnection()){
    String internName = iEmail;
    try(PreparedStatement pn=con.prepareStatement("SELECT name FROM intern WHERE email=?")){
      pn.setString(1,iEmail);
      ResultSet rn=pn.executeQuery();
      if(rn.next() && rn.getString(1)!=null) internName=rn.getString(1);
    }
    PreparedStatement ps=con.prepareStatement(
      "SELECT ila.status, ila.lawyer_email, lr.name as lawyer_name " +
      "FROM intern_lawyer_assignments ila " +
      "JOIN lawyer_reg lr ON ila.lawyer_email=lr.email " +
      "WHERE ila.intern_email=? AND ila.status IN ('PENDING','ACCEPTED') " +
      "ORDER BY ila.assigned_date DESC LIMIT 1"
    );
    ps.setString(1,iEmail);
    ResultSet rs=ps.executeQuery();
    if(rs.next()){
      assignStatus=rs.getString("status");
      lawyerEmail=rs.getString("lawyer_email");
      lawyerName=rs.getString("lawyer_name");
    }
    if("ACCEPTED".equals(assignStatus) && lawyerEmail!=null){
      PreparedStatement pc=con.prepareStatement(
        "SELECT c.cid, c.title, c.cname as client, c.courttype, c.city, c.curdate, c.flag " +
        "FROM casetb c " +
        "JOIN allotlawyer al ON al.cid=c.cid " +
        "WHERE al.lname=? AND c.flag>=1 " +
        "ORDER BY c.cid DESC"
      );
      pc.setString(1, lawyerEmail);
      ResultSet rc=pc.executeQuery();
      while(rc.next()){
        cases.add(new String[]{
          String.valueOf(rc.getInt("cid")),
          rc.getString("title"),
          rc.getString("client"),
          rc.getString("courttype") != null ? rc.getString("courttype") : "",
          rc.getString("city") != null ? rc.getString("city") : "",
          rc.getString("curdate") != null ? rc.getString("curdate") : "",
          rc.getInt("flag") == 1 ? "ACTIVE" : "CLOSED"
        });
      }
    }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Intern Dashboard"/>
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
              <h2 class="mb-0 text-serif fw-bold">Intern Workspace</h2>
              <p class="text-muted small mb-0">Your legal practice training portal</p>
            </div>
            <div class="col-sm-6 text-end d-none d-sm-block">
              <span class="badge badge-gold-subtle px-3 py-2">
                <i class="bi bi-mortarboard-fill me-1"></i>
                <%= "ACCEPTED".equals(assignStatus) ? "Active Placement" : "Pending Placement" %>
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
            <div class="col-12 col-sm-6 col-md-4">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Assignment Status</div>
                <div class="h4 fw-bold mb-0 text-serif">
                  <% if("ACCEPTED".equals(assignStatus)){ %>
                    <span class="text-success"><i class="bi bi-check-circle-fill me-1"></i> Accepted</span>
                  <% } else if("PENDING".equals(assignStatus)){ %>
                    <span class="text-warning"><i class="bi bi-clock-fill me-1"></i> Pending</span>
                  <% } else { %>
                    <span class="text-muted"><i class="bi bi-dash-circle me-1"></i> Unassigned</span>
                  <% } %>
                </div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Supervising Lawyer</div>
                <div class="h4 fw-bold mb-0 text-serif"><%= lawyerName != null ? lawyerName : "—" %></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-4">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Active Cases</div>
                <div class="h2 fw-bold mb-0 text-serif text-gold"><%= cases.size() %></div>
              </div>
            </div>
          </div>
          <% if(assignStatus == null){ %>
            <div class="card border-0 bg-white">
              <div class="card-body text-center py-5">
                <i class="bi bi-hourglass-split fs-1 d-block mb-3 text-muted opacity-25"></i>
                <h4 class="text-serif fw-bold mb-2">Awaiting Assignment</h4>
                <p class="text-muted small mb-0">The admin has not yet assigned you to a lawyer.<br>You will be notified when an assignment is made.</p>
              </div>
            </div>
          <% } else if("PENDING".equals(assignStatus)){ %>
            <div class="card border-0 bg-white">
              <div class="card-body text-center py-5">
                <i class="bi bi-clock-history fs-1 d-block mb-3 text-warning"></i>
                <h4 class="text-serif fw-bold mb-2">Waiting for Lawyer Approval</h4>
                <p class="text-muted small mb-0">
                  You have been assigned to <strong><%= lawyerName %></strong>.<br>
                  Waiting for the lawyer to accept your placement.<br>
                  You will gain case access once approved.
                </p>
              </div>
            </div>
          <% } else if("ACCEPTED".equals(assignStatus)){ %>
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-0 bg-white">
                  <div class="card-header bg-transparent border-0 py-4 px-4 d-flex justify-content-between align-items-center">
                    <h5 class="card-title fw-bold mb-0 text-serif">My Cases</h5>
                    <span class="badge badge-gold-subtle px-2 py-1 small"><%= cases.size() %> matters</span>
                  </div>
                  <div class="card-body p-0">
                    <div class="table-responsive">
                      <table class="table align-middle mb-0">
                        <thead>
                          <tr>
                            <th class="ps-4">Case</th>
                            <th>Client</th>
                            <th>Status</th>
                            <th class="text-end pe-4">Actions</th>
                          </tr>
                        </thead>
                        <tbody>
                        <% if(cases.isEmpty()){ %>
                          <tr>
                            <td colspan="4" class="text-center py-5 text-muted small opacity-50">
                              <i class="bi bi-briefcase fs-2 d-block mb-2"></i>
                              No active cases yet. Your lawyer has no accepted cases.
                            </td>
                          </tr>
                        <% } else { for(String[] c : cases){ %>
                          <tr class="border-light">
                            <td class="ps-4">
                              <div class="fw-semibold text-dark"><%= c[1] %></div>
                              <div class="text-muted small" style="font-size:0.7rem;">
                                #<%= c[0] %> &middot; <%= c[3] %> &middot; <%= c[4] %>
                              </div>
                            </td>
                            <td>
                              <div class="small fw-medium text-dark"><%= c[2] %></div>
                            </td>
                            <td>
                              <span class="badge badge-gold-subtle px-2 py-1 text-uppercase fw-bold" style="font-size:0.6rem;"><%= c[6] %></span>
                            </td>
                            <td class="text-end pe-4">
                              <div class="btn-group">
                                <a href="viewcase_intern.jsp?cid=<%= c[0] %>" class="btn btn-sm btn-outline-dark border-0 px-2" title="View Case"><i class="bi bi-eye"></i></a>
                                <a href="<%=request.getContextPath()%>/shared/caseDiscussion.jsp?case_id=<%= c[0] %>" class="btn btn-sm btn-outline-gold border-0 px-2" title="Discussion"><i class="bi bi-chat-dots-fill"></i></a>
                              </div>
                            </td>
                          </tr>
                        <% } } %>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-lg-4">
                <div class="card border-0 bg-white mb-4">
                  <div class="card-header bg-transparent border-0 py-4 px-4">
                    <h5 class="card-title fw-bold mb-0 text-serif">My Assigned Lawyer</h5>
                  </div>
                  <div class="card-body px-4 pb-4 pt-0">
                    <div class="d-flex align-items-center gap-3 mb-3">
                      <div class="bg-gold-light text-gold rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:48px; height:48px; font-size:1.2rem;">
                        <%= lawyerName != null ? lawyerName.substring(0,1).toUpperCase() : "?" %>
                      </div>
                      <div>
                        <div class="fw-bold text-dark"><%= lawyerName %></div>
                        <div class="text-muted small"><%= lawyerEmail %></div>
                      </div>
                    </div>
                    <div class="border-top pt-3">
                      <div class="d-flex justify-content-between small mb-2">
                        <span class="text-muted">Status</span>
                        <span class="fw-bold text-success"><i class="bi bi-check-circle-fill me-1"></i>Active</span>
                      </div>
                      <div class="d-flex justify-content-between small">
                        <span class="text-muted">Cases Assigned</span>
                        <span class="fw-bold"><%= cases.size() %></span>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="card border-0 bg-white">
                  <div class="card-header bg-transparent border-0 py-4 px-4">
                    <h5 class="card-title fw-bold mb-0 text-serif">Quick Access</h5>
                  </div>
                  <div class="card-body px-4 pb-4 pt-0">
                    <div class="d-grid gap-2">
                      <a href="<%=request.getContextPath()%>/shared/caseDiscussions.jsp" class="btn btn-outline-dark btn-sm py-2">
                        <i class="bi bi-chat-left-text me-1"></i> Case Discussions
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          <% } %>
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