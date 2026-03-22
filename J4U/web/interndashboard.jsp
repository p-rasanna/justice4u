<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, java.util.Map, java.util.ArrayList"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Intern Dashboard | Justice4U</title>
  
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    :root {
      --bg-ivory: #FAFAF8;
      --ink-primary: #121212;
      --ink-secondary: #555555;
      --gold-main: #C6A75E;
      --glass-surface: rgba(255, 255, 255, 0.7);
      --glass-border: rgba(255, 255, 255, 0.8);
      --ease-spring: cubic-bezier(0.2, 0.8, 0.2, 1);
    }

    * { box-sizing: border-box; -webkit-font-smoothing: antialiased; }
    
    body {
      margin: 0; min-height: 100vh; font-family: 'Inter', sans-serif;
      background: #F5F5F7; color: var(--ink-primary); overflow-x: hidden;
    }

    /* Aurora Background */
    .aurora-bg {
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: 
        radial-gradient(at 0% 0%, rgba(219, 234, 254, 0.6) 0px, transparent 50%),
        radial-gradient(at 100% 0%, rgba(255, 255, 255, 0.8) 0px, transparent 50%),
        radial-gradient(at 100% 100%, rgba(198, 167, 94, 0.1) 0px, transparent 50%);
      filter: blur(60px); z-index: -1;
    }
    .orb { position: absolute; border-radius: 50%; filter: blur(80px); z-index: -1; opacity: 0.4; animation: float 15s ease-in-out infinite; }
    .orb-1 { width: 500px; height: 500px; background: rgba(37, 99, 235, 0.1); top: -10%; left: -10%; }
    .orb-2 { width: 400px; height: 400px; background: rgba(198, 167, 94, 0.15); bottom: 10%; right: 10%; animation-delay: -7s; }

    @keyframes float { 0%, 100% { transform: translateY(0) scale(1); } 50% { transform: translateY(-30px) scale(1.05); } }

    .dashboard-shell {
      max-width: 1240px; margin: 40px auto; padding: 0 24px; position: relative; z-index: 10;
    }

    /* Main Glass Card */
    .glass-panel {
      background: var(--glass-surface); backdrop-filter: saturate(180%) blur(25px); -webkit-backdrop-filter: saturate(180%) blur(25px);
      border: 1px solid var(--glass-border); border-radius: 32px; padding: 40px;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.08);
      animation: slideUp 0.8s var(--ease-spring);
    }

    @keyframes slideUp { 0% { opacity: 0; transform: translateY(30px); } 100% { opacity: 1; transform: translateY(0); } }

    /* Header Styling */
    .header-section { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-start; }
    .title-group h1 { font-family: 'Playfair Display', serif; font-size: 2.8rem; margin: 0; letter-spacing: -0.02em; font-weight: 600; }
    .title-group h1 span { color: var(--gold-main); font-style: italic; }
    .title-group p { color: var(--ink-secondary); font-size: 1rem; margin-top: 8px; }

    .user-badge {
      display: flex; align-items: center; gap: 16px; background: rgba(255,255,255,0.6); padding: 8px 20px; border-radius: 99px; border: 1px solid rgba(255,255,255,0.8);
    }
    .avatar { width: 48px; height: 48px; background: var(--gold-main); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 1.2rem; }

    /* Metric Cards */
    .metric-grid {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 40px;
    }
    .metric-card {
      background: white; padding: 24px; border-radius: 20px; border: 1px solid #F0F0F0; transition: none;
      display: flex; align-items: center; gap: 20px;
    }
    .metric-card:hover { transform: translateY(-5px); box-shadow: 0 15px 30px rgba(0,0,0,0.05); border-color: var(--gold-main); }
    .metric-icon { width: 56px; height: 56px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; }
    .icon-blue { background: rgba(37, 99, 235, 0.1); color: #2563EB; }
    .icon-gold { background: rgba(198, 167, 94, 0.1); color: var(--gold-main); }
    .icon-green { background: rgba(16, 185, 129, 0.1); color: #10B981; }
    .icon-purple { background: rgba(139, 92, 246, 0.1); color: #8B5CF6; }
    .metric-info h3 { margin: 0; font-size: 1.8rem; font-weight: 700; color: var(--ink-primary); }
    .metric-info p { margin: 0; font-size: 0.85rem; color: var(--ink-secondary); text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px; }

    /* Sections & Tables */
    .section-header { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; border-bottom: 1px solid rgba(0,0,0,0.05); padding-bottom: 12px; }
    .section-header i { font-size: 1.4rem; color: var(--gold-main); }
    .section-header h2 { font-size: 1.2rem; margin: 0; font-weight: 600; }

    .table-custom { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
    .table-custom th { padding: 12px 20px; font-size: 0.75rem; text-transform: uppercase; color: var(--ink-secondary); letter-spacing: 0.05em; font-weight: 600; }
    .table-custom tr { background: rgba(255,255,255,0.4); transition: none; }
    .table-custom td { padding: 20px; border-top: 1px solid rgba(0,0,0,0.03); border-bottom: 1px solid rgba(0,0,0,0.03); }
    .table-custom td:first-child { border-left: 1px solid rgba(0,0,0,0.03); border-top-left-radius: 16px; border-bottom-left-radius: 16px; }
    .table-custom td:last-child { border-right: 1px solid rgba(0,0,0,0.03); border-top-right-radius: 16px; border-bottom-right-radius: 16px; }
    .table-custom tr:hover { background: white; box-shadow: 0 8px 20px rgba(0,0,0,0.04); transform: scale(1.005); }

    .status-badge { padding: 6px 12px; border-radius: 99px; font-size: 0.75rem; font-weight: 600; }
    .status-active { background: #E8F5E9; color: #2E7D32; }
    .status-pending { background: #FFF3E0; color: #EF6C00; }

    .btn-action {
      background: var(--ink-primary); color: white; border: none; padding: 10px 20px; border-radius: 12px;
      font-size: 0.85rem; font-weight: 500; transition: none; text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
    }
    .btn-action:hover { background: var(--gold-main); transform: translateY(-2px); color: white; }

    /* Forms */
    .form-glass { background: rgba(255,255,255,0.5); padding: 30px; border-radius: 24px; border: 1px solid rgba(255,255,255,0.8); }
    .form-label { font-size: 0.85rem; font-weight: 600; margin-bottom: 10px; color: var(--ink-secondary); }
    .form-control, .form-select {
      background: white; border: 1px solid #EAEAEA; border-radius: 12px; padding: 12px 16px; transition: none;
    }
    .form-control:focus { border-color: var(--gold-main); box-shadow: 0 0 0 4px rgba(198, 167, 94, 0.1); }

    .nav-footer { margin-top: 50px; padding-top: 30px; border-top: 1px solid rgba(0,0,0,0.05); display: flex; justify-content: space-between; }
    
    .pill-info { background: #FEE2E2; color: #B91C1C; padding: 12px 20px; border-radius: 16px; font-size: 0.85rem; font-weight: 500; border: 1px dashed #FECACA; }

    @media (max-width: 900px) {
      .header-section { flex-direction: column; gap: 24px; }
      .glass-panel { padding: 24px; }
    }
  </style>
</head>
<body>
<%
  // STRICT ROLE CHECK
  String username = (String) session.getAttribute("iname");
  if (username == null) {
    session.invalidate();
    response.sendRedirect("internlogin.html");
    return;
  }
%>
  <div class="aurora-bg"></div>
  <div class="orb orb-1"></div>
  <div class="orb orb-2"></div>

  <div class="dashboard-shell">
    <div class="glass-panel">
      <!-- Header Section -->
      <div class="header-section">
        <div class="title-group">
          <h1>Associate <span>Workspace</span></h1>
          <p>Managed environment for legal research and case assistance.</p>
        </div>
        <div class="user-badge">
          <div class="avatar">
            <%= (username != null && !username.isEmpty()) ? username.substring(0, 1).toUpperCase() : "I" %>
          </div>
          <div>
            <div style="font-weight: 600; font-size: 0.95rem;"><%= username %></div>
            <div style="font-size: 0.75rem; color: var(--ink-secondary);">Verified Intern</div>
          </div>
        </div>
      </div>

      <!-- 1. Overview Metrics -->
<%
  @SuppressWarnings("unchecked")
  List<Map<String,Object>> assignedCasesList = (List<Map<String,Object>>) request.getAttribute("assignedCasesList");
  if(assignedCasesList == null) assignedCasesList = new ArrayList<Map<String,Object>>();
  int assignedCasesCount = assignedCasesList.size();
  @SuppressWarnings("unchecked")
  List<Map<String,Object>> pendingTasksList = (List<Map<String,Object>>) request.getAttribute("pendingTasksList");
  if(pendingTasksList == null) pendingTasksList = new ArrayList<Map<String,Object>>();
  int pendingTasksCount = pendingTasksList.size();
  int draftsUploadedCount = 0; Object duc = request.getAttribute("draftsUploadedCount"); if(duc != null) try{draftsUploadedCount = Integer.parseInt(duc.toString());}catch(Exception e){}
  int unreadMessagesCount = 0; Object umc = request.getAttribute("unreadMessagesCount"); if(umc != null) try{unreadMessagesCount = Integer.parseInt(umc.toString());}catch(Exception e){}
  boolean hasUploadCaseList = false;
  @SuppressWarnings("unchecked")
  List<Map<String,Object>> uploadCaseList = (List<Map<String,Object>>) request.getAttribute("uploadCaseList");
  if(uploadCaseList == null) uploadCaseList = new ArrayList<Map<String,Object>>();
%>
      <div class="metric-grid">
        <div class="metric-card">
          <div class="metric-icon icon-blue"><i class="ph ph-briefcase"></i></div>
          <div class="metric-info">
            <h3><%= assignedCasesCount %></h3>
            <p>Assigned Cases</p>
          </div>
        </div>
        <div class="metric-card">
          <div class="metric-icon icon-gold"><i class="ph ph-list-checks"></i></div>
          <div class="metric-info">
            <h3><%= pendingTasksCount %></h3>
            <p>Pending Tasks</p>
          </div>
        </div>
        <div class="metric-card">
          <div class="metric-icon icon-green"><i class="ph ph-file-arrow-up"></i></div>
          <div class="metric-info">
            <h3><%= draftsUploadedCount %></h3>
            <p>Drafts Shared</p>
          </div>
        </div>
        <div class="metric-card">
          <div class="metric-icon icon-purple"><i class="ph ph-chat-circle-text"></i></div>
          <div class="metric-info">
            <h3><%= unreadMessagesCount %></h3>
            <p>Lawyer Mails</p>
          </div>
        </div>
      </div>

      <!-- 2. My Assigned Cases -->
      <div class="section-header">
        <i class="ph ph-file-text"></i>
        <h2>Active Assignments</h2>
      </div>
      <div class="table-responsive">
        <table class="table-custom" style="width: 100%;">
          <thead>
            <tr>
              <th>Reference</th>
              <th>Case Profile</th>
              <th>Jurisdiction</th>
              <th>Supervising Lawyer</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
          <%
            if(!assignedCasesList.isEmpty()) {
              for(Map<String,Object> c : assignedCasesList) {
          %>
                      <tr>
                        <td style="font-family: 'Space Grotesk', sans-serif; font-weight: 700;">#J4U-<%= c.get("caseId") %></td>
                        <td><div style="font-weight: 600;"><%= c.get("title") %></div></td>
                        <td><%= c.get("courtType") %></td>
                        <td>
                          <div style="display: flex; align-items: center; gap: 8px;">
                            <i class="ph ph-user-circle" style="font-size: 1.2rem; color: var(--gold-main);"></i>
                            <%= c.get("lawyerName") %>
                          </div>
                        </td>
                        <td><span class="status-badge status-active">ACTIVE ASSIST</span></td>
                        <td>
                          <a href="viewcase_intern.jsp?cid=<%= c.get("caseId") %>" class="btn-action">
                            Review <i class="ph ph-caret-right"></i>
                          </a>
                        </td>
                      </tr>
          <% } } else { %>
                  <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: var(--ink-secondary);">
                      <i class="ph ph-folder-open" style="font-size: 3rem; opacity: 0.2; display: block; margin-bottom: 10px;"></i>
                      No active cases assigned to your profile yet.
                    </td>
                  </tr>
          <% } %>
          </tbody>
        </table>
      </div>

      <!-- 3. Tasks & Upload Work -->
      <div class="row g-4 mt-4">
        <div class="col-lg-6">
          <div class="section-header">
            <i class="ph ph-clipboard-text"></i>
            <h2>Pending Directives</h2>
          </div>
          <div class="table-responsive">
            <table class="table-custom" style="width: 100%;">
              <thead>
                <tr>
                  <th>Task Directive</th>
                  <th>Deadline</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
              <%
                if(!pendingTasksList.isEmpty()) {
                  for(Map<String,Object> task : pendingTasksList) {
                    String st = task.get("status") != null ? task.get("status").toString() : "PENDING";
              %>
                          <tr>
                            <td><div style="font-weight: 500;"><%= task.get("title") %></div></td>
                            <td><%= task.get("dueDate") %></td>
                            <td>
                              <span class="status-badge status-pending"><%= st %></span>
                            </td>
                          </tr>
              <% } } else { %>
                      <tr>
                        <td colspan="3" style="text-align: center; padding: 20px; color: var(--ink-secondary);">No active tasks from supervisor.</td>
                      </tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="section-header">
            <i class="ph ph-upload-simple"></i>
            <h2>Submit Research/Drafts</h2>
          </div>
          <div class="form-glass">
            <form method="post" action="uploadInternWork.jsp" enctype="multipart/form-data">
              <div class="mb-3">
                <label class="form-label" for="caseIdSelect">Target Case</label>
                <select id="caseIdSelect" name="caseId" class="form-select" required>
                  <option value="">Select an assigned case...</option>
                  <% for(Map<String,Object> uc : uploadCaseList) { %>
                      <option value="<%= uc.get("caseId") %>">#<%= uc.get("caseId") %> - <%= uc.get("title") %></option>
                  <% } %>
                </select>
              </div>
              <div class="mb-4">
                <label class="form-label" for="draftFileInput">Upload Document (PDF/DOCX)</label>
                <input type="file" id="draftFileInput" name="draftFile" class="form-control" required>
              </div>
              <button type="submit" class="btn-action" style="width: 100%; justify-content: center;">
                <i class="ph ph-paper-plane-tilt"></i> Dispatch to Lawyer
              </button>
            </form>
          </div>
        </div>
      </div>

      <!-- 4. Ethics & Restrictions -->
      <div class="row g-4 mt-4">
        <div class="col-md-6">
          <div class="section-header">
            <i class="ph ph-chats-circle"></i>
            <h2>Encrypted Communication</h2>
          </div>
          <p style="font-size: 0.9rem; color: var(--ink-secondary);">
            Communications are recorded for compliance. Direct interaction with clients is strictly prohibited.
          </p>
          <div class="btn-action" style="background: rgba(198, 167, 94, 0.1); color: var(--gold-main); border: 1px solid var(--gold-main);">
            <i class="ph ph-chat-teardrop-dots"></i> Channel Active
          </div>
        </div>
        <div class="col-md-6">
          <div class="section-header">
            <i class="ph ph-warning-octagon"></i>
            <h2>Protocol Compliance</h2>
          </div>
          <div class="pill-info">
            <i class="ph ph-lock-keyhole"></i> Restricted Access: You cannot modify case status or talk to clients.
          </div>
        </div>
      </div>

      <!-- Footer Navigation -->
      <div class="nav-footer">
        <div>
          <a href="viewlawyeri.jsp" class="btn-action" style="background: rgba(37, 99, 235, 0.05); color: #2563EB;">
            <i class="ph ph-users-three"></i> Global Directory
          </a>
        </div>
        <a href="isignout.jsp" class="btn-action" style="background: #FEE2E2; color: #DC2626;">
          <i class="ph ph-power"></i> Terminate Session
        </a>
      </div>
    </div> <!-- End glass-panel -->
  </div> <!-- End dashboard-shell -->

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

