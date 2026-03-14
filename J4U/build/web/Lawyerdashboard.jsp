<%@page contentType="text/html" pageEncoding="UTF-8"
    import="java.util.List, java.util.Map, java.util.ArrayList"%>
<%
  // STRICT ROLE CHECK
  String username = (String) session.getAttribute("lname");
  if (username == null) {
      session.invalidate();
      response.sendRedirect("Lawyer_login.html");
      return;
  }
%>
<%
  // UI HELPER: Time-of-day logic (Purely cosmetic, does not touch backend/DB)
  java.time.LocalTime now = java.time.LocalTime.now();
  String timeGreeting;
  int hour = now.getHour();
  if (hour < 12) { timeGreeting = "Good Morning"; }
  else if (hour < 17) { timeGreeting = "Good Afternoon"; }
  else { timeGreeting = "Good Evening"; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Justice4U · Counsel Workspace</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

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
          
          /* Authority Colors */
          --gold-main: #C6A75E;
          --gold-dim: #9C824A;
          --alert-amber: #D97706;
          --success-green: #059669;
          --danger-red: #DC2626;
          
          /* Surfaces */
          --surface-card: #FFFFFF;
          --surface-hover: #FDFDFD;
          --border-subtle: #E6E6E6;
          --border-focus: #121212;
          
          /* 10/10 Physics */
          --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
          --shadow-hover: 0 15px 40px -10px rgba(198, 167, 94, 0.15);
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

      /* ============================
         2. LAYOUT & STRUCTURE
         ============================ */
      .dashboard-shell {
          max-width: 1400px;
          margin: 0 auto;
          padding: 40px 32px;
      }

      /* Entrance Stagger */
      .smart-enter {
          opacity: 0; transform: translateY(15px);
          animation: enterUp 0.6s var(--ease-smart) forwards;
      }
      .d-1 { animation-delay: 0.1s; }
      .d-2 { animation-delay: 0.2s; }
      .d-3 { animation-delay: 0.3s; }
      .d-4 { animation-delay: 0.4s; }

      @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

      /* ============================
         3. INTELLIGENT HEADER
         ============================ */
      .admin-header {
          display: flex; justify-content: space-between; align-items: flex-end;
          margin-bottom: 48px; border-bottom: 1px solid var(--border-subtle); padding-bottom: 24px;
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
      .secure-lock { color: var(--success-green); }

      .admin-profile {
          display: flex; align-items: center; gap: 12px;
          padding: 8px 16px; background: #fff; border: 1px solid var(--border-subtle);
          border-radius: 100px; box-shadow: var(--shadow-card);
      }
      .profile-role { 
          font-family: 'Inter', sans-serif;
          font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600; color: var(--gold-main); 
      }
      .profile-dot { width: 8px; height: 8px; background: var(--success-green); border-radius: 50%; box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.1); }

      /* ============================
         4. GRID SYSTEM
         ============================ */
      .grid-layout {
          display: grid;
          grid-template-columns: 2fr 1fr;
          gap: 32px;
      }
      
      @media (max-width: 900px) {
          .grid-layout { grid-template-columns: 1fr; }
      }

      /* ============================
         5. DATA PANELS
         ============================ */
      .panel {
          background: var(--surface-card);
          border: 1px solid var(--border-subtle);
          border-radius: 16px; overflow: hidden;
          box-shadow: var(--shadow-card);
          display: flex; flex-direction: column;
          margin-bottom: 32px;
      }

      .panel-head {
          padding: 24px; border-bottom: 1px solid var(--border-subtle);
          display: flex; justify-content: space-between; align-items: center;
          background: #FAFAFA;
      }
      .panel-head h3 { 
          font-family: 'Inter', sans-serif; 
          font-size: 1.1rem; margin: 0; font-weight: 600; color: var(--ink-primary); 
          display: flex; align-items: center; gap: 8px;
      }
      .panel-icon { color: var(--gold-main); font-size: 1.4rem; }

      .tag-info {
          font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
          color: var(--ink-secondary); background: #f5f5f5; padding: 4px 10px; border-radius: 100px;
      }

      .panel-body { padding: 24px; }

      /* Action List */
      .action-list {
          display: flex; flex-direction: column; gap: 12px;
      }
      .action-item {
          display: flex; justify-content: space-between; align-items: center;
          padding: 16px; border-radius: 12px;
          border: 1px solid var(--border-subtle);
          background: #fff; text-decoration: none; color: var(--ink-primary);
          transition: all 0.2s;
      }
      .action-item:hover {
          border-color: var(--gold-main); background: #FCFCFA; transform: translateY(-2px);
          box-shadow: var(--shadow-hover);
      }
      .action-item-info { display: flex; align-items: center; gap: 16px; }
      .action-item-icon {
          width: 40px; height: 40px; border-radius: 8px; background: rgba(198, 167, 94, 0.1);
          color: var(--gold-main); display: flex; align-items: center; justify-content: center; font-size: 1.2rem;
      }
      .action-item-text h4 { margin: 0 0 4px 0; font-size: 0.95rem; font-weight: 600; }
      .action-item-text p { margin: 0; font-size: 0.8rem; color: var(--ink-secondary); }
      .action-item-arrow { color: var(--ink-tertiary); transition: color 0.2s; margin-left: 12px; }
      .action-item:hover .action-item-arrow { color: var(--gold-main); }

      /* Stats Row */
      .stats-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 32px; }
      .stat-card {
          padding: 20px; border-radius: 12px; background: var(--surface-card);
          border: 1px solid var(--border-subtle); display: flex; flex-direction: column; gap: 12px;
      }
      .stat-val { font-family: 'Playfair Display', serif; font-size: 2rem; font-weight: 600; color: var(--ink-primary); }
      .stat-label { font-size: 0.8rem; font-weight: 600; color: var(--ink-secondary); text-transform: uppercase; letter-spacing: 0.05em; }
      
      /* Urgent Request Card */
      .urgent-request-card {
          padding: 20px; border-radius: 12px;
          background: #FFFBEB; border: 1px solid #FEF3C7; border-left: 4px solid var(--alert-amber);
          margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;
      }
      .urgent-info h4 { margin: 0 0 4px 0; color: #92400E; font-size: 1rem; font-weight: 600; display: flex; align-items: center; gap: 8px;}
      .urgent-info p { margin: 0; color: #B45309; font-size: 0.85rem; }
      .urgent-actions { display: flex; gap: 8px; }
      
      /* Standard Button */
      .btn-custom {
          padding: 8px 16px; border-radius: 8px; font-weight: 600; font-size: 0.85rem;
          text-decoration: none; border: 1px solid transparent; transition: all 0.2s; cursor: pointer;
          display: inline-flex; align-items: center; gap: 6px;
      }
      .btn-accept { background: #fff; border-color: rgba(5, 150, 105, 0.4); color: var(--success-green); }
      .btn-accept:hover { background: var(--success-green); color: #fff; border-color: var(--success-green); }
      .btn-decline { background: #fff; border-color: rgba(220, 38, 38, 0.4); color: var(--danger-red); }
      .btn-decline:hover { background: var(--danger-red); color: #fff; border-color: var(--danger-red); }

      /* ============================
         6. NAVIGATION FOOTER
         ============================ */
      .footer-nav {
          display: flex; justify-content: space-between; margin-top: 24px; align-items: center;
          padding-top: 24px; border-top: 1px solid var(--border-subtle);
      }
      
      .btn-nav-danger {
          display: inline-flex; align-items: center; gap: 8px;
          padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: 0.85rem;
          background: #FEF2F2; color: var(--danger-red); text-decoration: none; transition: all 0.2s;
          border: 1px solid rgba(220,38,38,0.2);
      }
      .btn-nav-danger:hover { background: var(--danger-red); color: #fff; }

      .empty-state { text-align: center; padding: 32px 0; color: var(--ink-tertiary); font-size: 0.9rem; font-style: italic; }

  </style>
</head>
<body>

  <div class="dashboard-shell">

    <header class="admin-header smart-enter d-1">
        <div class="header-content">
            <h1><%= timeGreeting %>, <%= username %></h1>
            <div class="header-meta">
                <span class="meta-item"><i class="ph ph-lock-key secure-lock"></i> Secure Counsel Session</span>
                <span class="meta-item"><i class="ph ph-calendar-check"></i> Connected & Syncing</span>
            </div>
        </div>
        <div class="admin-profile">
            <span class="profile-dot"></span>
            <span class="profile-role">Verified Counsel</span>
        </div>
    </header>

<%-- Replaced by LawyerDashboardServlet for MVC strictness --%>

    <div class="stats-row smart-enter d-2">
      <%
        Integer activeMatters = (Integer) request.getAttribute("activeMattersCount");
        Integer pendingReplies = (Integer) request.getAttribute("pendingRepliesCount");
        Integer hearingsToday = (Integer) request.getAttribute("hearingsTodayCount");
        if (activeMatters == null) activeMatters = 0;
        if (pendingReplies == null) pendingReplies = 0;
        if (hearingsToday == null) hearingsToday = 0;
      %>
      <div class="stat-card">
        <div class="stat-label">Active Matters</div>
        <div class="stat-val"><%= activeMatters %></div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Pending Replies</div>
        <div class="stat-val"><%= pendingReplies %></div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Hearings Today</div>
        <div class="stat-val"><%= hearingsToday %></div>
      </div>
    </div>

    <div class="grid-layout">
        
        <!-- Main Content Area -->
        <div class="main-column">
            
            <%-- PENDING REQUESTS SECTION --%>
            <div class="panel smart-enter d-3" style="border-color: rgba(217, 119, 6, 0.3);">
                <div class="panel-head" style="background:#FFFBF2;">
                    <h3><i class="ph ph-hourglass-high panel-icon" style="color:var(--alert-amber);"></i> Pending Validations</h3>
                    <span class="tag-info" style="color:#D97706; background:rgba(217, 119, 6, 0.1);">Expiring in 48h</span>
                </div>
                <div class="panel-body">
                <%
                  @SuppressWarnings("unchecked")
                  List<Map<String,Object>> pendingRequests = (List<Map<String,Object>>) request.getAttribute("pendingRequests");
                  if (pendingRequests == null) pendingRequests = new ArrayList<Map<String,Object>>();
                  if (!pendingRequests.isEmpty()) {
                    for (Map<String,Object> req : pendingRequests) {
                %>
                            <div class="urgent-request-card">
                                <div class="urgent-info">
                                    <h4><i class="ph-fill ph-warning-circle"></i> <%= req.get("clientName") %></h4>
                                    <p><%= req.get("title") %></p>
                                </div>
                                <div class="urgent-actions">
                                    <button onclick="handleCaseAction('<%= req.get("caseId") %>', 'accept', this)" class="btn-custom btn-accept"><i class="ph ph-check"></i> Accept</button>
                                    <button onclick="handleCaseAction('<%= req.get("caseId") %>', 'reject', this)" class="btn-custom btn-decline"><i class="ph ph-x"></i> Decline</button>
                                </div>
                            </div>
                <%  } } else { %>
                        <div class="empty-state">No pending case requests at this time.</div>
                <%  } %>
                </div>
            </div>

            <div class="panel smart-enter d-4">
                <div class="panel-head">
                    <h3><i class="ph ph-briefcase panel-icon"></i> Practice Operations</h3>
                    <span class="tag-info">Quick Actions</span>
                </div>
                <div class="panel-body">
                    <div class="action-list">
                      <a href="viewcustdetails.jsp" class="action-item">
                          <div class="action-item-info">
                              <div class="action-item-icon"><i class="ph ph-user-list"></i></div>
                              <div class="action-item-text">
                                  <h4>Client Roster</h4>
                                  <p>View active cases and client details.</p>
                              </div>
                          </div>
                          <i class="ph-bold ph-arrow-right action-item-arrow"></i>
                      </a>
                      <a href="disf.jsp" class="action-item">
                          <div class="action-item-info">
                              <div class="action-item-icon"><i class="ph ph-chat-circle-dots"></i></div>
                              <div class="action-item-text">
                                  <h4>Consultation Hub</h4>
                                  <p>Respond to new client inquiries.</p>
                              </div>
                          </div>
                          <i class="ph-bold ph-arrow-right action-item-arrow"></i>
                      </a>
                      <a href="viewdisl.jsp" class="action-item">
                          <div class="action-item-info">
                              <div class="action-item-icon"><i class="ph ph-archive-box"></i></div>
                              <div class="action-item-text">
                                  <h4>Case Archives</h4>
                                  <p>Access historical discussion logs.</p>
                              </div>
                          </div>
                          <i class="ph-bold ph-arrow-right action-item-arrow"></i>
                      </a>
                      <a href="viewinternl.jsp" class="action-item">
                          <div class="action-item-info">
                              <div class="action-item-icon"><i class="ph ph-graduation-cap"></i></div>
                              <div class="action-item-text">
                                  <h4>Manage Interns</h4>
                                  <p>Assign tasks and review performance.</p>
                              </div>
                          </div>
                          <i class="ph-bold ph-arrow-right action-item-arrow"></i>
                      </a>
                    </div>
                </div>
            </div>

        </div>

        <!-- Sidebar Area -->
        <div class="side-column">
            <div class="panel smart-enter d-3">
                <div class="panel-head">
                    <h3><i class="ph ph-users panel-icon"></i> Assigned Clients</h3>
                </div>
                <div class="panel-body" style="padding: 16px;">
                    <div class="action-list">
                    <%
                      @SuppressWarnings("unchecked")
                      List<Map<String,Object>> assignedClients = (List<Map<String,Object>>) request.getAttribute("assignedClients");
                      if (assignedClients == null) assignedClients = new ArrayList<Map<String,Object>>();
                      if (!assignedClients.isEmpty()) {
                        for (Map<String,Object> client : assignedClients) {
                    %>
                                <a href="viewcusdet.jsp?client_id=<%= client.get("clientId") %>" class="action-item" style="padding: 12px;">
                                  <div class="action-item-info">
                                      <div class="action-item-icon" style="width:32px; height:32px; font-size:1rem;"><i class="ph ph-user"></i></div>
                                      <div class="action-item-text">
                                          <h4 style="font-size:0.85rem;"><%= client.get("clientName") %></h4>
                                          <p style="font-size:0.75rem;"><%= client.get("title") %></p>
                                      </div>
                                  </div>
                                </a>
                    <%  } } else { %>
                            <div class="empty-state">No recently assigned clients.</div>
                    <%  } %>
                    </div>
                </div>
            </div>

            <%-- ASSOCIATE WORKSPACE WIDGET --%>
            <div class="panel smart-enter d-4">
                <div class="panel-head">
                    <h3><i class="ph ph-graduation-cap panel-icon"></i> Associate Workspace</h3>
                    <a href="viewinternl.jsp" class="tag-info" style="text-decoration:none;">Manage <i class="ph ph-arrow-right"></i></a>
                </div>
                <div class="panel-body" style="padding: 16px;">
                    <h5 style="font-size: 0.75rem; text-transform: uppercase; color: var(--ink-tertiary); margin-bottom: 12px; font-weight: 700;">Active Team</h5>
                    <div class="action-list">
                    <%
                      @SuppressWarnings("unchecked")
                      List<Map<String,Object>> assignedInterns = (List<Map<String,Object>>) request.getAttribute("assignedInterns");
                      if (assignedInterns == null) assignedInterns = new ArrayList<Map<String,Object>>();
                      if (!assignedInterns.isEmpty()) {
                        for (Map<String,Object> intern : assignedInterns) {
                    %>
                            <div class="action-item" style="padding: 10px; border-style: dashed;">
                                <div class="action-item-info">
                                    <div class="action-item-icon" style="width:28px; height:28px; font-size:0.9rem; background:rgba(5, 150, 105, 0.1); color:var(--success-green);"><i class="ph ph-student"></i></div>
                                    <div class="action-item-text">
                                        <h4 style="font-size:0.8rem; margin:0;"><%= intern.get("name") %></h4>
                                    </div>
                                </div>
                                <span class="status-dot" style="background:var(--success-green); width:6px; height:6px;"></span>
                            </div>
                    <%  } } else { %>
                            <div class="empty-state" style="padding: 12px; font-size: 0.75rem;">No associates currently assigned.</div>
                    <%  } %>
                    </div>

                    <h5 style="font-size: 0.75rem; text-transform: uppercase; color: var(--ink-tertiary); margin: 20px 0 12px 0; font-weight: 700;">Pending Deliverables</h5>
                    <div class="action-list">
                    <%
                      @SuppressWarnings("unchecked")
                      List<Map<String,Object>> pendingInternWork = (List<Map<String,Object>>) request.getAttribute("pendingInternWork");
                      if (pendingInternWork == null) pendingInternWork = new ArrayList<Map<String,Object>>();
                      if (!pendingInternWork.isEmpty()) {
                        for (Map<String,Object> work : pendingInternWork) {
                    %>
                            <a href="download_case_doc.jsp?file=<%= work.get("fileName") %>" class="action-item" style="padding: 10px;">
                                <div class="action-item-info">
                                    <div class="action-item-icon" style="width:28px; height:28px; font-size:0.9rem; background:rgba(198, 167, 94, 0.1); color:var(--gold-main);"><i class="ph ph-file-text"></i></div>
                                    <div class="action-item-text">
                                        <h4 style="font-size:0.8rem; margin:0;"><%= work.get("fileName") %></h4>
                                        <p style="font-size:0.7rem;"><%= work.get("internName") %> · <%= work.get("caseTitle") %></p>
                                    </div>
                                </div>
                            </a>
                    <%  } } else { %>
                            <div class="empty-state" style="padding: 12px; font-size: 0.75rem;">No new documents pending review.</div>
                    <%  } %>
                    </div>
                </div>
            </div>
            
        </div>

    </div>

    <div class="footer-nav smart-enter d-4">
        <span style="font-size:0.8rem; color:var(--ink-tertiary);">Justice4U Legal Entity Management System</span>
        <a href="lsignout.jsp" class="btn-nav-danger">
            <i class="ph ph-sign-out"></i> Secure Sign Out
        </a>
    </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <%
      String msg = request.getParameter("msg");
      if (msg != null && !msg.trim().isEmpty()) {
          boolean isError = msg.toLowerCase().contains("error") || msg.toLowerCase().contains("invalid") || msg.toLowerCase().contains("fail");
  %>
      <div id="action-toast" class="toast-popup smart-enter">
          <% if(isError) { %>
              <i class="ph-fill ph-warning-circle" style="color: var(--danger-red); font-size: 1.4rem;"></i>
          <% } else { %>
              <i class="ph-fill ph-check-circle" style="color: var(--success-green); font-size: 1.4rem;"></i>
          <% } %>
          <span><%= com.j4u.Sanitizer.sanitize(msg) %></span>
      </div>
      <style>
          .toast-popup {
              position: fixed;
              bottom: 32px;
              right: 32px;
              background: #fff;
              border: 1px solid var(--border-subtle);
              border-left: 4px solid <%= isError ? "var(--danger-red)" : "var(--success-green)" %>;
              padding: 16px 24px;
              border-radius: 12px;
              box-shadow: 0 15px 35px rgba(0,0,0,0.1);
              display: flex;
              align-items: center;
              gap: 12px;
              z-index: 9999;
              font-family: 'Inter', sans-serif;
              font-weight: 600;
              font-size: 0.95rem;
              color: var(--ink-primary);
              transition: all 0.4s cubic-bezier(0.2, 0.8, 0.2, 1);
          }
      </style>
      <script>
          // Toast Auto-Dismiss for page-load messages
          document.addEventListener("DOMContentLoaded", function() {
              const toast = document.getElementById('action-toast');
              if (toast) {
                  // Remove URL parameter silently
                  if (window.history.replaceState) {
                      const url = new URL(window.location);
                      url.searchParams.delete('msg');
                      window.history.replaceState({path:url.href}, '', url.href);
                  }
                  
                  // Auto dismiss after 4 seconds
                  setTimeout(() => {
                      toast.style.opacity = '0';
                      toast.style.transform = 'translateY(20px)';
                      setTimeout(() => toast.remove(), 400);
                  }, 4000);
              }
          });

          // AJAX Case Approval/Rejection
          function handleCaseAction(caseId, action, btnElement) {
              const url = action === 'accept' ? 'acceptcase.jsp?case_id=' + caseId : 'rejectcase.jsp?case_id=' + caseId;
              const card = btnElement.closest('.urgent-request-card');
              const buttons = card.querySelectorAll('button');
              
              // Disable buttons to prevent double click
              buttons.forEach(b => { b.disabled = true; b.style.opacity = '0.7'; });
              btnElement.innerHTML = '<i class="ph ph-spinner ph-spin"></i> Processing...';
              
              fetch(url)
              .then(response => {
                  if(response.ok) {
                      showDynamicToast(action === 'accept' ? 'Case Accepted Successfully' : 'Case Declined', action === 'accept');
                      
                      // Animate removal of the card
                      card.style.transition = 'all 0.4s cubic-bezier(0.2, 0.8, 0.2, 1)';
                      card.style.opacity = '0';
                      card.style.transform = 'translateY(-10px)';
                      setTimeout(() => {
                          card.remove();
                          // Reload page after a delay to refresh lists
                          setTimeout(() => window.location.reload(), 1500);
                      }, 400);
                  } else {
                      showDynamicToast('Action failed. Please try again.', false);
                      buttons.forEach(b => { b.disabled = false; b.style.opacity = '1'; });
                      btnElement.innerHTML = action === 'accept' ? '<i class="ph ph-check"></i> Accept' : '<i class="ph ph-x"></i> Decline';
                  }
              })
              .catch(err => {
                  showDynamicToast('Network error.', false);
                  buttons.forEach(b => { b.disabled = false; b.style.opacity = '1'; });
                  btnElement.innerHTML = action === 'accept' ? '<i class="ph ph-check"></i> Accept' : '<i class="ph ph-x"></i> Decline';
              });
          }

          function showDynamicToast(message, isSuccess) {
              // Remove existing toast if any
              const existingToast = document.getElementById('dynamic-toast');
              if(existingToast) existingToast.remove();

              const toast = document.createElement('div');
              toast.id = 'dynamic-toast';
              toast.className = 'toast-popup smart-enter';
              
              const iconColor = isSuccess ? 'var(--success-green)' : 'var(--danger-red)';
              const iconClass = isSuccess ? 'ph-check-circle' : 'ph-warning-circle';
              const borderColor = isSuccess ? 'var(--success-green)' : 'var(--danger-red)';
              
              toast.style.borderLeft = `4px solid ${borderColor}`;
              
              toast.innerHTML = `
                  <i class="ph-fill ${iconClass}" style="color: ${iconColor}; font-size: 1.4rem;"></i>
                  <span>${message}</span>
              `;
              
              document.body.appendChild(toast);
              
              setTimeout(() => {
                  toast.style.opacity = '0';
                  toast.style.transform = 'translateY(20px)';
                  setTimeout(() => toast.remove(), 400);
              }, 4000);
          }
      </script>
  <% } %>

</body>
</html>