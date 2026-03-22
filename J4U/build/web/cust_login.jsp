<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil" %>
<%@ include file="db_connection.jsp" %>
<%
    try {
        String email = request.getParameter("txtname");
        String password = request.getParameter("txtpass");
        Connection con = getDatabaseConnection();

        // Use prepared statement to get stored password hash
        String query = "SELECT cid, cname, verification_status, pass FROM cust_reg WHERE email=?";
        PreparedStatement pst = con.prepareStatement(query);
        pst.setString(1, email.trim().toLowerCase());
        ResultSet rs = pst.executeQuery();

        if (rs.next()) {
            String storedHash = rs.getString("pass");
            String verificationStatus = rs.getString("verification_status");

            // Debug logging
            System.out.println("Login attempt for email: " + email);
            if (password != null) {
                System.out.println(" Input password length: " + password.length());
            } else {
                System.out.println(" Input password is null");
            }
            if (storedHash != null) {
                System.out.println(" Stored hash length: " + storedHash.length());
                System.out.println(" Stored hash starts with: " + storedHash.substring(0, Math.min(10, storedHash.length())));
            }
            System.out.println(" Verification status: " + verificationStatus);
            
            boolean passwordMatch = PasswordUtil.verifyPassword(password, storedHash);
            System.out.println(" Password verification result: " + passwordMatch);

            // Verify password against stored hash (with legacy plain text fallback)
            if (!passwordMatch && !password.equals(storedHash)) {
                System.out.println(" Password verification failed");
                response.sendRedirect("cust_login.html?msg=Invalid credentials");
                rs.close();
                pst.close();
                con.close();
                return;
            }

            if (!"VERIFIED".equals(verificationStatus)) {
                System.out.println("Account not verified: " + verificationStatus);
                response.sendRedirect("cust_login.html?msg=Account not approved");
                rs.close();
                pst.close();
                con.close();
                return;
            }

            int customerId = rs.getInt("cid");
            String customerName = rs.getString("cname");

            // Get profile type from client_profiles
            String profileQuery = "SELECT profile_type FROM client_profiles WHERE customer_id=? AND is_active=1";
            PreparedStatement profilePst = con.prepareStatement(profileQuery);
            profilePst.setInt(1, customerId);
            ResultSet profileRs = profilePst.executeQuery();
            
            String profileType = "manual"; // default to manual
            
            if (profileRs.next()) {
                String dbProfileType = profileRs.getString("profile_type");
                if (dbProfileType != null) {
                    profileType = dbProfileType;
                }
            }
            
            // Check if already logged in as client
            if (session.getAttribute("cname") != null) {
                // Already logged in as client, redirect to dashboard
                response.sendRedirect("clientdashboard_manual.jsp");
                profileRs.close();
                profilePst.close();
                rs.close();
                pst.close();
                con.close();
                return;
            }

            // Set session attributes (add client role to existing session)
            session.setAttribute("cid", customerId);
            session.setAttribute("cname", email); // CHANGED: SecurityFilter expects email in 'cname'
            session.setAttribute("c_full_name", customerName); // Store full name separately
            session.setAttribute("cemail", email);
            session.setAttribute("profileType", profileType);
            session.setAttribute("role", "client"); // REQUIRED for J4USecurityFilter

            // Always redirect to client dashboard
            response.sendRedirect("clientdashboard_manual.jsp");

            profileRs.close();
            profilePst.close();
        } else {
            response.sendRedirect("cust_login.html?msg=Invalid credentials");
        }
        
        rs.close();
        pst.close();
        con.close();
    } catch(Exception ee) {
        out.println("Error: " + ee.getMessage());
        ee.printStackTrace();
    }
%>
