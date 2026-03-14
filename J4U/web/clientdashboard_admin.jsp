<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%
  // ==========================================
  // BACKEND LOGIC (PRESERVED)
  // ==========================================
  String username = (String) session.getAttribute("cname");
  if (username == null) {
    response.sendRedirect("cust_login.html?msg=Session expired");
    return;
  }

  // Database integration for dynamic data
  int activeCases = 0;
  int pendingActions = 0;
  String upcomingHearing = "Oct 24"; // Can be made dynamic if hearings table exists
  ResultSet caseRs = null;
  Connection con = null;
  try {
    con = getDatabaseConnection();

    // Fetch active cases count for this client
    try {
      PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE cname = ? AND flag=1");
      ps.setString(1, username);
      ResultSet rs = ps.executeQuery();
      if(rs.next()) activeCases = rs.getInt(1);
      rs.close();
      ps.close();
    } catch(Exception e) {
      activeCases = 0; // Fallback on error
    }

    // Fetch pending actions count (unassigned cases for this client)
    try {
      PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE cname = ? AND flag=0");
      ps.setString(1, username);
      ResultSet rs = ps.executeQuery();
      if(rs.next()) pendingActions = rs.getInt(1);
      rs.close();
      ps.close();
    } catch(Exception e) {
      pendingActions = 0; // Fallback on error
    }

    // Fetch recent case updates for table (client-specific with assigned lawyers)
    try {
      PreparedStatement ps = con.prepareStatement(
        "SELECT c.*, COALESCE(l.lname, 'Not Assigned') as lawyer_name " +
        "FROM casetb c " +
        "LEFT JOIN customer_cases cc ON c.cid = cc.case_id " +
        "LEFT JOIN lawyer_reg l ON cc.assigned_lawyer_id = l.lid " +
        "WHERE c.cname = ? AND c.flag=1 " +
        "ORDER BY c.cid DESC LIMIT 3"
      );
      ps.setString(1, username);
      caseRs = ps.executeQuery();
    } catch(Exception e) {
      caseRs = null; // Fallback on error
    }

  } catch(Exception e) {
    // Connection error: keep default values
    activeCases = 0;
    pendingActions = 0;
    caseRs = null;
  } finally {
    // Ensure connection is closed
    if(con != null) try { con.close(); } catch(Exception ex) {}
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Justice4U | Client Portal</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
  <script src="https://unpkg.com/@phosphor-icons/web"></script>

  <style>
    /* ========================
       1. MODERN VARIABLES
       ======================== */
    :root {
      --bg-body: #F3F4F6;
      --bg-surface: #FFFFFF;
      --bg-sidebar: #111827; /* Darker, richer grey */
      
      --text-primary: #1F2937;
      --text-secondary: #6B7280;
      --text-on-dark: #F9FAFB;
      
      --brand-gold: #C6A75E;
      --brand-gold-hover: #B0924B;
      
      --border-light: #E5E7EB;
      
      --success-bg: #D1FAE5;
      --success-text: #065F46;
      --warning-bg: #FEF3C7;
      --warning-text: #92400E;
      --blue-bg: #DBEAFE;
      --blue-text: #1E40AF;
      
      --shadow-sm: 0 1px 3px rgba(0,0,0,0.1);
      --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
      
      --radius: 12px;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'Inter', sans-serif;
      background-color: var(--bg-body);
      color: var(--text-primary);
      display: flex;
      min-height: 100vh;
      overflow-x: hidden;
      animation: fadeIn 0.5s ease-out;
    }
    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

    /* ========================
       2. SIDEBAR
       ======================== */
    .sidebar {
      width: 280px;
      background-color: var(--bg-sidebar);
      color: var(--text-on-dark);
      display: flex;
      flex-direction: column;
      padding: 32px 24px;
      position: fixed;
      height: 100vh;
      z-index: 50;
      transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      box-shadow: 4px 0 24px rgba(0,0,0,0.1);
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 48px;
      padding-left: 8px;
    }
    
    .brand-icon {
      color: var(--brand-gold);
      font-size: 28px;
    }

    .brand h2 {
      font-family: 'Playfair Display', serif;
      font-size: 1.5rem;
      letter-spacing: 0.02em;
      color: #fff;
    }

    .nav-group { margin-bottom: 32px; }
    .nav-title {
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: #9CA3AF;
      margin-bottom: 16px;
      padding-left: 12px;
      font-weight: 600;
    }

    .nav-link {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px;
      color: #D1D5DB;
      text-decoration: none;
      border-radius: 8px;
      font-size: 0.95rem;
      font-weight: 500;
      transition: all 0.2s ease;
      margin-bottom: 4px;
    }

    .nav-link:hover {
      background: rgba(255,255,255,0.05);
      color: #fff;
      transform: translateX(4px);
    }

    .nav-link.active {
      background: rgba(198, 167, 94, 0.15);
      color: var(--brand-gold);
      border: 1px solid rgba(198, 167, 94, 0.2);
    }

    .nav-link i { font-size: 1.25rem; }

    /* ========================
       3. MAIN CONTENT
       ======================== */
    .main-content {
      flex: 1;
      margin-left: 280px;
      padding: 40px;
      max-width: 1600px;
    }

    /* Header & Top Bar */
    .top-bar {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 48px;
      flex-wrap: wrap;
      gap: 20px;
    }

    .welcome-text h1 {
      font-family: 'Playfair Display', serif;
      font-size: 2rem;
      color: var(--text-primary);
      margin-bottom: 8px;
    }
    .welcome-text p { font-size: 1rem; color: var(--text-secondary); }

    .header-actions {
      display: flex;
      gap: 16px;
      align-items: center;
    }

    .btn-primary {
      background-color: var(--brand-gold);
      color: #fff;
      border: none;
      padding: 12px 24px;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: background 0.2s;
      box-shadow: 0 4px 6px -1px rgba(198, 167, 94, 0.3);
    }
    .btn-primary:hover { background-color: var(--brand-gold-hover); }

    .user-profile {
      display: flex;
      align-items: center;
      gap: 12px;
      background: var(--bg-surface);
      padding: 6px 6px 6px 16px;
      border-radius: 50px;
      border: 1px solid var(--border-light);
      box-shadow: var(--shadow-sm);
      cursor: pointer;
    }

    .avatar-circle {
      width: 36px; height: 36px;
      background: var(--bg-sidebar);
      color: #fff;
      border-radius: 50%;
      display: grid; place-items: center;
      font-weight: 600;
    }

    /* Metrics Grid */
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 24px;
      margin-bottom: 40px;
    }

    .stat-card {
      background: var(--bg-surface);
      padding: 28px;
      border-radius: var(--radius);
      border: 1px solid var(--border-light);
      box-shadow: var(--shadow-card);
      position: relative;
      overflow: hidden;
    }
    
    .stat-card::after {
      content: '';
      position: absolute;
      top: 0; left: 0; width: 4px; height: 100%;
      background: var(--brand-gold);
      opacity: 0;
      transition: opacity 0.2s;
    }
    .stat-card:hover::after { opacity: 1; }

    .stat-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 12px;
    }
    
    .stat-icon {
      color: var(--text-secondary);
      font-size: 1.5rem;
      background: #F3F4F6;
      padding: 8px;
      border-radius: 8px;
    }

    .stat-value { font-size: 2.25rem; font-weight: 700; color: var(--text-primary); line-height: 1; margin-bottom: 8px; }
    .stat-label { font-size: 0.9rem; color: var(--text-secondary); font-weight: 500; }

    /* Case Table */
    .table-container {
      background: var(--bg-surface);
      border-radius: var(--radius);
      border: 1px solid var(--border-light);
      box-shadow: var(--shadow-card);
      overflow: hidden;
    }

    .section-header {
      padding: 24px 32px;
      border-bottom: 1px solid var(--border-light);
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: #fff;
    }

    .section-header h3 { font-family: 'Playfair Display', serif; font-size: 1.25rem; }

    table { width: 100%; border-collapse: collapse; }
    
    th {
      text-align: left;
      padding: 16px 32px;
      background: #F9FAFB;
      font-size: 0.75rem;
      text-transform: uppercase;
      color: var(--text-secondary);
      font-weight: 600;
      letter-spacing: 0.05em;
    }

    td {
      padding: 20px 32px;
      border-bottom: 1px solid var(--border-light);
      font-size: 0.95rem;
      color: var(--text-primary);
      vertical-align: middle;
    }

    tr:last-child td { border-bottom: none; }
    tr:hover { background-color: #FAFAFA; }

    /* Status Pills */
    .status-pill {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 0.8rem;
      font-weight: 600;
    }
    .status-pill::before {
      content: ''; display: block; width: 6px; height: 6px; border-radius: 50%;
    }
    
    .status-active { background: var(--success-bg); color: var(--success-text); }
    .status-active::before { background: var(--success-text); }
    
    .status-pending { background: var(--warning-bg); color: var(--warning-text); }
    .status-pending::before { background: var(--warning-text); }
    
    .status-review { background: var(--blue-bg); color: var(--blue-text); }
    .status-review::before { background: var(--blue-text); }

    .btn-text {
      background: none; border: none;
      color: var(--brand-gold);
      font-weight: 600;
      cursor: pointer;
      font-size: 0.9rem;
    }
    .btn-text:hover { text-decoration: underline; }

    /* Mobile Logic */
    .menu-btn { display: none; font-size: 1.5rem; background: var(--bg-surface); border: 1px solid var(--border-light); padding: 8px; border-radius: 8px; cursor: pointer; color: var(--text-primary); box-shadow: var(--shadow-sm); }
    .overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); backdrop-filter: blur(2px); z-index: 40; }

    @media (max-width: 900px) {
      .sidebar { transform: translateX(-100%); }
      .sidebar.active { transform: translateX(0); }
      .main-content { margin-left: 0; padding: 20px; padding-top: 80px; }
      .menu-btn { display: block; position: fixed; top: 20px; left: 20px; z-index: 60; }
      .overlay.active { display: block; }
      .top-bar { flex-direction: column; gap: 16px; }
      .header-actions { width: 100%; justify-content: space-between; }
    }
  </style>
