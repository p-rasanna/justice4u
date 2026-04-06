<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("lname");
  if (email == null) { response.sendRedirect(request.getContextPath() + "/auth/Login.jsp"); return; }
  String lname = email; int tC=0, pA=0, cR=0, iR=0;
  try (Connection con = DatabaseConfig.getConnection()) {
    ResultSet r; PreparedStatement p;
    p = con.prepareStatement("SELECT name FROM lawyer_reg WHERE email=?"); p.setString(1,email); r=p.executeQuery(); if(r.next()&&r.getString(1)!=null) lname=r.getString(1);
    p = con.prepareStatement("SELECT COUNT(*) FROM casetb c JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? AND c.flag>=1"); p.setString(1,email); r=p.executeQuery(); if(r.next()) tC=r.getInt(1);
    p = con.prepareStatement("SELECT COUNT(*) FROM casetb c JOIN allotlawyer al ON al.cid=c.cid WHERE c.flag=0 AND al.lname=?"); p.setString(1,email); r=p.executeQuery(); if(r.next()) pA=r.getInt(1);
    p = con.prepareStatement("SELECT COUNT(*) FROM lawyer_requests WHERE lawyer_email=? AND status='PENDING'"); p.setString(1,email); r=p.executeQuery(); if(r.next()) cR=r.getInt(1);
    p = con.prepareStatement("SELECT COUNT(*) FROM intern_lawyer_assignments WHERE lawyer_email=? AND status='PENDING'"); p.setString(1,email); r=p.executeQuery(); if(r.next()) iR=r.getInt(1);
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Lawyer Dashboard"/></jsp:include>
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
            <h2 class="mb-1 fw-semibold" style="font-size:1.5rem;color:#111;">Lawyer Dashboard</h2>
            <p class="text-muted small mb-0">Welcome, <strong>Adv. <%= lname %></strong></p>
          </div>
          <span class="badge-minimal badge-active px-3 py-2">
            <i class="bi bi-patch-check-fill"></i> Verified Counsel
          </span>
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
              <div class="stat-icon"><i class="bi bi-briefcase"></i></div>
              <div class="stat-lbl">Total Matters</div>
              <div class="stat-num"><%= tC %></div>
            </div>
          </div>
          <div class="col-12 col-md-3">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-clock-history"></i></div>
              <div class="stat-lbl">Pending Acceptance</div>
              <div class="stat-num"><%= pA %></div>
            </div>
          </div>
          <div class="col-12 col-md-3">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-person-raised-hand"></i></div>
              <div class="stat-lbl">Client Requests</div>
              <div class="stat-num"><%= cR %></div>
            </div>
          </div>
          <div class="col-12 col-md-3">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-mortarboard"></i></div>
              <div class="stat-lbl">Intern Requests</div>
              <div class="stat-num"><%= iR %></div>
            </div>
          </div>
        </div>

          <div class="section-card">
          <div class="section-header">
            <span class="section-title">Admin Assigned Cases</span>
            <span class="badge bg-secondary-subtle text-secondary rounded-pill ms-auto" style="font-size:.62rem;">Requires Acceptance</span>
          </div>
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th class="ps-4 fw-semibold text-muted small">Matter</th>
                  <th class="fw-semibold text-muted small">Client</th>
                  <th class="fw-semibold text-muted small">Filed</th>
                  <th class="text-end pe-4 fw-semibold text-muted small">Action</th>
                </tr>
              </thead>
              <tbody>
              <%
                boolean a1=false;
                try(PreparedStatement p1=con.prepareStatement(
                  "SELECT c.cid,c.title,c.cname,c.curdate FROM casetb c JOIN allotlawyer al ON al.cid=c.cid " +
                  "WHERE c.flag=0 AND al.lname=? AND COALESCE(c.assignment_type,'ADMIN')='ADMIN' ORDER BY c.cid DESC")){
                  p1.setString(1,email); ResultSet r1=p1.executeQuery();
                  while(r1.next()){ a1=true; int id=r1.getInt(1);
              %>
              <tr>
                <td class="ps-4">
                  <div class="fw-semibold text-dark small"><%= r1.getString(2) %></div>
                  <div class="text-muted" style="font-size:.7rem;">#<%= id %> &nbsp;<span class="badge bg-secondary-subtle text-secondary" style="font-size:.58rem;">Admin Routed</span></div>
                </td>
                <td class="small"><%= r1.getString(3) %></td>
                <td class="small text-muted"><%= r1.getString(4) %></td>
                <td class="text-end pe-4">
                  <a href="<%= request.getContextPath() %>/lawyer/accept_case.jsp?case_id=<%= id %>&action=accept" class="action-cta gold me-1">Accept</a>
                  <a href="<%= request.getContextPath() %>/lawyer/accept_case.jsp?case_id=<%= id %>&action=reject" class="btn btn-sm btn-link text-danger text-decoration-none small">Reject</a>
                </td>
              </tr>
              <% }} if(!a1){ %>
              <tr><td colspan="4" class="text-center py-5 text-muted">
                <i class="bi bi-shield-check d-block" style="font-size:2rem;opacity:.25;margin-bottom:.5rem;"></i>
                <span class="small">No pending admin-assigned cases.</span>
              </td></tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Client Requests -->
        <div class="section-card">
          <div class="section-header">
            <i class="bi bi-person-raised-hand text-primary"></i>
            <span class="section-title">Client Requests</span>
            <span class="badge bg-primary-subtle text-primary rounded-pill ms-auto" style="font-size:.62rem;">Direct</span>
          </div>
          <div class="table-responsive">
            <table class="table-minimal w-100 mb-0">
              <thead>
                <tr>
                  <th class="ps-4">Matter</th>
                  <th class="fw-semibold text-muted small">Client</th>
                  <th class="fw-semibold text-muted small">Filed</th>
                  <th class="text-end pe-4 fw-semibold text-muted small">Action</th>
                </tr>
              </thead>
              <tbody>
              <%
                boolean a2=false;
                try(PreparedStatement p2=con.prepareStatement(
                  "SELECT lr.request_id,c.cid,c.title,c.cname,c.curdate FROM lawyer_requests lr " +
                  "JOIN casetb c ON c.cid=lr.case_id WHERE lr.lawyer_email=? AND lr.status='PENDING' ORDER BY lr.request_id DESC")){
                  p2.setString(1,email); ResultSet r2=p2.executeQuery();
                  while(r2.next()){ a2=true; int rid=r2.getInt(1),cid=r2.getInt(2);
              %>
              <tr>
                <td class="ps-4">
                  <div class="fw-semibold text-dark small"><%= r2.getString(3) %></div>
                  <div class="text-muted" style="font-size:.7rem;">#<%= cid %> &nbsp;<span class="badge bg-primary-subtle text-primary" style="font-size:.58rem;">Client Direct</span></div>
                </td>
                <td class="small"><%= r2.getString(4) %></td>
                <td class="small text-muted"><%= r2.getString(5) %></td>
                <td class="text-end pe-4">
                  <a href="<%= request.getContextPath() %>/lawyer/process_client_request.jsp?request_id=<%= rid %>&action=accept" class="action-cta gold me-1">Accept</a>
                  <a href="<%= request.getContextPath() %>/lawyer/process_client_request.jsp?request_id=<%= rid %>&action=reject" class="btn btn-sm btn-link text-danger text-decoration-none small">Reject</a>
                </td>
              </tr>
              <% }} if(!a2){ %>
              <tr><td colspan="4" class="text-center py-5 text-muted">
                <i class="bi bi-inbox d-block" style="font-size:2rem;opacity:.25;margin-bottom:.5rem;"></i>
                <span class="small">No client requests pending.</span>
              </td></tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Intern Requests -->
        <div class="section-card">
          <div class="section-header">
            <i class="bi bi-mortarboard-fill" style="color:#b4975a;"></i>
            <span class="section-title">Intern Requests</span>
            <span class="badge rounded-pill ms-auto" style="background:rgba(124,58,237,.1);color:#7c3aed;font-size:.62rem;">Placement</span>
          </div>
          <div class="table-responsive">
            <table class="table-minimal w-100 mb-0">
              <thead>
                <tr>
                  <th class="ps-4">Intern</th>
                  <th class="fw-semibold text-muted small">Contact</th>
                  <th class="fw-semibold text-muted small">Assigned</th>
                  <th class="text-end pe-4 fw-semibold text-muted small">Action</th>
                </tr>
              </thead>
              <tbody>
              <%
                boolean a3=false;
                try(PreparedStatement p3=con.prepareStatement(
                  "SELECT ila.id,i.name,i.email,i.mobno,ila.assigned_date FROM intern_lawyer_assignments ila " +
                  "JOIN intern i ON ila.intern_email=i.email WHERE ila.lawyer_email=? AND ila.status='PENDING' ORDER BY ila.assigned_date DESC")){
                  p3.setString(1,email); ResultSet r3=p3.executeQuery();
                  while(r3.next()){ a3=true; int aid=r3.getInt(1); String ad=r3.getString(5);
              %>
              <tr>
                <td class="ps-4">
                  <div class="d-flex align-items-center gap-2">
                    <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold flex-shrink-0"
                         style="width:30px;height:30px;background:#f5f3ff;color:#7c3aed;font-size:.8rem;">
                      <%= r3.getString(2)!=null?r3.getString(2).substring(0,1).toUpperCase():"?" %>
                    </div>
                    <span class="fw-semibold text-dark small"><%= r3.getString(2) %></span>
                  </div>
                </td>
                <td>
                  <div class="small text-dark"><%= r3.getString(3) %></div>
                  <div class="text-muted" style="font-size:.7rem;"><%= r3.getString(4)!=null?r3.getString(4):"" %></div>
                </td>
                <td class="small text-muted"><%= ad!=null?ad.substring(0,10):"—" %></td>
                <td class="text-end pe-4">
                  <a href="<%= request.getContextPath() %>/lawyer/intern_action.jsp?id=<%= aid %>&action=accept" class="action-cta gold me-1">Accept</a>
                  <a href="<%= request.getContextPath() %>/lawyer/intern_action.jsp?id=<%= aid %>&action=reject" class="btn btn-sm btn-link text-danger text-decoration-none small">Reject</a>
                </td>
              </tr>
              <% }} if(!a3){ %>
              <tr><td colspan="4" class="text-center py-5 text-muted">
                <i class="bi bi-mortarboard d-block" style="font-size:2rem;opacity:.25;margin-bottom:.5rem;"></i>
                <span class="small">No pending intern requests.</span>
              </td></tr>
              <% } %>
              </tbody>
            </table>
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