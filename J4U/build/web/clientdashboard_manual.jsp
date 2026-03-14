<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.RBACUtil, java.util.Calendar" %>
<%@ include file="db_connection.jsp" %>
<% 
    // ==========================================
    // BACKEND LOGIC (STRICTLY PRESERVED)
    // ==========================================
    String username = (String) session.getAttribute("cname");
    
    // Supporting both email and name as identifier depending on legacy login
    String cemailSession = (String) session.getAttribute("cemail"); 
    // Fallback if cemail not set
    if(cemailSession == null && username != null && username.contains("@")) {
        cemailSession = username;
    }
    
    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }

    if (!RBACUtil.isValidClient(username)) { 
        session.invalidate();
        response.sendRedirect("cust_login.html?msg=Invalid Access");
        return;
    } 

    // Time-based Greeting (UX Only)
    Calendar c = Calendar.getInstance();
    int timeOfDay = c.get(Calendar.HOUR_OF_DAY);
    String greeting = (timeOfDay < 12) ? "Good Morning" : (timeOfDay < 16) ? "Good Afternoon" : (timeOfDay < 21) ? "Good Evening" : "Welcome";

    String customerName = "";
    String assignedLawyerName = "";
    String assignedLawyerEmail = "";
    String assignedLawyerPhone = "";
    String caseStatus = "";
    String caseId = "";

    try {
        Connection con = getDatabaseConnection();
        
        // 1. Get Customer Details
        PreparedStatement st = con.prepareStatement("SELECT cname FROM cust_reg WHERE email=?");
        st.setString(1, cemailSession != null ? cemailSession : username);
        ResultSet rs = st.executeQuery();
        if (rs.next()) {
            customerName = rs.getString("cname");
        }

        // 2. Get Assigned Lawyer
        PreparedStatement caseSt = con.prepareStatement(
            "SELECT c.case_id, c.status, l.lname, l.email, l.phone "
            + "FROM customer_cases c "
            + "LEFT JOIN lawyer_reg l ON c.assigned_lawyer_id = l.lid "
            + "WHERE c.customer_id = (SELECT cid FROM cust_reg WHERE email=?) "
            + "ORDER BY c.case_id DESC LIMIT 1"
        );
        caseSt.setString(1, cemailSession != null ? cemailSession : username);
        ResultSet caseRs = caseSt.executeQuery();

        if (caseRs.next()) {
            caseId = caseRs.getString("case_id");
            caseStatus = caseRs.getString("status");
            if (caseStatus == null) caseStatus = "OPEN";
            
            assignedLawyerName = caseRs.getString("lname");
            assignedLawyerEmail = caseRs.getString("email");
            assignedLawyerPhone = caseRs.getString("phone");
        } else {
            caseStatus = "No active case";
        }

        // Dashboard specific flags
        boolean isAssigned = "ASSIGNED".equalsIgnoreCase(caseStatus);
        boolean isPending = "PENDING_LAWYER_CONFIRMATION".equalsIgnoreCase(caseStatus);
        boolean isOpen = "OPEN".equalsIgnoreCase(caseStatus);
        boolean hasCase = (caseId != null && !caseId.isEmpty());

        rs.close(); caseRs.close(); st.close(); caseSt.close(); con.close();
    } catch (Exception e) {
        caseStatus = "Error loading data: " + e.getMessage();
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Client Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
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
            --alert-amber: #D97706;
            
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        body {
            margin: 0; background-color: var(--bg-ivory); color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .layout-wrapper { display: flex; min-height: 100vh; }

        /* ============================
           2. SIDEBAR NAVIGATION
           ============================ */
        .sidebar {
            width: 260px; background: var(--surface-card); border-right: 1px solid var(--border-subtle);
            padding: 32px 24px; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh;
        }

        .brand { display: flex; align-items: center; gap: 12px; margin-bottom: 48px; text-decoration: none; }
        .brand-icon { font-size: 2rem; color: var(--gold-main); }
        .brand h2 { font-family: 'Playfair Display', serif; margin: 0; color: var(--ink-primary); font-size: 1.5rem; }

        .nav-group { margin-bottom: 32px; }
        .nav-title { font-size: 0.75rem; text-transform: uppercase; color: var(--ink-tertiary); margin-bottom: 12px; font-weight: 600; letter-spacing: 0.05em; }
        .nav-link {
            display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: 8px;
            color: var(--ink-secondary); text-decoration: none; font-weight: 500; transition: all 0.2s; margin-bottom: 4px; border: 1px solid transparent;
        }
        .nav-link:hover, .nav-link.active {
            background: #FAFAFA; color: var(--ink-primary); border-color: var(--border-subtle);
        }
        .nav-link.active { box-shadow: 0 2px 8px rgba(0,0,0,0.02); }
        .nav-link i { font-size: 1.2rem; color: var(--gold-dim); }

        .logout-link {
            display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: 8px;
            color: var(--ink-secondary); text-decoration: none; font-weight: 500; transition: all 0.2s; margin-top: auto;
        }
        .logout-link:hover { background: #FEF2F2; color: #DC2626; }
        .logout-link i { font-size: 1.2rem; }

        /* ============================
           3. MAIN LAYOUT
           ============================ */
        .main-content { flex: 1; padding: 40px 48px; max-width: 1200px; margin: 0 auto; }

        .smart-enter {
            opacity: 0; transform: translateY(15px);
            animation: enterUp 0.6s var(--ease-smart) forwards;
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }
        .d-3 { animation-delay: 0.3s; }
        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* HEADER */
        .dashboard-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 40px; }
        .header-left h1 { font-family: 'Playfair Display', serif; font-size: 2.2rem; margin: 0 0 8px 0; color: var(--ink-primary); }
        .header-left p { color: var(--ink-secondary); margin: 0; display: flex; align-items: center; gap: 6px; font-family: 'Space Grotesk', monospace; font-size: 0.85rem;}

        .profile-pill {
            display: flex; align-items: center; gap: 12px; background: #fff; padding: 8px 20px 8px 8px;
            border-radius: 100px; border: 1px solid var(--border-subtle); box-shadow: var(--shadow-card);
        }
        .avatar {
            width: 36px; height: 36px; background: rgba(198, 167, 94, 0.1); color: var(--gold-main);
            border-radius: 50%; display: grid; place-items: center; font-weight: 600; font-family: 'Playfair Display', serif; font-size:1.1rem;
        }

        /* GRID */
        .dashboard-grid { display: grid; grid-template-columns: 1fr; gap: 32px; align-items: start; }
        
        /* TIMELINE CARD */
        .panel {
            background: var(--surface-card); border-radius: 16px; border: 1px solid var(--border-subtle);
            box-shadow: var(--shadow-card); padding: 32px;
        }
        
        .panel-title { font-size: 1.1rem; font-weight: 600; margin: 0 0 32px 0; display: flex; justify-content: space-between; align-items: center; }

        /* COUNSEL CARD */
        .counsel-card {
            background: #FAFAFA; border-radius: 16px; border: 1px solid var(--border-subtle); padding: 24px; text-align: center;
        }

        .counsel-avatar {
            width: 64px; height: 64px; border-radius: 50%; background: #fff; border: 1px solid var(--border-subtle);
            display: grid; place-items: center; font-size: 1.5rem; color: var(--ink-primary); margin: 0 auto 16px;
        }

        .counsel-name { font-family: 'Playfair Display', serif; font-size: 1.25rem; margin: 0 0 4px 0; }
        .counsel-role { font-size: 0.8rem; color: var(--success-green); font-weight: 600; margin-bottom: 20px; display:inline-flex; align-items:center; gap:4px; }

        .btn-chat {
            display: flex; justify-content: center; align-items: center; gap: 8px;
            background: var(--ink-primary); color: white; text-decoration: none;
            padding: 12px; border-radius: 8px; font-weight: 500; transition: all 0.2s; width: 100%;
        }
        .btn-chat:hover { background: var(--gold-main); transform: translateY(-2px); }

        .status-pill {
            display: inline-block; padding: 4px 10px; border-radius: 100px; font-size: 0.75rem; font-weight: 600;
        }
        .status-pending { background: #FFFBEB; color: var(--alert-amber); border: 1px solid #FEF3C7; }
        .status-empty { background: #FAFAFA; color: var(--ink-tertiary); border: 1px solid var(--border-subtle); }

        /* ACTION GRID */
        .actions-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-top: 32px; }
        
        .action-tile {
            background: var(--surface-card); padding: 24px; border-radius: 16px; border: 1px solid var(--border-subtle);
            text-decoration: none; color: inherit; transition: all 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
            position: relative; overflow: hidden;
        }
        .action-tile:hover {
            transform: translateY(-4px); border-color: var(--gold-main); box-shadow: 0 12px 24px rgba(198, 167, 94, 0.1);
        }
        .at-icon {
            width: 48px; height: 48px; background: #FAFAFA; border-radius: 12px; display: grid; place-items: center;
            font-size: 1.5rem; color: var(--gold-dim); margin-bottom: 16px; transition: transform 0.3s;
        }
        .action-tile:hover .at-icon { transform: scale(1.1); background: #FFFAF0; color: var(--gold-main); }
        .action-tile h4 { margin: 0 0 4px 0; font-size: 1rem; color: var(--ink-primary); }
        .action-tile p { margin: 0; font-size: 0.85rem; color: var(--ink-secondary); }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .main-content { padding: 24px; }
            .dashboard-grid { grid-template-columns: 1fr; }
            .actions-grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 768px) {
            .actions-grid { grid-template-columns: 1fr; }
            .dashboard-header { flex-direction: column; align-items: flex-start; gap: 24px; }
        }
    </style>
</head>
<body>
    <div class="layout-wrapper">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <a href="#" class="brand">
                <i class="ph-fill ph-scales brand-icon"></i>
                <h2>Justice4U</h2>
            </a>

            <div class="nav-group">
                <div class="nav-title">Client Workspace</div>
                <a href="#" class="nav-link active"><i class="ph-duotone ph-squares-four"></i> Console</a>
                <a href="case.jsp" class="nav-link"><i class="ph-duotone ph-file-plus"></i> File Case</a>
                <a href="ClientDashboard" class="nav-link"><i class="ph-duotone ph-briefcase"></i> My Portfolio</a>
            </div>
            
            <div class="nav-group">
                <div class="nav-title">Lawyer Network</div>
                <a href="findlawyer.jsp" class="nav-link"><i class="ph-duotone ph-magnifying-glass"></i> Find Counsel</a>
                <a href="viewlawdetails.jsp" class="nav-link"><i class="ph-duotone ph-identification-card"></i> Assigned Lawyer</a>
            </div>

            <a href="csignout.jsp" class="logout-link"><i class="ph-duotone ph-sign-out"></i> Secure Logout</a>
        </aside>

        <!-- MAIN WINDOW -->
        <main class="main-content">
            
            <header class="dashboard-header smart-enter d-1">
                <div class="header-left">
                    <h1><%= greeting %>, <%= com.j4u.Sanitizer.sanitize(customerName) %></h1>
                    <p><i class="ph-fill ph-shield-check" style="color:var(--success-green)"></i> 256-bit Encrypted Session Active</p>
                </div>
                <div class="profile-pill">
                    <div class="avatar"><%= (customerName != null && !customerName.isEmpty()) ? customerName.charAt(0) : "U" %></div>
                    <div style="display:flex; flex-direction:column; justify-content:center;">
                        <span style="font-weight:600; font-size:0.9rem; line-height:1;"><%= com.j4u.Sanitizer.sanitize(username) %></span>
                        <span style="font-size:0.75rem; color:var(--ink-secondary); margin-top:2px;">Verified Client</span>
                    </div>
                </div>
            </header>

            <div class="dashboard-grid">
                
                <!-- ASSIGNED COUNSEL CARD -->
                <div class="panel smart-enter d-2">
                    <h3 class="panel-title">Assigned Counsel</h3>
                    
                    <% if (isAssigned && assignedLawyerName != null) { %>
                        <div class="counsel-avatar"><%= assignedLawyerName.charAt(0) %></div>
                        <h4 class="counsel-name"><%= com.j4u.Sanitizer.sanitize(assignedLawyerName) %></h4>
                        <div class="counsel-role"><i class="ph-fill ph-seal-check"></i> Verified Attorney</div>
                        
                        <a href="client_chat.jsp?case_id=<%= caseId %>" class="btn-chat">
                            <i class="ph-bold ph-chat-text"></i> Open Secure Portal
                        </a>
                        <a href="viewlawdetails.jsp?id=<%= assignedLawyerEmail %>" style="display:block; margin-top:16px; font-size:0.85rem; color:var(--ink-secondary); text-decoration:none; font-weight:500;">View Full Profile</a>

                    <% } else if (isPending) { %>
                        <div class="counsel-avatar" style="color:var(--alert-amber); background:#FFFBEB; border-color:#FEF3C7;"><i class="ph-bold ph-hourglass"></i></div>
                        <h4 class="counsel-name" style="font-size:1.1rem;">Awaiting Review</h4>
                        <p style="font-size:0.85rem; color:var(--ink-secondary); margin-bottom:20px;">
                            Waiting for <strong><%= assignedLawyerName != null ? com.j4u.Sanitizer.sanitize(assignedLawyerName) : "counsel" %></strong> to accept the inquiry.
                        </p>
                        <span class="status-pill status-pending">Decision Pending</span>

                    <% } else { %>
                        <div class="counsel-avatar" style="color:var(--ink-tertiary); background:#FAFAFA;"><i class="ph-bold ph-magnifying-glass"></i></div>
                        <h4 class="counsel-name" style="font-size:1.1rem;">No Counsel Found</h4>
                        <p style="font-size:0.85rem; color:var(--ink-secondary); margin-bottom:20px;">You currently have no active legal representation.</p>
                        
                        <% if(hasCase) { %>
                            <a href="findlawyer.jsp?case_id=<%= caseId %>" class="btn-chat" style="background:var(--gold-main);">Find Lawyer</a>
                        <% } else { %>
                            <span class="status-pill status-empty">Submit a case to start</span>
                        <% } %>
                    <% } %>
                </div>
            </div>

            <!-- MODULES -->
            <div class="actions-grid smart-enter d-3">
                <a href="case.jsp" class="action-tile">
                    <div class="at-icon"><i class="ph-duotone ph-file-plus"></i></div>
                    <h4>Submit Inquiry</h4>
                    <p>File a new legal case securely</p>
                </a>
                
                <a href="findlawyer.jsp" class="action-tile">
                    <div class="at-icon"><i class="ph-duotone ph-users"></i></div>
                    <h4>Find Counsel</h4>
                    <p>Browse our verified lawyer network</p>
                </a>

                <a href="viewdisc.jsp" class="action-tile">
                    <div class="at-icon"><i class="ph-duotone ph-chat-circle-dots"></i></div>
                    <h4>History Logs</h4>
                    <p>Review past legal consultations</p>
                </a>

                <a href="ClientDashboard" class="action-tile">
                    <div class="at-icon"><i class="ph-duotone ph-folders"></i></div>
                    <h4>Case Portfolio</h4>
                    <p>Access all your legal documents</p>
                </a>
                
                <a href="client_case_details.jsp" class="action-tile" style="border-color:var(--gold-main); background:#FFFAF0;">
                    <div class="at-icon" style="color:var(--gold-main); background:#fff;"><i class="ph-duotone ph-chart-line-up"></i></div>
                    <h4>Intelligent Dashboard</h4>
                    <p>Advanced tracking & financials</p>
                </a>
            </div>

        </main>
    </div>
</body>
</html>