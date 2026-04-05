<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("cname");
  if (email == null) {
    response.sendRedirect("../auth/cust_login.jsp");
    return;
  }
  String cidStr = request.getParameter("cid");
  if (cidStr == null) {
    response.sendRedirect("clientdashboard.jsp?error=Invalid+request");
    return;
  }
  int cid;
  try {
    cid = Integer.parseInt(cidStr);
  } catch (NumberFormatException e) {
    response.sendRedirect("clientdashboard.jsp?error=Invalid+case+ID");
    return;
  }
  try (Connection con = DatabaseConfig.getConnection()) {
    PreparedStatement check = con.prepareStatement(
      "SELECT cid FROM casetb WHERE cid=? AND cname=? AND flag=1"
    );
    check.setInt(1, cid);
    check.setString(2, email);
    ResultSet rs = check.executeQuery();
    if (!rs.next()) {
      response.sendRedirect("clientdashboard.jsp?error=Case+not+found+or+already+closed");
      return;
    }
    PreparedStatement ps = con.prepareStatement("UPDATE casetb SET flag=2 WHERE cid=?");
    ps.setInt(1, cid);
    int updated = ps.executeUpdate();
    if (updated > 0) {
      try {
        PreparedStatement getLawyer = con.prepareStatement("SELECT lname FROM allotlawyer WHERE cid=? ORDER BY alid DESC LIMIT 1");
        getLawyer.setInt(1, cid);
        ResultSet rl = getLawyer.executeQuery();
        if (rl.next()) {
          String lawyerEmail = rl.getString("lname");
          com.j4u.NotificationService.create(lawyerEmail,
            "Case #" + cid + " has been closed by the client.",
            "case", "viewcases.jsp");
        }
      } catch (Exception ne) { /* notification is best-effort */ }
      response.sendRedirect("clientdashboard.jsp?msg=Case+%23" + cid + "+closed+successfully");
    } else {
      response.sendRedirect("clientdashboard.jsp?error=Failed+to+close+case");
    }
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("clientdashboard.jsp?error=Server+error");
  }
%>