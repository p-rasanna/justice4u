<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("lname");
  if (email == null) {
    response.sendRedirect("../auth/Login.jsp");
    return;
  }
  String cidStr = request.getParameter("cid");
  if (cidStr == null) {
    response.sendRedirect("viewcases.jsp?msg=Invalid+request");
    return;
  }
  int cid;
  try {
    cid = Integer.parseInt(cidStr);
  } catch (NumberFormatException e) {
    response.sendRedirect("viewcases.jsp?msg=Invalid+case+ID");
    return;
  }
  try (Connection con = DatabaseConfig.getConnection()) {
    PreparedStatement check = con.prepareStatement(
      "SELECT al.cid FROM allotlawyer al JOIN casetb c ON al.cid=c.cid WHERE al.cid=? AND al.lname=? AND c.flag=1"
    );
    check.setInt(1, cid);
    check.setString(2, email);
    ResultSet rs = check.executeQuery();
    if (!rs.next()) {
      response.sendRedirect("viewcases.jsp?msg=Case+not+found+or+already+closed");
      return;
    }
    PreparedStatement ps = con.prepareStatement("UPDATE casetb SET flag=2 WHERE cid=?");
    ps.setInt(1, cid);
    int updated = ps.executeUpdate();
    if (updated > 0) {
      try {
        PreparedStatement getClient = con.prepareStatement("SELECT cname FROM casetb WHERE cid=?");
        getClient.setInt(1, cid);
        ResultSet rc = getClient.executeQuery();
        if (rc.next()) {
          String clientEmail = rc.getString("cname");
          com.j4u.NotificationService.create(clientEmail,
            "Your case #" + cid + " has been closed by your assigned lawyer.",
            "case", "../client/client_case_details.jsp?cid=" + cid);
        }
      } catch (Exception ne) { /* notification is best-effort */ }
      response.sendRedirect("viewcases.jsp?msg=Case+%23" + cid + "+closed+successfully");
    } else {
      response.sendRedirect("viewcases.jsp?msg=Failed+to+close+case");
    }
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("viewcases.jsp?msg=Server+error");
  }
%>