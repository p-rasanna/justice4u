<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<%
    // SECURE SESSION CHECK (10/10 SECURITY)
    String sessionUser = null;
    String sessionRole = null;
    
    if (session.getAttribute("cname") != null) {
        sessionUser = (String) session.getAttribute("cname");
        sessionRole = "client";
    } else if (session.getAttribute("lname") != null) {
        sessionUser = (String) session.getAttribute("lname");
        sessionRole = "lawyer";
    } else if (session.getAttribute("iname") != null) {
        sessionUser = (String) session.getAttribute("iname");
        sessionRole = "intern";
    }

    if (sessionUser == null) {
        out.print("error: Unauthorized - Login Required");
        return;
    }

    String caseId = request.getParameter("case_id");
    String receiverEmail = request.getParameter("receiver_email");
    String receiverRole = request.getParameter("receiver_role");
    String messageText = request.getParameter("message_text");
    
    boolean success = false;
    String errorMessage = "";

    try {
        // Validate required parameters
        if (caseId == null || messageText == null) {
            throw new Exception("Missing required parameters");
        }

        messageText = messageText.trim();
        if (messageText.isEmpty()) {
            throw new Exception("Message cannot be empty");
        }

        Connection con = getDatabaseConnection();

        // Insert message into discussions table
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO discussions (case_id, sender_email, sender_role, receiver_email, receiver_role, message_text, timestamp) " +
            "VALUES (?, ?, ?, ?, ?, ?, NOW())"
        );
        ps.setInt(1, Integer.parseInt(caseId));
        ps.setString(2, sessionUser);
        ps.setString(3, sessionRole);
        ps.setString(4, receiverEmail);
        ps.setString(5, receiverRole);
        ps.setString(6, messageText);

        int result = ps.executeUpdate();
        if (result > 0) {
            success = true;
        } else {
            errorMessage = "Failed to send message";
        }

        ps.close();
        con.close();

    } catch (Exception e) {
        errorMessage = "Error: " + e.getMessage();
        e.printStackTrace();
    }

    if (success) {
        out.print("success");
    } else {
        out.print("error: " + errorMessage);
    }
%>