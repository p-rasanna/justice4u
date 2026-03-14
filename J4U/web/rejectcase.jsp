<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<%
    // SECURE HANDLER: Decline Case
    // Transition: PENDING_LAWYER_CONFIRMATION -> OPEN
    // Action: Clear assigned_lawyer_id
    // Idempotent: Only updates if status is currently PENDING_LAWYER_CONFIRMATION

    String lawyerEmail = (String) session.getAttribute("lname");
    if (lawyerEmail == null) {
        response.sendRedirect("Lawyer_login.html");
        return;
    }

    String caseIdStr = request.getParameter("case_id");
    if (caseIdStr == null) {
        response.sendRedirect("lawyerdashboard.jsp?msg=Invalid Request");
        return;
    }

    int caseId = Integer.parseInt(caseIdStr);

    try {
        Connection con = getDatabaseConnection();

        // 1. Get Lawyer ID
        PreparedStatement psLaw = con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email = ?");
        psLaw.setString(1, lawyerEmail);
        ResultSet rsLaw = psLaw.executeQuery();
        int lawyerId = 0;
        if (rsLaw.next()) {
            lawyerId = rsLaw.getInt("lid");
        }
        rsLaw.close();
        psLaw.close();

        if (lawyerId == 0) {
            con.close();
            response.sendRedirect("lawyerdashboard.jsp?msg=Error identifying lawyer");
            return;
        }

        // 2. ATOMIC UPDATE
        // Set assigned_lawyer_id to NULL, status to OPEN
        String updateSql = "UPDATE customer_cases SET status='OPEN', assigned_lawyer_id=NULL WHERE case_id=? AND assigned_lawyer_id=? AND status='PENDING_LAWYER_CONFIRMATION'";
        PreparedStatement psUpdate = con.prepareStatement(updateSql);
        psUpdate.setInt(1, caseId);
        psUpdate.setInt(2, lawyerId);
        
        int rows = psUpdate.executeUpdate();
        
        if (rows > 0) {
             // 3. RESET LEGACY FLAGS
             // Release case back to Admin view
             PreparedStatement psFlag = con.prepareStatement("UPDATE casetb SET flag=0 WHERE cid=?");
             psFlag.setInt(1, caseId);
             psFlag.executeUpdate();
             psFlag.close();
             
             // Remove from allotlawyer (since it's no longer allotted)
             PreparedStatement psRem = con.prepareStatement("DELETE FROM allotlawyer WHERE cid=?");
             psRem.setInt(1, caseId);
             psRem.executeUpdate();
             psRem.close();
             
             response.sendRedirect("lawyerdashboard.jsp?msg=Case Declined. It has been released back to the marketplace.");
        } else {
             response.sendRedirect("lawyerdashboard.jsp?msg=Could not decline case. It may have already been handled.");
        }
        
        psUpdate.close();
        con.close();

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("lawyerdashboard.jsp?msg=Error: " + e.getMessage());
    }
%>
