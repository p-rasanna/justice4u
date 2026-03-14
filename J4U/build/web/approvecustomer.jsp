<%-- Document : approvecustomer Created on : 21 Mar, 2025, 8:24:54 PM Author : ZulkiflMugad --%>

    <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
        import="java.sql.*, util.EmailUtil" %>
        <%@ include file="db_connection.jsp" %>
            <% try { String id=request.getParameter("id"); // Input validation if (id==null || id.trim().isEmpty()) {
                throw new Exception("Customer ID is required"); } int customerId; try {
                customerId=Integer.parseInt(id.trim()); } catch (NumberFormatException e) { throw new Exception("Invalid
                customer ID format"); } Connection con=getDatabaseConnection(); // Update verification status using
                prepared statement String q="UPDATE cust_reg SET verification_status='VERIFIED' WHERE cid=?" ;
                PreparedStatement pst=con.prepareStatement(q); pst.setInt(1, customerId); pst.executeUpdate(); // Get
                customer's email using prepared statement String emailQuery="SELECT email FROM cust_reg WHERE cid=?" ;
                PreparedStatement emailPst=con.prepareStatement(emailQuery); emailPst.setInt(1, customerId); ResultSet
                rs=emailPst.executeQuery(); String customerEmail="" ; if (rs.next()) {
                customerEmail=rs.getString("email"); } rs.close(); emailPst.close(); pst.close(); con.close(); // Send
                approval email if (customerEmail !=null && !customerEmail.trim().isEmpty()) { try {
                EmailUtil.sendEmail(customerEmail, "Account Approved"
                , "Congratulations! Your account has been approved and is now active." ); } catch (Exception emailEx) {
                // Log email error but don't fail approval System.out.println("Email sending failed: " + emailEx.getMessage());
            }
        }

        response.sendRedirect(" viewcustomers.jsp"); } catch (Exception e) { out.println("Error: " + e.getMessage());
    }
%>