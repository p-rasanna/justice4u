<%-- Document : approvel Created on : 3 Apr, 2025, 8:24:27 PM Author : ZulkiflMugad --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
        <%@ include file="db_connection.jsp" %>
<%
    // Admin Session Validation Guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html?msg=Unauthorized access");
        return;
    }

    try { 
        Connection con = getDatabaseConnection(); 
        Statement st = con.createStatement(); 
        int id = Integer.parseInt(request.getParameter("id")); 
        
        // First check if lawyer's documents are verified
        ResultSet rs = st.executeQuery("SELECT document_verification_status FROM lawyer_reg WHERE lid=" + id);
        boolean canApprove = false;
        String message = "";

        if(rs.next()) {
            String docStatus = rs.getString("document_verification_status"); 
            if("VERIFIED".equals(docStatus)) {
                canApprove = true; 
            } else {
                message = "Cannot approve lawyer. Documents must be verified first. Please review documents in Lawyer Documents section."; 
            } 
        } else { 
            message = "Lawyer not found."; 
        } 
        rs.close(); 
        
        if(canApprove) { 
            String q = "UPDATE lawyer_reg SET flag=1 WHERE lid=" + id; 
            st.executeUpdate(q);
            message = "Lawyer approved successfully!";
        }
        
        st.close();
        con.close(); 
        
        // Redirect with message
        response.sendRedirect("viewlawyers.jsp?msg=" + java.net.URLEncoder.encode(message, "UTF-8")); 
    } catch(Exception e) { 
        response.sendRedirect("viewlawyers.jsp?msg=" + java.net.URLEncoder.encode("Error: " + e.getMessage(), "UTF-8")); 
    } 
%>