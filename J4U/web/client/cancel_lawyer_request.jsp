<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig" %>
<%
  String clientEmail = (String) session.getAttribute("cname");
  if (clientEmail == null) { response.sendRedirect("../auth/cust_login.jsp"); return; }
  String requestIdStr = request.getParameter("request_id");
  if (requestIdStr == null) {
    response.sendRedirect("clientdashboard.jsp?msg=Invalid+request"); return;
  }
  int requestId;
  try { requestId = Integer.parseInt(requestIdStr); }
  catch (NumberFormatException e) { response.sendRedirect("clientdashboard.jsp?msg=Invalid+request"); return; }
  try (Connection con = DatabaseConfig.getConnection()) {
    int  caseId    = 0;
    String reqStatus = null;
    try (PreparedStatement ps = con.prepareStatement(
        "SELECT case_id, status FROM lawyer_requests WHERE request_id=? AND client_email=?")) {
      ps.setInt(1, requestId);
      ps.setString(2, clientEmail);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          caseId    = rs.getInt("case_id");
          reqStatus = rs.getString("status");
        }
      }
    }
    if (caseId == 0) {
      response.sendRedirect("clientdashboard.jsp?msg=Request+not+found"); return;
    }
    if (!"PENDING".equals(reqStatus)) {
      response.sendRedirect("clientdashboard.jsp?msg=Cannot+cancel+a+processed+request"); return;
    }
    try (PreparedStatement ps = con.prepareStatement(
        "UPDATE lawyer_requests SET status='CANCELLED' WHERE request_id=?")) {
      ps.setInt(1, requestId); ps.executeUpdate();
    }
    try (PreparedStatement ps = con.prepareStatement(
        "UPDATE casetb SET case_status='SEARCHING' WHERE cid=? AND assignment_type='MANUAL'")) {
      ps.setInt(1, caseId); ps.executeUpdate();
    }
    response.sendRedirect("clientdashboard.jsp?msg=Request+cancelled.+You+can+now+choose+another+lawyer.");
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("clientdashboard.jsp?msg=Server+error+while+cancelling");
  }
%>