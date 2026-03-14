<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%
  String lnameSession = (String) session.getAttribute("lname");
  if (lnameSession == null) {
      session.invalidate();
      response.sendRedirect("Lawyer_login.html");
      return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Justice4U · Intern Directory</title>
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
          
          --gold-main: #C6A75E;
          --gold-dim: #9C824A;
          --alert-amber: #D97706;
          --success-green: #059669;
          --danger-red: #DC2626;
          
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

      /* ============================
         2. LAYOUT & STRUCTURE
         ============================ */
      .dashboard-shell {
          max-width: 1400px;
          margin: 0 auto;
          padding: 40px 32px;
      }

      .smart-enter {
          opacity: 0; transform: translateY(15px);
          /* animation removed */
      }
      .d-1 { animation-delay: 0.1s; }
      .d-2 { animation-delay: 0.2s; }
      .d-3 { animation-delay: 0.3s; }

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
         4. DATA PANEL
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
      
      .panel-head-left {
          display: flex; align-items: center; gap: 16px;
      }

      .panel-head h3 { 
          font-family: 'Inter', sans-serif; 
          font-size: 1.1rem; margin: 0; font-weight: 600; color: var(--ink-primary); 
          display: flex; align-items: center; gap: 8px;
      }
      .panel-icon { color: var(--gold-main); font-size: 1.4rem; }

      /* ============================
         5. INTELLIGENT TABLE
         ============================ */
      .table-responsive { max-height: 600px; overflow: auto; }
      
      .table { margin-bottom: 0; width: 100%; border-collapse: collapse; }
      
      .table thead th {
          background: #FAFAFA; color: var(--ink-secondary);
          font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
          padding: 16px 20px; border-bottom: 1px solid var(--border-subtle);
          position: sticky; top: 0; z-index: 10;
      }

      .table tbody tr { transition: background 0.2s; border-bottom: 1px solid #f5f5f5; }
      .table tbody tr:hover { background: #FCFCFA; }

      .table tbody td {
          padding: 16px 20px; font-size: 0.85rem; color: var(--ink-primary); vertical-align: middle;
      }

      .col-main { font-weight: 600; font-size: 0.95rem; display: flex; align-items: center; gap: 12px; }
      .col-sub { color: var(--ink-secondary); font-size: 0.8rem; margin-top: 4px; }
      
      .avatar-circle {
          width: 36px; height: 36px; background: rgba(198, 167, 94, 0.1);
          color: var(--gold-main); border-radius: 50%;
          display: flex; align-items: center; justify-content: center;
          font-weight: 700; font-size: 0.9rem; font-family: 'Playfair Display', serif;
      }

      /* Tags */
      .status-active {
          display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px;
          background: rgba(5, 150, 105, 0.1); color: var(--success-green);
          border-radius: 100px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase;
      }
      .status-dot { width: 6px; height: 6px; background: var(--success-green); border-radius: 50%; }

      /* Actions */
      .action-flex { display: flex; gap: 8px; align-items: center; }
      
      .btn-action {
          display: inline-flex; align-items: center; justify-content: center; gap: 6px;
          padding: 8px 14px; border-radius: 8px;
          font-size: 0.8rem; font-weight: 600; text-decoration: none; border: none;
          transition: all 0.2s; background: #fff; border: 1px solid var(--border-subtle); cursor: pointer; color: var(--ink-primary);
      }
      .btn-action-primary { border-color: rgba(198, 167, 94, 0.5); color: var(--gold-dim); }
      
      .btn-action:hover { border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-1px); }
      .btn-action-primary:hover { background: var(--gold-main); color: #fff; border-color: var(--gold-main); }

      /* ============================
         6. NAVIGATION FOOTER
         ============================ */
      .footer-nav {
          display: flex; justify-content: flex-end; gap: 16px; margin-top: 24px;
      }
      .btn-nav {
          display: inline-flex; align-items: center; gap: 8px;
          padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: 0.85rem;
          text-decoration: none; transition: all 0.2s; background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary);
      }
      .btn-nav:hover { border-color: var(--gold-main); color: var(--gold-main); }

      .empty-state { text-align: center; padding: 48px; color: var(--ink-tertiary); font-style: italic; }

  </style>
</head>
<body>
  <div class="dashboard-shell">

    <header class="admin-header smart-enter d-1">
        <div class="header-content">
            <h1>Intern Directory</h1>
            <div class="header-meta">
                <span class="meta-item"><i class="ph ph-lock-key" style="color:var(--success-green);"></i> Secure Counsel Session</span>
                <span class="meta-item"><i class="ph ph-graduation-cap"></i> Student Allocation System</span>
            </div>
        </div>
        <div class="admin-profile">
            <span class="profile-dot"></span>
            <span class="profile-role">Verified Counsel</span>
        </div>
    </header>

    <div class="panel smart-enter d-2">
        <div class="panel-head">
            <div class="panel-head-left">
                <h3><i class="ph ph-users-three panel-icon"></i> Associate Directory</h3>
            </div>
            <span class="tag-info">Managed Talent</span>
        </div>

        <div class="table-responsive">
            <table class="table">
              <thead>
                <tr>
                  <th>Associate Profile</th>
                  <th>Department / Focus</th>
                  <th>Engagement Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
              <%
                try {
                  Connection con = getDatabaseConnection();
                  
                  // Get lawyer ID
                  int lawyerId = 0;
                  PreparedStatement psL = con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?");
                  psL.setString(1, lnameSession);
                  ResultSet rsL = psL.executeQuery();
                  if(rsL.next()) lawyerId = rsL.getInt("lid");
                  rsL.close(); psL.close();

                  // Get list of intern emails already assigned to this lawyer
                  java.util.Set<String> myTeamEmails = new java.util.HashSet<>();
                  PreparedStatement psTeam = con.prepareStatement("SELECT DISTINCT intern_email FROM intern_assignments WHERE alid=? AND status='ACTIVE'");
                  psTeam.setInt(1, lawyerId);
                  ResultSet rsTeam = psTeam.executeQuery();
                  while(rsTeam.next()) myTeamEmails.add(rsTeam.getString("intern_email"));
                  rsTeam.close(); psTeam.close();

                  // Fetch only approved interns
                  PreparedStatement ps = con.prepareStatement("SELECT * FROM intern WHERE flag=1 ORDER BY name ASC");
                  ResultSet rs = ps.executeQuery();
                  
                  boolean hasInterns = false;
                  while(rs.next()) {
                    hasInterns = true;
                    int internId = rs.getInt("internid"); 
                    String name = rs.getString("name");
                    String email = rs.getString("email");
                    String mobile = rs.getString("mobno");
                    String cadd = rs.getString("cadd");
                    boolean isMyTeam = myTeamEmails.contains(email);
              %>
                <tr style="<%= isMyTeam ? "background: rgba(198, 167, 94, 0.03);" : "" %>">
                  <td>
                    <div class="col-main">
                        <div class="avatar-circle" style="<%= isMyTeam ? "background: var(--gold-main); color: #fff;" : "" %>">
                            <%= name != null && !name.isEmpty() ? name.charAt(0) : 'A' %>
                        </div>
                        <div>
                            <%= com.j4u.Sanitizer.sanitize(name) %>
                            <% if(isMyTeam) { %>
                                <span style="font-size:0.65rem; background:var(--gold-main); color:#fff; padding:2px 6px; border-radius:4px; margin-left:8px; vertical-align:middle;">MY TEAM</span>
                            <% } %>
                            <div class="col-sub"><%= email %></div>
                        </div>
                    </div>
                  </td>
                  <td>
                    <div style="font-weight:500;"><i class="ph ph-mortar-board" style="color:var(--gold-dim)"></i> Legal Research</div>
                    <div class="col-sub"><i class="ph ph-map-pin"></i> <%= com.j4u.Sanitizer.sanitize(cadd) %></div>
                  </td>
                  <td>
                    <% if(isMyTeam) { %>
                        <div class="status-active" style="background: rgba(198, 167, 94, 0.1); color: var(--gold-dim);">
                            <span class="status-dot" style="background: var(--gold-main);"></span> Collaborating
                        </div>
                    <% } else { %>
                        <div class="status-active"><span class="status-dot"></span> Available</div>
                    <% } %>
                  </td>
                  <td>
                    <div class="action-flex">
                        <a href="assign_intern_case.jsp?intern_email=<%= email %>&intern_name=<%= name %>" class="btn-action <%= isMyTeam ? "" : "btn-action-primary" %>">
                            <i class="ph ph-briefcase"></i> <%= isMyTeam ? "Assign Another" : "Deploy to Case" %>
                        </a>
                        <% if(isMyTeam) { %>
                            <a href="assign_task.jsp?intern_id=<%= internId %>" class="btn-action btn-action-primary">
                                <i class="ph ph-clipboard-text"></i> Delegate Task
                            </a>
                        <% } %>
                    </div>
                  </td>
                </tr>
              <%
                  }
                  if(!hasInterns) {
              %>
                <tr>
                  <td colspan="4">
                    <div class="empty-state">
                        <i class="ph-duotone ph-graduation-cap" style="font-size:3rem; margin-bottom:12px; color:var(--ink-tertiary);"></i><br>
                        The associate talent pool is currently empty.
                    </div>
                  </td>
                </tr>
              <%
                  }
                  rs.close(); ps.close(); con.close();
                } catch(Exception e) {
              %>
                <tr><td colspan="4" style="color:red; text-align:center; padding:20px;">Database Error: <%= e.getMessage() %></td></tr>
              <%
                }
              %>
              </tbody>
            </table>
        </div>
    </div>

    <div class="footer-nav smart-enter d-3">
        <a href="Lawyerdashboard.jsp" class="btn-nav">
            <i class="ph ph-arrow-left"></i> Counsel Workspace
        </a>
    </div>

  </div>
</body>
</html>
