<%--
    Document   : rejectcustomer
    Created on : 21 Mar, 2025, 8:24:54 PM
    Author     : ZulkiflMugad
--%>

<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, util.EmailUtil"%>
<%@include file="db_connection.jsp" %>
<%
    try {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("viewcustomers.jsp?error=Invalid ID");
            return;
        }
        
        int id = Integer.parseInt(idStr);
        Connection con = getDatabaseConnection();
        
        // Get customer's email before updating
        PreparedStatement psEmail = con.prepareStatement("SELECT email FROM cust_reg WHERE cid=?");
        psEmail.setInt(1, id);
        ResultSet rs = psEmail.executeQuery();
        
        String customerEmail = "";
        if (rs.next()) {
            customerEmail = rs.getString("email");
        }
        rs.close();
        psEmail.close();
        
        // Update verification status
        PreparedStatement psUpdate = con.prepareStatement("UPDATE cust_reg SET verification_status='REJECTED' WHERE cid=?");
        psUpdate.setInt(1, id);
        psUpdate.executeUpdate();
        psUpdate.close();
        con.close();

        // Send rejection email
        if (customerEmail != null && !customerEmail.isEmpty()) {
             try {
                EmailUtil.sendEmail(customerEmail, "Account Registration Status", 
                    "We regret to inform you that your registration has been rejected. Please contact support for more information.");
             } catch (Exception e) {
                 // Ignore email errors
             }
        }

        response.sendRedirect("viewcustomers.jsp?msg=Customer Rejected");
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewcustomers.jsp?error=System Error");
    }
%>
