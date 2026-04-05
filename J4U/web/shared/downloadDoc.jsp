<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.File, java.io.FileInputStream, java.io.OutputStream" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
  String role = (String) session.getAttribute("role");
  String userEmail = null;
  if ("admin".equals(role)) {
    userEmail = (String) session.getAttribute("aname");
  } else if ("client".equals(role)) {
    userEmail = (String) session.getAttribute("cname");
  } else if ("lawyer".equals(role)) {
    userEmail = (String) session.getAttribute("lname");
  } else if ("intern".equals(role)) {
    userEmail = (String) session.getAttribute("iname");
  }
  if (userEmail == null || role == null) {
    response.sendError(401, "Unauthorized");
    return;
  }
  String idStr = request.getParameter("id");
  if (idStr == null) {
    response.sendError(400, "Bad Request");
    return;
  }
  int docId;
  try {
    docId = Integer.parseInt(idStr);
  } catch (NumberFormatException e) {
    response.sendError(400, "Invalid Document ID");
    return;
  }
  String fileName = null;
  String filePath = null;
  int caseId = -1;
  try (Connection con = DatabaseConfig.getConnection()) {
    try (PreparedStatement ps = con.prepareStatement("SELECT file_name, file_path, case_id FROM case_documents WHERE id=?")) {
      ps.setInt(1, docId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          fileName = rs.getString("file_name");
          filePath = rs.getString("file_path");
          caseId = rs.getInt("case_id");
        } else {
          response.sendError(404, "Document not found");
          return;
        }
      }
    }
    boolean hasAccess = false;
    if ("admin".equals(role)) {
      hasAccess = true;
    } else if ("client".equals(role)) {
      String checkSql = "SELECT 1 FROM casetb c JOIN cust_reg cr ON c.cname = cr.cname WHERE c.cid=? AND cr.email=?";
      try (PreparedStatement ps = con.prepareStatement(checkSql)) {
        ps.setInt(1, caseId);
        ps.setString(2, userEmail);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) hasAccess = true;
        }
      }
    } else if ("lawyer".equals(role)) {
      String checkSql = "SELECT 1 FROM allotlawyer WHERE cid=? AND lname=?";
      try (PreparedStatement ps = con.prepareStatement(checkSql)) {
        ps.setInt(1, caseId);
        ps.setString(2, userEmail);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) hasAccess = true;
        }
      }
    } else if ("intern".equals(role)) {
      String checkSql = "SELECT 1 FROM intern_assignments WHERE case_id=? AND intern_email=?";
      try (PreparedStatement ps = con.prepareStatement(checkSql)) {
        ps.setInt(1, caseId);
        ps.setString(2, userEmail);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) hasAccess = true;
        }
      }
    }
    if (!hasAccess) {
      response.sendError(403, "Access denied");
      return;
    }
  } catch (Exception e) {
    e.printStackTrace();
    response.sendError(500, "Server Error");
    return;
  }
  if (filePath == null || fileName == null) {
    response.sendError(404, "File configuration missing");
    return;
  }
  File file = new File(filePath);
  if (!file.exists()) {
    response.sendError(404, "File not found on server");
    return;
  }
  response.setContentType("application/octet-stream");
  response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
  response.setContentLengthLong(file.length());
  try (FileInputStream fis = new FileInputStream(file);
     OutputStream os = response.getOutputStream()) {
    byte[] buffer = new byte[4096];
    int bytesRead;
    while ((bytesRead = fis.read(buffer)) != -1) {
      os.write(buffer, 0, bytesRead);
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
%>