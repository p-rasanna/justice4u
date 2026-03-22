<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
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
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Justice4U · Case Archives</title>

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
          /* animation removed */
      }
      .d-1 { animation-delay: 0s; }
      .d-2 { animation-delay: 0s; }
      .d-3 { animation-delay: 0s; }

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
         4. DATA MANAGEMENT PANEL
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

      .tag-info {
          font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
          color: var(--ink-secondary); background: #f5f5f5; padding: 4px 10px; border-radius: 100px;
      }

      /* Search Bar */
      .search-bar {
          display: flex; align-items: center; gap: 12px;
          background: #FFF; border: 1px solid var(--border-subtle);
          padding: 8px 16px; border-radius: 100px; width: 300px;
          transition: none;
      }
      .search-bar:focus-within { border-color: var(--gold-main); box-shadow: 0 0 0 3px rgba(198, 167, 94, 0.1); }
      .search-input { border: none; outline: none; width: 100%; font-family: 'Inter', sans-serif; font-size: 0.85rem; color: var(--ink-primary); }

      /* ============================
         5. INTELLIGENT TABLE
         ============================ */
      .table-responsive {
          max-height: 600px; overflow: auto;
      }
      
      .table {
          margin-bottom: 0;
          width: 100%; border-collapse: collapse;
      }
      
      .table thead th {
          background: #FAFAFA;
          color: var(--ink-secondary);
          font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
          padding: 16px 20px;
          border-bottom: 1px solid var(--border-subtle);
          position: sticky; top: 0; z-index: 10;
          white-space: nowrap;
      }

      .table tbody tr {
          transition: none;
          border-bottom: 1px solid #f5f5f5;
      }
      
      .table tbody tr:hover { background: #FCFCFA; }

      .table tbody td {
          padding: 16px 20px;
          font-size: 0.85rem; color: var(--ink-primary);
          vertical-align: top;
      }

      .wrap-cell {
          white-space: normal;
          min-width: 250px; line-height: 1.5;
      }

      .col-main { font-weight: 600; font-size: 0.95rem; margin-bottom: 2px; }
      .col-sub { color: var(--ink-secondary); font-size: 0.8rem; }
      .col-id { font-family: 'Space Grotesk', monospace; color: var(--gold-dim); font-size: 0.8rem; font-weight: 700; }

      /* Description formatting */
      .desc-box {
          background: #f9f9f9; border-left: 3px solid var(--border-subtle);
          padding: 12px 16px; border-radius: 0 8px 8px 0; margin-top: 8px;
          font-size: 0.85rem; color: var(--ink-primary);
          font-style: italic;
      }

      /* Tags */
      .tag { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
      .tag-date { background: rgba(198, 167, 94, 0.1); color: var(--gold-dim); border: 1px solid rgba(198, 167, 94, 0.2); }

      /* Actions */
      .action-flex { display: flex; gap: 8px; align-items: center; }
      
      .btn-action {
          display: inline-flex; align-items: center; justify-content: center; gap: 6px;
          padding: 6px 12px; border-radius: 6px;
          font-size: 0.75rem; font-weight: 600; text-decoration: none; border: none;
          transition: none; background: #fff; border: 1px solid var(--border-subtle);
          cursor: pointer; color: var(--ink-primary); text-transform: uppercase; letter-spacing: 0.05em;
      }
      .btn-action:hover {
          border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-1px);
      }

      /* ============================
         6. NAVIGATION FOOTER
         ============================ */
      .footer-nav {
          display: flex; justify-content: flex-end; gap: 16px; margin-top: 24px;
      }
      
      .btn-nav {
          display: inline-flex; align-items: center; gap: 8px;
          padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: 0.85rem;
          text-decoration: none; transition: none;
      }
      
      .btn-back {
          background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary);
      }
      .btn-back:hover { border-color: var(--gold-main); color: var(--gold-main); }

      .empty-state { text-align: center; padding: 48px; color: var(--ink-tertiary); font-size: 0.95rem; font-style: italic; }

      /* Responsive */
      @media (max-width: 900px) {
          .panel-head { flex-direction: column; align-items: flex-start; gap: 16px; }
          .search-bar { width: 100%; }
      }
  </style>
</head>

