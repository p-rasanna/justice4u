<%--
    Document   : enhanced_document_upload
    Created on : 2025
    Author     : Justice4U System
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, java.io.*, java.util.*, com.j4u.RBACUtil, com.j4u.FileUploadUtil, com.oreilly.servlet.MultipartRequest, com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@include file="db_connection.jsp" %>
<%@include file="csrf_token.jsp" %>

<%
  // Session validation and RBAC check
  String username = (String) session.getAttribute("lname");
  if (username == null) {
    response.sendRedirect("Lawyerlogin.html?msg=Session expired");
    return;
  }

  // Additional validation - check if lawyer is approved
  try {
    Class.forName("com.mysql.jdbc.Driver");
            Connection con = getDatabaseConnection();
    PreparedStatement pst = con.prepareStatement("SELECT flag FROM lawyer_reg WHERE email=?");
    pst.setString(1, username);
    ResultSet rs = pst.executeQuery();
    if (rs.next()) {
      int flag = rs.getInt("flag");
      if (flag != 1) {
        session.invalidate();
        response.sendRedirect("Lawyer_login.html?msg=Account not approved yet");
        return;
      }
    } else {
      session.invalidate();
      response.sendRedirect("Lawyer_login.html?msg=Invalid session");
      return;
    }
    rs.close();
    pst.close();
    con.close();
  } catch(Exception e) {
    session.invalidate();
    response.sendRedirect("Lawyer_login.html?msg=Database error");
    return;
  }

  // Handle form submission for document upload
  String message = "";
  String messageType = "";

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
      // Validate CSRF token first
      if (!CSRFTokenUtil.validateToken(request)) {
        message = "Security validation failed. Please try again.";
        messageType = "danger";
      } else {
        // Handle secure file upload
        String uploadPath = application.getRealPath("/") + "uploads/documents/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
          uploadDir.mkdirs();
        }

        // Get form parameters
        String caseId = request.getParameter("case_id");
        String docType = request.getParameter("doc_type");
        String documentType = request.getParameter("document_type");

        // Get uploaded file
        Part filePart = request.getPart("document_file");

        if (filePart != null && filePart.getSize() > 0) {
          // Validate file using secure utility
          FileUploadUtil.ValidationResult validation = FileUploadUtil.validateFile(filePart);

          if (validation.isValid()) {
            // Save file with secure naming
            FileUploadUtil.UploadResult uploadResult = FileUploadUtil.saveFile(filePart, uploadPath);

            if (uploadResult.isSuccess()) {
              String secureFileName = uploadResult.getFileName();
              String filePath = "uploads/documents/" + secureFileName;

              // Get database connection
              Connection con = getDatabaseConnection();

              // Get the latest version for this document type
              String versionQuery = "SELECT MAX(version) as max_version FROM lawyer_documents WHERE alid=? AND document_type=?";
              PreparedStatement versionPst = con.prepareStatement(versionQuery);
              versionPst.setInt(1, Integer.parseInt(caseId));
              versionPst.setString(2, documentType);
              ResultSet versionRs = versionPst.executeQuery();
              int nextVersion = 1;
              if (versionRs.next() && versionRs.getInt("max_version") > 0) {
                nextVersion = versionRs.getInt("max_version") + 1;
              }
              versionRs.close();
              versionPst.close();

              // Insert document record
              String query = "INSERT INTO lawyer_documents (alid, uploaded_by, doc_type, document_type, file_name, file_path, version, file_size) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
              PreparedStatement pst = con.prepareStatement(query);
              pst.setInt(1, Integer.parseInt(caseId));
              pst.setString(2, username);
              pst.setString(3, docType);
              pst.setString(4, documentType);
              pst.setString(5, secureFileName);
              pst.setString(6, filePath);
              pst.setInt(7, nextVersion);
              pst.setLong(8, filePart.getSize());
              pst.executeUpdate();
              pst.close();

              // Add to timeline
              String timelineQuery = "INSERT INTO case_timeline (alid, event_type, event_description, created_by) VALUES (?, 'DOCUMENTS_UPLOADED', ?, ?)";
              PreparedStatement timelinePst = con.prepareStatement(timelineQuery);
              timelinePst.setInt(1, Integer.parseInt(caseId));
              timelinePst.setString(2, "Secure document uploaded: " + secureFileName + " (v" + nextVersion + ", " + FileUploadUtil.formatFileSize(filePart.getSize()) + ")");
              timelinePst.setString(3, username);
              timelinePst.executeUpdate();
              timelinePst.close();

              con.close();

              message = "Document uploaded securely! Version: " + nextVersion + " (" + FileUploadUtil.formatFileSize(filePart.getSize()) + ")";
              messageType = "success";
            } else {
              message = "Failed to save file: " + uploadResult.getMessage();
              messageType = "danger";
            }
          } else {
            message = "File validation failed: " + validation.getMessage();
            messageType = "warning";
          }
        } else {
          message = "Please select a file to upload.";
          messageType = "warning";
        }
      }

    } catch (Exception e) {
      message = "Error uploading document: " + e.getMessage();
      messageType = "danger";
    }
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Enhanced Document Upload | Justice4U</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

  <style>
    :root {
      --j4u-bg: #f5f2ea;
      --j4u-surface: #fdfbf6;
      --j4u-border: #ddd1b8;
      --j4u-gold: #c9a76a;
      --j4u-gold-soft: #e3c796;
      --j4u-text-main: #111827;
      --j4u-text-muted: #6b7280;
      --j4u-accent-blue: #2563eb;
      --j4u-accent-green: #16a34a;
      --j4u-accent-red: #dc2626;
    }

    body {
      margin: 0;
      min-height: 100vh;
      background: radial-gradient(circle at top, #f0ebe0 0, #f5f2ea 32%, #e8decc 100%);
      font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
      color: var(--j4u-text-main);
    }

    .dashboard-shell {
      max-width: 1200px;
      margin: 24px auto 32px;
      padding: 0 16px;
    }

    .card-main {
      background: var(--j4u-surface);
      border-radius: 20px;
      border: 1px solid var(--j4u-border);
      box-shadow: 0 20px 40px rgba(15, 23, 42, 0.14), 0 0 0 1px rgba(148, 133, 96, 0.12);
      padding: 18px 20px 20px;
      position: relative;
      overflow: hidden;
    }

    .card-main::before {
      content: "";
      position: absolute;
      top: 0;
      left: 18px;
      right: 18px;
      height: 4px;
      border-radius: 0 0 999px 999px;
      background: linear-gradient(90deg, var(--j4u-gold), var(--j4u-gold-soft));
      opacity: 0.95;
    }

    .upload-form {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 20px;
    }

    .document-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 12px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    .document-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
    }

    .document-title {
      font-weight: 600;
      color: var(--j4u-text-main);
    }

    .document-meta {
      font-size: 0.85rem;
      color: var(--j4u-text-muted);
    }

    .version-badge {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 999px;
      font-size: 0.75rem;
      font-weight: 500;
      background: var(--j4u-gold-soft);
      color: #7c5f2b;
    }

    .btn-custom {
      background: linear-gradient(135deg, var(--j4u-gold), var(--j4u-gold-soft));
      border: none;
      color: #111827;
      padding: 8px 16px;
      border-radius: 8px;
      font-weight: 500;
      transition: all 0.2s ease;
    }

    .btn-custom:hover {
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(201, 167, 106, 0.3);
    }

    .file-upload-area {
      border: 2px dashed var(--j4u-border);
      border-radius: 8px;
      padding: 20px;
      text-align: center;
      background: #fafaf9;
      transition: all 0.2s ease;
      cursor: pointer;
    }

    .file-upload-area:hover {
      border-color: var(--j4u-gold);
      background: #fefce8;
    }

    .file-upload-area.dragover {
      border-color: var(--j4u-accent-blue);
      background: #eff6ff;
    }
  </style>
