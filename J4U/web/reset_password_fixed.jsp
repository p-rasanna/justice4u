<%--
    Document   : reset_password_fixed
    Created on : Reset password with fixed hashing
    Author     : Admin Utility
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, java.security.MessageDigest, java.nio.charset.StandardCharsets, java.math.BigInteger, com.j4u.PasswordUtil"%>
<%@ include file="db_connection.jsp" %>
<%
    try
    {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = getDatabaseConnection();

        out.println("<h1>Password Reset with Fixed Hashing</h1>");

        String newPassword = "test123";
        String hashedPassword = PasswordUtil.hashPassword(newPassword);

        out.println("<p><strong>New Password:</strong> " + newPassword + "</p>");
        out.println("<p><strong>Generated Hash:</strong> " + hashedPassword + "</p>");
        out.println("<p><strong>Hash Length:</strong> " + hashedPassword.length() + "</p>");
        out.println("<p><strong>Contains +:</strong> " + hashedPassword.contains("+") + "</p>");
        out.println("<p><strong>Contains /:</strong> " + hashedPassword.contains("/") + "</p>");
        out.println("<p><strong>Ends with =:</strong> " + hashedPassword.endsWith("=") + "</p>");

        // Test verification
        boolean testVerify = PasswordUtil.verifyPassword(newPassword, hashedPassword);
        out.println("<p><strong>Self-verification:</strong> " + testVerify + "</p>");

        // Update the database
        String updateQuery = "UPDATE cust_reg SET pass = ? WHERE email = ?";
        PreparedStatement pst = con.prepareStatement(updateQuery);
        pst.setString(1, hashedPassword);
        pst.setString(2, "client242@gmail.com");

        int rowsAffected = pst.executeUpdate();
        out.println("<p><strong>Rows Updated:</strong> " + rowsAffected + "</p>");

        if (rowsAffected > 0) {
            out.println("<h2 style='color:green;'>✓ Password Reset Successful</h2>");

            // Verify the database update
            String verifyQuery = "SELECT pass FROM cust_reg WHERE email = ?";
            PreparedStatement verifyPst = con.prepareStatement(verifyQuery);
            verifyPst.setString(1, "client242@gmail.com");

            ResultSet rs = verifyPst.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("pass");
                boolean dbVerify = PasswordUtil.verifyPassword(newPassword, storedHash);

                out.println("<p><strong>Stored Hash After Update:</strong> " + storedHash + "</p>");
                out.println("<p><strong>Database Verification:</strong> <span style='color:" + (dbVerify ? "green" : "red") + "; font-weight:bold;'>" + dbVerify + "</span></p>");

                if (dbVerify) {
                    out.println("<h3 style='color:green;'>✓ SUCCESS - You can now login!</h3>");
                    out.println("<p><strong>Login Credentials:</strong></p>");
                    out.println("<ul>");
                    out.println("<li><strong>Email:</strong> client242@gmail.com</li>");
                    out.println("<li><strong>Password:</strong> test123</li>");
                    out.println("</ul>");
                } else {
                    out.println("<h3 style='color:red;'>✗ VERIFICATION FAILED</h3>");
                }
            }

            rs.close();
            verifyPst.close();
        } else {
            out.println("<h2 style='color:red;'>✗ Password Reset Failed</h2>");
        }

        pst.close();
        con.close();

    }
    catch(Exception ee)
    {
        out.println("<h1 style='color:red;'>Database Error</h1>");
        out.println("<p>Error: " + ee.getMessage() + "</p>");
        ee.printStackTrace();
    }
%>
