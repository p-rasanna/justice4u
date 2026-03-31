<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String email = (String)session.getAttribute("cname");
    String role = (String)session.getAttribute("role");
    String profileType = (String)session.getAttribute("profileType");
    
    if(email == null) {
        out.println("<h1>Not logged in</h1>");
        out.println("<p>cname session attribute is null</p>");
        out.println("<a href='../auth/cust_login.jsp'>Login</a>");
        return;
    }
    
    out.println("<h1>Session OK</h1>");
    out.println("<p>Email: " + email + "</p>");
    out.println("<p>Role: " + role + "</p>");
    out.println("<p>Profile: " + profileType + "</p>");
    
    // Test DB connection
    try (Connection con = DatabaseConfig.getConnection()) {
        out.println("<p style='color:green'>Database connected</p>");
        
        PreparedStatement ps = con.prepareStatement("SELECT cname, verification_status FROM cust_reg WHERE email=?");
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();
        
        if(rs.next()) {
            out.println("<p>User found: " + rs.getString("cname") + "</p>");
            out.println("<p>Status: " + rs.getString("verification_status") + "</p>");
            
            if("VERIFIED".equalsIgnoreCase(rs.getString("verification_status"))) {
                out.println("<p><a href='customerdashboard.jsp'>Go to Dashboard</a></p>");
            } else {
                out.println("<p style='color:red'>Account not verified yet</p>");
            }
        } else {
            out.println("<p style='color:red'>User not found in database</p>");
        }
    } catch(Exception e) {
        out.println("<p style='color:red'>DB Error: " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