</head>
<body>
  <div class="dashboard-shell">
    <div class="card-main">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h2 class="mb-1"><i class="fas fa-file-upload"></i> Enhanced Document Upload</h2>
          <p class="text-muted mb-0">Upload documents with versioning and categorization</p>
        </div>
        <a href="Lawyerdashboard.jsp" class="btn btn-outline-secondary">
          <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
      </div>

      <% if (!message.isEmpty()) { %>
      <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
        <%= message %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
      <% } %>

      <!-- Upload Form -->
      <div class="upload-form">
        <h4 class="mb-3"><i class="fas fa-cloud-upload-alt"></i> Upload New Document</h4>
        <form method="post" enctype="multipart/form-data">
          <%@include file="csrf_token.jsp" %>
          <div class="row g-3">
            <div class="col-md-6">
              <label for="case_id" class="form-label">Case</label>
              <select class="form-select" id="case_id" name="case_id" required>
                <option value="">Select Case</option>
                <%
                  try {
                    Class.forName("com.mysql.jdbc.Driver");
                            Connection con = getDatabaseConnection();
                    String query = "SELECT a.alid, a.title, a.cname FROM allotlawyer a JOIN case_status cs ON a.alid = cs.alid WHERE a.lname=? AND cs.status IN ('ACCEPTED', 'IN_PROGRESS')";
                    PreparedStatement pst = con.prepareStatement(query);
                    pst.setString(1, username);
                    ResultSet rs = pst.executeQuery();
                    while(rs.next()) {
                %>
                <option value="<%= rs.getInt("alid") %>"><%= com.j4u.Sanitizer.sanitize(rs.getString("title")) %> - <%= com.j4u.Sanitizer.sanitize(rs.getString("cname")) %></option>
                <%
                    }
                    rs.close();
                    pst.close();
                    con.close();
                  } catch(Exception e) {
                    out.println("<!-- Error: " + e.getMessage() + " -->");
                  }
                %>
              </select>
            </div>
            <div class="col-md-6">
              <label for="document_type" class="form-label">Document Type</label>
              <select class="form-select" id="document_type" name="document_type" required>
                <option value="DRAFT">Draft</option>
                <option value="NOTICE">Notice</option>
                <option value="REPLY">Reply</option>
                <option value="ORDER">Order</option>
                <option value="OTHER">Other</option>
              </select>
            </div>
            <div class="col-12">
              <label for="doc_type" class="form-label">Document Category</label>
              <select class="form-select" id="doc_type" name="doc_type" required>
                <option value="DRAFT">Draft Document</option>
                <option value="NOTICE">Legal Notice</option>
                <option value="REPLY">Reply/Response</option>
                <option value="ORDER">Court Order</option>
                <option value="OTHER">Other Document</option>
              </select>
            </div>
            <div class="col-12">
              <label class="form-label">File Upload</label>
              <div class="file-upload-area" onclick="document.getElementById('file_input').click()">
                <i class="fas fa-cloud-upload-alt fa-2x text-muted mb-2"></i>
                <p class="mb-1">Click to select file or drag and drop</p>
                <small class="text-muted">Supported formats: PDF, DOC, DOCX, JPG, PNG (Max: 50MB)</small>
                <input type="file" id="file_input" name="document_file" style="display: none;" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" required>
              </div>
              <div id="file-info" class="mt-2" style="display: none;">
                <small class="text-success"><i class="fas fa-check-circle"></i> File selected</small>
              </div>
            </div>
            <div class="col-12">
              <button type="submit" class="btn btn-custom">
                <i class="fas fa-upload"></i> Upload Document
              </button>
            </div>
          </div>
        </form>
      </div>

      <!-- Document Versions -->
      <h4 class="mb-3"><i class="fas fa-history"></i> Document Versions</h4>
      <div class="row">
        <%
          try {
            Class.forName("com.mysql.jdbc.Driver");
                    Connection con = getDatabaseConnection();
            String query = "SELECT ld.*, a.title, a.cname FROM lawyer_documents ld JOIN allotlawyer a ON ld.alid = a.alid WHERE ld.uploaded_by=? ORDER BY ld.upload_date DESC";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, username);
            ResultSet rs = pst.executeQuery();

            boolean hasDocuments = false;
            while(rs.next()) {
              hasDocuments = true;
              String fileName = rs.getString("file_name");
              String documentType = rs.getString("document_type");
              String docType = rs.getString("doc_type");
              int version = rs.getInt("version");
              String uploadDate = rs.getString("upload_date");
              String caseTitle = rs.getString("title");
              String clientName = rs.getString("cname");
              String filePath = rs.getString("file_path");
        %>
        <div class="col-md-6 mb-3">
          <div class="document-card">
            <div class="document-header">
              <div class="document-title"><%= fileName %></div>
              <div class="version-badge">v<%= version %></div>
            </div>
            <div class="document-meta">
              <strong>Case:</strong> <%= caseTitle %> - <%= clientName %><br>
              <strong>Type:</strong> <%= documentType %> | <strong>Category:</strong> <%= docType %><br>
              <strong>Uploaded:</strong> <%= uploadDate %>
            </div>
            <div class="mt-2">
              <a href="<%= filePath %>" target="_blank" class="btn btn-sm btn-outline-primary">
                <i class="fas fa-eye"></i> View
              </a>
              <a href="<%= filePath %>" download class="btn btn-sm btn-outline-success">
                <i class="fas fa-download"></i> Download
              </a>
            </div>
          </div>
        </div>
        <%
            }
            if (!hasDocuments) {
        %>
        <div class="col-12">
          <div class="text-center py-5">
            <i class="fas fa-file-alt fa-3x text-muted mb-3"></i>
            <h5 class="text-muted">No documents uploaded yet</h5>
            <p class="text-muted">Upload your first document using the form above.</p>
          </div>
        </div>
        <%
            }
            rs.close();
            pst.close();
            con.close();
          } catch(Exception e) {
        %>
        <div class="col-12">
          <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle"></i> Error loading documents: <%= e.getMessage() %>
          </div>
        </div>
        <%
          }
        %>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    // File upload feedback
    document.getElementById('file_input').addEventListener('change', function(e) {
      const fileInfo = document.getElementById('file-info');
      if (this.files.length > 0) {
        fileInfo.style.display = 'block';
        fileInfo.innerHTML = '<small class="text-success"><i class="fas fa-check-circle"></i> ' + this.files[0].name + ' selected</small>';
      } else {
        fileInfo.style.display = 'none';
      }
    });

    // Drag and drop functionality
    const uploadArea = document.querySelector('.file-upload-area');
    const fileInput = document.getElementById('file_input');

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      uploadArea.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
      e.preventDefault();
      e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
      uploadArea.addEventListener(eventName, highlight, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
      uploadArea.addEventListener(eventName, unhighlight, false);
    });

    function highlight(e) {
      uploadArea.classList.add('dragover');
    }

    function unhighlight(e) {
      uploadArea.classList.remove('dragover');
    }

    uploadArea.addEventListener('drop', handleDrop, false);

    function handleDrop(e) {
      const dt = e.dataTransfer;
      const files = dt.files;

      if (files.length > 0) {
        fileInput.files = files;
        fileInput.dispatchEvent(new Event('change'));
      }
    }
  </script>
</body>
</html>
