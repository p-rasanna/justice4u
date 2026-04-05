<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String email = null, role = null;
  if (session.getAttribute("cname") != null) { email=(String)session.getAttribute("cname"); role="client"; }
  else if (session.getAttribute("lname") != null) { email=(String)session.getAttribute("lname"); role="lawyer"; }
  else if (session.getAttribute("iname") != null) { email=(String)session.getAttribute("iname"); role="intern"; }
  else if (session.getAttribute("aname") != null) { email=(String)session.getAttribute("aname"); role="admin"; }
  if (email == null) { response.sendRedirect(request.getContextPath() + "/auth/cust_login.jsp"); return; }
  java.util.List<String[]> cases = new java.util.ArrayList<>();
  try (Connection con = DatabaseConfig.getConnection()) {
    String sql = "";
    if ("client".equals(role)) {
      sql = "SELECT c.cid, c.title, c.courttype, c.city, c.curdate, " +
          "(SELECT COUNT(*) FROM case_messages m WHERE m.case_id=c.cid) as msg_count " +
          "FROM casetb c WHERE c.cname=? ORDER BY c.cid DESC";
    } else if ("lawyer".equals(role)) {
      sql = "SELECT c.cid, c.title, c.courttype, c.city, c.curdate, " +
          "(SELECT COUNT(*) FROM case_messages m WHERE m.case_id=c.cid) as msg_count " +
          "FROM casetb c JOIN allotlawyer a ON a.cid=c.cid WHERE a.lname=? ORDER BY c.cid DESC";
    } else if ("admin".equals(role)) {
      sql = "SELECT c.cid, c.title, c.courttype, c.city, c.curdate, " +
          "(SELECT COUNT(*) FROM case_messages m WHERE m.case_id=c.cid) as msg_count " +
          "FROM casetb c ORDER BY c.cid DESC LIMIT 50";
    } else {
      sql = "SELECT c.cid, c.title, c.courttype, c.city, c.curdate, " +
          "(SELECT COUNT(*) FROM case_messages m WHERE m.case_id=c.cid) as msg_count " +
          "FROM casetb c ORDER BY c.cid DESC LIMIT 20";
    }
    PreparedStatement ps = con.prepareStatement(sql);
    if (!"admin".equals(role)) ps.setString(1, email);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      cases.add(new String[]{
        String.valueOf(rs.getInt("cid")),
        rs.getString("title") != null ? rs.getString("title") : "Untitled Case",
        rs.getString("courttype") != null ? rs.getString("courttype") : "--",
        rs.getString("city") != null ? rs.getString("city") : "--",
        rs.getString("curdate") != null ? rs.getString("curdate") : "--",
        String.valueOf(rs.getInt("msg_count"))
      });
    }
  } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Case Discussions"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
<div class="app-wrapper">
  <jsp:include page="../shared/_sidebar.jsp" />
  <main class="app-main">
    <jsp:include page="../shared/_topbar.jsp"><jsp:param name="title" value="Case Discussions"/></jsp:include>
    <div class="app-content pt-4">
      <div class="container-fluid">
        <div class="mb-4">
          <h3 class="text-serif fw-bold mb-1">Case Discussions</h3>
          <p class="text-muted small mb-0">Select a case to view or participate in its discussion thread.</p>
        </div>
        <% if (cases.isEmpty()) { %>
          <div class="card border-0 text-center py-5">
            <div class="card-body">
              <i class="bi bi-chat-square-dots display-4 text-muted opacity-25"></i>
              <h5 class="mt-3 text-muted">No Cases Available</h5>
              <p class="small text-muted">You don't have any cases yet. File a new case to start a discussion.</p>
              <% if ("client".equals(role)) { %>
              <a href="${pageContext.request.contextPath}/client/case.jsp" class="btn px-4 mt-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                <i class="bi bi-plus-lg me-2"></i>File New Case
              </a>
              <% } %>
            </div>
          </div>
        <% } else { %>
          <div class="row g-3">
            <% for (String[] c : cases) {
              int msgCount = Integer.parseInt(c[5]);
            %>
            <div class="col-xl-4 col-md-6">
              <a href="${pageContext.request.contextPath}/shared/caseDiscussion.jsp?case_id=<%= c[0] %>" class="text-decoration-none">
                <div class="card border-0 h-100">
                  <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                      <span class="fw-bold" style="color:var(--gold);">#<%= c[0] %></span>
                      <% if (msgCount > 0) { %>
                      <span class="badge rounded-pill fw-normal" style="background:var(--gold);color:#111827;font-size:0.7rem;">
                        <i class="bi bi-chat-dots me-1"></i><%= msgCount %>
                      </span>
                      <% } else { %>
                      <span class="badge bg-light text-muted fw-normal" style="font-size:0.7rem;">No messages</span>
                      <% } %>
                    </div>
                    <h6 class="fw-bold text-dark text-serif mb-2"><%= c[1] %></h6>
                    <div class="d-flex flex-wrap gap-2 text-muted small">
                      <span><i class="bi bi-bank me-1"></i><%= c[2] %></span>
                      <span><i class="bi bi-geo-alt me-1"></i><%= c[3] %></span>
                      <span><i class="bi bi-calendar3 me-1"></i><%= c[4] %></span>
                    </div>
                  </div>
                </div>
              </a>
            </div>
            <% } %>
          </div>
        <% } %>
      </div>
    </div>
    <jsp:include page="../shared/_footer.jsp" />
  </main>
</div>
</body>
</html>