<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<%
    try {
        Connection con = getDatabaseConnection();
        String query = "SELECT cid, cname, verification_status, pass FROM cust_reg WHERE email = ?";
        PreparedStatement pst = con.prepareStatement(query);
        pst.setString(1, "mike@gmail.com");
        ResultSet rs = pst.executeQuery();

        if (rs.next()) {
            int cid = rs.getInt("cid");
            String cname = rs.getString("cname");
            String verificationStatus = rs.getString("verification_status");
            String pass = rs.getString("pass");

            out.println("<h1>Mike's Account Details</h1>");
            out.println("<p><strong>ID:</strong> " + cid + "</p>");
            out.println("<p><strong>Name:</strong> " + cname + "</p>");
            out.println("<p><strong>Verification Status:</strong> " + verificationStatus + "</p>");
            out.println("<p><strong>Password Hash:</strong> " + pass + "</p>");

            // Test password verification
            String testPassword = "123456789";
            boolean passwordMatch = com.j4u.PasswordUtil.verifyPassword(testPassword, pass);
            boolean legacyMatch = testPassword.equals(pass);

            out.println("<p><strong>Password Match (Hashed):</strong> " + passwordMatch + "</p>");
            out.println("<p><strong>Password Match (Legacy):</strong> " + legacyMatch + "</p>");

            if ("VERIFIED".equals(verificationStatus) && (passwordMatch || legacyMatch)) {
                out.println("<h2 style='color:green;'>Login should work</h2>");
            } else {
                out.println("<h2 style='color:red;'>Login will fail</h2>");
                if (!"VERIFIED".equals(verificationStatus)) {
                    out.println("<p>Reason: Account not verified</p>");
                } else {
                    out.println("<p>Reason: Password does not match</p>");
                }
            }
        } else {
            out.println("<h1 style='color:red;'>Account not found</h1>");
        }

        rs.close();
        pst.close();
        con.close();
    } catch(Exception e) {
        out.println("<h1 style='color:red;'>Error</h1>");
        out.println("<p>" + e.getMessage() + "</p>");
    }
%>
