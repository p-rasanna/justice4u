<%-- 
    Document   : rejectl
    Created on : 3 Apr, 2025, 8:26:01 PM
    Author     : ZulkiflMugad
--%>



<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, util.EmailUtil" %>
<%@include file="db_connection.jsp" %>
 <% 
    // Admin Session Validation Guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html?msg=Unauthorized access");
        return;
    }

     try {
        Connection con = getDatabaseConnection();
        int id = Integer.parseInt(request.getParameter("id"));
        
        // 1. Get Email and Name
        String email = null;
        String name = "Intern";
        PreparedStatement psGet = con.prepareStatement("SELECT email, name FROM intern WHERE internid=?");
        psGet.setInt(1, id);
        ResultSet rs = psGet.executeQuery();
        if(rs.next()) {
            email = rs.getString("email");
            name = rs.getString("name");
        }
        rs.close();
        psGet.close();

        // 2. Update intern table
        PreparedStatement psUpdate1 = con.prepareStatement("UPDATE intern SET flag=2 WHERE internid=?");
        psUpdate1.setInt(1, id);
        psUpdate1.executeUpdate();
        psUpdate1.close();
        
        // 3. Update intern_profiles table
        if(email != null) {
            PreparedStatement psUpdate2 = con.prepareStatement("UPDATE intern_profiles SET verification_status='REJECTED' WHERE intern_email=?");
            psUpdate2.setString(1, email);
            psUpdate2.executeUpdate();
            psUpdate2.close();

            // 4. Send Notification Email
            String subject = "Internship Application Status - Justice4U";
            String body = "Dear " + name + ",\n\n"
                    + "Thank you for your interest in Justice4U. After careful review, we regret to inform you that your internship application has not been approved at this time.\n\n"
                    + "If you have any questions, please feel free to contact our administration.\n\n"
                    + "Best Regards,\n"
                    + "Justice4U Administration";
            EmailUtil.sendEmail(email, subject, body);
        }

        con.close();
        response.sendRedirect("viewinterns.jsp?msg=Intern Rejected");
    } catch(Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewinterns.jsp?error=Error rejecting intern: " + e.getMessage());
    }
 %>
