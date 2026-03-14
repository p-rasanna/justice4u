<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*,com.j4u.Sanitizer" %>
<%@ include file="db_connection.jsp" %>
<%
    String email = request.getParameter("email");
    
    // Authorization check
    String loggedInUser = (String) session.getAttribute("cname");
    if (loggedInUser == null || !loggedInUser.equals(email)) {
        response.sendRedirect("cust_login.html");
        return;
    }

    String cname = request.getParameter("cname");
    String mobno = request.getParameter("mobno");
    String dob = request.getParameter("dob");
    String cadd = request.getParameter("cadd");
    String padd = request.getParameter("padd");

    if (email != null && cname != null && mobno != null && dob != null) {
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getDatabaseConnection();
            ps = con.prepareStatement("UPDATE cust_reg SET cname = ?, mobno = ?, dob = ?, cadd = ?, padd = ? WHERE email = ?");
            ps.setString(1, Sanitizer.sanitize(cname));
            ps.setString(2, Sanitizer.sanitize(mobno));
            ps.setString(3, Sanitizer.sanitize(dob));
            ps.setString(4, Sanitizer.sanitize(cadd));
            ps.setString(5, Sanitizer.sanitize(padd));
            ps.setString(6, email);
            
            int result = ps.executeUpdate();
            if (result > 0) {
                response.sendRedirect("profile.jsp?msg=Profile updated successfully");
            } else {
                response.sendRedirect("profile.jsp?error=Update failed");
            }
        } catch (Exception e) {
            response.sendRedirect("profile.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
    } else {
        response.sendRedirect("profile.jsp?error=Invalid parameters");
    }
%>
