<%-- Document : check_passwords Created on : Check current password formats in database Author : System Check --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
        <%@ include file="db_connection.jsp" %>
            <% // Check current password formats in database try { Connection con=getDatabaseConnection();
                out.println("<h1>Current Password Formats Check</h1>");
                out.println("<style>
                    body {
                        font-family: Arial;
                    }

                    .old {
                        color: orange;
                    }

                    .new {
                        color: green;
                    }

                    .unknown {
                        color: red;
                    }
                </style>");

                // Check customer passwords
                out.println("<h2>Customer Passwords</h2>");
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT email, pass, verification_status FROM cust_reg LIMIT 10");

                while(rs.next()) {
                String email = rs.getString("email");
                String storedHash = rs.getString("pass");
                String status = rs.getString("verification_status");

                String format = "unknown";
                String color = "unknown";

                if (storedHash.length() > 32 && storedHash.contains("=")) {
                format = "new (SHA-256 + salt)";
                color = "new";
                } else if (storedHash.length() == 32 && !storedHash.contains("=")) {
                format = "old (MD5)";
                color = "old";
                } else {
                format = "plaintext or other";
                color = "unknown";
                }

                out.println("<p><strong>" + email + "</strong> (" + status + "): <span class='" + color + "'>" + format
                        + "</span> - Length: " + storedHash.length() + "</p>");
                }
                rs.close();

                // Check admin passwords
                out.println("<h2>Admin Passwords</h2>");
                rs = stmt.executeQuery("SELECT email, pass FROM admin");
                while(rs.next()) {
                String email = rs.getString("email");
                String storedHash = rs.getString("pass");

                String format = "unknown";
                String color = "unknown";

                if (storedHash.length() > 32 && storedHash.contains("=")) {
                format = "new (SHA-256 + salt)";
                color = "new";
                } else if (storedHash.length() == 32 && !storedHash.contains("=")) {
                format = "old (MD5)";
                color = "old";
                } else {
                format = "plaintext or other";
                color = "unknown";
                }

                out.println("<p><strong>" + email + "</strong>: <span class='" + color + "'>" + format + "</span> -
                    Length: " + storedHash.length() + "</p>");
                }
                rs.close();

                stmt.close();
                con.close();

                out.println("<h2>Summary</h2>");
                out.println("<p>If you see 'old (MD5)' or 'plaintext or other' formats, you need to run the migration
                    script.</p>");
                out.println("<p><a href='migrate_passwords.jsp'>Run Migration Script</a></p>");

                }
                catch(Exception ee)
                {
                out.println("<h1>Database Error</h1>");
                out.println("<p>Error: " + ee.getMessage() + "</p>");
                ee.printStackTrace();
                }
                %>