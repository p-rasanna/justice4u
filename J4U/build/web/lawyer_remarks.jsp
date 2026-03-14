<%--
    Document   : lawyer_remarks
    Created on : 2025
    Author     : Justice4U System
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.RBACUtil"%>
<%@ include file="db_connection.jsp" %>

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

  // Handle form submission
  String message = "";
  String messageType = "";

  if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
      String caseId = request.getParameter("case_id");
      String remarkText = request.getParameter("remark_text");
      String visibility = request.getParameter("visibility");

      Class.forName("com.mysql.jdbc.Driver");
              Connection con = getDatabaseConnection();
      String query = "INSERT INTO lawyer_remarks (alid, lawyer_email, remark_text, visibility) VALUES (?, ?, ?, ?)";
      PreparedStatement pst = con.prepareStatement(query);
      pst.setInt(1, Integer.parseInt(caseId));
      pst.setString(2, username);
      pst.setString(3, remarkText);
      pst.setString(4, visibility);
      pst.executeUpdate();
      pst.close();
      con.close();

      message = "Remark added successfully!";
      messageType = "success";

    } catch (Exception e) {
      message = "Error adding remark: " + e.getMessage();
      messageType = "danger";
    }
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lawyer Remarks | Justice4U</title>
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

    .remark-form {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 20px;
    }

    .remark-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 12px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    .remark-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
    }

    .remark-author {
      font-weight: 600;
      color: var(--j4u-text-main);
    }

    .remark-date {
      font-size: 0.85rem;
      color: var(--j4u-text-muted);
    }

    .remark-text {
      color: var(--j4u-text-main);
      margin-bottom: 8px;
    }

    .visibility-badge {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 999px;
      font-size: 0.75rem;
      font-weight: 500;
    }

    .visibility-internal {
      background: #fef3c7;
      color: #92400e;
    }

    .visibility-client {
      background: #dbeafe;
      color: #1e40af;
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
  </style>
</head>
<body>
  <div class="dashboard-shell">
    <div class="card-main">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h2 class="mb-1"><i class="fas fa-comments"></i> Case Remarks</h2>
          <p class="text-muted mb-0">Add and manage remarks for your cases</p>
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

      <!-- Add New Remark Form -->
      <div class="remark-form">
        <h4 class="mb-3"><i class="fas fa-plus-circle"></i> Add New Remark</h4>
        <form method="post">
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
              <label for="visibility" class="form-label">Visibility</label>
              <select class="form-select" id="visibility" name="visibility" required>
                <option value="INTERNAL">Internal Only</option>
                <option value="CLIENT_VISIBLE">Visible to Client</option>
              </select>
            </div>
            <div class="col-12">
              <label for="remark_text" class="form-label">Remark</label>
              <textarea class="form-control" id="remark_text" name="remark_text" rows="4" placeholder="Enter your remark..." required></textarea>
            </div>
            <div class="col-12">
              <button type="submit" class="btn btn-custom">
                <i class="fas fa-save"></i> Add Remark
              </button>
            </div>
          </div>
        </form>
      </div>

      <!-- Existing Remarks -->
      <h4 class="mb-3"><i class="fas fa-list"></i> Case Remarks</h4>
      <div class="row">
        <%
          try {
            Class.forName("com.mysql.jdbc.Driver");
                    Connection con = getDatabaseConnection();
            String query = "SELECT lr.*, a.title, a.cname FROM lawyer_remarks lr JOIN allotlawyer a ON lr.alid = a.alid WHERE lr.lawyer_email=? ORDER BY lr.created_at DESC";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, username);
            ResultSet rs = pst.executeQuery();

            boolean hasRemarks = false;
            while(rs.next()) {
              hasRemarks = true;
              String remarkText = rs.getString("remark_text");
              String visibility = rs.getString("visibility");
              String createdAt = rs.getString("created_at");
              String caseTitle = rs.getString("title");
              String clientName = rs.getString("cname");
        %>
        <div class="col-md-6 mb-3">
          <div class="remark-card">
            <div class="remark-header">
              <div class="remark-author"><%= caseTitle %> - <%= clientName %></div>
              <div class="remark-date"><%= createdAt %></div>
            </div>
            <div class="remark-text"><%= remarkText %></div>
            <div class="visibility-badge visibility-<%= visibility.toLowerCase() %>">
              <%= "INTERNAL".equals(visibility) ? "Internal Only" : "Visible to Client" %>
            </div>
          </div>
        </div>
        <%
            }
            if (!hasRemarks) {
        %>
        <div class="col-12">
          <div class="text-center py-5">
            <i class="fas fa-comments fa-3x text-muted mb-3"></i>
            <h5 class="text-muted">No remarks added yet</h5>
            <p class="text-muted">Add your first case remark using the form above.</p>
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
            <i class="fas fa-exclamation-triangle"></i> Error loading remarks: <%= e.getMessage() %>
          </div>
        </div>
        <%
          }
        %>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
