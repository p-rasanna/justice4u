<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%@ page import="com.j4u.NotificationService" %>
<%
    String email = (String) session.getAttribute("lname");
    if (email == null) {
        response.sendRedirect("../auth/Login.jsp");
        return;
    }

    String caseIdStr = request.getParameter("case_id");
    String action = request.getParameter("action");
    
    if (caseIdStr == null || action == null) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
        return;
    }
    
    int caseId;
    try {
        caseId = Integer.parseInt(caseIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
        return;
    }

    try (Connection con = DatabaseConfig.getConnection()) {
        String clientEmail = null;
        String caseTitle = null;
        
        try (PreparedStatement ps = con.prepareStatement("SELECT c.cname as client_email, c.title FROM casetb c WHERE c.cid=?")) {
            ps.setInt(1, caseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    clientEmail = rs.getString("client_email");
                    caseTitle = rs.getString("title");
                }
            }
        }
        
        if (clientEmail == null) {
            response.sendRedirect("Lawyerdashboard.jsp?msg=Case+not+found");
            return;
        }

        if ("accept".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement("UPDATE casetb SET status='ACCEPTED', flag=2 WHERE cid=?")) {
                ps.setInt(1, caseId);
                ps.executeUpdate();
            }
            NotificationService.create(clientEmail, "Your lawyer has accepted your case: " + caseTitle, "case", "../client/mycases.jsp");
            response.sendRedirect("Lawyerdashboard.jsp?msg=Case+accepted+successfully");
            
        } else if ("reject".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement("UPDATE casetb SET status='PENDING', flag=0 WHERE cid=?")) {
                ps.setInt(1, caseId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM allotlawyer WHERE cid=?")) {
                ps.setInt(1, caseId);
                ps.executeUpdate();
            }
            NotificationService.create(clientEmail, "Your lawyer was unable to accept case: " + caseTitle + ". An admin will reassign.", "case", "../client/mycases.jsp");
            response.sendRedirect("Lawyerdashboard.jsp?msg=Case+returned+to+queue");
            
        } else {
            response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("Lawyerdashboard.jsp?msg=Server+error");
    }
%>
