<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<%
  // ==========================================
  // BACKEND LOGIC (STRICTLY PRESERVED)
  // ==========================================
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
  <title>Justice4U · Client Roster</title>

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
          transition: all 0.2s;
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
          transition: background 0.2s;
          border-bottom: 1px solid #f5f5f5;
      }
      
      .table tbody tr:hover { background: #FCFCFA; }

      .table tbody td {
          padding: 16px 20px;
          font-size: 0.85rem; color: var(--ink-primary);
          vertical-align: middle;
      }

      .wrap-cell {
          white-space: normal;
          min-width: 250px; line-height: 1.4;
      }

      .col-main { font-weight: 600; font-size: 0.95rem; margin-bottom: 2px; }
      .col-sub { color: var(--ink-secondary); font-size: 0.8rem; }
      .col-id { font-family: 'Space Grotesk', monospace; color: var(--gold-dim); font-size: 0.8rem; font-weight: 700; }

      /* Tags */
      .tag { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
      .tag-court { background: #F1F5F9; color: #475569; border: 1px solid #E2E8F0; }
      .tag-pay { background: rgba(5, 150, 105, 0.1); color: var(--success-green); border: 1px solid rgba(5,150,105,0.2); }

      /* Actions */
      .action-flex { display: flex; gap: 8px; align-items: center; }
      
      .btn-action {
          display: inline-flex; align-items: center; justify-content: center; gap: 6px;
          padding: 8px 14px; border-radius: 8px;
          font-size: 0.8rem; font-weight: 600; text-decoration: none; border: none;
          transition: all 0.2s; background: #fff; border: 1px solid var(--border-subtle);
          cursor: pointer; color: var(--ink-primary);
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
          text-decoration: none; transition: all 0.2s;
      }
      
      .btn-back {
          background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary);
      }
      .btn-back:hover { border-color: var(--gold-main); color: var(--gold-main); }
      
      .btn-danger { background: var(--danger-red); color: #fff; border: none; }
      .btn-danger:hover { opacity: 0.9; }

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
            <h1>Assigned Portfolio</h1>
            <div class="header-meta">
                <span class="meta-item"><i class="ph ph-lock-key secure-lock"></i> Secure Counsel Session</span>
                <span class="meta-item"><i class="ph ph-users-three"></i> Client Roster</span>
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
                <h3><i class="ph ph-address-book panel-icon"></i> Client Intelligence Roster</h3>
                <span class="tag-info">Live Database</span>
            </div>
            
            <div class="search-bar">
                <i class="ph-bold ph-magnifying-glass" style="color:var(--ink-tertiary)"></i>
                <input type="text" id="clientSearch" class="search-input" placeholder="Search client name, court, or case..." onkeyup="filterTable()">
            </div>
        </div>

        <div class="table-responsive">
            <table class="table" id="clientTable">
              <thead>
                <tr>
                  <th>Case Ref</th>
                  <th>Client Profile</th>
                  <th>Matter Details</th>
                  <th>Jurisdiction</th>
                  <th>Financials</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <%
                  try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = getDatabaseConnection();
                    
                    // 1. Get Lawyer ID
                    PreparedStatement psLid = con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?");
                    psLid.setString(1, lnameSession);
                    ResultSet rsLid = psLid.executeQuery();
                    int lawyerId = 0;
                    if (rsLid.next()) {
                        lawyerId = rsLid.getInt(1);
                    }
                    rsLid.close(); psLid.close();

                    // 2. Query allotlawyer and casetb
                    PreparedStatement ps = con.prepareStatement(
                      "SELECT a.cid as case_id, a.title, a.des as description, a.curdate as created_date, " +
                      "a.courttype as preferred_court_location, a.mop as payment_model, a.amt as total_fee, " +
                      "a.name as cname, a.cname as email, cr.cid as client_id " +
                      "FROM allotlawyer a " +
                      "JOIN casetb c ON a.cid = c.cid " +
                      "JOIN cust_reg cr ON a.cname = cr.email " +
                      "WHERE a.lname = ? AND c.flag >= 1"
                    );
                    ps.setString(1, lnameSession);
                    ResultSet rs = ps.executeQuery();

                    boolean hasData = false;
                    while(rs.next()) {
                      hasData = true;
                      int caseId = rs.getInt("case_id");
                      String title = rs.getString("title");
                      if(title == null) title = "Case #" + caseId;
                      String desc = rs.getString("description");
                      if(desc == null) desc = "N/A";
                      Date date = rs.getDate("created_date");
                      String court = rs.getString("preferred_court_location");
                      if(court == null) court = "Online Jurisdiction";
                      String payMode = rs.getString("payment_model");
                      if(payMode == null) payMode = "Standard";
                      double amount = rs.getDouble("total_fee");
                      String clientName = rs.getString("cname");
                      String email = rs.getString("email");
                      int clientId = rs.getInt("client_id");
                %>
                <tr>
                  <td>
                    <div class="col-id">#C-<%= caseId %></div>
                    <div class="col-sub">Assigned</div>
                  </td>
                  <td>
                    <div class="col-main"><%= com.j4u.Sanitizer.sanitize(clientName) %></div>
                    <div class="col-sub"><%= com.j4u.Sanitizer.sanitize(email) %></div>
                  </td>
                  <td class="wrap-cell">
                    <div class="col-main"><%= com.j4u.Sanitizer.sanitize(title) %></div>
                    <div class="col-sub" style="margin-bottom:4px;"><%= com.j4u.Sanitizer.sanitize(desc) %></div>
                    <div class="col-sub" style="color:var(--gold-main); font-weight:600;"><i class="ph-bold ph-calendar"></i> <%= date %></div>
                  </td>
                  <td>
                    <span class="tag tag-court"><%= com.j4u.Sanitizer.sanitize(court) %></span>
                  </td>
                  <td>
                    <div class="col-main">$<%= String.format("%.2f", amount) %></div>
                    <div style="margin-top:4px;"><span class="tag tag-pay"><%= com.j4u.Sanitizer.sanitize(payMode) %></span></div>
                  </td>
                  <td>
                    <div class="action-flex">
                        <a href="viewcusdet.jsp?client_id=<%= clientId %>" class="btn-action">
                            <i class="ph ph-folder-open"></i> Dossier
                        </a>
                    </div>
                  </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr>
                  <td colspan="6">
                    <div class="empty-state">
                      <i class="ph-duotone ph-folder-dashed" style="font-size:3rem; margin-bottom:12px; color:var(--ink-tertiary);"></i><br>
                      <span>No Clients Assigned Yet. When administrators assign cases to you, they will appear here.</span>
                    </div>
                  </td>
                </tr>
                <%
                    }
                    rs.close(); ps.close(); con.close();
                  } catch(Exception e) {
                %>
                <tr><td colspan="6" style="color:red; padding:20px; text-align:center;">System Error: <%= e.getMessage() %></td></tr>
                <% } %>
              </tbody>
            </table>
        </div>
    </div>

    <div class="footer-nav smart-enter d-3">
        <a href="Lawyerdashboard.jsp" class="btn-nav btn-back">
            <i class="ph ph-arrow-left"></i> Counsel Workspace
        </a>
        <a href="lsignout.jsp" class="btn-nav btn-danger">
            <i class="ph ph-sign-out"></i> Sign Out
        </a>
    </div>

  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    /* REAL-TIME SEARCH FILTER */
    function filterTable() {
      const input = document.getElementById("clientSearch");
      const filter = input.value.toUpperCase();
      const table = document.getElementById("clientTable");
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
