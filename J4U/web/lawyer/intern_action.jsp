<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("lname");
  if (email == null) {
    response.sendRedirect("../auth/Login.jsp");
    return;
  }
  String idStr = request.getParameter("id");
  String action = request.getParameter("action");
  if (idStr == null || action == null) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
    return;
  }
  int assignId;
  try {
    assignId = Integer.parseInt(idStr);
  } catch (NumberFormatException e) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
    return;
  }
  try (Connection con = DatabaseConfig.getConnection()) {
    PreparedStatement check = con.prepareStatement(
      "SELECT intern_email FROM intern_lawyer_assignments WHERE id=? AND lawyer_email=? AND status='PENDING'"
    );
    check.setInt(1, assignId);
    check.setString(2, email);
    ResultSet rs = check.executeQuery();
    if (!rs.next()) {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Assignment+not+found+or+already+processed");
      return;
    }
    String internEmail = rs.getString("intern_email");
    if ("accept".equals(action)) {
      PreparedStatement ps = con.prepareStatement(
        "UPDATE intern_lawyer_assignments SET status='ACCEPTED', response_date=NOW() WHERE id=?"
      );
      ps.setInt(1, assignId);
      ps.executeUpdate();
      try {
        com.j4u.NotificationService.create(internEmail,
          "Your assignment has been accepted! You now have access to your lawyer's cases.",
          "assignment", "../intern/interndashboard.jsp");
      } catch(Exception ne){}
      response.sendRedirect("Lawyerdashboard.jsp?msg=Intern+accepted+successfully");
    } else if ("reject".equals(action)) {
      PreparedStatement ps = con.prepareStatement(
        "UPDATE intern_lawyer_assignments SET status='REJECTED', response_date=NOW() WHERE id=?"
      );
      ps.setInt(1, assignId);
      ps.executeUpdate();
      try {
        com.j4u.NotificationService.create(internEmail,
          "Your assignment request was not approved. The admin will reassign you.",
          "assignment", "../intern/interndashboard.jsp");
      } catch(Exception ne){}
      response.sendRedirect("Lawyerdashboard.jsp?msg=Intern+assignment+rejected");
    } else {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+action");
    }
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("Lawyerdashboard.jsp?msg=Server+error");
  }
%>