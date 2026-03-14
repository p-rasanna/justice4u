<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.io.*,javax.servlet.http.Part" %>
<%@ include file="db_connection.jsp" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%
    // 1. Session Check
    String internEmail = (String) session.getAttribute("iname");
    if (internEmail == null) {
        response.sendRedirect("internlogin.html");
        return;
    }

    String msg = "";
    try {
        // 2. Parse Multipart Request (Standard Servlet 3.0)
        // Note: web.xml must map this JSP to a servlet with <multipart-config> OR we rely on container support
        // Since we added InternRegistrationServlet for processintern.jsp, we might need a similar mapping here.
        // However, many containers (Tomcat) allow multipart in JSP if config is right, or we use getParts().
        
        Part filePart = request.getPart("file"); 
        String caseIdParam = request.getParameter("caseId");
        
        if (filePart == null || caseIdParam == null) {
            throw new Exception("Missing file or case ID");
        }

        int caseId = Integer.parseInt(caseIdParam);
        String fileName = filePart.getSubmittedFileName();

        Connection con = getDatabaseConnection();

        // 3. Verify Assignment
        PreparedStatement psAuth = con.prepareStatement(
            "SELECT assignment_id FROM intern_assignments WHERE intern_email=? AND case_id=? AND status='ACTIVE'"
        );
        psAuth.setString(1, internEmail);
        psAuth.setInt(2, caseId);
        ResultSet rsAuth = psAuth.executeQuery();
        if (!rsAuth.next()) {
            rsAuth.close(); psAuth.close(); con.close();
            response.sendRedirect("interndashboard.jsp?msg=Unauthorized Upload Access");
            return;
        }
        rsAuth.close(); psAuth.close();

        // 4. Save File
        String uploadPath = "C:/J4U_Uploads/case_documents/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String secureName = "CASE" + caseId + "_INTERN_" + System.currentTimeMillis() + "_" + fileName;
        filePart.write(uploadPath + secureName);

        // 5. Insert Record
        PreparedStatement psIns = con.prepareStatement(
            "INSERT INTO case_documents (case_id, uploader_email, uploader_role, file_name, file_path) VALUES (?, ?, 'intern', ?, ?)"
        );
        psIns.setInt(1, caseId);
        psIns.setString(2, internEmail);
        psIns.setString(3, fileName); // Original Name for display
        psIns.setString(4, uploadPath + secureName); // Full path for download
        psIns.executeUpdate();
        psIns.close();
        con.close();

        msg = "Document Uploaded Successfully";

    } catch (Exception e) {
        e.printStackTrace();
        msg = "Upload Failed: " + e.getMessage();
    }

    response.sendRedirect("interndashboard.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
%>
