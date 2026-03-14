<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="db_connection.jsp" %>
<%!
    // Input validation helper method
    private static int validateIntParam(String param, String paramName) throws ServletException {
        if (param == null || param.trim().isEmpty()) {
            throw new ServletException("Missing required parameter: " + paramName);
        }
        try {
            int value = Integer.parseInt(param.trim());
            if (value <= 0) {
                throw new ServletException("Invalid " + paramName + ": must be positive number");
            }
            return value;
        } catch (NumberFormatException e) {
            throw new ServletException("Invalid " + paramName + ": must be a number");
        }
    }
%>
<%
    // SECURITY PATCH: Admin Session Validation (FIXED)
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html?msg=Unauthorized access");
        return;
    }

    try {
        // Validate input parameter
        String idParam = request.getParameter("id");
        int lawyerId = validateIntParam(idParam, "lawyer ID");
        
        try (Connection con = getDatabaseConnection()) {
            // Update lawyer status to REJECTED (flag=2) using PreparedStatement
            String updateSql = "UPDATE lawyer_reg SET flag = 2 WHERE lid = ?";
            try (PreparedStatement pst = con.prepareStatement(updateSql)) {
                pst.setInt(1, lawyerId);
                int rowsUpdated = pst.executeUpdate();
                
                if (rowsUpdated > 0) {
                    response.sendRedirect("viewlawyers.jsp?msg=Lawyer Rejected Successfully");
                } else {
                    response.sendRedirect("viewlawyers.jsp?error=Lawyer not found");
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewlawyers.jsp?error=Error rejecting lawyer: " + e.getMessage());
    }
%>
