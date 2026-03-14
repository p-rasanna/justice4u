<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp"%>
<%
    // Validate session
    String lawyerEmail = (String) session.getAttribute("lname");
    Integer lawyerId = (Integer) session.getAttribute("lid");

    if (lawyerEmail == null || lawyerId == null) {
        response.sendRedirect("Lawyer_login.html?msg=Unauthorized");
        return;
    }

    String clientIdParam = request.getParameter("client_id");
    String caseIdParam = request.getParameter("case_id");
    String noteText = request.getParameter("note_text");

    if (clientIdParam == null || caseIdParam == null || noteText == null || noteText.trim().isEmpty()) {
        response.sendRedirect("viewcustdetails.jsp?msg=Missing required note fields");
        return;
    }

    try {
        int caseId = Integer.parseInt(caseIdParam);
        Connection con = getDatabaseConnection();

        // 1. Verify this lawyer actually owns this case
        PreparedStatement checkPs = con.prepareStatement(
            "SELECT 1 FROM customer_cases WHERE case_id = ? AND assigned_lawyer_id = ?"
        );
        checkPs.setInt(1, caseId);
        checkPs.setInt(2, lawyerId);
        ResultSet checkRs = checkPs.executeQuery();
        
        if (!checkRs.next()) {
            checkRs.close();
            checkPs.close();
            con.close();
            response.sendRedirect("viewcusdet.jsp?client_id=" + clientIdParam + "&msg=Unauthorized case update");
            return;
        }
        checkRs.close();
        checkPs.close();

        // 2. Insert into case_timeline
        PreparedStatement insertPs = con.prepareStatement(
            "INSERT INTO case_timeline (alid, event_type, event_description, created_by) VALUES (?, ?, ?, ?)"
        );
        // We use ALID column for case_id as per refactoring
        insertPs.setInt(1, caseId);
        insertPs.setString(2, "Lawyer Note");
        insertPs.setString(3, noteText.trim());
        insertPs.setString(4, lawyerEmail);

        insertPs.executeUpdate();
        insertPs.close();
        con.close();

        response.sendRedirect("viewcusdet.jsp?client_id=" + clientIdParam + "&msg=Case Note Added Successfully");
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewcusdet.jsp?client_id=" + clientIdParam + "&msg=Error adding note");
    }
%>
