<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String adminEmail=(String)session.getAttribute("aname");
  if(adminEmail==null){response.sendRedirect(request.getContextPath()+"/auth/Login.jsp");return;}
  int pClient=0, pLawyer=0, pIntern=0, openC=0;
  java.util.List<String[]> timeline=new java.util.ArrayList<>();
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement ps; ResultSet rs;
    ps=con.prepareStatement("SELECT COUNT(*) FROM cust_reg WHERE verification_status='PENDING'");
    rs=ps.executeQuery(); if(rs.next()) pClient=rs.getInt(1);
    ps=con.prepareStatement("SELECT COUNT(*) FROM lawyer_reg WHERE flag=0");
    rs=ps.executeQuery(); if(rs.next()) pLawyer=rs.getInt(1);
    ps=con.prepareStatement("SELECT COUNT(*) FROM intern WHERE flag=0");
    rs=ps.executeQuery(); if(rs.next()) pIntern=rs.getInt(1);
    ps=con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE status='OPEN'");
    rs=ps.executeQuery(); if(rs.next()) openC=rs.getInt(1);
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
<style>
  /* Minimalist Theme Overrides */
  body { background-color: #fafafa; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }

  .dash-stat { background: #ffffff; border: 1px solid #eaeaea; border-radius: 8px; padding: 24px; transition: box-shadow 0.2s ease; }
  .dash-stat:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
  .dash-stat .stat-icon { font-size: 1.25rem; color: #111; margin-bottom: 12px; }
  .dash-stat .stat-lbl { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #888; font-weight: 500; margin-bottom: 4px; }
  .dash-stat .stat-num { font-size: 1.5rem; font-weight: 600; color: #111; line-height: 1.2; margin: 0; }

  .section-card { background: #ffffff; border: 1px solid #eaeaea; border-radius: 8px; overflow: hidden; }
  .section-header { padding: 18px 24px; border-bottom: 1px solid #eaeaea; display: flex; align-items: center; gap: 10px; background: #ffffff; }
  .section-title { font-size: 0.95rem; font-weight: 500; color: #111; margin: 0; }

  .action-cta { background: #111; color: #fff; border-radius: 6px; padding: 7px 14px; font-size: 0.82rem; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; text-decoration: none; transition: background 0.2s; border: 1px solid #111; }
  .action-cta:hover { background: #333; color: #fff; border-color: #333; }

  .quick-btn { display: flex; width: 100%; padding: 10px 14px; border-radius: 6px; font-size: 0.85rem; font-weight: 500; text-decoration: none; margin-bottom: 8px; align-items: center; gap: 8px; transition: background 0.15s; }
  .quick-btn.dark { background: #111; color: #fff; }
  .quick-btn.dark:hover { background: #333; }
  .quick-btn.outline { background: #fff; color: #111; border: 1px solid #eaeaea; }
  .quick-btn.outline:hover { background: #fafafa; border-color: #ccc; }

  .pulse-dot { width: 7px; height: 7px; border-radius: 50%; background: #ccc; flex-shrink: 0; margin-top: 6px; }

  /* Table Minimalism */
  .table-minimal th { border-bottom: 1px solid #eaeaea; font-weight: 500; color: #888; text-transform: uppercase; font-size: 0.7rem; letter-spacing: 0.05em; padding: 14px 24px; background: transparent; }
  .table-minimal td { padding: 16px 24px; border-bottom: 1px solid #eaeaea; vertical-align: middle; color: #333; font-size: 0.875rem; }
  .table-minimal tbody tr:last-child td { border-bottom: none; }
  .table-minimal tbody tr:hover { background-color: #fafafa; }

  /* Badges */
  .badge-minimal { font-weight: 500; padding: 4px 8px; font-size: 0.7rem; border-radius: 4px; letter-spacing: 0.02em; display: inline-flex; align-items: center; gap: 4px; }
  .badge-neutral { background: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
  .badge-pending { background: #fffbeb; color: #92400e; border: 1px solid #fef3c7; }
</style>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="../shared/_topbar.jsp" />
    <jsp:include page="../shared/_sidebar.jsp" />
    <main class="app-main">

      <div class="app-content-header pb-0 pt-4">
        <div class="container-fluid">
          <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
            <div>
              <h2 class="mb-1 fw-semibold" style="font-size:1.5rem;color:#111;">Admin Console</h2>
              <p class="text-muted small mb-0">System oversight and approval queue</p>
            </div>
            <span class="badge-minimal badge-neutral px-3 py-2">
              <i class="bi bi-shield-check"></i> System Active
            </span>
          </div>
        </div>
      </div>

      <div class="app-content mt-2">
        <div class="container-fluid">

          <div class="row g-3 mb-4">
            <div class="col-12 col-md-3">
              <div class="dash-stat">
                <div class="stat-icon"><i class="bi bi-people"></i></div>
                <div class="stat-lbl">Pending Clients</div>
                <div class="stat-num"><%=pClient%></div>
              </div>
            </div>
            <div class="col-12 col-md-3">
              <div class="dash-stat">
                <div class="stat-icon"><i class="bi bi-shield-shaded"></i></div>
                <div class="stat-lbl">Pending Lawyers</div>
                <div class="stat-num"><%=pLawyer%></div>
              </div>
            </div>
            <div class="col-12 col-md-3">
              <div class="dash-stat">
                <div class="stat-icon"><i class="bi bi-mortarboard"></i></div>
                <div class="stat-lbl">Pending Interns</div>
                <div class="stat-num"><%=pIntern%></div>
              </div>
            </div>
            <div class="col-12 col-md-3">
              <div class="dash-stat">
                <div class="stat-icon"><i class="bi bi-briefcase"></i></div>
                <div class="stat-lbl">Open Cases</div>
                <div class="stat-num"><%=openC%></div>
              </div>
            </div>
          </div>

          <div class="row g-4">
            <div class="col-lg-8">

              <div class="section-card mb-4">
                <div class="section-header">
                  <span class="section-title">Pending Lawyer Authorization</span>
                  <span class="badge-minimal badge-pending ms-auto">Needs Review</span>
                </div>
                <div class="table-responsive">
                  <table class="table-minimal w-100 mb-0">
                    <thead>
                      <tr>
                        <th class="ps-4" style="width:50%">Name</th>
                        <th>Role</th>
                        <th class="text-end pe-4">Action</th>
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
                      <tr>
                        <td class="ps-4">
                          <div class="d-flex align-items-center gap-2">
                            <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                 style="width:30px;height:30px;background:#f5f5f5;color:#111;font-size:.8rem;font-weight:500;border:1px solid #eaeaea;">
                              <%=name.substring(0,1).toUpperCase()%>
                            </div>
                            <span style="font-size:.875rem;"><%=name%></span>
                          </div>
                        </td>
                        <td><span class="badge-minimal badge-neutral"><%=type%></span></td>
                        <td class="text-end pe-4">
                          <a href="user_action.jsp?type=<%=type.toLowerCase()%>&action=approve&id=<%=id%>" class="action-cta me-2" style="font-size:.78rem;padding:5px 12px;background:#111;">Approve</a>
                          <a href="user_action.jsp?type=<%=type.toLowerCase()%>&action=reject&id=<%=id%>" style="font-size:.78rem;color:#dc3545;text-decoration:none;">Reject</a>
                        </td>
                      </tr>
                      <% } if(none){ %>
                      <tr><td colspan="3" class="text-center py-5 text-muted">
                        <span class="small">No pending authorizations.</span>
                      </td></tr>
                      <% } } catch(Exception e){} %>
                    </tbody>
                  </table>
                </div>
                <div class="text-center py-3 border-top bg-light">
                  <a href="<%=request.getContextPath()%>/admin/viewlawyers.jsp" class="small fw-medium text-dark text-decoration-none">Full Lawyer Registry</a>
                </div>
              </div>

              <div class="section-card">
                <div class="section-header">
                  <span class="section-title">Assignment Queue</span>
                  <span class="badge-minimal badge-pending ms-auto">Needs Lawyer</span>
                </div>
                <div class="table-responsive">
                  <table class="table-minimal w-100 mb-0">
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
                      <tr>
                        <td class="ps-4">
                          <div class="fw-semibold text-dark small"><%=qtitle%></div>
                          <div class="text-muted" style="font-size:0.7rem;">#<%=qcid%>
                            <span class="badge bg-warning-subtle text-warning ms-1" style="font-size:0.55rem;"><%=qstatus%></span>
                          </div>
                        </td>
                        <td class="small"><%=qclient%></td>
                        <td class="small text-muted"><%=qcourt != null ? qcourt : "—"%></td>
                        <td class="text-end pe-4">
                          <a href="<%=request.getContextPath()%>/admin/allotlawyer.jsp?id=<%=qcid%>"
                             class="action-cta gold" style="font-size:.78rem;padding:6px 14px;">
                            <i class="bi bi-person-check"></i> Assign
                          </a>
                        </td>
                      </tr>
                    <% } } catch(Exception e3){} if(queueEmpty){ %>
                      <tr><td colspan="4" class="text-center py-5 text-muted">
                        <i class="bi bi-check2-all d-block mb-2" style="font-size:2rem;opacity:.2;"></i>
                        <span class="small">All admin-flow cases assigned.</span>
                      </td></tr>
                    <% } %>
                    </tbody>
                  </table>
                </div>
                <div class="text-center py-2 border-top">
                  <a href="<%=request.getContextPath()%>/admin/viewcases.jsp" class="small fw-semibold text-decoration-none" style="color:#b4975a;">Full Case Repository →</a>
                </div>
              </div>
            </div>

            <div class="col-lg-4">

              <!-- Quick Actions -->
              <div class="section-card mb-3">
                <div class="section-header">
                  <i class="bi bi-lightning-charge-fill" style="color:#b4975a;"></i>
                  <span class="section-title">Quick Actions</span>
                </div>
                <div class="p-3">
                  <a href="<%=request.getContextPath()%>/admin/allotlawyer.jsp" class="quick-btn dark">
                    <i class="bi bi-person-check-fill"></i> Assign Legal Counsel
                  </a>
                  <a href="<%=request.getContextPath()%>/admin/assign_intern_to_lawyer.jsp" class="quick-btn outline">
                    <i class="bi bi-mortarboard"></i> Intern Placement
                  </a>
                  <a href="<%=request.getContextPath()%>/admin/viewcases.jsp" class="quick-btn outline">
                    <i class="bi bi-archive"></i> Case Repository
                  </a>
                  <a href="<%=request.getContextPath()%>/admin/viewlawyers.jsp" class="quick-btn outline">
                    <i class="bi bi-shield-shaded"></i> Lawyer Registry
                  </a>
                  <a href="<%=request.getContextPath()%>/admin/viewcustomers.jsp" class="quick-btn outline">
                    <i class="bi bi-people"></i> Client Registry
                  </a>
                </div>
              </div>

              <!-- Recent Pulse -->
              <div class="section-card">
                <div class="section-header">
                  <i class="bi bi-activity text-primary"></i>
                  <span class="section-title">Recent Activity</span>
                </div>
                <div class="p-3">
                  <% if(timeline.isEmpty()){ %>
                    <div class="text-center py-4 text-muted">
                      <i class="bi bi-clock-history d-block mb-2" style="font-size:1.8rem;opacity:.2;"></i>
                      <p class="small mb-0">No recent activity.</p>
                    </div>
                  <% } else { %>
                    <% for(String[] evt:timeline){ %>
                    <div class="d-flex gap-2 mb-3">
                      <div class="pulse-dot mt-1 flex-shrink-0"></div>
                      <div class="flex-grow-1">
                        <div class="d-flex justify-content-between align-items-start">
                          <span class="fw-semibold small text-dark"><%=evt[0].replace("_"," ")%></span>
                          <span class="text-muted" style="font-size:.67rem;white-space:nowrap;margin-left:8px;"><%=evt[2].substring(11)%></span>
                        </div>
                        <p class="mb-0 text-muted" style="font-size:.78rem;"><%=evt[1]%></p>
                      </div>
                    </div>
                    <% } %>
                  <% } %>
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