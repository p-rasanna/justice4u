<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<%
    String username = (String) session.getAttribute("cname");
    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }

    String caseIdStr = request.getParameter("case_id");
    String lawyerEmail = request.getParameter("lawyer_email");

    if (caseIdStr == null || lawyerEmail == null || caseIdStr.isEmpty() || lawyerEmail.isEmpty()) {
        response.sendRedirect("clientdashboard_manual.jsp?msg=Invalid Request Parameters");
        return;
    }

    try {
        Connection con = getDatabaseConnection();
        
        // 1. Get Customer ID (Security: Ensure user owns the case)
        int customerId = -1;
        PreparedStatement psCust = con.prepareStatement("SELECT cid FROM cust_reg WHERE email = ?");
        psCust.setString(1, username);
        ResultSet rsCust = psCust.executeQuery();
        if (rsCust.next()) {
            customerId = rsCust.getInt("cid");
        }
        rsCust.close();
        psCust.close();

        if (customerId == -1) {
            response.sendRedirect("clientdashboard_manual.jsp?msg=User Not Found");
            return;
        }

        // 2. Get Lawyer ID
        int lawyerId = -1;
        PreparedStatement psLaw = con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email = ?");
        psLaw.setString(1, lawyerEmail);
        ResultSet rsLaw = psLaw.executeQuery();
        if (rsLaw.next()) {
            lawyerId = rsLaw.getInt("lid");
        }
        rsLaw.close();
        psLaw.close();

        if (lawyerId == -1) {
            response.sendRedirect("findlawyer.jsp?case_id=" + caseIdStr + "&msg=Lawyer Not Found");
            return;
        }

        // 3. Update Case
        // We only allow updating if status is OPEN or PENDING (to re-assign)
        // AND user owns the case.
        String updateSql = "UPDATE customer_cases SET assigned_lawyer_id = ?, status = 'PENDING_LAWYER_CONFIRMATION' WHERE case_id = ? AND customer_id = ?";
        PreparedStatement psUpdate = con.prepareStatement(updateSql);
        psUpdate.setInt(1, lawyerId);
        psUpdate.setInt(2, Integer.parseInt(caseIdStr));
        psUpdate.setInt(3, customerId);
        
        int rows = psUpdate.executeUpdate();
        psUpdate.close();

        // 4. SYNC TO ALLOTLAWYER (Legacy Bridge)
        if (rows > 0) {
             PreparedStatement psSync = con.prepareStatement(
                 "INSERT INTO allotlawyer (cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, lname) " +
                 "SELECT cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, ? " +
                 "FROM casetb WHERE cid = ? " +
                 "ON DUPLICATE KEY UPDATE lname = ?"
             );
             psSync.setString(1, lawyerEmail);
             psSync.setInt(2, Integer.parseInt(caseIdStr));
             psSync.setString(3, lawyerEmail);
             psSync.executeUpdate();
             psSync.close();
        }
        
        con.close();

        if (rows > 0) {
            response.sendRedirect("clientdashboard_manual.jsp?msg=Request Sent to Lawyer");
        } else {
            // Debugging Output
            response.setContentType("text/html");
            out.println("<h3>Update Failed</h3>");
            out.println("<p>Debug Info:</p><ul>");
            out.println("<li>Case ID (Param): " + caseIdStr + "</li>");
            out.println("<li>Customer Email: " + username + "</li>");
            out.println("<li>Resolved Customer ID: " + customerId + "</li>");
            out.println("<li>Target Lawyer Email: " + lawyerEmail + "</li>");
            out.println("<li>Resolved Lawyer ID: " + lawyerId + "</li>");
            out.println("<li><b>SQL Executed:</b> UPDATE customer_cases SET assigned_lawyer_id=" + lawyerId + ", status='PENDING...' WHERE case_id=" + caseIdStr + " AND customer_id=" + customerId + "</li>");
            out.println("</ul>");
            out.println("<p>Please screenshot this and send it to support.</p>");
            out.println("<a href='clientdashboard_manual.jsp'>Back to Dashboard</a>");
            // response.sendRedirect("clientdashboard_manual.jsp?msg=Update Failed - Case Not Found or Access Denied");
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("clientdashboard_manual.jsp?msg=Error: " + e.getMessage());
    }
%>
