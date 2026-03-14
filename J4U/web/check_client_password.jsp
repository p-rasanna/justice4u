<%-- Document : check_client_password Created on : Check current password hash for client242@gmail.com Author : Debug
    Script --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
        <%@ include file="db_connection.jsp" %>
            <% try { Connection con=getDatabaseConnection(); out.println("<h1>Current Password Hash for
                client242@gmail.com</h1>");

                String query = "SELECT cid, cname, pass, verification_status FROM cust_reg WHERE email = ?";
                PreparedStatement pst = con.prepareStatement(query);
                pst.setString(1, "client242@gmail.com");

                ResultSet rs = pst.executeQuery();
                if (rs.next()) {
                String storedHash = rs.getString("pass");
                String verificationStatus = rs.getString("verification_status");
                String customerName = rs.getString("cname");
                int customerId = rs.getInt("cid");

                out.println("<p><strong>Name:</strong> " + customerName + "</p>");
                out.println("<p><strong>Email:</strong> client242@gmail.com</p>");
                out.println("<p><strong>Status:</strong> " + verificationStatus + "</p>");
                out.println("<p><strong>Password Hash Length:</strong> " + storedHash.length() + "</p>");
                out.println("<p><strong>Password Hash:</strong> " + storedHash + "</p>");

                // Test password verification
                boolean test123456789 = com.j4u.PasswordUtil.verifyPassword("123456789", storedHash);
                boolean testPassword123 = com.j4u.PasswordUtil.verifyPassword("password123", storedHash);

                out.println("<p><strong>Test '123456789':</strong> <span
                        style='color:" + (test123456789 ? "green" : "red") + "; font-weight:bold;'>" + test123456789 +
                        "</span></p>");
                out.println("<p><strong>Test 'password123':</strong> <span
                        style='color:" + (testPassword123 ? "green" : "red") + "; font-weight:bold;'>" + testPassword123
                        + "</span></p>");

                } else {
                out.println("<h2 style='color:red;'>User not found!</h2>");
                }

                rs.close();
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
