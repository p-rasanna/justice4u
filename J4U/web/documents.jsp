<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<%
  String username = (String) session.getAttribute("cname");
  if (username == null) {
    response.sendRedirect("cust_login.html");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Justice4U | My Documents</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <style>
    :root {
      --bg-body: #F3F4F6;
      --bg-surface: #FFFFFF;
      --text-primary: #1F2937;
      --text-secondary: #6B7280;
      --brand-gold: #C6A75E;
      --border-light: #E5E7EB;
      --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
      --radius: 12px;
    }
    body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-primary); }
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    .header { background: var(--bg-surface); padding: 24px; border-radius: var(--radius); margin-bottom: 24px; box-shadow: var(--shadow-card); }
    .doc-card { background: var(--bg-surface); border: 1px solid var(--border-light); border-radius: var(--radius); padding: 20px; margin-bottom: 16px; box-shadow: var(--shadow-card); }
    .doc-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
    .doc-title { font-weight: 600; color: var(--text-primary); }
    .doc-meta { font-size: 0.9rem; color: var(--text-secondary); }
    .btn-upload { background: var(--brand-gold); color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; }
    .btn-upload:hover { background: #B0924B; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>My Documents</h2>
      <p>Manage your case-related documents and uploads</p>
    </div>

    <div class="mb-4">
      <button class="btn-upload" onclick="document.getElementById('fileInput').click()">
        <i class="ph ph-upload"></i> Upload New Document
      </button>
      <input type="file" id="fileInput" style="display: none;" multiple>
    </div>

    <div id="documentsList">
      <%
        try {
          Class.forName("com.mysql.jdbc.Driver");
          Connection con = getDatabaseConnection();

          // Get documents for this client
          String query = "SELECT ld.doc_id, ld.filename, ld.upload_date, ld.status, c.title as case_title " +
                        "FROM lawyer_documents ld " +
                        "JOIN allotlawyer al ON ld.alid = al.alid " +
                        "JOIN cust_reg cr ON al.cname = cr.cname " +
                        "JOIN casetb c ON al.cid = c.cid " +
                        "WHERE cr.email = ? " +
                        "ORDER BY ld.upload_date DESC";

          PreparedStatement ps = con.prepareStatement(query);
          ps.setString(1, username);
          ResultSet rs = ps.executeQuery();

          boolean hasDocs = false;
          while (rs.next()) {
            hasDocs = true;
      %>
      <div class="doc-card">
        <div class="doc-header">
          <div>
            <div class="doc-title"><%= com.j4u.Sanitizer.sanitize(rs.getString("filename")) %></div>
            <div class="doc-meta">Case: <%= com.j4u.Sanitizer.sanitize(rs.getString("case_title")) %> | Uploaded: <%= com.j4u.Sanitizer.sanitize(rs.getString("upload_date")) %></div>
          </div>
          <div>
            <span class="badge bg-<%= com.j4u.Sanitizer.sanitize(rs.getString("status").equals("APPROVED") ? "success" : "warning") %>">
              <%= com.j4u.Sanitizer.sanitize(rs.getString("status")) %>
            </span>
            <button class="btn btn-sm btn-outline-primary ms-2">
              <i class="ph ph-download"></i> Download
            </button>
          </div>
        </div>
      </div>
      <%
          }

          if (!hasDocs) {
      %>
      <div class="text-center py-5">
        <i class="ph ph-files" style="font-size: 3rem; color: var(--text-secondary);"></i>
        <h5 class="mt-3">No documents yet</h5>
        <p class="text-muted">Upload your first document to get started</p>
      </div>
      <%
          }

          rs.close();
          ps.close();
          con.close();
        } catch (Exception e) {
      %>
      <div class="alert alert-danger">
        Error loading documents: <%= e.getMessage() %>
      </div>
      <%
        }
      %>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
