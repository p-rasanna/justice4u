<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String user=(String)session.getAttribute("lname"), f=request.getParameter("f");
  if(user==null){ response.sendRedirect("../auth/Lawyer_login_form.jsp"); return; }
  java.util.List<String[]> list=new java.util.ArrayList<>();
  try(Connection con=DatabaseConfig.getConnection()){
    String sql="SELECT al.alid, al.cid, al.cname, al.title, c.flag, al.curdate FROM allotlawyer al JOIN casetb c ON al.cid=c.cid WHERE al.lname=?" + ("a".equals(f)?" AND c.flag >= 1":"") + " ORDER BY al.alid DESC";
    PreparedStatement ps=con.prepareStatement(sql);
    ps.setString(1,user);
    ResultSet rs=ps.executeQuery();
    while(rs.next()) {
      int flag = rs.getInt("flag");
      String statusStr = flag == 0 ? "PENDING" : (flag == 1 ? "ACTIVE" : "CLOSED");
      list.add(new String[]{
        String.valueOf(rs.getInt("alid")),
        rs.getString("cname"),
        rs.getString("title"),
        statusStr,
        rs.getString("curdate"),
        String.valueOf(rs.getInt("cid"))
      });
    }
  } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Case Repository"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="../shared/_sidebar.jsp" />
    <main class="app-main">
      <jsp:include page="../shared/_topbar.jsp">
        <jsp:param name="title" value="Legal Repository"/>
        <jsp:param name="subtitle" value="Case Management Archive"/>
      </jsp:include>
      <div class="app-content pt-4">
        <div class="container-fluid text-start">
          <% if(request.getParameter("msg") != null) { %>
          <div class="alert alert-success alert-dismissible fade show border-0 mb-4" style="border-left: 4px solid var(--success) !important;">
            <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
          <% } %>
          <div class="mb-4 d-flex flex-wrap gap-2 align-items-center">
            <span class="text-muted small fw-bold text-uppercase ls-1 me-2">Registry View:</span>
            <a href="viewcases.jsp" class="btn btn-sm btn-outline-dark rounded-pill px-4 <%= f == null ? "active btn-dark text-white shadow-sm" : "" %>">All Entrustments</a>
            <a href="viewcases.jsp?f=a" class="btn btn-sm btn-outline-dark rounded-pill px-4 <%= "a".equals(f) ? "active btn-dark text-white shadow-sm" : "" %>">Active Mandates</a>
          </div>
          <div class="row g-4">
            <% if(list.isEmpty()){ %>
              <div class="col-12">
                <div class="card border-0 shadow-sm rounded-4 text-center py-5">
                  <div class="card-body">
                    <i class="bi bi-folder-x display-4 text-muted opacity-25"></i>
                    <h5 class="mt-3 text-muted">No case files located in this repository.</h5>
                    <p class="small text-muted">New assignments will appear here once approved by the administrator.</p>
                  </div>
                </div>
              </div>
            <% } else { %>
              <% for(String[] c : list){ %>
                <div class="col-xl-4 col-md-6">
                  <div class="card border-0 shadow-sm rounded-4 h-100 attorney-card transition-base overflow-hidden">
                    <div class="card-body p-4 d-flex flex-column">
                      <div class="d-flex justify-content-between align-items-start mb-3">
                        <div>
                          <span class="badge bg-gold-subtle text-gold px-3 mb-2 text-uppercase fw-bold" style="font-size: 0.65rem; letter-spacing: 0.5px;">
                            <%= c[3] %>
                          </span>
                          <h5 class="card-title fw-bold mb-1 text-serif"><%= c[2] %></h5>
                        </div>
                        <div class="text-muted small fw-bold text-uppercase" style="font-size: 0.7rem;">#<%= c[0] %></div>
                      </div>
                      <div class="mb-4">
                        <div class="text-muted small fw-bold text-uppercase ls-1 mb-1" style="font-size: 0.65rem;">Primary Client</div>
                        <div class="text-dark small fw-semibold"><i class="bi bi-person-fill text-gold me-2"></i><%= c[1] %></div>
                      </div>
                      <div class="d-flex align-items-center gap-3 text-muted small mb-4 py-2 border-top border-light">
                        <span><i class="bi bi-calendar3 me-2"></i><%= c[4] %></span>
                      </div>
                      <div class="d-flex gap-2 mt-auto">
                        <a href="../shared/caseDiscussion.jsp?case_id=<%= c[5] %>" class="btn btn-gold flex-fill rounded-3 py-2 fw-bold shadow-sm border-0">
                          Discussion <i class="bi bi-chat-left-dots-fill ms-2"></i>
                        </a>
                        <% if("ACTIVE".equals(c[3])) { %>
                        <a href="close_case.jsp?cid=<%= c[5] %>" class="btn btn-outline-danger rounded-3 px-3 py-2 fw-bold" onclick="return confirm('Are you sure you want to close this case? This action cannot be undone.');">
                          <i class="bi bi-x-circle-fill"></i>
                        </a>
                        <% } %>
                      </div>
                    </div>
                  </div>
                </div>
              <% } %>
            <% } %>
          </div>
        </div>
      </div>
      <jsp:include page="../shared/_footer.jsp" />
    </main>
  </div>
</body>
</html>