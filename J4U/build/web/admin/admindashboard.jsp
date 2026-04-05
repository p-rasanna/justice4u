<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String adminEmail=(String)session.getAttribute("aname");
if(adminEmail==null){response.sendRedirect("${pageContext.request.contextPath}/auth/Login.jsp");return;}
  int pClient=0, pLawyer=0, pIntern=0, openC=0, assigC=0, ipC=0, closedC=0;
  java.util.List<String[]> timeline=new java.util.ArrayList<>();
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement ps; ResultSet rs;
    ps=con.prepareStatement("SELECT COUNT(*) FROM cust_reg WHERE verification_status='PENDING'");
    rs=ps.executeQuery(); if(rs.next()) pClient=rs.getInt(1);
    ps=con.prepareStatement("SELECT COUNT(*) FROM lawyer_reg WHERE flag=0");
    rs=ps.executeQuery(); if(rs.next()) pLawyer=rs.getInt(1);
    ps=con.prepareStatement("SELECT COUNT(*) FROM intern WHERE flag=0");
    rs=ps.executeQuery(); if(rs.next()) pIntern=rs.getInt(1);
    ps=con.prepareStatement("SELECT status, COUNT(*) FROM casetb GROUP BY status");
    rs=ps.executeQuery();
    while(rs.next()){
      String s=rs.getString(1); int c=rs.getInt(2);
      if("OPEN".equalsIgnoreCase(s)) openC=c;
      else if("ASSIGNED".equalsIgnoreCase(s)) assigC=c;
      else if("IN_PROGRESS".equalsIgnoreCase(s)||"COMPLETED".equalsIgnoreCase(s)) ipC+=c;
      else if("CLOSED".equalsIgnoreCase(s)) closedC=c;
    }
    try{
      ps=con.prepareStatement("SELECT event_type, event_description, created_at FROM case_timeline ORDER BY created_at DESC LIMIT 5");
      rs=ps.executeQuery();
      while(rs.next()) timeline.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3).substring(0,16)});
    }catch(Exception e){}
  }catch(Exception e){e.printStackTrace();}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Admin Dashboard"/>
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
              <h2 class="mb-0 text-serif fw-bold">Admin Console</h2>
              <p class="text-muted small mb-0">System performance and oversight overview</p>
            </div>
            <div class="col-sm-6 text-end d-none d-sm-block">
              <span class="badge badge-gold-subtle px-3 py-2">
                <i class="bi bi-shield-check me-1"></i> System Secured
              </span>
            </div>
          </div>
        </div>
      </div>
      <div class="app-content">
        <div class="container-fluid">
          <div class="row g-4 mb-5">
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Pending Clients</div>
                <div class="h2 fw-bold mb-0 text-serif"><%=pClient%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Legal Counsel</div>
                <div class="h2 fw-bold mb-0 text-serif text-gold"><%=pLawyer%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Intern Program</div>
                <div class="h2 fw-bold mb-0 text-serif"><%=pIntern%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Active Matters</div>
                <div class="h2 fw-bold mb-0 text-serif text-success"><%=openC%></div>
              </div>
            </div>
          </div>
          <div class="row g-4">
            <div class="col-lg-8">
              <div class="card border-0 bg-white mb-4">
                <div class="card-header bg-transparent border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">Pending Authorization</h5>
                </div>
                <div class="card-body p-0">
                  <div class="table-responsive">
                    <table class="table align-middle mb-0">
                      <thead>
                        <tr>
                          <th class="ps-4">Entity Identity</th>
                          <th>Classification</th>
                          <th class="text-end pe-4">Procedural Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        <%
                        try(Connection c2=DatabaseConfig.getConnection()){
                          PreparedStatement ps2=c2.prepareStatement("SELECT lid, name, 'Lawyer' as type FROM lawyer_reg WHERE flag=0 LIMIT 6");
                          ResultSet rs2=ps2.executeQuery(); boolean none=true;
                          while(rs2.next()){
                            none=false; String name=rs2.getString(2); if(name==null) name="User #"+rs2.getInt(1);
                            String type = rs2.getString(3);
                            int id = rs2.getInt(1);
                        %>
                        <tr class="border-light">
                          <td class="ps-4">
                            <div class="d-flex align-items-center gap-3 py-1">
                              <div class="bg-gold-light text-gold rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:36px; height:36px; font-size:0.85rem;">
                                <%=name.substring(0,1).toUpperCase()%>
                              </div>
                              <div class="fw-semibold text-dark"><%=name%></div>
                            </div>
                          </td>
                          <td>
                            <span class="badge <%= "Client".equals(type) ? "badge-gold-subtle" : "bg-dark text-white" %> px-2 py-1">
                              <%=type%>
                            </span>
                          </td>
                          <td class="text-end pe-4">
                            <div class="btn-group">
                              <a href="user_action.jsp?type=<%=type.toLowerCase()%>&action=approve&id=<%=id%>" class="btn btn-sm btn-outline-success border-0 px-2">
                                <i class="bi bi-check-lg"></i>
                              </a>
                              <a href="user_action.jsp?type=<%=type.toLowerCase()%>&action=reject&id=<%=id%>" class="btn btn-sm btn-outline-danger border-0 px-2 ms-2">
                                <i class="bi bi-x-lg"></i>
                              </a>
                            </div>
                          </td>
                        </tr>
                        <% } if(none){ %>
                        <tr>
                          <td colspan="3" class="text-center py-5 text-muted small opacity-50">
                            <i class="bi bi-patch-check fs-2 d-block mb-2"></i>
                            Queue Cleared. No pending items.
                          </td>
                        </tr>
                        <% } } catch(Exception e){} %>
                      </tbody>
                    </table>
                  </div>
                </div>
                <div class="card-footer bg-transparent border-0 text-center py-3">
                  <a href="<%=request.getContextPath()%>/admin/viewlawyers.jsp" class="text-gold small fw-bold text-decoration-none">Review Full Registry <i class="bi bi-arrow-right ms-1"></i></a>
                </div>
              </div>
              <div class="card border-0 bg-white">
                <div class="card-header bg-transparent border-0 py-4 px-4 d-flex align-items-center gap-2">
                  <i class="bi bi-person-lines-fill text-gold fs-5"></i>
                  <h5 class="card-title fw-bold mb-0 text-serif">Admin Assignment Queue</h5>
                  <span class="badge bg-warning-subtle text-warning ms-auto px-2 py-1" style="font-size:0.65rem;">
                    <i class="bi bi-exclamation-triangle-fill me-1"></i>Needs Lawyer
                  </span>
                </div>
                <div class="card-body p-0">
                  <div class="table-responsive">
                    <table class="table align-middle mb-0">
                      <thead>
                        <tr>
                          <th class="ps-4">Case</th>
                          <th>Client</th>
                          <th>Court</th>
                          <th class="text-end pe-4">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                      <%
                        boolean queueEmpty = true;
                        try(Connection c3 = DatabaseConfig.getConnection()){
                          PreparedStatement ps3 = c3.prepareStatement(
                            "SELECT c.cid, c.title, c.cname as client_email, c.courttype, " +
                            "COALESCE(c.case_status,'PENDING') as cstatus " +
                            "FROM casetb c " +
                            "LEFT JOIN allotlawyer al ON al.cid=c.cid " +
                            "WHERE COALESCE(c.assignment_type,'ADMIN')='ADMIN' " +
                            "AND c.flag=0 AND al.alid IS NULL " +
                            "ORDER BY c.cid DESC LIMIT 8"
                          );
                          ResultSet rs3 = ps3.executeQuery();
                          while(rs3.next()){
                            queueEmpty = false;
                            int    qcid    = rs3.getInt("cid");
                            String qtitle  = rs3.getString("title");
                            String qclient = rs3.getString("client_email");
                            String qcourt  = rs3.getString("courttype");
                            String qstatus = rs3.getString("cstatus");
                      %>
                        <tr class="border-light">
                          <td class="ps-4">
                            <div class="fw-semibold text-dark"><%=qtitle%></div>
                            <div class="text-muted" style="font-size:0.7rem;">#<%=qcid%>
                              <span class="badge bg-warning-subtle text-warning ms-1" style="font-size:0.55rem;"><%=qstatus%></span>
                            </div>
                          </td>
                          <td><div class="small text-dark fw-medium"><%=qclient%></div></td>
                          <td><div class="small text-muted"><%=qcourt != null ? qcourt : "—"%></div></td>
                          <td class="text-end pe-4">
                            <a href="<%=request.getContextPath()%>/admin/allotlawyer.jsp?id=<%=qcid%>"
                               class="btn btn-sm btn-gold px-3 fw-semibold">
                              <i class="bi bi-person-check me-1"></i>Assign
                            </a>
                          </td>
                        </tr>
                      <%
                          }
                        } catch(Exception e3){ e3.printStackTrace(); }
                        if(queueEmpty){
                      %>
                        <tr>
                          <td colspan="4" class="text-center py-5 text-muted small opacity-50">
                            <i class="bi bi-check2-all fs-2 d-block mb-2"></i>
                            All admin-flow cases have been assigned.
                          </td>
                        </tr>
                      <% } %>
                      </tbody>
                    </table>
                  </div>
                </div>
                <div class="card-footer bg-transparent border-0 text-center py-3">
                  <a href="<%=request.getContextPath()%>/admin/viewcases.jsp" class="text-gold small fw-bold text-decoration-none">Full Case Repository <i class="bi bi-arrow-right ms-1"></i></a>
                </div>
              </div>
            </div>
            <div class="col-lg-4">
              <div class="card border-0 bg-white mb-4">
                <div class="card-header bg-transparent border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">Quick Directives</h5>
                </div>
                <div class="card-body px-4 pt-0">
                  <div class="d-grid gap-2">
                    <a href="<%=request.getContextPath()%>/admin/allotlawyer.jsp" class="btn btn-gold btn-sm py-2 mb-2">
                      Assign Legal Counsel
                    </a>
                    <a href="<%=request.getContextPath()%>/admin/assign_intern_to_lawyer.jsp" class="btn btn-outline-dark btn-sm py-2 mb-2">
                      <i class="bi bi-mortarboard me-1"></i> Assign Intern to Lawyer
                    </a>
                    <a href="<%=request.getContextPath()%>/admin/viewcases.jsp" class="btn btn-primary btn-sm py-2">
                      Case Repository
                    </a>
                  </div>
                </div>
              </div>
              <div class="card border-0 bg-white">
                <div class="card-header bg-transparent border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">Recent Pulse</h5>
                </div>
                <div class="card-body p-0">
                  <% if(timeline.isEmpty()){ %>
                    <div class="p-4 text-center small text-muted opacity-50">No pulse detected.</div>
                  <% } else { %>
                    <div class="px-4 pb-4">
                      <% for(String[] evt:timeline){ %>
                      <div class="d-flex gap-3 mb-4 last-child-mb-0">
                        <div class="text-gold opacity-50 small"><i class="bi bi-circle-fill" style="font-size: 8px;"></i></div>
                        <div class="flex-grow-1 border-start ps-3" style="border-left: 1px solid var(--border) !important;">
                          <div class="d-flex justify-content-between align-items-start mb-1">
                            <span class="fw-bold small text-dark"><%=evt[0].replace("_"," ")%></span>
                            <span class="text-muted" style="font-size: 10px;"><%=evt[2].substring(11)%></span>
                          </div>
                          <p class="mb-0 text-muted small" style="font-size: 11px;"><%=evt[1]%></p>
                        </div>
                      </div>
                      <% } %>
                    </div>
                  <% } %>
                </div>
                <div class="card-footer bg-transparent border-0 text-center py-3">
                  <span class="small text-muted opacity-50">Auto-updating globally</span>
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