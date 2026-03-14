<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<%!
    // Input validation helper methods
    private static String validateStringParam(String param, String paramName) throws ServletException {
        if (param == null || param.trim().isEmpty()) {
            throw new ServletException("Missing required parameter: " + paramName);
        }
        // Basic sanitization to prevent SQL injection in string values
        return param.trim().replace("'", "''");
    }
%>
<%
    // SECURITY PATCH: Lawyer Session Validation
    String lawyerEmail = (String) session.getAttribute("userEmail");
    String userRole = (String) session.getAttribute("userRole");
    if (lawyerEmail == null || !"lawyer".equals(userRole)) {
        session.invalidate();
        response.sendRedirect("Login.html?msg=Unauthorized access");
        return;
    }

    try {
        // Validate and sanitize input parameters
        String title = validateStringParam(request.getParameter("title"), "title");
        String cdate = validateStringParam(request.getParameter("cdate"), "date");
        String descr = validateStringParam(request.getParameter("descr"), "description");
        String cname = validateStringParam(request.getParameter("cname"), "client name");
        String lemail = validateStringParam(request.getParameter("lemail"), "lawyer email");
        
        try (Connection con = getDatabaseConnection()) {
            // Insert discussion using PreparedStatement
            String insertSql = "INSERT INTO discussion(title, cdate, descr, cname, lname) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pst = con.prepareStatement(insertSql)) {
                pst.setString(1, title);
                pst.setString(2, cdate);
                pst.setString(3, descr);
                pst.setString(4, cname);
                pst.setString(5, lemail);
                
                int rowsInserted = pst.executeUpdate();
                
                if (rowsInserted > 0) {
                    response.sendRedirect("Lawyerdashboard.jsp?msg=Discussion added successfully");
                } else {
                    response.sendRedirect("Lawyerdashboard.jsp?error=Failed to add discussion");
                }
            }
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>
