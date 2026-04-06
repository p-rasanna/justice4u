<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil" %>
<%@ include file="../shared/db_connection.jsp" %>
<%
  try {
    String email = request.getParameter("txtname");
    String password = request.getParameter("txtpass");
    if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
      response.sendRedirect("internlogin.html?msg=Please enter both email and password");
      return;
    }
    Connection con = getDatabaseConnection();
    String query = "SELECT email, pass FROM intern WHERE flag=1 AND email=?";
    PreparedStatement pst = con.prepareStatement(query);
    pst.setString(1, email.trim());
    ResultSet rs = pst.executeQuery();
    if (rs.next()) {
      String storedHash = rs.getString("pass");
      boolean isPasswordValid = PasswordUtil.verifyPassword(password.trim(), storedHash);
      boolean isLegacyPasswordValid = password.trim().equals(storedHash);
      if (isPasswordValid || isLegacyPasswordValid) {
        if (session.getAttribute("iname") != null) {
          response.sendRedirect("../intern/interndashboard.jsp");
          rs.close();
          pst.close();
          con.close();
          return;
        }
        session.setAttribute("iname", email.trim());
        session.setAttribute("role", "intern"); // REQUIRED for J4USecurityFilter
        response.sendRedirect("../intern/interndashboard.jsp");
      } else {
        response.sendRedirect("internlogin.html?msg=Invalid credentials");
      }
    } else {
      response.sendRedirect("internlogin.html?msg=Invalid credentials");
    }
    rs.close();
    pst.close();
    con.close();
  } catch (Exception e) {
    e.printStackTrace();
    out.println("Error: " + e.getMessage());
  }
%>