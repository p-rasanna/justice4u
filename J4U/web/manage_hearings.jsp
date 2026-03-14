<%-- Document : manage_hearings Created on : 2025 Author : Justice4U System --%>

  <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*, java.io.*, java.util.*, com.j4u.RBACUtil, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.io.*"
    %>
    <%@ include file="db_connection.jsp" %>

      <% // Session validation and RBAC check String username=(String) session.getAttribute("lname"); if
        (username==null) { response.sendRedirect("Lawyerlogin.html?msg=Session expired"); return; } // Lawyer is already
        validated during login, no additional check needed // Handle form submission for adding hearing String
        message="" ; String messageType="" ; if ("POST".equalsIgnoreCase(request.getMethod())) { try { // Handle file
        upload String uploadPath=application.getRealPath("/") + "uploads/hearings/" ; File uploadDir=new
        File(uploadPath); if (!uploadDir.exists()) { uploadDir.mkdirs(); } MultipartRequest multi=new
        MultipartRequest(request, uploadPath, 50 * 1024 * 1024, "UTF-8" , new DefaultFileRenamePolicy()); String
        caseId=multi.getParameter("case_id"); String hearingDate=multi.getParameter("hearing_date"); String
        courtName=multi.getParameter("court_name"); String remarks=multi.getParameter("remarks"); Enumeration
        files=multi.getFileNames(); String orderCopyPath=null; if (files.hasMoreElements()) { String fileField=(String)
        files.nextElement(); File uploadedFile=multi.getFile(fileField); if (uploadedFile !=null) {
        orderCopyPath="uploads/hearings/" + multi.getFilesystemName(fileField); } } // Insert into database Connection
        con=getDatabaseConnection(); String
        query="INSERT INTO hearing_schedule (case_id, hearing_date, court_name, remarks, created_by, order_copy_path) VALUES (?, ?, ?, ?, ?, ?)"
        ; PreparedStatement pst=con.prepareStatement(query); pst.setInt(1, Integer.parseInt(caseId)); pst.setString(2,
        hearingDate); pst.setString(3, courtName); pst.setString(4, remarks); pst.setString(5, username);
        pst.setString(6, orderCopyPath); pst.executeUpdate(); // Add to timeline String
        timelineQuery="INSERT INTO case_timeline (alid, event_type, event_description, created_by) VALUES (?, 'HEARING_SCHEDULED', ?, ?)"
        ; PreparedStatement timelinePst=con.prepareStatement(timelineQuery); timelinePst.setInt(1,
        Integer.parseInt(caseId)); timelinePst.setString(2, "Hearing scheduled for " + hearingDate + " at " +
        courtName); timelinePst.setString(3, username); timelinePst.executeUpdate(); pst.close(); timelinePst.close();
        con.close(); message="Hearing scheduled successfully!" ; messageType="success" ; } catch (Exception e) {
        message="Error scheduling hearing: " + e.getMessage(); messageType="danger" ; } } %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Manage Court Hearings | Justice4U</title>
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

            .hearing-form {
              background: #f8fafc;
              border: 1px solid #e2e8f0;
              border-radius: 12px;
              padding: 20px;
              margin-bottom: 20px;
            }

            .hearing-card {
              background: #ffffff;
              border: 1px solid #e2e8f0;
              border-radius: 12px;
              padding: 16px;
              margin-bottom: 12px;
              box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            }

            .hearing-header {
              display: flex;
              justify-content: space-between;
              align-items: center;
              margin-bottom: 8px;
            }

            .hearing-title {
              font-weight: 600;
              color: var(--j4u-text-main);
            }

            .hearing-date {
              font-size: 0.9rem;
              color: var(--j4u-accent-blue);
              font-weight: 500;
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
                  <h2 class="mb-1"><i class="fas fa-gavel"></i> Court Hearing Management</h2>
                  <p class="text-muted mb-0">Schedule and manage court hearings for your cases</p>
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

                  <!-- Add New Hearing Form -->
                  <div class="hearing-form">
                    <h4 class="mb-3"><i class="fas fa-plus-circle"></i> Schedule New Hearing</h4>
                    <form method="post" enctype="multipart/form-data">
                      <div class="row g-3">
                        <div class="col-md-6">
                          <label for="case_id" class="form-label">Case</label>
                          <select class="form-select" id="case_id" name="case_id" required>
                            <option value="">Select Case</option>
                            <% try { Connection con=getDatabaseConnection(); String
                              query="SELECT a.alid, a.title, a.cname FROM allotlawyer a JOIN case_status cs ON a.alid = cs.alid WHERE a.lname=? AND cs.status IN ('ACCEPTED', 'IN_PROGRESS')"
                              ; PreparedStatement pst=con.prepareStatement(query); pst.setString(1, username); ResultSet
                              rs=pst.executeQuery(); while(rs.next()) { %>
                              <option value="<%= rs.getInt(" alid") %>"><%= com.j4u.Sanitizer.sanitize(rs.getString("title")) %> - <%= com.j4u.Sanitizer.sanitize(rs.getString("cname")) %>
                              </option>
                              <% } rs.close(); pst.close(); con.close(); } catch(Exception e) { out.println("<!--
                                Error: " + e.getMessage() + " -->");
                                }
                                %>
                          </select>
                        </div>
                        <div class="col-md-6">
                          <label for="hearing_date" class="form-label">Hearing Date</label>
                          <input type="date" class="form-control" id="hearing_date" name="hearing_date" required>
                        </div>
                        <div class="col-12">
                          <label for="court_name" class="form-label">Court Name</label>
                          <input type="text" class="form-control" id="court_name" name="court_name"
                            placeholder="e.g., District Court, Solapur" required>
                        </div>
                        <div class="col-12">
                          <label for="remarks" class="form-label">Remarks</label>
                          <textarea class="form-control" id="remarks" name="remarks" rows="3"
                            placeholder="Additional notes about the hearing..."></textarea>
                        </div>
                        <div class="col-12">
                          <label for="order_copy" class="form-label">Order Copy (Optional)</label>
                          <input type="file" class="form-control" id="order_copy" name="order_copy"
                            accept=".pdf,.doc,.docx,.jpg,.jpeg,.png">
                          <div class="form-text">Upload court order copy or related documents (Max: 50MB)</div>
                        </div>
                        <div class="col-12">
                          <button type="submit" class="btn btn-custom">
                            <i class="fas fa-calendar-plus"></i> Schedule Hearing
                          </button>
                        </div>
                      </div>
                    </form>
                  </div>

                  <!-- Existing Hearings -->
                  <h4 class="mb-3"><i class="fas fa-list"></i> Scheduled Hearings</h4>
                  <div class="row">
                    <% try { Connection con=getDatabaseConnection(); String
                      query="SELECT hs.*, a.title, a.cname FROM hearing_schedule hs JOIN allotlawyer a ON hs.case_id = a.alid WHERE hs.created_by=? ORDER BY hs.hearing_date DESC"
                      ; PreparedStatement pst=con.prepareStatement(query); pst.setString(1, username); ResultSet
                      rs=pst.executeQuery(); boolean hasHearings=false; while(rs.next()) { hasHearings=true; %>
                      <div class="col-md-6 mb-3">
                        <div class="hearing-card">
                          <div class="hearing-header">
                            <div class="hearing-title">
                              <%= com.j4u.Sanitizer.sanitize(rs.getString("court_name")) %>
                            </div>
                            <div class="hearing-date">
                              <%= com.j4u.Sanitizer.sanitize(rs.getString("hearing_date")) %>
                            </div>
                          </div>
                          <div class="mb-2">
                            <strong>Case:</strong>
                            <%= com.j4u.Sanitizer.sanitize(rs.getString("title")) %> (<%= com.j4u.Sanitizer.sanitize(rs.getString("cname")) %>)
                          </div>
                          <% if (rs.getString("remarks") !=null && !rs.getString("remarks").isEmpty()) { %>
                            <div class="mb-2">
                              <strong>Remarks:</strong>
                              <%= com.j4u.Sanitizer.sanitize(rs.getString("remarks")) %>
                            </div>
                            <% } %>
                              <% if (rs.getString("order_copy_path") !=null) { %>
                                <div class="mb-2">
                                  <strong>Order Copy:</strong>
                                  <a href="<%= com.j4u.Sanitizer.sanitize(rs.getString(" order_copy_path")) %>" target="_blank"
                                    class="text-primary">
                                    <i class="fas fa-file-download"></i> View Document
                                  </a>
                                </div>
                                <% } %>
                                  <small class="text-muted">Scheduled on: <%= com.j4u.Sanitizer.sanitize(rs.getString("created_at")) %></small>
                        </div>
                      </div>
                      <% } if (!hasHearings) { %>
                        <div class="col-12">
                          <div class="text-center py-5">
                            <i class="fas fa-calendar-times fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">No hearings scheduled yet</h5>
                            <p class="text-muted">Schedule your first court hearing using the form above.</p>
                          </div>
                        </div>
                        <% } rs.close(); pst.close(); con.close(); } catch(Exception e) { %>
                          <div class="col-12">
                            <div class="alert alert-danger">
                              <i class="fas fa-exclamation-triangle"></i> Error loading hearings: <%= e.getMessage() %>
                            </div>
                          </div>
                          <% } %>
                  </div>
            </div>
          </div>

          <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>
