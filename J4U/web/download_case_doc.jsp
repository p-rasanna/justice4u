<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.io.*" %>
<%@ include file="db_connection.jsp" %>
<%
    // SIMPLE DOWNLOAD HANDLER
    String fileName = request.getParameter("file");
    if (fileName == null || fileName.trim().isEmpty()) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid file request");
        return;
    }

    String uploadPath = "C:/J4U_Uploads/case_documents/";
    // Security: Basic check to prevent directory traversal
    if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Security violation");
        return;
    }

    // In a real system, we'd verify the user has access to the case this file belongs to.
    // Assuming session validation is done in the calling page or here.
    if (session.getAttribute("lname") == null && session.getAttribute("cname") == null && session.getAttribute("intername") == null) {
        response.sendError(403, "Access Denied");
        return;
    }

    // Search for the file in the upload directory
    // Files are named: CASE{id}_{ROLE}_{timestamp}_{name}
    // The fileName parameter should be the original name, but we need the secure path.
    // For this prototype, we'll look up the path in the DB if we only have the filename.
    
    String filePath = "";
    try {
        Connection con = getDatabaseConnection();
        PreparedStatement ps = con.prepareStatement("SELECT file_path FROM case_documents WHERE file_name = ? LIMIT 1");
        ps.setString(1, fileName);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            filePath = rs.getString("file_path");
        }
        rs.close(); ps.close(); con.close();
    } catch (Exception e) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=DB Error");
        return;
    }

    if (filePath.isEmpty()) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=File not found in registry");
        return;
    }

    File downloadFile = new File(filePath);
    if (!downloadFile.exists()) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=File not found on server");
        return;
    }

    FileInputStream inStream = new FileInputStream(downloadFile);
    
    // gets MIME type of the file
    String mimeType = getServletContext().getMimeType(filePath);
    if (mimeType == null) {        
        mimeType = "application/octet-stream";
    }
    
    response.setContentType(mimeType);
    response.setContentLength((int) downloadFile.length());
    
    String headerKey = "Content-Disposition";
    String headerValue = String.format("attachment; filename=\"%s\"", fileName);
    response.setHeader(headerKey, headerValue);
    
    OutputStream outStream = response.getOutputStream();
    byte[] buffer = new byte[4096];
    int bytesRead = -1;
    
    while ((bytesRead = inStream.read(buffer)) != -1) {
        outStream.write(buffer, 0, bytesRead);
    }
    
    inStream.close();
    outStream.close();
%>
