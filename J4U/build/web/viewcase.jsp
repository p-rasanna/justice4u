<%--
    Document   : viewcase
    Created on : 21 Mar, 2025
    Author     : ZulkiflMugad
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>

<%
  String lname = (String) session.getAttribute("lname");
  if (lname == null) {
    response.sendRedirect("Lawyerlogin.html");
    return;
  }

  String idParam = request.getParameter("id");
  if (idParam == null || idParam.isEmpty()) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid case ID");
    return;
  }

  int alid = Integer.parseInt(idParam);
  String caseTitle = "";
  String caseDesc = "";
  String clientName = "";
  String clientEmail = "";
  String courtType = "";
  String city = "";
  String filedDate = "";
  String status = "REQUESTED";

  try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = getDatabaseConnection();

    // Get case details
    PreparedStatement caseStmt = con.prepareStatement(
      "SELECT a.*, COALESCE(cs.status, 'REQUESTED') as current_status " +
      "FROM allotlawyer a " +
      "LEFT JOIN case_status cs ON a.alid = cs.alid " +
      "WHERE a.alid=? AND a.lname=?"
    );
    caseStmt.setInt(1, alid);
    caseStmt.setString(2, lname);
    ResultSet caseRs = caseStmt.executeQuery();

    if (caseRs.next()) {
      caseTitle = caseRs.getString("title");
      caseDesc = caseRs.getString("des");
      clientName = caseRs.getString("name");
      clientEmail = caseRs.getString("cname");
      courtType = caseRs.getString("courttype");
      city = caseRs.getString("city");
      filedDate = caseRs.getString("curdate");
      status = caseRs.getString("current_status");
    } else {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Case not found or unauthorized");
      return;
    }
    caseRs.close();
    caseStmt.close();
    con.close();

  } catch(Exception e) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Error loading case: " + e.getMessage());
    return;
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Case Details | Justice4U</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body {
      background: linear-gradient(135deg, #f5f2ea 0%, #e8decc 100%);
      min-height: 100vh;
    }
    .case-card {
      background: white;
      border-radius: 15px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.1);
      margin: 20px auto;
      max-width: 800px;
    }
    .status-badge {
      padding: 5px 15px;
      border-radius: 20px;
      font-size: 0.9rem;
      font-weight: 500;
    }
    .status-requested { background: #fff3cd; color: #856404; }
    .status-accepted { background: #d1ecf1; color: #0c5460; }
    .status-progress { background: #d4edda; color: #155724; }
    .status-closed { background: #f8d7da; color: #721c24; }
  </style>
</head>
<body>
<div class="container py-5">
  <div class="case-card p-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h2 class="mb-0">Case Details</h2>
      <span class="status-badge status-<%= status.toLowerCase() %>">
        <%= status.replace("_", " ").toUpperCase() %>
      </span>
    </div>

    <div class="row mb-3">
      <div class="col-md-6">
        <strong>Case ID:</strong> <%= alid %>
      </div>
      <div class="col-md-6">
        <strong>Filed Date:</strong> <%= filedDate %>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-6">
        <strong>Court Type:</strong> <%= courtType %>
      </div>
      <div class="col-md-6">
        <strong>City:</strong> <%= city %>
      </div>
    </div>

    <div class="mb-3">
      <strong>Case Title:</strong><br>
      <%= caseTitle %>
    </div>

    <div class="mb-3">
      <strong>Description:</strong><br>
      <%= caseDesc %>
    </div>

    <div class="row mb-4">
      <div class="col-md-6">
        <strong>Client Name:</strong> <%= clientName %>
      </div>
      <div class="col-md-6">
        <strong>Client Email:</strong> <%= clientEmail %>
      </div>
    </div>

    <div class="d-flex gap-2">
      <a href="Lawyerdashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
      <% if ("REQUESTED".equals(status)) { %>
        <a href="acceptcase.jsp?id=<%= alid %>" class="btn btn-success">Accept Case</a>
        <a href="rejectcase.jsp?id=<%= alid %>" class="btn btn-danger">Reject Case</a>
      <% } else if ("ACCEPTED".equals(status) || "IN_PROGRESS".equals(status)) { %>
        <a href="chat.jsp?case_id=<%= alid %>" class="btn btn-primary">Open Chat</a>
        <button type="button" class="btn btn-secondary" onclick="document.getElementById('uploadModal').style.display='block'">Upload Doc</button>
        <a href="view_case_documents.jsp?caseId=<%= alid %>" class="btn btn-info">View Documents</a>
        <a href="closecase.jsp?id=<%= alid %>" class="btn btn-warning">Close Case</a>
      <% } %>
    </div>
  </div>
</div>

<!-- Simple Upload Modal -->
<div id="uploadModal" class="modal" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; overflow:auto; background-color:rgba(0,0,0,0.4);">
  <div class="modal-content" style="background-color:#fefefe; margin:15% auto; padding:20px; border:1px solid #888; width:400px; border-radius:10px;">
    <button type="button" class="close" onclick="document.getElementById('uploadModal').style.display='none'" style="border:none; background:none; color:#aaa; float:right; font-size:28px; font-weight:bold; cursor:pointer;" aria-label="Close">&times;</button>
    <h3>Upload Case Document</h3>
    <form action="upload_case_doc.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="caseId" value="<%= alid %>">
        <div class="mb-3">
            <label class="form-label" for="caseFile">Select File</label>
            <input type="file" id="caseFile" name="file" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-success">Upload</button>
    </form>
  </div>
</div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
