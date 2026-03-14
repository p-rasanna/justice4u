<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil" %>
    <%@ include file="db_connection.jsp" %>
        <% try { String email=request.getParameter("txtname"); String password=request.getParameter("txtpass"); /* Check
            for null parameters */ if (email==null || password==null || email.trim().isEmpty() ||
            password.trim().isEmpty()) { response.sendRedirect("Lawyer_login.html?msg=Please enter both email and password"); return; } Connection con=getDatabaseConnection(); String
            query="SELECT email, pass, document_verification_status FROM lawyer_reg WHERE flag=1 AND email=?" ;
            PreparedStatement pst=con.prepareStatement(query); pst.setString(1, email.trim()); ResultSet
            if (rs.next()) {
                String storedHash = rs.getString("pass");
                String documentStatus = rs.getString("document_verification_status");
                
                // 1. Check Document Verification First
                if (!"VERIFIED".equals(documentStatus)) {
                    response.sendRedirect("Lawyer_login.html?msg=Documents not verified");
                    rs.close();
                    pst.close();
                    con.close();
                    return;
                }
                
                // 2. Check Password
                /* Check both secure hash and legacy plain text */
                boolean isPasswordValid = PasswordUtil.verifyPassword(password.trim(), storedHash);
                boolean isLegacyPasswordValid = password.trim().equals(storedHash);

                if (isPasswordValid || isLegacyPasswordValid) {
                    // Login Success
                    session.setAttribute("lname", email.trim());
                    session.setAttribute("role", "lawyer"); // REQUIRED for J4USecurityFilter
                    response.sendRedirect("Lawyerdashboard.jsp");
                } else {
                    response.sendRedirect("Lawyer_login.html?msg=Invalid credentials");
                }
            } else {
                response.sendRedirect("Lawyer_login.html?msg=Invalid credentials");
            }
            
            rs.close();
            pst.close();
            con.close();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    }
%>