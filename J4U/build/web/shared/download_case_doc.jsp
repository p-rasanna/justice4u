<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.io.*" %>
<%@ include file="db_connection.jsp" %>
<%
  String fileName = request.getParameter("file");
  if (fileName == null || fileName.trim().isEmpty()) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid file request");
    return;
  }
  String uploadPath = "C:/J4U_Uploads/case_documents/";
  if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Security violation");
    return;
  }
  if (session.getAttribute("lname") == null && session.getAttribute("cname") == null && session.getAttribute("intername") == null) {
    response.sendError(403, "Access Denied");
    return;
  }
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