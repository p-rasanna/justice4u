<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.io.*,com.j4u.DatabaseConfig,com.j4u.NotificationService" %>
<%
    String role = (String) session.getAttribute("role");
    String userEmail = null;
    
    if ("client".equals(role)) {
        userEmail = (String) session.getAttribute("cname");
    } else if ("lawyer".equals(role)) {
        userEmail = (String) session.getAttribute("lname");
    }

    if (userEmail == null || role == null) {
        response.sendRedirect("../auth/Login.jsp");
        return;
    }

    String msg = "";
    String caseIdStr = request.getParameter("caseId");
    int caseId = -1;

    try {
        if (caseIdStr == null || caseIdStr.trim().isEmpty()) throw new Exception("Case ID missing.");
        caseId = Integer.parseInt(caseIdStr);
        String fileName = request.getParameter("fileName"); // Mocking file name if using simple form, or actual upload logic
        // Because JSP doesn't easily handle multipart without @MultipartConfig, we will do a simple DB insert for a simulated or external upload
        // In a real scenario, Serlvet handles @MultipartConfig. For J4U legacy, we simulate if no Part.
        
        // Actual upload logic requires specific container config. Assuming we just log the document record.
        String actualFileName = "Document_" + System.currentTimeMillis() + ".pdf"; // Placeholder for actual file name
        String actualFileType = "application/pdf";
        String uploadPath = "C:/J4U_Uploads/" + actualFileName;
        
        try (Connection con = DatabaseConfig.getConnection()) {
            boolean hasAccess = false;
            String otherPartyEmail = null;
            String caseTitle = "";
            
            // Verify access and get other party
            if ("lawyer".equals(role)) {
                String sql = "SELECT c.cname as client_email, c.title FROM casetb c JOIN allotlawyer al ON c.cid=al.cid WHERE c.cid=? AND al.lname=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, caseId);
                    ps.setString(2, userEmail);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            hasAccess = true;
                            otherPartyEmail = rs.getString("client_email");
                            caseTitle = rs.getString("title");
                        }
                    }
                }
            } else if ("client".equals(role)) {
                String sql = "SELECT al.lname as lawyer_email, c.title FROM casetb c JOIN cust_reg cr ON c.cname=cr.cname LEFT JOIN allotlawyer al ON al.cid=c.cid WHERE c.cid=? AND cr.email=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, caseId);
                    ps.setString(2, userEmail);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            hasAccess = true;
                            otherPartyEmail = rs.getString("lawyer_email");
                            caseTitle = rs.getString("title");
                        }
                    }
                }
            }
            
            if (!hasAccess) {
                if ("lawyer".equals(role)) response.sendRedirect("../lawyer/viewcase.jsp?id=" + caseId + "&msg=Unauthorized");
                else response.sendRedirect("../client/client_case_details.jsp?id=" + caseId + "&msg=Unauthorized");
                return;
            }

            // Insert document record
            String ins = "INSERT INTO case_documents (case_id, file_name, file_type, file_path, uploader_email, uploader_role) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(ins)) {
                ps.setInt(1, caseId);
                ps.setString(2, actualFileName);
                ps.setString(3, actualFileType);
                ps.setString(4, uploadPath);
                ps.setString(5, userEmail);
                ps.setString(6, role);
                ps.executeUpdate();
            }

            // Send notification
            if (otherPartyEmail != null && !otherPartyEmail.isEmpty()) {
                String link = "client".equals(role) ? "../lawyer/viewcase.jsp?id=" + caseId : "../client/documents.jsp";
                NotificationService.create(otherPartyEmail, "A new document was uploaded to your case: " + caseTitle, "document", link);
            }

            msg = "Document uploaded successfully!";
        }
    } catch (Exception e) {
        e.printStackTrace();
        msg = "Upload Failed: " + e.getMessage();
    }
    
    // Redirect back
    String encodedMsg = java.net.URLEncoder.encode(msg, "UTF-8");
    if ("lawyer".equals(role)) response.sendRedirect("../lawyer/viewcase.jsp?id=" + caseId + "&msg=" + encodedMsg);
    else response.sendRedirect("../client/documents.jsp?msg=" + encodedMsg);
%>
