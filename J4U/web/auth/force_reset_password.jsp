<%--
    Document   : force_reset_password
    Created on : Force reset password for client242@gmail.com
    Author     : Admin Utility
--%>
<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil"%>
<%@ include file="../shared/db_connection.jsp" %>
<%
    try
    {
        // Class.forName("com.mysql.jdbc.Driver");
        Connection con = getDatabaseConnection();
        out.println("<h1>Forced Password Reset for client242@gmail.com</h1>");
        // Hash the new password
        String newPassword = "test123";
        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        out.println("<p><strong>New Password:</strong> " + newPassword + "</p>");
        out.println("<p><strong>Generated Hash:</strong> " + hashedPassword + "</p>");
        // Update the password
        String updateQuery = "UPDATE cust_reg SET pass = ? WHERE email = ?";
        PreparedStatement pst = con.prepareStatement(updateQuery);
        pst.setString(1, hashedPassword);
        pst.setString(2, "client242@gmail.com");
        int rowsAffected = pst.executeUpdate();
        out.println("<p><strong>Rows Updated:</strong> " + rowsAffected + "</p>");
        if (rowsAffected > 0) {
            out.println("<h2 style='color:green;'>âœ“ Password Reset Successful</h2>");
            // Verify the update worked
            String verifyQuery = "SELECT pass FROM cust_reg WHERE email = ?";
            PreparedStatement verifyPst = con.prepareStatement(verifyQuery);
            verifyPst.setString(1, "client242@gmail.com");
            ResultSet rs = verifyPst.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("pass");
                boolean verificationTest = PasswordUtil.verifyPassword(newPassword, storedHash);
                out.println("<p><strong>Stored Hash After Update:</strong> " + storedHash + "</p>");
                out.println("<p><strong>Verification Test:</strong> <span style='color:" + (verificationTest ? "green" : "red") + "; font-weight:bold;'>" + verificationTest + "</span></p>");
                if (verificationTest) {
                    out.println("<h3 style='color:green;'>âœ“ VERIFICATION PASSED - You can now login!</h3>");
                    out.println("<p><strong>Login Credentials:</strong></p>");
                    out.println("<ul>");
                    out.println("<li><strong>Email:</strong> client242@gmail.com</li>");
                    out.println("<li><strong>Password:</strong> test123</li>");
                    out.println("</ul>");
                } else {
                    out.println("<h3 style='color:red;'>âœ— VERIFICATION FAILED - Something is wrong</h3>");
                }
            }
            rs.close();
            verifyPst.close();
        } else {
            out.println("<h2 style='color:red;'>âœ— Password Reset Failed</h2>");
            out.println("<p>No rows were updated. User may not exist.</p>");
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
