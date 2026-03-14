<%--
    Document   : migrate_passwords
    Created on : Migration script for password hashing
    Author     : System Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil"%>
<%@ include file="db_connection.jsp" %>
<%
    // This script should only be run once by an admin to migrate existing passwords
    // After migration, this file should be deleted for security

    try
    {
        // Class.forName("com.mysql.jdbc.Driver");
        Connection con = getDatabaseConnection();

        out.println("<h1>Password Migration in Progress</h1>");
        out.println("<style>body{font-family:Arial;} .success{color:green;} .error{color:red;} .info{color:blue;}</style>");

        // Migrate admin passwords
        out.println("<h2>Migrating Admin Passwords...</h2>");
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT email, pass FROM admin");

        PreparedStatement updateStmt = con.prepareStatement("UPDATE admin SET pass = ? WHERE email = ?");
        int adminCount = 0;

        while(rs.next()) {
            String email = rs.getString("email");
            String oldPass = rs.getString("pass");

            // Check if already migrated (new format is longer)
            if (oldPass.length() > 32) {
                out.println("<p class='info'>Admin " + email + ": Already migrated</p>");
                continue;
            }

            // Hash the old password with new method
            String newHash = PasswordUtil.hashPassword(oldPass);
            updateStmt.setString(1, newHash);
            updateStmt.setString(2, email);
            updateStmt.executeUpdate();
            adminCount++;
            out.println("<p class='success'>Admin " + email + ": Migrated successfully</p>");
        }
        rs.close();

        // Migrate customer passwords
        out.println("<h2>Migrating Customer Passwords...</h2>");
        rs = stmt.executeQuery("SELECT email, pass FROM cust_reg");
        updateStmt = con.prepareStatement("UPDATE cust_reg SET pass = ? WHERE email = ?");
        int customerCount = 0;

        while(rs.next()) {
            String email = rs.getString("email");
            String oldPass = rs.getString("pass");

            if (oldPass.length() > 32) {
                out.println("<p class='info'>Customer " + email + ": Already migrated</p>");
                continue;
            }

            String newHash = PasswordUtil.hashPassword(oldPass);
            updateStmt.setString(1, newHash);
            updateStmt.setString(2, email);
            updateStmt.executeUpdate();
            customerCount++;
            out.println("<p class='success'>Customer " + email + ": Migrated successfully</p>");
        }
        rs.close();

        // Migrate lawyer passwords
        out.println("<h2>Migrating Lawyer Passwords...</h2>");
        rs = stmt.executeQuery("SELECT email, pass FROM lawyer_reg");
        updateStmt = con.prepareStatement("UPDATE lawyer_reg SET pass = ? WHERE email = ?");
        int lawyerCount = 0;

        while(rs.next()) {
            String email = rs.getString("email");
            String oldPass = rs.getString("pass");

            if (oldPass.length() > 32) {
                out.println("<p class='info'>Lawyer " + email + ": Already migrated</p>");
                continue;
            }

            String newHash = PasswordUtil.hashPassword(oldPass);
            updateStmt.setString(1, newHash);
            updateStmt.setString(2, email);
            updateStmt.executeUpdate();
            lawyerCount++;
            out.println("<p class='success'>Lawyer " + email + ": Migrated successfully</p>");
        }
        rs.close();

        // Migrate intern passwords
        out.println("<h2>Migrating Intern Passwords...</h2>");
        rs = stmt.executeQuery("SELECT email, pass FROM intern");
        updateStmt = con.prepareStatement("UPDATE intern SET pass = ? WHERE email = ?");
        int internCount = 0;

        while(rs.next()) {
            String email = rs.getString("email");
            String oldPass = rs.getString("pass");

            if (oldPass.length() > 32) {
                out.println("<p class='info'>Intern " + email + ": Already migrated</p>");
                continue;
            }

            String newHash = PasswordUtil.hashPassword(oldPass);
            updateStmt.setString(1, newHash);
            updateStmt.setString(2, email);
            updateStmt.executeUpdate();
            internCount++;
            out.println("<p class='success'>Intern " + email + ": Migrated successfully</p>");
        }
        rs.close();

        updateStmt.close();
        stmt.close();
        con.close();

        out.println("<h1 class='success'>Migration Complete!</h1>");
        out.println("<div style='background:#e8f5e8; padding:15px; border:1px solid #4CAF50; margin:20px 0;'>");
        out.println("<h3>Migration Summary:</h3>");
        out.println("<ul>");
        out.println("<li><strong>Admins migrated:</strong> " + adminCount + "</li>");
        out.println("<li><strong>Customers migrated:</strong> " + customerCount + "</li>");
        out.println("<li><strong>Lawyers migrated:</strong> " + lawyerCount + "</li>");
        out.println("<li><strong>Interns migrated:</strong> " + internCount + "</li>");
        out.println("</ul>");
        out.println("</div>");

        out.println("<div style='background:#fff3cd; padding:15px; border:1px solid #ffc107; margin:20px 0;'>");
        out.println("<h3>⚠️ Security Notice:</h3>");
        out.println("<p><strong>Important:</strong> Delete this migration script immediately after confirming everything works!</p>");
        out.println("<p>All existing users should now be able to login with their previous passwords.</p>");
        out.println("<p>New registrations will automatically use the secure hashing.</p>");
        out.println("</div>");

        out.println("<div style='background:#d1ecf1; padding:15px; border:1px solid #17a2b8; margin:20px 0;'>");
        out.println("<h3>Next Steps:</h3>");
        out.println("<ol>");
        out.println("<li>Test login with existing accounts</li>");
        out.println("<li>Test new user registration</li>");
        out.println("<li>Delete this migration file</li>");
        out.println("<li>Delete test files (test_password_hashing.jsp)</li>");
        out.println("</ol>");
        out.println("</div>");

    }
    catch(Exception ee)
    {
        out.println("<h1 class='error'>Migration Error</h1>");
        out.println("<div style='background:#f8d7da; padding:15px; border:1px solid #dc3545; margin:20px 0;'>");
        out.println("<h3>Error Details:</h3>");
        out.println("<p><strong>Message:</strong> " + ee.getMessage() + "</p>");
        out.println("<p><strong>Type:</strong> " + ee.getClass().getName() + "</p>");
        out.println("</div>");
        ee.printStackTrace();
    }
%>
