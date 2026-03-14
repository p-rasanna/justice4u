<%-- 
    Document   : Login
    Created on : 21 Mar, 2025, 8:26:11 PM
    Author     : ZulkiflMugad
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil, java.io.InputStream, java.util.Properties, java.math.BigInteger"%>
<%@ include file="db_connection.jsp" %>
<%
    try
    {
        String username = request.getParameter("txtname");
        String password = request.getParameter("txtpass");

        // Input validation
        if(username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("Login.html?error=invalid");
            return;
        }

        username = username.trim();
        password = password.trim();

        if(username.length() < 3 || password.length() < 6) {
            response.sendRedirect("Login.html?error=invalid");
            return;
        }

        // Use standard DB connection utility
        Connection con = getDatabaseConnection();

        // Use prepared statement to get stored password hash
        String query = "SELECT email, pass FROM admin WHERE email = ?";
        PreparedStatement pst = con.prepareStatement(query);
        pst.setString(1, username);

        ResultSet rs = pst.executeQuery();

        if(rs.next())
        {
            // Secure password check with legacy fallback
            String storedPass = rs.getString("pass");
            boolean isPasswordValid = PasswordUtil.verifyPassword(password, storedPass);
            boolean isLegacyPasswordValid = password.equals(storedPass);

            if(isPasswordValid || isLegacyPasswordValid) {
                 session.setAttribute("aname", username);
                 session.setAttribute("role", "admin"); // REQUIRED for J4USecurityFilter
                 response.sendRedirect("admindashboard.jsp");
            } else {
                 response.sendRedirect("Login.html?error=invalid");
            }
        }
        else
        {
            response.sendRedirect("Login.html?error=invalid");
        }

        // Close resources
        rs.close();
        pst.close();
        con.close();
    }
    catch(Exception ee)
    {
        // Log error instead of printing to page
        ee.printStackTrace();
        response.sendRedirect("Login.html?error=system");
    }
%>
