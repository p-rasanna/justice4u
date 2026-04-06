<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String iEmail = (String) session.getAttribute("iname");
  if (iEmail == null) { response.sendRedirect("../auth/Login.jsp"); return; }
  String iname = iEmail, lawyerEmail = null, lawyerName = null, assignStatus = null;
  java.util.List<String[]> cases = new java.util.ArrayList<>();
  try (Connection con = DatabaseConfig.getConnection()) {
    ResultSet r; PreparedStatement p;
    p = con.prepareStatement("SELECT name FROM intern WHERE email=?"); p.setString(1,iEmail); r=p.executeQuery(); if(r.next()&&r.getString(1)!=null) iname=r.getString(1);
    p = con.prepareStatement(
      "SELECT ila.status,ila.lawyer_email,lr.name FROM intern_lawyer_assignments ila " +
      "JOIN lawyer_reg lr ON ila.lawyer_email=lr.email " +
      "WHERE ila.intern_email=? AND ila.status IN ('PENDING','ACCEPTED') ORDER BY ila.assigned_date DESC LIMIT 1");
    p.setString(1,iEmail); r=p.executeQuery();
    if(r.next()){ assignStatus=r.getString(1); lawyerEmail=r.getString(2); lawyerName=r.getString(3); }
    if("ACCEPTED".equals(assignStatus) && lawyerEmail!=null){
      p = con.prepareStatement(
        "SELECT c.cid,c.title,c.cname,c.courttype,c.city,c.curdate,c.flag FROM casetb c " +
        "JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? AND c.flag>=1 ORDER BY c.cid DESC");
      p.setString(1,lawyerEmail); r=p.executeQuery();
      while(r.next()) cases.add(new String[]{
        String.valueOf(r.getInt(1)), r.getString(2), r.getString(3),
        r.getString(4)!=null?r.getString(4):"", r.getString(5)!=null?r.getString(5):"",
        r.getString(6)!=null?r.getString(6):"", r.getInt(7)==1?"ACTIVE":"CLOSED"
      });
    }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Intern Dashboard"/></jsp:include>
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
  
  .action-cta { background: #111; color: #fff; border-radius: 6px; padding: 8px 16px; font-size: 0.85rem; font-weight: 500; display: inline-flex; align-items: center; justify-content: center; gap: 6px; text-decoration: none; transition: background 0.2s; border: 1px solid #111; }
  .action-cta:hover { background: #333; color: #fff; border-color: #333; }
  .btn-outline-simple { background: transparent; color: #111; border: 1px solid #eaeaea; border-radius: 6px; padding: 8px 16px; font-size: 0.85rem; font-weight: 500; text-decoration: none; transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px; }
  .btn-outline-simple:hover { background: #fafafa; border-color: #ccc; color: #000; }
  
  .state-card { background: #ffffff; border: 1px dashed #d1d5db; border-radius: 8px; padding: 60px 32px; text-align: center; }
  
  /* Table Minimalism */
  .table-minimal th { border-bottom: 1px solid #eaeaea; font-weight: 500; color: #888; text-transform: uppercase; font-size: 0.7rem; letter-spacing: 0.05em; padding: 14px 24px; background: transparent; }
  .table-minimal td { padding: 16px 24px; border-bottom: 1px solid #eaeaea; vertical-align: middle; color: #333; }
  .table-minimal tbody tr:last-child td { border-bottom: none; }
  .table-minimal tbody tr:hover { background-color: #fafafa; }
  
  /* Badges */
  .badge-minimal { font-weight: 500; padding: 6px 10px; font-size: 0.7rem; border-radius: 4px; letter-spacing: 0.02em; }
  .badge-active { background: #f0fdf4; color: #166534; border: 1px solid #dcfce7; }
  .badge-pending { background: #fffbeb; color: #92400e; border: 1px solid #fef3c7; }
  .badge-neutral { background: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
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
            <h2 class="mb-1 fw-semibold" style="font-size:1.5rem;color:#111;">Overview</h2>
            <p class="text-muted small mb-0">Welcome back, <span class="text-dark"><%= iname %></span></p>
          </div>
          <span class="badge-minimal 
            <%= "ACCEPTED".equals(assignStatus) ? "badge-active" : 
                "PENDING".equals(assignStatus) ? "badge-pending" : "badge-neutral" %>">
            <%= "ACCEPTED".equals(assignStatus) ? "Active Placement" : 
                "PENDING".equals(assignStatus) ? "Pending Approval" : "Awaiting Assignment" %>
          </span>
        </div>
      </div>
    </div>

    <div class="app-content mt-2">
      <div class="container-fluid">

        <% if(request.getParameter("msg")!=null){ %>
        <div class="alert alert-light border alert-dismissible small mb-4 rounded-2" style="border-color:#eaeaea !important;">
          <i class="bi bi-info-circle me-2 text-dark"></i><%= request.getParameter("msg") %>
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="row g-3 mb-4">
          <div class="col-12 col-md-4">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-activity"></i></div>
              <div class="stat-lbl">Status</div>
              <div class="stat-num" style="font-size:1.1rem; padding-top:4px;">
                <% if("ACCEPTED".equals(assignStatus)){ %>Active
                <% }else if("PENDING".equals(assignStatus)){ %>Pending
                <% }else{ %><span class="text-muted">Unassigned</span><% } %>
              </div>
            </div>
          </div>
          <div class="col-12 col-md-4">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-person"></i></div>
              <div class="stat-lbl">Supervisor</div>
              <div class="stat-num" style="font-size:1.1rem; padding-top:4px;">
                <%= lawyerName!=null ? lawyerName : "—" %>
              </div>
            </div>
          </div>
          <div class="col-12 col-md-4">
            <div class="dash-stat">
              <div class="stat-icon"><i class="bi bi-folder2-open"></i></div>
              <div class="stat-lbl">Shared Cases</div>
              <div class="stat-num"><%= cases.size() %></div>
            </div>
          </div>
        </div>

        <% if(assignStatus==null){ %>
        <div class="state-card">
          <i class="bi bi-hourglass text-muted d-block mb-3" style="font-size:2rem;"></i>
          <h5 class="fw-medium mb-2" style="color:#111;">Awaiting Assignment</h5>
          <p class="text-muted small mb-0">The admin has not yet assigned you to a lawyer.<br>You will be notified when an assignment is made.</p>
        </div>

        <% }else if("PENDING".equals(assignStatus)){ %>
        <div class="state-card">
          <i class="bi bi-clock text-muted d-block mb-3" style="font-size:2rem;"></i>
          <h5 class="fw-medium mb-2" style="color:#111;">Pending Approval</h5>
          <p class="text-muted small mb-0">
            You have been assigned to <strong><%= lawyerName %></strong>.<br>
            Awaiting their confirmation for your placement.
          </p>
        </div>

        <% }else{ %>
        <div class="row g-4">
          <div class="col-lg-8">
            <div class="section-card">
              <div class="section-header">
                <span class="section-title">Assigned Cases</span>
                <span class="ms-auto text-muted small"><%= cases.size() %> total</span>
              </div>
              <div class="table-responsive">
                <table class="table table-minimal mb-0">
                  <thead>
                    <tr>
                      <th class="ps-4">Case Details</th>
                      <th>Client</th>
                      <th>Status</th>
                      <th class="text-end pe-4">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                  <% if(cases.isEmpty()){ %>
                  <tr><td colspan="4" class="text-center py-5 text-muted">
                    <span class="small">No cases assigned yet.</span>
                  </td></tr>
                  <% }else{ for(String[] c : cases){ %>
                  <tr>
                    <td class="ps-4">
                      <div class="fw-medium text-dark" style="font-size:0.85rem;"><%= c[1] %></div>
                      <div class="text-muted mt-1" style="font-size:0.75rem;">ID: <%= c[0] %> <span class="mx-1">&middot;</span> <%= c[3] %><% if(!c[4].isEmpty()){ %> <span class="mx-1">&middot;</span> <%= c[4] %><% } %></div>
                    </td>
                    <td style="font-size:0.85rem;"><%= c[2] %></td>
                    <td>
                      <span class="badge-minimal <%= "ACTIVE".equals(c[6]) ? "badge-active" : "badge-neutral" %>">
                        <%= c[6] %>
                      </span>
                    </td>
                    <td class="text-end pe-4">
                      <a href="viewcase_intern.jsp?cid=<%= c[0] %>" class="btn-outline-simple me-2">
                        View
                      </a>
                      <a href="<%= request.getContextPath() %>/shared/caseDiscussion.jsp?case_id=<%= c[0] %>" class="btn-outline-simple">
                        Chat
                      </a>
                    </td>
                  </tr>
                  <% }} %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <div class="col-lg-4">
            <div class="section-card mb-4">
              <div class="section-header">
                <span class="section-title">Supervisor Profile</span>
              </div>
              <div class="p-4">
                <div class="d-flex align-items-center gap-3 mb-4">
                  <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                       style="width:48px; height:48px; background:#f5f5f5; color:#111; font-weight:500; font-size:1.1rem; border:1px solid #eaeaea;">
                    <%= lawyerName!=null ? lawyerName.substring(0,1).toUpperCase() : "?" %>
                  </div>
                  <div>
                    <div class="fw-medium text-dark" style="font-size:0.95rem;">Adv. <%= lawyerName %></div>
                    <div class="text-muted mt-1" style="font-size:0.8rem;"><%= lawyerEmail %></div>
                  </div>
                </div>
                <div class="d-flex justify-content-between align-items-center small border-top pt-3">
                  <span class="text-muted">Collaboration</span>
                  <span class="text-dark fw-medium">Active</span>
                </div>
              </div>
            </div>

            <div class="section-card">
              <div class="section-header">
                <span class="section-title">Actions</span>
              </div>
              <div class="p-3">
                <a href="<%= request.getContextPath() %>/shared/caseDiscussions.jsp" class="action-cta w-100">
                  Open Case Discussions
                </a>
              </div>
            </div>
          </div>
        </div>
        <% } %>

      </div>
    </div>
  </main>
  <jsp:include page="../shared/_footer.jsp"/>
</div>
</body>
</html>
<% } catch(Exception e){ e.printStackTrace(); out.println("<div class='alert alert-danger m-3'><pre>"+e+"</pre></div>"); } %>