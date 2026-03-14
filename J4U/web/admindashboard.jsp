<%-- 
    Document   : admindashboard
    Created on : 21 Mar, 2025, 8:24:54 PM
    Author     : ZulkiflMugad
--%>

<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" %>
<%
    // View-layer fallback authentication guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html");
        return;
    }

    // Check for pending notifications
    String pendingNotification = (String) session.getAttribute("pendingNotification");
    String pendingCustomerName = (String) session.getAttribute("pendingCustomerName");
    String pendingCustomerEmail = (String) session.getAttribute("pendingCustomerEmail");
    
    // Clear notification after displaying
    if (pendingNotification != null) {
        session.removeAttribute("pendingNotification");
        session.removeAttribute("pendingCustomerName");
        session.removeAttribute("pendingCustomerEmail");
    }

    java.util.Map<String, Integer> metrics = (java.util.Map<String, Integer>) request.getAttribute("metrics");
    java.util.List<java.util.Map<String, Object>> pendingClients = (java.util.List<java.util.Map<String, Object>>) request.getAttribute("pendingClients");

    if (metrics == null) metrics = new java.util.HashMap<String, Integer>();
    if (pendingClients == null) pendingClients = new java.util.ArrayList<java.util.Map<String, Object>>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U – Command Center</title>

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
            /* Font Change: Inter is cleaner and more minimal */
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            /* Subtle grain for texture */
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
            /* Playfair maintained for Brand Identity */
            font-family: 'Playfair Display', serif;
            font-size: 2.2rem; margin: 0; color: var(--ink-primary);
        }
        
        .header-meta {
            display: flex; gap: 24px; align-items: center; margin-top: 8px;
            /* Space Grotesk for Tech Data */
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
           4. "NEED TO KNOW" NOTIFICATIONS
           ============================ */
        .insight-banner {
            background: #FFFBEB; border: 1px solid #FEF3C7;
            border-left: 4px solid var(--alert-amber);
            border-radius: 8px; padding: 20px; margin-bottom: 32px;
            display: flex; align-items: flex-start; gap: 16px;
            box-shadow: 0 4px 12px rgba(217, 119, 6, 0.05);
        }
        .insight-icon { font-size: 1.4rem; color: var(--alert-amber); }
        .insight-text h4 { margin: 0 0 4px 0; font-size: 0.95rem; font-weight: 600; color: #92400E; }
        .insight-text p { margin: 0; font-size: 0.85rem; color: #B45309; }

        /* ============================
           5. DATA INTELLIGENCE GRID (STATS)
           ============================ */
        .data-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 24px; margin-bottom: 48px;
        }

        .metric-card {
            background: var(--surface-card);
            border: 1px solid var(--border-subtle);
            border-radius: 12px; padding: 24px;
            position: relative; overflow: hidden;
            transition: all 0.3s var(--ease-smart);
        }

        .metric-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-hover);
            border-color: var(--gold-main);
        }

        .metric-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
        .metric-label { font-size: 0.75rem; color: var(--ink-secondary); font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .metric-icon { color: var(--ink-tertiary); font-size: 1.2rem; transition: color 0.3s; }
        .metric-card:hover .metric-icon { color: var(--gold-main); }

        .metric-value { 
            font-family: 'Space Grotesk', sans-serif; /* Tech Font for Numbers */
            font-size: 2.2rem; font-weight: 700; color: var(--ink-primary); line-height: 1; 
        }
        
        .metric-context {
            margin-top: 12px; padding-top: 12px; border-top: 1px solid #f5f5f5;
            font-size: 0.75rem; color: var(--ink-tertiary); display: flex; align-items: center; gap: 6px;
        }
        .status-good { color: var(--success-green); background: rgba(5, 150, 105, 0.1); padding: 2px 6px; border-radius: 4px; font-weight: 600; }
        .status-warn { color: var(--alert-amber); background: rgba(217, 119, 6, 0.1); padding: 2px 6px; border-radius: 4px; font-weight: 600; }

        /* ============================
           6. CONTROL PANEL (Split View)
           ============================ */
        .control-layout {
            display: grid; grid-template-columns: 2fr 1fr; gap: 32px;
        }
        @media (max-width: 992px) { .control-layout { grid-template-columns: 1fr; } }

        .panel {
            background: var(--surface-card);
            border: 1px solid var(--border-subtle);
            border-radius: 16px; overflow: hidden;
            box-shadow: var(--shadow-card);
            display: flex; flex-direction: column;
        }

        .panel-head {
            padding: 24px; border-bottom: 1px solid var(--border-subtle);
            display: flex; justify-content: space-between; align-items: center;
            background: #FAFAFA;
        }
        .panel-head h3 { 
            font-family: 'Inter', sans-serif; 
            font-size: 1rem; margin: 0; font-weight: 600; color: var(--ink-primary); 
        }
        
        .action-link { font-size: 0.8rem; color: var(--gold-main); text-decoration: none; font-weight: 600; display: flex; align-items: center; gap: 4px; transition: gap 0.2s; }
        .action-link:hover { gap: 8px; }

        /* Pending List */
        .task-list { padding: 8px; }
        .task-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px; border-bottom: 1px solid #f5f5f5;
            transition: background 0.2s; border-radius: 8px;
        }
        .task-item:last-child { border-bottom: none; }
        .task-item:hover { background: #FCFCFA; }

        .task-info h4 { font-size: 0.95rem; margin: 0 0 4px 0; color: var(--ink-primary); font-weight: 600; }
        .task-meta { font-size: 0.85rem; color: var(--ink-secondary); }
        .task-time { font-family: 'Space Grotesk', monospace; font-size: 0.75rem; color: var(--ink-tertiary); display: block; margin-top: 4px; }

        .btn-verify {
            padding: 8px 16px; background: #fff;
            border: 1px solid var(--border-subtle); border-radius: 6px;
            font-size: 0.8rem; font-weight: 600; color: var(--ink-primary);
            text-decoration: none; transition: all 0.2s;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .btn-verify:hover { border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-1px); }

        /* Quick Nav */
        .nav-menu { display: flex; flex-direction: column; }
        .menu-link {
            padding: 20px 24px; display: flex; align-items: center; gap: 16px;
            text-decoration: none; border-bottom: 1px solid #f5f5f5;
            transition: all 0.2s;
        }
        .menu-link:last-child { border-bottom: none; }
        .menu-icon { 
            width: 36px; height: 36px; border-radius: 8px; background: #F5F5F0; 
            color: var(--ink-secondary); display: flex; align-items: center; justify-content: center; font-size: 1.1rem;
            transition: all 0.2s;
        }
        .menu-text h4 { margin: 0; font-size: 0.9rem; font-weight: 600; color: var(--ink-primary); }
        .menu-text p { margin: 2px 0 0; font-size: 0.75rem; color: var(--ink-tertiary); }

        .menu-link:hover { background: #FCFCFA; padding-left: 28px; }
        .menu-link:hover .menu-icon { background: var(--gold-main); color: #fff; }
        
        .menu-link.danger:hover .menu-icon { background: #DC2626; color: #fff; }
        .menu-link.danger:hover .menu-text h4 { color: #DC2626; }

        /* Empty State */
        .all-clear { text-align: center; padding: 40px; color: var(--ink-tertiary); font-size: 0.9rem; }
        .all-clear i { font-size: 2rem; color: #E5E5E5; margin-bottom: 10px; display: block; }

    </style>
</head>
<body>

    <div class="dashboard-shell">
        
        <header class="admin-header smart-enter d-1">
            <div class="header-content">
                <h1>Command Center</h1>
                <div class="header-meta">
                    <span class="meta-item"><i class="ph ph-lock-key secure-lock"></i> Secure Session Active</span>
                    <span class="meta-item"><i class="ph ph-clock"></i> Updated: Just Now</span>
                </div>
            </div>
            <div class="admin-profile">
                <span class="profile-dot"></span>
                <span class="profile-role">System Admin</span>
            </div>
        </header>

        <% if (pendingNotification != null && pendingCustomerName != null) { %>
        <div class="insight-banner smart-enter d-2">
            <i class="ph ph-warning-circle insight-icon"></i>
            <div class="insight-text">
                <h4>Action Required: New Registration</h4>
                <p>Client <strong><%= pendingCustomerName %></strong> (<%= pendingCustomerEmail %>) is pending verification.</p>
            </div>
        </div>
        <% } %>

        <section class="data-grid smart-enter d-2">
            
            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Total Clients</span>
                    <i class="ph ph-users metric-icon"></i>
                </div>
                <div class="metric-value">
                    <%= metrics.containsKey("totalClients") ? metrics.get("totalClients") : "0" %>
                </div>
                <div class="metric-context">
                    <span class="status-good">Healthy</span> Database Active
                </div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Verify Queue</span>
                    <i class="ph ph-user-check metric-icon"></i>
                </div>
                <div class="metric-value" style="color: var(--alert-amber);">
                    <%= metrics.containsKey("verifyQueue") ? metrics.get("verifyQueue") : "0" %>
                </div>
                <div class="metric-context">
                    <span class="status-warn">Attention</span> Awaiting Review
                </div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Pending Matches</span>
                    <i class="ph ph-handshake metric-icon"></i>
                </div>
                <div class="metric-value" style="color: var(--alert-amber);">
                    <%= metrics.containsKey("pendingMatches") ? metrics.get("pendingMatches") : "0" %>
                </div>
                <div class="metric-context">
                    <span class="status-warn">Action</span> Client-Lawyer Handshakes
                </div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Lawyer Requests</span>
                    <i class="ph ph-briefcase metric-icon"></i>
                </div>
                <div class="metric-value">
                    <%= metrics.containsKey("lawyerRequests") ? metrics.get("lawyerRequests") : "0" %>
                </div>
                <div class="metric-context">
                    Pending Approval
                </div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Doc Verification</span>
                    <i class="ph ph-file-text metric-icon"></i>
                </div>
                <div class="metric-value">
                    <%= metrics.containsKey("docVerification") ? metrics.get("docVerification") : "0" %>
                </div>
                <div class="metric-context">
                    Files to review
                </div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Intern Apps</span>
                    <i class="ph ph-student metric-icon"></i>
                </div>
                <div class="metric-value">
                    <%= metrics.containsKey("internApps") ? metrics.get("internApps") : "0" %>
                </div>
                <div class="metric-context">
                    Review Applications
                </div>
            </div>
        </section>

        <div class="control-layout smart-enter d-3">
            
            <div class="panel">
                <div class="panel-head">
                    <h3>Priority: Pending Clients</h3>
                    <a href="viewcustomers.jsp" class="action-link">View Full Registry <i class="ph ph-arrow-right"></i></a>
                </div>
                <div class="task-list">
                    <% if (!pendingClients.isEmpty()) { %>
                        <% for(java.util.Map<String, Object> clientMap : pendingClients) { %>
                            <div class="task-item">
                                <div class="task-info">
                                    <h4><%= clientMap.get("name") %></h4>
                                    <div class="task-meta"><%= clientMap.get("email") %></div>
                                    <span class="task-time"><i class="ph ph-clock"></i> Registered: <%= clientMap.get("registrationDate") %></span>
                                </div>
                                <a href="viewcustomers.jsp" class="btn-verify">Review</a>
                            </div>
                        <% } %>
                    <% } else { %>
                        <div class="all-clear">
                            <i class="ph ph-check-circle"></i>
                            <p>Queue Clear. No pending verifications.</p>
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="panel">
                <div class="panel-head">
                    <h3>System Actions</h3>
                </div>
                <div class="nav-menu">
                    <a href="ViewCustomers" class="menu-link">
                        <div class="menu-icon"><i class="ph ph-users"></i></div>
                        <div class="menu-text">
                            <h4>Client Registry</h4>
                            <p>Verify & Manage Users</p>
                        </div>
                    </a>

                    <a href="viewapprovedlawyers.jsp" class="menu-link">
                        <div class="menu-icon"><i class="ph ph-scales"></i></div>
                        <div class="menu-text">
                            <h4>Approved Lawyers</h4>
                            <p>Active Professionals Directory</p>
                        </div>
                    </a>

                    <a href="ViewInterns" class="menu-link">
                        <div class="menu-icon"><i class="ph ph-user-plus"></i></div>
                        <div class="menu-text">
                            <h4>Intern Approval</h4>
                            <p>Verify New Applications</p>
                        </div>
                    </a>

                    <a href="viewapprovedinterns.jsp" class="menu-link">
                        <div class="menu-icon"><i class="ph ph-graduation-cap"></i></div>
                        <div class="menu-text">
                            <h4>Approved Interns</h4>
                            <p>Active Interns Directory</p>
                        </div>
                    </a>

                    <a href="ViewLawyers" class="menu-link">
                        <div class="menu-icon"><i class="ph ph-gavel"></i></div>
                        <div class="menu-text">
                            <h4>Lawyer Approval</h4>
                            <p>Review Profiles</p>
                        </div>
                    </a>

                    <a href="viewlawyerdocuments.jsp" class="menu-link">
                        <div class="menu-icon"><i class="ph ph-file-doc"></i></div>
                        <div class="menu-text">
                            <h4>Document Audit</h4>
                            <p>Verify Certificates</p>
                        </div>
                    </a>

                    <a href="ViewCases" class="menu-link">
                        <div class="menu-icon"><i class="ph ph-folder-notch"></i></div>
                        <div class="menu-text">
                            <h4>Case Allocation</h4>
                            <p>Assign Matters</p>
                        </div>
                    </a>

                    <a href="asignout.jsp" class="menu-link danger">
                        <div class="menu-icon"><i class="ph ph-sign-out"></i></div>
                        <div class="menu-text">
                            <h4>Terminate Session</h4>
                            <p>Secure Logout</p>
                        </div>
                    </a>
                </div>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
