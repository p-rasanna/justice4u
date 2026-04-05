<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%@ page import="com.j4u.NotificationService" %>
<%
  String email = (String) session.getAttribute("lname");
  if (email == null) {
    response.sendRedirect("../auth/Login.jsp");
    return;
  }
  String caseIdStr = request.getParameter("case_id");
  if (caseIdStr == null || caseIdStr.trim().isEmpty()) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+case");
    return;
  }
  int caseId;
  try {
    caseId = Integer.parseInt(caseIdStr);
  } catch (NumberFormatException e) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+case");
    return;
  }
  String method = request.getMethod();
  String msg = "";
  String currentTitle = "";
  String currentStatus = "";
  String clientEmail = "";
  try (Connection con = DatabaseConfig.getConnection()) {
    String checkSql = "SELECT c.title, c.status, c.cname as client_email FROM casetb c JOIN allotlawyer al ON c.cid=al.cid WHERE c.cid=? AND al.lname=?";
    try (PreparedStatement ps = con.prepareStatement(checkSql)) {
      ps.setInt(1, caseId);
      ps.setString(2, email);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          currentTitle = rs.getString("title");
          currentStatus = rs.getString("status");
          clientEmail = rs.getString("client_email");
        } else {
          response.sendRedirect("Lawyerdashboard.jsp?msg=Unauthorized+access");
          return;
        }
      }
    }
    if ("POST".equalsIgnoreCase(method)) {
      String newStatus = request.getParameter("status");
      int newFlag = -1;
      if ("IN_PROGRESS".equals(newStatus)) newFlag = 3;
      else if ("HEARING_SCHEDULED".equals(newStatus)) newFlag = 3;
      else if ("CLOSED".equals(newStatus)) newFlag = 4;
      if (newFlag != -1) {
        try (PreparedStatement ps = con.prepareStatement("UPDATE casetb SET status=?, flag=? WHERE cid=?")) {
          ps.setString(1, newStatus);
          ps.setInt(2, newFlag);
          ps.setInt(3, caseId);
          ps.executeUpdate();
        }
        NotificationService.create(clientEmail, "Your case status has been updated to: " + newStatus, "case", "../client/mycases.jsp");
        response.sendRedirect("Lawyerdashboard.jsp?msg=Status+updated+successfully");
        return;
      } else {
        msg = "Invalid status selected.";
      }
    }
  } catch (Exception e) {
    e.printStackTrace();
    msg = "Server Error. Please try again.";
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <jsp:include page="components/_head.jsp" />
  <title>Update Case Status</title>
</head>
<body>
  <div class="app-layout">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main-content">
      <div class="container-fluid">
        <div class="card shadow" style="max-width: 600px; margin: 0 auto; margin-top: 50px;">
          <div class="card-header bg-white">
            <h5 class="m-0 font-weight-bold text-dark">Update Status: <%= currentTitle %></h5>
          </div>
          <div class="card-body">
            <% if (!msg.isEmpty()) { %>
              <div class="alert alert-danger"><%= msg %></div>
            <% } %>
            <form method="POST" action="update_case_status.jsp?case_id=<%= caseId %>">
              <div class="mb-3">
                <label class="form-label text-muted">Current Status</label>
                <input type="text" class="form-control bg-light" value="<%= currentStatus %>" readonly>
              </div>
              <div class="mb-4">
                <label class="form-label form-label-required">New Status</label>
                <select name="status" class="form-select" required>
                  <option value="" disabled selected>Select new status...</option>
                  <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(currentStatus) ? "disabled" : "" %>>IN_PROGRESS</option>
                  <option value="HEARING_SCHEDULED" <%= "HEARING_SCHEDULED".equals(currentStatus) ? "disabled" : "" %>>HEARING_SCHEDULED</option>
                  <option value="CLOSED" <%= "CLOSED".equals(currentStatus) ? "disabled" : "" %>>CLOSED</option>
                </select>
              </div>
              <div class="d-grid gap-2">
                <button type="submit" class="btn btn-dark">Confirm Update</button>
                <a href="Lawyerdashboard.jsp" class="btn btn-outline-secondary">Cancel</a>
              </div>
            </form>
          </div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>