<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<%
  // ==========================================
  // 1️⃣ ENHANCED SESSION & ROLE SECURITY
  // ==========================================

  // Validate lawyer session
  String lawyerEmail = (String) session.getAttribute("lname");
  Integer lawyerId = (Integer) session.getAttribute("lid");

  // Strict validation: must have valid lawyer session
  if (lawyerEmail == null || lawyerId == null) {
    response.sendRedirect("Lawyer_login.html?msg=Unauthorized access. Please login as lawyer.");
    return;
  }

  // ==========================================
  // 2️⃣ SECURE CLIENT ID PARAMETER
  // ==========================================

  // Use client_id instead of email in URL
  String clientIdParam = request.getParameter("client_id");
  if (clientIdParam == null || clientIdParam.trim().isEmpty()) {
    response.sendRedirect("viewcustdetails.jsp?msg=Invalid client access");
    return;
  }

  int clientId = 0;
  try {
    clientId = Integer.parseInt(clientIdParam);
  } catch (NumberFormatException e) {
    response.sendRedirect("viewcustdetails.jsp?msg=Invalid client ID");
    return;
  }

  // ==========================================
  // 3️⃣ AUTHORIZATION CHECK 
  // ==========================================

  // Database connection and data fetching
  Connection con = null;
  PreparedStatement ps = null;
  ResultSet rs = null;

  // Client basic info
  String clientName = "", clientEmail = "", clientDOB = "", clientMobile = "", clientAadhar = "", clientCurrentAddr = "", clientPermanentAddr = "";

  // Cases assigned to this lawyer for this client
  ResultSet caseRs = null;

  boolean isAuthorized = false;

  try {
    Class.forName("com.mysql.jdbc.Driver");
    con = getDatabaseConnection();

    // Check if this lawyer is assigned to this client via customer_cases
    ps = con.prepareStatement(
        "SELECT COUNT(*) FROM customer_cases cc " +
        "WHERE cc.assigned_lawyer_id = ? AND cc.customer_id = ?"
    );
    ps.setInt(1, lawyerId);
    ps.setInt(2, clientId);
    rs = ps.executeQuery();
    if (rs.next() && rs.getInt(1) > 0) {
      isAuthorized = true;
    }
    rs.close();
    ps.close();

    if (!isAuthorized) {
      // Block unauthorized access
      response.sendRedirect("viewcustdetails.jsp?msg=Unauthorized Client Access - You are not assigned to this client");
      return;
    }

    // Fetch client basic information using client_id
    ps = con.prepareStatement("SELECT * FROM cust_reg WHERE cid = ?");
    ps.setInt(1, clientId);
    rs = ps.executeQuery();
    if (rs.next()) {
      clientName = rs.getString("cname");
      clientEmail = rs.getString("email");
      clientDOB = rs.getString("dob");
      clientMobile = rs.getString("mobno");
      clientAadhar = rs.getString("ano");
      clientCurrentAddr = rs.getString("cadd");
      clientPermanentAddr = rs.getString("padd");
    }
    rs.close();
    ps.close();

    // Fetch cases assigned to this lawyer for this client
    ps = con.prepareStatement(
      "SELECT cc.* FROM customer_cases cc " +
      "WHERE cc.assigned_lawyer_id = ? AND cc.customer_id = ?"
    );
    ps.setInt(1, lawyerId);
    ps.setInt(2, clientId);
    caseRs = ps.executeQuery();

  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("viewcustdetails.jsp?msg=System error occurred. Please try again.");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Justice4U · Client Dossier</title>

  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
      /* ============================
         1. 10/10 INTELLIGENCE THEME
         ============================ */
      :root {
          --bg-ivory: #FAFAF8;
          --ink-primary: #121212;
          --ink-secondary: #555555;
          --ink-tertiary: #888888;
          
          --gold-main: #C6A75E;
          --gold-dim: #9C824A;
          --success-green: #059669;
          
          --surface-card: #FFFFFF;
          --border-subtle: #E6E6E6;
          
          --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
          --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
      }

      * { box-sizing: border-box; }

      body {
          margin: 0;
          background-color: var(--bg-ivory);
          color: var(--ink-primary);
          font-family: 'Inter', sans-serif;
          min-height: 100vh;
          background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
      }

      .dashboard-shell {
          max-width: 1400px; margin: 0 auto; padding: 40px 32px;
      }

      .smart-enter {
          opacity: 0; transform: translateY(15px);
          /* animation removed */
      }
      .d-1 { animation-delay: 0.1s; }
      .d-2 { animation-delay: 0.2s; }
      .d-3 { animation-delay: 0.3s; }
      .d-4 { animation-delay: 0.4s; }

      @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

      /* HEADER */
      .admin-header {
          display: flex; justify-content: space-between; align-items: flex-end;
          margin-bottom: 40px; border-bottom: 1px solid var(--border-subtle); padding-bottom: 24px;
      }

      .header-content h1 {
          font-family: 'Playfair Display', serif;
          font-size: 2.2rem; margin: 0; color: var(--ink-primary);
      }
      
      .header-meta {
          display: flex; gap: 24px; align-items: center; margin-top: 8px;
          font-family: 'Space Grotesk', monospace; font-size: 0.8rem; color: var(--ink-secondary);
      }
      .meta-item { display: flex; align-items: center; gap: 6px; }

      .btn-back-header {
          display: inline-flex; align-items: center; gap: 8px;
          padding: 8px 16px; border-radius: 100px; font-weight: 600; font-size: 0.85rem;
          text-decoration: none; border: 1px solid var(--border-subtle); background: #fff;
          color: var(--ink-primary); transition: all 0.2s;
      }
      .btn-back-header:hover { border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-1px); }

      /* PANEL & GRID */
      .panel {
          background: var(--surface-card); border: 1px solid var(--border-subtle);
          border-radius: 16px; overflow: hidden; box-shadow: var(--shadow-card);
          margin-bottom: 32px;
      }

      .panel-head {
          padding: 24px 32px; border-bottom: 1px solid var(--border-subtle);
          background: #FAFAFA; display: flex; justify-content: space-between; align-items: center;
      }
      .panel-head h3 {
          font-family: 'Inter', sans-serif; font-size: 1.1rem; margin: 0; 
          font-weight: 600; color: var(--ink-primary); display: flex; align-items: center; gap: 10px;
      }
      .panel-icon { color: var(--gold-main); font-size: 1.4rem; }

      .grid-layout {
          display: grid; grid-template-columns: 1fr 300px; gap: 32px; align-items: start;
      }
      
      @media (max-width: 992px) { .grid-layout { grid-template-columns: 1fr; } }

      /* INFO GRID */
      .info-grid {
          display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 24px; padding: 32px;
      }

      .info-item { display: flex; flex-direction: column; }
      .info-label {
          font-size: 0.75rem; font-weight: 600; color: var(--ink-secondary);
          text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 6px;
      }
      .info-value { font-size: 0.95rem; color: var(--ink-primary); font-weight: 500; }

      /* TABLE */
      .table-responsive { max-height: 400px; overflow: auto; }
      .table { margin: 0; width: 100%; border-collapse: collapse; }
      .table thead th {
          background: #FFF; color: var(--ink-secondary);
          font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
          padding: 16px 32px; border-bottom: 1px solid var(--border-subtle);
          position: sticky; top: 0; z-index: 10; font-family: 'Inter', sans-serif;
      }
      .table tbody tr { transition: background 0.2s; border-bottom: 1px solid #f5f5f5; }
      .table tbody tr:hover { background: #FCFCFA; }
      .table tbody td { padding: 16px 32px; font-size: 0.9rem; color: var(--ink-primary); vertical-align: middle; }

      .col-main { font-weight: 600; font-family: 'Inter', sans-serif; }
      .col-sub { color: var(--ink-secondary); font-size: 0.8rem; margin-top: 2px; }

      .status-active {
          display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px;
          background: rgba(5, 150, 105, 0.1); color: var(--success-green);
          border-radius: 100px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase;
      }

      .btn-action {
          display: inline-flex; align-items: center; justify-content: center; gap: 6px;
          padding: 6px 14px; border-radius: 8px; font-size: 0.8rem; font-weight: 600; 
          text-decoration: none; border: 1px solid var(--border-subtle); color: var(--ink-primary);
          transition: all 0.2s; background: #fff; cursor: pointer;
      }
      .btn-action-primary { border-color: rgba(198, 167, 94, 0.5); color: var(--gold-dim); padding: 6px 20px; }
      .btn-action:hover { border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-1px); }
      .btn-action-primary:hover { background: var(--gold-main); color: #fff; border-color: var(--gold-main); }

      /* ACTIONS SIDEBAR */
      .action-list { padding: 24px; display: flex; flex-direction: column; gap: 12px; }
      .btn-sidebar-action {
          display: flex; align-items: center; gap: 12px; padding: 14px 16px;
          border-radius: 8px; background: #FAFAFA; border: 1px solid var(--border-subtle);
          color: var(--ink-primary); font-weight: 600; font-size: 0.9rem; text-decoration: none;
          transition: all 0.2s; cursor: pointer; text-align: left; width: 100%;
      }
      .btn-sidebar-action:hover { background: #fff; border-color: var(--gold-main); color: var(--gold-main); box-shadow: 0 4px 12px rgba(198, 167, 94, 0.05); }
      .btn-sidebar-action i { font-size: 1.2rem; color: var(--gold-dim); }

      /* MODAL & TOAST */
      .modal-overlay {
          position: fixed; top: 0; left: 0; right: 0; bottom: 0;
          background: rgba(18, 18, 18, 0.5); backdrop-filter: blur(4px);
          display: none; align-items: center; justify-content: center; z-index: 1000;
          opacity: 0; transition: opacity 0.3s ease;
      }
      .modal-overlay.active { display: flex; opacity: 1; }
      .modal-content {
          background: var(--surface-card); width: 100%; max-width: 500px;
          border-radius: 16px; padding: 32px; box-shadow: 0 24px 48px rgba(0,0,0,0.1);
          transform: translateY(20px); transition: transform 0.3s ease;
          border: 1px solid var(--border-subtle);
      }
      .modal-overlay.active .modal-content { transform: translateY(0); }
      .modal-header {
          display: flex; justify-content: space-between; align-items: center;
          margin-bottom: 24px; border-bottom: 1px solid var(--border-subtle); padding-bottom: 16px;
      }
      .modal-title { font-size: 1.25rem; font-weight: 600; font-family: 'Playfair Display', serif; display: flex; align-items: center; gap: 8px; margin: 0; }
      .modal-close { background: none; border: none; font-size: 1.2rem; cursor: pointer; color: var(--ink-secondary); transition: color 0.2s; }
      .modal-close:hover { color: var(--ink-primary); }
      
      .form-group { margin-bottom: 20px; }
      .form-label { display: block; font-size: 0.85rem; font-weight: 600; color: var(--ink-secondary); margin-bottom: 8px; }
      .form-control {
          width: 100%; padding: 12px 16px; border: 1px solid var(--border-subtle);
          border-radius: 8px; font-size: 0.95rem; font-family: 'Inter', sans-serif;
          transition: all 0.2s; background: #FAFAFA;
      }
      .form-control:focus { outline: none; border-color: var(--gold-main); background: #fff; box-shadow: 0 0 0 3px rgba(198, 167, 94, 0.1); }
      textarea.form-control { resize: vertical; min-height: 100px; }
      
      .btn-submit {
          width: 100%; padding: 14px; background: var(--ink-primary); color: #fff;
          border: none; border-radius: 8px; font-weight: 600; font-size: 0.95rem;
          cursor: pointer; transition: all 0.2s; margin-top: 10px;
      }
      .btn-submit:hover { background: var(--gold-main); }

      .toast {
          position: fixed; top: 24px; right: 24px; background: var(--surface-card);
          border-left: 4px solid var(--gold-main); padding: 16px 24px; border-radius: 8px;
          box-shadow: 0 8px 24px rgba(0,0,0,0.1); display: flex; align-items: center; gap: 12px;
          transform: translateX(120%); transition: transform 0.4s cubic-bezier(0.2, 0.8, 0.2, 1);
          z-index: 1000; font-weight: 500; font-size: 0.95rem;
      }
      .toast.show { transform: translateX(0); }
  </style>
</head>
<body>
    <% String msg = request.getParameter("msg"); if (msg != null && !msg.trim().isEmpty()) { %>
        <div class="toast" id="sysToast">
            <i class="ph-fill ph-info" style="color: var(--gold-main); font-size: 1.2rem;"></i>
            <%= com.j4u.Sanitizer.sanitize(msg) %>
        </div>
        <script>
            setTimeout(() => document.getElementById('sysToast').classList.add('show'), 100);
            setTimeout(() => document.getElementById('sysToast').classList.remove('show'), 4000);
        </script>
    <% } %>

  <div class="dashboard-shell">

    <header class="admin-header smart-enter d-1">
        <div class="header-content">
            <h1>Client Dossier</h1>
            <div class="header-meta">
                <span class="meta-item"><i class="ph-bold ph-user-circle"></i> <%= com.j4u.Sanitizer.sanitize(clientName) %></span>
                <span class="meta-item"><i class="ph-bold ph-identification-card"></i> ID: <%= clientId %></span>
            </div>
        </div>
        <div>
            <a href="viewcustdetails.jsp" class="btn-back-header"><i class="ph ph-arrow-left"></i> Roster</a>
        </div>
    </header>

    <div class="grid-layout">
        <div class="main-column">
            <!-- INFO PANEL -->
            <div class="panel smart-enter d-2">
                <div class="panel-head">
                    <div class="panel-head-left">
                        <h3><i class="ph-fill ph-address-book panel-icon"></i> Basic Information</h3>
                    </div>
                </div>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Full Name</span>
                        <span class="info-value"><%= com.j4u.Sanitizer.sanitize(clientName) %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Email Address</span>
                        <span class="info-value"><%= clientEmail %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Mobile Number</span>
                        <span class="info-value"><%= clientMobile %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Current Address</span>
                        <span class="info-value"><%= com.j4u.Sanitizer.sanitize(clientCurrentAddr) %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Date of Birth</span>
                        <span class="info-value"><%= clientDOB %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Aadhar Number</span>
                        <span class="info-value"><%= clientAadhar %></span>
                    </div>
                </div>
            </div>

            <!-- CASES PANEL -->
            <div class="panel smart-enter d-3">
                <div class="panel-head">
                    <div class="panel-head-left">
                        <h3><i class="ph-fill ph-file-text panel-icon"></i> Assigned Cases</h3>
                    </div>
                    <a href="documents.jsp?client_id=<%= clientId %>" class="btn-action">
                        <i class="ph ph-files"></i> Global Docs
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Case Entry</th>
                                <th>Court & Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                              if (caseRs != null) {
                                try {
                                  boolean hasCases = false;
                                  while (caseRs.next()) {
                                    hasCases = true;
                                    int caseId = caseRs.getInt("case_id");
                                    String caseTitle = caseRs.getString("title");
                                    String court = caseRs.getString("preferred_court_location");
                                    if(court == null) court = "Online Hearing";
                                    String caseDate = caseRs.getString("created_date");
                            %>
                            <tr>
                                <td>
                                    <div class="col-main"><%= com.j4u.Sanitizer.sanitize(caseTitle) %></div>
                                    <div class="col-sub" style="font-family: 'Space Grotesk', monospace;">Case ID: #<%= caseId %></div>
                                </td>
                                <td>
                                    <div><i class="ph-bold ph-scales" style="color:var(--ink-tertiary)"></i> <%= com.j4u.Sanitizer.sanitize(court) %></div>
                                    <div class="col-sub"><i class="ph-bold ph-calendar"></i> <%= caseDate %></div>
                                </td>
                                <td>
                                    <div class="status-active">Active Hearing</div>
                                </td>
                                <td>
                                    <div style="display:flex; gap:8px;">
                                        <a href="case_timeline.jsp?case=<%= caseId %>" class="btn-action">Timeline</a>
                                        <a href="chat.jsp?case_id=<%= caseId %>" class="btn-action btn-action-primary"><i class="ph-bold ph-chat-circle"></i> Chat</a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                  }
                                  if (!hasCases) {
                                      out.print("<tr><td colspan='4' style='text-align:center; padding:40px; color:var(--ink-tertiary); font-style:italic;'>No active cases assigned to you for this client.</td></tr>");
                                  }
                                  caseRs.close();
                                } catch (Exception e) {}
                              }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- SIDEBAR -->
        <div class="sidebar smart-enter d-4">
            <div class="panel">
                <div class="panel-head" style="padding: 20px 24px;">
                    <h3><i class="ph-fill ph-lightning panel-icon"></i> Quick Actions</h3>
                </div>
                <div class="action-list">
                    <button class="btn-sidebar-action" onclick="openNoteModal()">
                        <i class="ph-duotone ph-note"></i> Add Case Notes
                    </button>
                    <button class="btn-sidebar-action" onclick="alert('Update Case Status Functionality Here')">
                        <i class="ph-duotone ph-pulse"></i> Update Status
                    </button>
                    <button class="btn-sidebar-action" onclick="alert('Schedule Hearing Functionality Here')">
                        <i class="ph-duotone ph-calendar-plus"></i> Schedule Hearing
                    </button>
                    <button class="btn-sidebar-action" onclick="alert('Upload Document Functionality Here')">
                        <i class="ph-duotone ph-upload-simple"></i> Upload Document
                    </button>
                </div>
            </div>
            
            <div class="panel" style="background:#FAFAF8; border:none; box-shadow:none;">
                <div style="padding: 24px; text-align:center; color:var(--ink-secondary); font-size:0.85rem; line-height:1.5;">
                    <i class="ph-duotone ph-shield-check" style="font-size:2rem; color:var(--success-green); margin-bottom:12px;"></i><br>
                    <strong>Secure Client Vault.</strong><br>
                    All communications and documents are heavily encrypted.
                </div>
            </div>
        </div>
    </div>

  </div>

  <!-- NOTE MODAL -->
  <div class="modal-overlay" id="noteModal">
      <div class="modal-content">
          <div class="modal-header">
              <h3 class="modal-title"><i class="ph-duotone ph-note-pencil" style="color:var(--gold-main);"></i> Add Case Note</h3>
              <button class="modal-close" onclick="closeNoteModal()"><i class="ph ph-x"></i></button>
          </div>
          <form action="add_case_note.jsp" method="POST">
              <input type="hidden" name="client_id" value="<%= clientId %>">
              
              <div class="form-group">
                  <label class="form-label">Select Case</label>
                  <select name="case_id" class="form-control" required>
                      <option value="" disabled selected>-- Select an active case --</option>
                      <%
                          try {
                              con = getDatabaseConnection();
                              ps = con.prepareStatement("SELECT case_id, title FROM customer_cases WHERE assigned_lawyer_id = ? AND customer_id = ?");
                              ps.setInt(1, lawyerId);
                              ps.setInt(2, clientId);
                              rs = ps.executeQuery();
                              while(rs.next()) {
                      %>
                      <option value="<%= rs.getInt("case_id") %>">#<%= rs.getInt("case_id") %> - <%= com.j4u.Sanitizer.sanitize(rs.getString("title")) %></option>
                      <%      }
                              rs.close();
                              ps.close();
                              con.close();
                          } catch (Exception e) {}
                      %>
                  </select>
              </div>

              <div class="form-group">
                  <label class="form-label">Note / Remark</label>
                  <textarea name="note_text" class="form-control" placeholder="Enter private remarks or timeline note..." required></textarea>
              </div>

              <button type="submit" class="btn-submit">Save Note</button>
          </form>
      </div>
  </div>

  <script>
      function openNoteModal() {
          document.getElementById('noteModal').classList.add('active');
          document.body.style.overflow = 'hidden';
      }
      function closeNoteModal() {
          document.getElementById('noteModal').classList.remove('active');
          document.body.style.overflow = 'auto';
      }
      
      // Close on completely outside click
      document.getElementById('noteModal').addEventListener('click', function(e) {
          if (e.target === this) closeNoteModal();
      });
  </script>

</body>
</html>
