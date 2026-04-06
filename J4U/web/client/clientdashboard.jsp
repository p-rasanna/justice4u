<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("cname");
  String profileType = (String) session.getAttribute("profileType");
  if (email == null) { response.sendRedirect("../auth/Login.jsp"); return; }
  if (profileType == null) profileType = "admin";
  boolean isManual = "manual".equalsIgnoreCase(profileType);
  String cname = email; int mC = 0; String aLawyer = "None assigned"; int aCaseId = 0;
  try (Connection con = DatabaseConfig.getConnection()) {
    ResultSet r; PreparedStatement p;
    p = con.prepareStatement("SELECT cname FROM cust_reg WHERE email=?"); p.setString(1,email); r=p.executeQuery(); if(r.next()&&r.getString(1)!=null) cname=r.getString(1);
    p = con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE cname=?"); p.setString(1,email); r=p.executeQuery(); if(r.next()) mC=r.getInt(1);
    p = con.prepareStatement("SELECT c.cid,COALESCE(lr.name,al.lname) FROM casetb c LEFT JOIN allotlawyer al ON al.cid=c.cid LEFT JOIN lawyer_reg lr ON lr.email=al.lname WHERE c.cname=? AND al.lname IS NOT NULL ORDER BY c.cid DESC LIMIT 1");
    p.setString(1,email); r=p.executeQuery(); if(r.next()){ aCaseId=r.getInt(1); aLawyer=r.getString(2); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Client Dashboard"/></jsp:include>
<style>
  /* Minimalist Theme Overrides */
  body { background-color: #fafafa; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }

  .dash-stat { background: #ffffff; border: 1px solid #eaeaea; border-radius: 8px; padding: 24px; transition: box-shadow 0.2s ease; }
  .dash-stat:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
  .dash-stat .stat-icon { font-size: 1.25rem; color: #111; margin-bottom: 12px; }
  .dash-stat .stat-lbl { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #888; font-weight: 500; margin-bottom: 4px; }
  .dash-stat .stat-num { font-size: 1.5rem; font-weight: 600; color: #111; line-height: 1.2; margin: 0; }

  .section-card { background: #ffffff; border: 1px solid #eaeaea; border-radius: 8px; overflow: hidden; margin-bottom: 20px; }
  .section-header { padding: 18px 24px; border-bottom: 1px solid #eaeaea; display: flex; align-items: center; gap: 10px; background: #ffffff; }
  .section-title { font-size: 0.95rem; font-weight: 500; color: #111; margin: 0; }

  .action-cta { background: #111; color: #fff; border-radius: 6px; padding: 6px 14px; font-size: 0.82rem; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; text-decoration: none; transition: background 0.2s; border: 1px solid #111; }
  .action-cta:hover { background: #333; color: #fff; border-color: #333; }
  .action-cta.gold { background: var(--gold); border-color: var(--gold); }
  .action-cta.gold:hover { background: var(--gold-dark); border-color: var(--gold-dark); color: #fff; }

  /* Table Minimalism */
  .table-minimal th { border-bottom: 1px solid #eaeaea; font-weight: 500; color: #888; text-transform: uppercase; font-size: 0.7rem; letter-spacing: 0.05em; padding: 14px 24px; background: transparent; }
  .table-minimal td { padding: 16px 24px; border-bottom: 1px solid #eaeaea; vertical-align: middle; color: #333; font-size: 0.875rem; }
  .table-minimal tbody tr:last-child td { border-bottom: none; }
  .table-minimal tbody tr:hover { background-color: #fafafa; }

  /* Badges */
  .badge-minimal { font-weight: 500; padding: 4px 8px; font-size: 0.7rem; border-radius: 4px; letter-spacing: 0.02em; display: inline-flex; align-items: center; gap: 4px; }
  .badge-neutral { background: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
  .badge-pending { background: #fffbeb; color: #92400e; border: 1px solid #fef3c7; }
  .badge-active { background: #f0fdf4; color: #166534; border: 1px solid #dcfce7; }
  .badge-manual { background: #eff6ff; color: #1e40af; border: 1px solid #dbeafe; }

  .btn-outline-simple { background: transparent; color: #111; border: 1px solid #eaeaea; border-radius: 6px; padding: 6px 14px; font-size: 0.8rem; font-weight: 500; text-decoration: none; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 6px; }
  .btn-outline-simple:hover { background: #fafafa; border-color: #ccc; color: #000; }
  .btn-outline-danger-simple { background: transparent; color: #dc3545; border: 1px solid #f5c2c7; border-radius: 6px; padding: 6px 14px; font-size: 0.8rem; font-weight: 500; text-decoration: none; transition: all 0.2s; }
  .btn-outline-danger-simple:hover { background: #f8d7da; }
</style>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
<div class="app-wrapper">
  <jsp:include page="../shared/_topbar.jsp"/>
  <jsp:include page="../shared/_sidebar.jsp"/>
  <main class="app-main">

    <div class="app-content-header pb-0 pt-4">
      <div class="container-fluid">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
          <div>
            <h2 class="mb-1 fw-semibold" style="font-size:1.5rem;color:#111;">Client Portal</h2>
            <p class="text-muted small mb-0">Welcome back, <strong><%= cname %></strong></p>
          </div>
          <div class="d-flex gap-3 align-items-center">
            <span class="badge-minimal <%= isManual?"badge-manual":"badge-neutral" %> px-3 py-2">
              <i class="bi bi-<%= isManual?"person":"shield" %>"></i>
              <%= isManual?"Manual Assignment Mode":"Admin Assignment Mode" %>
            </span>
            <a href="case.jsp" class="action-cta gold"><i class="bi bi-plus"></i> New Case</a>
          </div>
        </div>
      </div>
    </div>

    <div class="app-content mt-2">
      <div class="container-fluid">

        <% if(request.getParameter("msg")!=null){ %>
        <div class="alert alert-success alert-dismissible border-0 small mb-4 rounded-3">
          <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="row g-3 mb-4">
          <div class="col-12 col-md-3">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-folder2-open"></i></div>
              <div class="stat-lbl">My Cases</div>
              <div class="stat-num"><%= mC %></div>
            </div>
          </div>
          <div class="col-12 col-md-3">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-person"></i></div>
              <div class="stat-lbl">Assigned Lawyer</div>
              <div class="stat-num" style="font-size: <%= aLawyer.length()>15?"1.1rem":"1.3rem" %>; padding-top:4px;">
                <%= aLawyer %>
              </div>
            </div>
          </div>
          <div class="col-12 col-md-3">
            <a href="case.jsp" class="dash-stat text-decoration-none d-block">
              <div class="stat-icon" style="color:var(--gold);"><i class="bi bi-plus-lg"></i></div>
              <div class="stat-lbl">Action</div>
              <div class="fw-medium mt-2" style="font-size: 1.1rem; color:var(--gold);">File a Case →</div>
            </a>
          </div>
          <div class="col-12 col-md-3">
            <a href="<%= aCaseId>0?"../shared/caseDiscussion.jsp?case_id="+aCaseId:"#" %>"
               class="dash-stat text-decoration-none d-block"
               <%= aCaseId==0?"onclick=\"alert('No active assigned case yet.');return false;\"":"" %>>
              <div class="stat-icon"><i class="bi bi-chat"></i></div>
              <div class="stat-lbl">Communication</div>
              <div class="fw-medium text-dark mt-2" style="font-size: 1.1rem;">
                <%= aCaseId>0?"Open Chat →":"Awaiting Lawyer" %>
              </div>
            </a>
          </div>
        </div>

        <div class="row g-4">
          <div class="col-lg-8">
            <div class="section-card">
              <div class="section-header">
                <span class="section-title">My Cases</span>
                <span class="ms-auto text-muted small"><%= mC %> total</span>
              </div>
              <div class="table-responsive">
                <table class="table-minimal w-100 mb-0">
                  <thead>
                    <tr>
                      <th class="ps-4">Matter</th>
                      <th>Status</th>
                      <th>Type</th>
                      <th class="text-end pe-4">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                  <%
                    boolean ha = false;
                    try(PreparedStatement p2 = con.prepareStatement(
                      "SELECT c.cid,c.title,c.curdate," +
                      "COALESCE(c.assignment_type,'ADMIN') atype," +
                      "COALESCE(c.case_status,'PENDING') cstatus," +
                      "COALESCE(lrn.name,al.lname) lname," +
                      "lr.request_id rid," +
                      "COALESCE(lrr.name,lr.lawyer_email) rln " +
                      "FROM casetb c " +
                      "LEFT JOIN allotlawyer al ON al.cid=c.cid " +
                      "LEFT JOIN lawyer_reg lrn ON lrn.email=al.lname " +
                      "LEFT JOIN lawyer_requests lr ON lr.case_id=c.cid AND lr.status='PENDING' " +
                      "LEFT JOIN lawyer_reg lrr ON lrr.email=lr.lawyer_email " +
                      "WHERE c.cname=? ORDER BY c.cid DESC")){
                      p2.setString(1,email); ResultSet r2=p2.executeQuery();
                      while(r2.next()){
                        ha=true;
                        int id=r2.getInt(1); String atype=r2.getString(4),cstatus=r2.getString(5),ln=r2.getString(6),rln=r2.getString(8);
                        int rid=r2.getInt(7); boolean hasL=(ln!=null&&!ln.isEmpty()),isM="MANUAL".equalsIgnoreCase(atype);
                  %>
                  <tr>
                    <td class="ps-4">
                      <div class="fw-semibold text-dark small"><%= r2.getString(2) %></div>
                      <div class="text-muted" style="font-size:0.7rem;">ID: <%= id %> <span class="mx-1">&middot;</span> <%= r2.getString(3) %></div>
                    </td>
                    <td>
                      <% if(!isM){ %>
                        <% if(hasL){ %>
                          <span class="badge-minimal badge-active"><i class="bi bi-check2"></i> <%= ln %></span>
                        <% }else{ %>
                          <span class="badge-minimal badge-pending"><i class="bi bi-hourglass"></i> Awaiting Assignment</span>
                        <% } %>
                      <% }else if("ACTIVE".equals(cstatus)&&hasL){ %>
                        <span class="badge-minimal badge-active"><i class="bi bi-check2"></i> <%= ln %></span>
                      <% }else if("REQUESTED".equals(cstatus)&&rid>0){ %>
                        <span class="badge-minimal badge-manual"><i class="bi bi-arrow-right"></i> Request Pending</span>
                      <% }else if("SEARCHING".equals(cstatus)){ %>
                        <span class="badge-minimal badge-pending"><i class="bi bi-search"></i> Searching</span>
                      <% } %>
                    </td>
                    <td>
                      <span class="badge-minimal <%= isM?"badge-manual":"badge-neutral" %>"><%= isM?"Manual":"Admin" %></span>
                    </td>
                    <td class="text-end pe-4">
                      <div class="d-flex justify-content-end align-items-center gap-2">
                        <% if(hasL&&"ACTIVE".equals(cstatus)){ %>
                          <a href="../shared/caseDiscussion.jsp?case_id=<%= id %>" class="btn-outline-simple" style="padding:4px 10px;font-size:0.75rem;"><i class="bi bi-chat"></i> View Chat</a>
                        <% }else if(isM){ %>
                          <% if("REQUESTED".equals(cstatus)&&rid>0){ %>
                            <a href="cancel_lawyer_request.jsp?request_id=<%= rid %>" onclick="return confirm('Cancel this request?')" class="btn-outline-danger-simple" style="padding:4px 10px;font-size:0.75rem;">Cancel Request</a>
                          <% } %>
                          <% if("SEARCHING".equals(cstatus)||"REQUESTED".equals(cstatus)){ %>
                            <a href="findlawyer.jsp?case_id=<%= id %>" class="btn-outline-simple" style="padding:4px 10px;font-size:0.75rem;"><i class="bi bi-search"></i> <%= "REQUESTED".equals(cstatus)?"Change":"Find" %></a>
                          <% } %>
                        <% }else{ %>
                          <span class="btn-outline-simple" style="opacity: 0.5; pointer-events: none; padding:4px 10px;font-size:0.75rem;">Waiting</span>
                        <% } %>
                        <a href="client_case_details.jsp?id=<%= id %>" class="action-cta gold" style="padding:4px 10px;font-size:0.75rem;">Details</a>
                      </div>
                    </td>
                  </tr>
                  <% }} if(!ha){ %>
                  <tr>
                    <td colspan="4" class="text-center py-5 text-muted">
                      <i class="bi bi-folder2-open d-block mb-3" style="font-size:2rem;opacity:.25;"></i>
                      <span class="small d-block mb-3">You haven't filed any cases yet.</span>
                      <a href="case.jsp" class="btn-outline-simple">File a Case</a>
                    </td>
                  </tr>
                  <% } %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <div class="col-lg-4">
            <div class="section-card mb-4">
              <div class="section-header">
                <span class="section-title">Notifications</span>
              </div>
              <%
                boolean hn=false;
                try(PreparedStatement p3=con.prepareStatement("SELECT message,type,link,created_at FROM notifications WHERE user_email=? AND is_read=0 ORDER BY created_at DESC LIMIT 6")){
                  p3.setString(1,email); ResultSet r3=p3.executeQuery();
                  while(r3.next()){ hn=true; String l=r3.getString(3),t=r3.getString(2);
                    String ic="bi-bell-fill";
                    if("case".equals(t)) ic="bi-folder2-open";
                    else if("message".equals(t)) ic="bi-chat-dots-fill";
                    else if("hearing".equals(t)) ic="bi-calendar-event-fill";
              %>
              <div class="d-flex gap-3 align-items-start px-4 py-3" style="border-bottom: 1px solid #eaeaea; transition:background 0.2s;" onmouseover="this.style.background='#fafafa'" onmouseout="this.style.background='transparent'">
                <div class="d-flex align-items-center justify-content-center flex-shrink-0" style="width:32px;height:32px;background:rgba(180,151,90,0.1);color:var(--gold);border-radius:50%;">
                  <i class="bi <%= ic %>" style="font-size: 0.9rem;"></i>
                </div>
                <div class="flex-grow-1 min-w-0 pt-1">
                  <% if(l!=null&&!l.isEmpty()){ %>
                    <a href="<%= l %>" class="text-decoration-none text-dark d-block fw-medium mb-1" style="font-size:0.85rem;"><%= r3.getString(1) %></a>
                  <% }else{ %><p class="mb-1 text-dark fw-medium" style="font-size:0.85rem;"><%= r3.getString(1) %></p><% } %>
                  <div class="text-muted" style="font-size:0.7rem;"><i class="bi bi-clock me-1"></i><%= r3.getTimestamp(4) %></div>
                </div>
              </div>
              <% }} if(!hn){ %>
              <div class="text-center py-5 text-muted">
                <i class="bi bi-bell-slash d-block mb-2" style="font-size:1.8rem;opacity:.2;"></i>
                <span class="small">All caught up.</span>
              </div>
              <% } %>
              <div class="text-center py-3 border-top bg-light">
                <a href="notifications.jsp" class="small fw-medium text-dark text-decoration-none">View All Notifications</a>
              </div>
            </div>

            <% if(isManual){ %>
            <div class="section-card border-dashed" style="border: 1px dashed #ccc;">
              <div class="section-header bg-transparent border-bottom-0 pb-0">
                <span class="section-title">Manual Assignment</span>
              </div>
              <div class="p-4 pt-2 text-center">
                <p class="small text-muted mb-3">Browse our directory and request a specific lawyer for your case.</p>
                <a href="findlawyer.jsp" class="btn-outline-simple w-100"><i class="bi bi-search"></i> Browse Directory</a>
              </div>
            </div>
            <% } %>
          </div>
        </div>

      </div>
    </div>
  </main>
  <jsp:include page="../shared/_footer.jsp"/>
</div>
</body>
</html>
<% } catch(Exception e){ e.printStackTrace(); out.println("<div class='alert alert-danger m-3'><pre>"+e+"</pre></div>"); } %>