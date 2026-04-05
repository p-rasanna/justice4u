package com.j4u;
import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
@MultipartConfig(
  fileSizeThreshold = 1024 * 1024,    // 1 MB
  maxFileSize       = 10 * 1024 * 1024, // 10 MB
  maxRequestSize    = 15 * 1024 * 1024  // 15 MB
)
public class SendMessageServlet extends HttpServlet {
  private static final String[] ALLOWED_EXTENSIONS = {
    ".pdf", ".jpg", ".jpeg", ".png", ".gif", ".doc", ".docx", ".xls", ".xlsx", ".txt"
  };
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession(false);
    if (session == null) {
      response.sendRedirect(request.getContextPath() + "/auth/cust_login.jsp");
      return;
    }
    String senderEmail = null;
    String senderRole = null;
    if (session.getAttribute("cname") != null) {
      senderEmail = (String) session.getAttribute("cname");
      senderRole = "client";
    } else if (session.getAttribute("lname") != null) {
      senderEmail = (String) session.getAttribute("lname");
      senderRole = "lawyer";
    } else if (session.getAttribute("iname") != null) {
      senderEmail = (String) session.getAttribute("iname");
      senderRole = "intern";
    } else if (session.getAttribute("aname") != null) {
      senderEmail = (String) session.getAttribute("aname");
      senderRole = "admin";
    }
    if (senderEmail == null) {
      response.sendRedirect(request.getContextPath() + "/auth/cust_login.jsp");
      return;
    }
    String caseIdStr = request.getParameter("case_id");
    String messageText = request.getParameter("message_text");
    if (caseIdStr == null || caseIdStr.trim().isEmpty()) {
      response.sendRedirect(request.getContextPath() + "/shared/error.jsp");
      return;
    }
    int caseId;
    try {
      caseId = Integer.parseInt(caseIdStr.trim());
    } catch (NumberFormatException e) {
      response.sendRedirect(request.getContextPath() + "/shared/error.jsp");
      return;
    }
    Part filePart = null;
    try {
      filePart = request.getPart("attachment");
    } catch (Exception e) {
    }
    boolean hasMessage = (messageText != null && !messageText.trim().isEmpty());
    boolean hasFile = (filePart != null && filePart.getSize() > 0);
    if (!hasMessage && !hasFile) {
      response.sendRedirect(request.getContextPath() +
        "/shared/caseDiscussion.jsp?case_id=" + caseId + "&error=Please+enter+a+message+or+attach+a+file");
      return;
    }
    String fileName = null;
    String filePath = null;
    if (hasFile) {
      String submittedFileName = getSubmittedFileName(filePart);
      if (submittedFileName != null && !submittedFileName.isEmpty()) {
        if (!isAllowedExtension(submittedFileName)) {
          response.sendRedirect(request.getContextPath() +
            "/shared/caseDiscussion.jsp?case_id=" + caseId + "&error=File+type+not+allowed");
          return;
        }
        String uploadDir = getServletContext().getRealPath("") + File.separator +
                   "uploads" + File.separator + "case_" + caseId;
        File uploadPath = new File(uploadDir);
        if (!uploadPath.exists()) {
          uploadPath.mkdirs();
        }
        String uniqueName = System.currentTimeMillis() + "_" + submittedFileName.replaceAll("[^a-zA-Z0-9._-]", "_");
        filePart.write(uploadDir + File.separator + uniqueName);
        fileName = submittedFileName;
        filePath = "uploads/case_" + caseId + "/" + uniqueName;
      }
    }
    Connection con = null;
    try {
      con = DatabaseConfig.getConnection();
      String sql = "INSERT INTO case_messages (case_id, sender_email, sender_role, message_text, file_name, file_path, created_at) "
             + "VALUES (?, ?, ?, ?, ?, ?, NOW())";
      PreparedStatement ps = con.prepareStatement(sql);
      ps.setInt(1, caseId);
      ps.setString(2, senderEmail);
      ps.setString(3, senderRole);
      ps.setString(4, hasMessage ? messageText.trim() : null);
      ps.setString(5, fileName);
      ps.setString(6, filePath);
      ps.executeUpdate();
      ps.close();
      response.sendRedirect(request.getContextPath() +
        "/shared/caseDiscussion.jsp?case_id=" + caseId + "&msg=Message+sent+successfully");
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect(request.getContextPath() +
        "/shared/caseDiscussion.jsp?case_id=" + caseId + "&error=Failed+to+send+message");
    } finally {
      if (con != null) {
        try { con.close(); } catch (SQLException e) {}
      }
    }
  }
  private String getSubmittedFileName(Part part) {
    String header = part.getHeader("content-disposition");
    if (header == null) return null;
    for (String token : header.split(";")) {
      if (token.trim().startsWith("filename")) {
        String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
        int idx = name.lastIndexOf(File.separator);
        if (idx >= 0) name = name.substring(idx + 1);
        idx = name.lastIndexOf('/');
        if (idx >= 0) name = name.substring(idx + 1);
        return name;
      }
    }
    return null;
  }
  private boolean isAllowedExtension(String fileName) {
    String lower = fileName.toLowerCase();
    for (String ext : ALLOWED_EXTENSIONS) {
      if (lower.endsWith(ext)) return true;
    }
    return false;
  }
}