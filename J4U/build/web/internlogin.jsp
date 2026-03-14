<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil" %>
<%@ include file="db_connection.jsp" %>
<%
    try {
        String email = request.getParameter("txtname");
        String password = request.getParameter("txtpass");
        
        /* Check for null parameters */
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
            
            /* Check both secure hash and legacy plain text */
            boolean isPasswordValid = PasswordUtil.verifyPassword(password.trim(), storedHash);
            boolean isLegacyPasswordValid = password.trim().equals(storedHash);

            if (isPasswordValid || isLegacyPasswordValid) {
                // Check if already logged in as intern
                if (session.getAttribute("iname") != null) {
                    // Already logged in as intern, redirect to dashboard
                    response.sendRedirect("interndashboard.jsp");
                    rs.close();
                    pst.close();
                    con.close();
                    return;
                }

                // Set session attribute (add intern role to existing session)
                session.setAttribute("iname", email.trim());
                session.setAttribute("role", "intern"); // REQUIRED for J4USecurityFilter
                response.sendRedirect("interndashboard.jsp");
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