<body>
  <div class="dashboard-shell">

    <header class="admin-header smart-enter d-1">
        <div class="header-content">
            <h1>Case Archives</h1>
            <div class="header-meta">
                <span class="meta-item"><i class="ph ph-lock-key secure-lock"></i> Secure Counsel Session</span>
                <span class="meta-item"><i class="ph ph-archive-box"></i> Discussion Logs</span>
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
                <h3><i class="ph ph-chat-circle-dots panel-icon"></i> Historical Discussions</h3>
                <span class="tag-info">Read Only</span>
            </div>
            
            <div class="search-bar">
                <i class="ph-bold ph-magnifying-glass" style="color:var(--ink-tertiary)"></i>
                <input type="text" id="archiveSearch" class="search-input" placeholder="Search by title, case ID, or email..." onkeyup="filterTable()">
            </div>
        </div>

        <div class="table-responsive">
            <table class="table" id="archiveTable">
              <thead>
                <tr>
                  <th>Log ID</th>
                  <th>Discussion Details</th>
                  <th>Client Contact</th>
                  <th style="text-align: right;">Action</th>
                </tr>
              </thead>
              <tbody>
                <%
                  try {
                    Connection con = getDatabaseConnection();
                    PreparedStatement pst = con.prepareStatement("SELECT * FROM discussion WHERE lname=? ORDER BY cdate DESC");
                    pst.setString(1, lnameSession);
                    ResultSet rs = pst.executeQuery();

                    boolean hasData = false;
                    while(rs.next()) {
                      hasData = true;
                      int logId = rs.getInt(1);
                      String title = rs.getString(2);
                      String date = rs.getString(3);
                      String desc = rs.getString(4);
                      String customerEmail = rs.getString(5);
                %>
                <tr>
                  <td style="width: 15%;">
                    <div class="col-id">#LOG-<%= logId %></div>
                    <div style="margin-top:8px;">
                        <span class="tag tag-date"><i class="ph-bold ph-clock"></i> <%= date %></span>
                    </div>
                  </td>
                  <td style="width: 50%;">
                    <div class="col-main"><%= com.j4u.Sanitizer.sanitize(title) %></div>
                    <div class="desc-box">"<%= com.j4u.Sanitizer.sanitize(desc) %>"</div>
                  </td>
                  <td style="width: 25%;">
                    <div class="col-main" style="font-size:0.85rem;"><i class="ph-bold ph-envelope" style="color:var(--ink-tertiary)"></i> <%= customerEmail %></div>
                  </td>
                  <td style="width: 10%; text-align: right;">
                    <a href="disf.jsp" class="btn-action">
                        Reply <i class="ph-bold ph-arrow-bend-up-left"></i>
                    </a>
                  </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr>
                  <td colspan="4">
                    <div class="empty-state">
                      <i class="ph-duotone ph-archive" style="font-size:3rem; margin-bottom:12px; color:var(--ink-tertiary);"></i><br>
                      <span>No historical discussions found.</span>
                    </div>
                  </td>
                </tr>
                <%
                    }
                    rs.close(); pst.close(); con.close();
                  } catch(Exception e) {
                %>
                <tr><td colspan="4" style="color:red; padding:20px; text-align:center;">System Error: <%= e.getMessage() %></td></tr>
                <% } %>
              </tbody>
            </table>
        </div>
    </div>

    <div class="footer-nav smart-enter d-3">
        <a href="Lawyerdashboard.jsp" class="btn-nav btn-back">
            <i class="ph ph-arrow-left"></i> Counsel Workspace
        </a>
    </div>

  </div>

  <script>
    /* REAL-TIME SEARCH FILTER */
    function filterTable() {
      const input = document.getElementById("archiveSearch");
      const filter = input.value.toUpperCase();
      const table = document.getElementById("archiveTable");
      const tr = table.getElementsByTagName("tr");

      for (let i = 1; i < tr.length; i++) { // Start at 1 to skip header
        let textContent = tr[i].textContent || tr[i].innerText;
        if (textContent.toUpperCase().indexOf(filter) > -1) {
          tr[i].style.display = "";
        } else {
          tr[i].style.display = "none";
        }
      }
    }
  </script>

</body>
</html>

