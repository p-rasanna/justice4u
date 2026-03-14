<%--
    Document   : reset_client_password
    Created on : Reset client password for testing
    Author     : Admin Utility
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, java.security.MessageDigest, java.nio.charset.StandardCharsets, java.math.BigInteger, com.j4u.PasswordUtil"%>
<%@ include file="db_connection.jsp" %>
<%
    // This is a temporary utility for testing - DELETE AFTER USE
    String targetEmail = request.getParameter("email");
    String newPassword = request.getParameter("newpassword");

    if (targetEmail != null && newPassword != null) {
        try
        {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = getDatabaseConnection();

            out.println("<h1>Password Reset Utility</h1>");

            // Hash the new password
            String hashedPassword = PasswordUtil.hashPassword(newPassword);

            // Update the password
            String updateQuery = "UPDATE cust_reg SET pass = ? WHERE email = ?";
            PreparedStatement pst = con.prepareStatement(updateQuery);
            pst.setString(1, hashedPassword);
            pst.setString(2, targetEmail.trim().toLowerCase());

            int rowsAffected = pst.executeUpdate();

            if (rowsAffected > 0) {
                out.println("<h2 style='color:green;'>✓ Password Reset Successful</h2>");
                out.println("<p><strong>Email:</strong> " + targetEmail + "</p>");
                out.println("<p><strong>New Password:</strong> " + newPassword + "</p>");
                out.println("<p><strong>Hashed:</strong> " + hashedPassword.substring(0, 20) + "...</p>");
                out.println("<p>You can now login with the new password.</p>");
            } else {
                out.println("<h2 style='color:red;'>✗ User Not Found</h2>");
                out.println("<p>No user found with email: " + targetEmail + "</p>");
            }

            pst.close();
            con.close();

        }
        catch(Exception ee)
        {
            out.println("<h1 style='color:red;'>Database Error</h1>");
            out.println("<p>Error: " + ee.getMessage() + "</p>");
        }
    } else {
%>
        <h1>Reset Client Password</h1>
        <p><strong>⚠️ SECURITY WARNING:</strong> This is a temporary testing utility. Delete this file after use!</p>

        <form method="post">
            <p>Enter the client email and new password:</p>
            <p><input type="email" name="email" placeholder="Client Email" required></p>
            <p><input type="password" name="newpassword" placeholder="New Password" required></p>
            <p><button type="submit">Reset Password</button></p>
        </form>

        <h3>Available Test Clients:</h3>
        <ul>
            <li>client242@gmail.com</li>
            <li>john@test.com (password123)</li>
            <li>jane@test.com (adminpass123)</li>
            <li>test1@test.com (testpass1)</li>
        </ul>
<%
    }
%>