</head>
<body>

  <button class="menu-btn" onclick="toggleSidebar()">
    <i class="ph ph-list"></i>
  </button>

  <div class="overlay" onclick="toggleSidebar()"></div>

  <aside class="sidebar">
    <div class="brand">
      <i class="ph-fill ph-scales brand-icon"></i>
      <h2>Justice4U</h2>
    </div>

    <div class="nav-group">
      <div class="nav-title">Main Menu</div>
      <a href="#" class="nav-link active">
        <i class="ph ph-squares-four"></i> Dashboard
      </a>
      <a href="ClientDashboard" class="nav-link">
        <i class="ph ph-briefcase"></i> My Cases
      </a>
      <a href="documents.jsp" class="nav-link">
        <i class="ph ph-files"></i> Documents
      </a>
      <a href="client_chat_cases.jsp" class="nav-link">
        <i class="ph ph-chats-circle"></i> Messages
        <span style="margin-left:auto; background:var(--brand-gold); color:#fff; font-size:0.7rem; padding:2px 6px; border-radius:10px;">2</span>
      </a>
    </div>
    
    <div class="nav-group">
      <div class="nav-title">Settings</div>
      <a href="profile.jsp" class="nav-link">
        <i class="ph ph-user-gear"></i> Profile
      </a>
      <a href="billing.jsp" class="nav-link">
        <i class="ph ph-credit-card"></i> Billing
      </a>
    </div>

    <div style="margin-top:auto; padding-top: 20px; border-top: 1px solid #374151;">
      <a href="csignout.jsp" class="nav-link" style="color:#F87171;">
        <i class="ph ph-sign-out"></i> Sign Out
      </a>
    </div>
  </aside>

  <div class="main-content">
    
    <div class="top-bar">
      <div class="welcome-text">
        <h1>Good Afternoon, <%= username != null ? username : "Client" %></h1>
        <p>Here is what’s happening with your legal matters today.</p>
      </div>
      
      <div class="header-actions">
        <a href="case.jsp" class="btn-primary" style="text-decoration: none; color: inherit;">
          <i class="ph-bold ph-plus"></i> New Inquiry
        </a>

        <div class="user-profile">
          <div style="text-align:right; margin-right:4px;">
            <div style="font-size:0.85rem; font-weight:600;"><%= username %></div>
            <div style="font-size:0.7rem; color:var(--text-secondary);">Client Account</div>
          </div>
          <div class="avatar-circle"><%= username != null ? username.charAt(0) : "C" %></div>
        </div>
      </div>
    </div>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-header">
          <span class="stat-label">Active Cases</span>
          <i class="ph ph-gavel stat-icon"></i>
        </div>
        <div class="stat-value"><%= activeCases %></div>
        <div style="font-size:0.8rem; color:var(--success-text);">
          <i class="ph-bold ph-trend-up"></i> Updated yesterday
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-header">
          <span class="stat-label">Pending Actions</span>
          <i class="ph ph-bell-ringing stat-icon" style="color:#D97706; background:#FFFBEB"></i>
        </div>
        <div class="stat-value"><%= pendingActions %></div>
        <div style="font-size:0.8rem; color:#D97706;">Requires your signature</div>
      </div>
      
      <div class="stat-card">
        <div class="stat-header">
          <span class="stat-label">Upcoming Hearings</span>
          <i class="ph ph-calendar-check stat-icon"></i>
        </div>
        <div class="stat-value">Oct 24</div>
        <div style="font-size:0.8rem; color:var(--text-secondary);">High Court, Room 4B</div>
      </div>
    </div>

    <div class="table-container">
      <div class="section-header">
        <h3>Recent Updates</h3>
        <a href="ClientDashboard" class="btn-text" style="font-size:0.85rem; text-decoration: none;">View All Cases <i class="ph-bold ph-arrow-right"></i></a>
      </div>
      <div style="overflow-x:auto;">
        <table>
          <thead>
            <tr>
              <th>Case Reference</th>
              <th>Category</th>
              <th>Assigned Lawyer</th>
              <th>Current Status</th>
              <th>Last Update</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <%
              if(caseRs != null) {
                try {
                  while(caseRs.next()) {
                    int caseId = caseRs.getInt(1);
                    String customerName = caseRs.getString(2);
                    String caseTitle = caseRs.getString(3);
                    String caseDescription = caseRs.getString(4);
                    String caseDate = caseRs.getString(5);
                    String court = caseRs.getString(6);
                    String city = caseRs.getString(7);
                    String paymentMode = caseRs.getString(8);
                    String transactionId = caseRs.getString(9);
                    String amount = caseRs.getString(10);
                    String customerEmail = caseRs.getString(11);
                    String lawyerName = caseRs.getString(12);
            %>
            <tr>
              <td>
                <div style="font-weight:600; color:var(--text-primary);">#J4U-<%= caseId %></div>
                <div style="font-size:0.8rem; color:var(--text-secondary);"><%= customerName %></div>
              </td>
              <td><%= caseTitle %></td>
              <td><%= lawyerName %></td>
              <td><span class="status-pill status-active">Active Hearing</span></td>
              <td><%= caseDate %></td>
              <td><a href="client_case_details.jsp" class="btn-text" style="text-decoration: none;">View Details</a></td>
            </tr>
            <%
                  }
                  caseRs.close();
                } catch(Exception e) {
            %>
            <tr>
              <td colspan="6" style="color:#b91c1c; font-weight:600;">Error loading case data: <%= e.getMessage() %></td>
            </tr>
            <%
                }
              } else {
            %>
            <tr>
              <td colspan="6" style="color:#6b7280;">No active cases found.</td>
            </tr>
            <%
              }
            %>
          </tbody>
        </table>
      </div>
    </div>

  </div>

  <script>
    function toggleSidebar() {
      document.querySelector('.sidebar').classList.toggle('active');
      document.querySelector('.overlay').classList.toggle('active');
    }
  </script>

</body>
</html>
