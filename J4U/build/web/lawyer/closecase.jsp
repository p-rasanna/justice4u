<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
  String lEmail = (String) session.getAttribute("lname");
  if (lEmail == null) { response.sendRedirect("../auth/Lawyer_login_form.jsp?error=Session expired"); return; }
  String alidStr = request.getParameter("alid");
  if (alidStr == null) { response.sendRedirect("viewcases.jsp?msg=Invalid request"); return; }
  int alid = Integer.parseInt(alidStr);
  Connection con = null;
  try {
    con = DatabaseConfig.getConnection();
    PreparedStatement pst;
    pst = con.prepareStatement("SELECT cname, title FROM allotlawyer WHERE alid=? AND lname=?");
    pst.setInt(1, alid); pst.setString(2, lEmail);
    ResultSet rs = pst.executeQuery();
    if (!rs.next()) { response.sendRedirect("viewcases.jsp?msg=Unauthorized"); return; }
    String clientEmail = rs.getString("cname");
    String caseTitle = rs.getString("title");
    rs.close(); pst.close();
    pst = con.prepareStatement("UPDATE allotlawyer SET status='Closed' WHERE alid=?");
    pst.setInt(1, alid); pst.executeUpdate(); pst.close();
    try {
      pst = con.prepareStatement("UPDATE casetb SET status='CLOSED' WHERE cname=? AND title=?");
      pst.setString(1, clientEmail); pst.setString(2, caseTitle);
      pst.executeUpdate(); pst.close();
    } catch (Exception ignored) {}
    try {
      pst = con.prepareStatement(
        "INSERT INTO case_timeline (alid, event_type, event_description, created_by) VALUES (?,?,?,?)");
      pst.setInt(1, alid);
      pst.setString(2, "CASE_CLOSED");
      pst.setString(3, "Lawyer " + lEmail + " closed the case: " + caseTitle + ". Case is now completed.");
      pst.setString(4, lEmail);
      pst.executeUpdate(); pst.close();
    } catch (Exception ignored) {}
    try {
      com.j4u.NotificationService.create(clientEmail,
        "Your case '" + caseTitle + "' has been successfully closed by your lawyer. The matter is resolved.",
        "case", "../client/clientdashboard.jsp");
    } catch (Exception e) { e.printStackTrace(); }
    response.sendRedirect("Lawyerdashboard.jsp?msg=Case closed successfully.");
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("viewcases.jsp?msg=Error: " + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
  } finally {
    if (con != null) try { con.close(); } catch (Exception ignored) {}
  }
%>