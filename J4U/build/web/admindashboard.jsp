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
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <title>Justice4U | System Administrator</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — ADMIN COMMAND CENTER
           2026 Golden Light Design System
           ===================================================================== */
        :root {
            --bg:           #FDFBF7;
            --bg2:          #F5F2EC;
            --surface:      #FFFFFF;
            --border:       rgba(28,25,23,0.08);
            --border-mid:   rgba(28,25,23,0.14);
            --text:         #1C1917;
            --text-muted:   #57534E;
            --text-faint:   #A8A29E;
            --gold:         #C9A227;
            --gold-light:   #FBF2D8;
            --gold-dark:    #9E7C18;
            --error:        #DC2626;
            --error-bg:     rgba(220,38,38,0.08);
            --success:      #059669;
            --warning:      #D97706;
            --font-sans:    'Switzer', sans-serif;
            --font-serif:   'Instrument Serif', serif;
            --ease-out:     cubic-bezier(0.16,1,0.3,1);
            --sidebar-w:    256px;
        }

        [data-theme="dark"] {
            --bg:           #0F0E0C;
            --bg2:          #161410;
            --surface:      #1A1814;
            --border:       rgba(255,255,255,0.07);
            --border-mid:   rgba(255,255,255,0.12);
            --text:         #F5F2EC;
            --text-muted:   #A8A29E;
            --text-faint:   #57534E;
            --gold:         #D4AF37;
            --gold-light:   rgba(212,175,55,0.12);
            --gold-dark:    #B4901E;
        }

        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        html { scroll-behavior:smooth; }

        body {
            background: var(--bg); color: var(--text);
            font-family: var(--font-sans); line-height:1.6;
            -webkit-font-smoothing: antialiased; font-weight: 400;
            transition: background .4s var(--ease-out), color .4s var(--ease-out);
            min-height: 100svh;
        }

        /* Subtle noise grain setup */
        body::before {
            content:''; position:fixed; inset:0; z-index:9999; pointer-events:none; opacity:.025;
            background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
            background-size:200px;
        }

        /* ---- LAYOUT ---- */
        .app { display:flex; min-height:100svh; }

        .sidebar {
            width: var(--sidebar-w); flex-shrink:0;
            background: var(--surface); border-right:1px solid var(--border);
            display:flex; flex-direction:column;
            position:sticky; top:0; height:100svh;
            padding: 28px 16px; overflow-y:auto;
            z-index: 10;
        }

        .brand {
            display:flex; align-items:center; gap:10px;
            text-decoration:none; color:var(--text);
            padding: 0 8px; margin-bottom:36px;
        }
        .brand-icon {
            width:36px; height:36px; border-radius:10px;
            background:var(--text); display:flex; align-items:center; justify-content:center;
            color:var(--bg); font-size:1.1rem; flex-shrink:0;
        }
        .brand-name { font-size:1.1rem; font-weight:500; letter-spacing:-.02em; }

        .nav-section { margin-bottom:24px; }
        .nav-label {
            font-size:.75rem; font-weight:500; letter-spacing:.05em; text-transform:uppercase;
            color:var(--text-faint); padding:0 8px; margin-bottom:6px; display:block;
        }

        .nav-item {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:10px; border:1px solid transparent;
            color:var(--text-muted); text-decoration:none; font-size:.95rem; font-weight:400;
            transition:all .2s var(--ease-out); margin-bottom:2px;
        }
        .nav-item i { font-size:1.1rem; flex-shrink:0; }
        .nav-item:hover { color:var(--text); background:var(--bg2); }
        .nav-item.active {
            color:var(--gold-dark); background:var(--gold-light);
            border-color:rgba(201,162,39,0.2); font-weight:500;
        }
        [data-theme="dark"] .nav-item.active { color:var(--gold); background:rgba(212,175,55,0.1); }

        .sidebar-footer { margin-top:auto; padding-top:16px; border-top:1px solid var(--border); }
        .logout-btn {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:10px;
            color:var(--text-muted); text-decoration:none; font-size:.95rem; font-weight:400;
            transition:all .2s; width:100%;
        }
        .logout-btn:hover { background:var(--error-bg); color:var(--error); font-weight:500;}

        .theme-row {
            display:flex; align-items:center; justify-content:space-between;
            padding:8px 12px; margin-bottom:8px;
        }
        .theme-row span { font-size:.85rem; color:var(--text-muted); font-weight:400;}
        .theme-toggle {
            width:34px; height:20px; border-radius:10px;
            background:var(--border-mid); border:none; cursor:pointer;
            position:relative; transition:background .2s; flex-shrink:0;
        }
        .theme-toggle.on { background:var(--gold); }
        .theme-toggle::after {
            content:''; position:absolute; top:3px; left:3px;
            width:14px; height:14px; border-radius:50%; background:#fff;
            transition:transform .2s var(--ease-out);
        }
        .theme-toggle.on::after { transform:translateX(14px); }

        /* MAIN AREA */
        .main {
            flex:1; overflow-y:auto;
            padding: 36px 40px; min-width:0;
        }

        /* TOPBAR */
        .topbar {
            display:flex; align-items:center; justify-content:space-between;
            margin-bottom:36px;
        }
        .topbar-left h1 {
            font-size:clamp(1.6rem,3vw,2.4rem); font-weight:400; font-family:var(--font-serif); font-style:italic;
            line-height:1.1; margin-bottom:5px; color:var(--text);
        }
        .topbar-left h1 em { font-family:var(--font-sans); font-style:normal; font-weight:500; color:var(--gold); letter-spacing:-0.03em;}
        .topbar-left p { color:var(--text-muted); font-size:.95rem; display:flex; align-items:center; gap:6px; font-weight:400;}

        /* NOTIFICATION */
        .insight-banner {
            background: var(--gold-light); border: 1px solid rgba(201,162,39,0.2);
            border-left: 4px solid var(--gold); border-radius: 12px;
            padding: 18px 24px; margin-bottom: 32px;
            display: flex; align-items: center; gap: 16px;
        }
        .insight-icon { font-size: 1.6rem; color: var(--gold-dark); }
        .insight-text h4 { margin: 0 0 4px 0; font-size: 1.05rem; font-weight: 500; color: var(--text); }
        .insight-text p { margin: 0; font-size: 0.95rem; color: var(--text-muted); }

        /* METRICS METRIC-GRID */
        .data-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px; margin-bottom: 40px;
        }

        .metric-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 16px; padding: 24px;
            display: flex; flex-direction: column; gap: 12px;
            transition: border-color .3s;
        }
        .metric-card:hover { border-color: var(--border-mid); }
        .metric-header { display: flex; justify-content: space-between; align-items: center; }
        .metric-label { font-size: 0.8rem; color: var(--text-muted); font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em; }
        .metric-icon { color: var(--gold); font-size: 1.4rem; padding: 8px; background: var(--bg2); border-radius: 10px; }
        
        .metric-value { font-size: 2.4rem; font-weight: 400; font-family: var(--font-serif); color: var(--text); line-height: 1; }
        
        .metric-context { font-size: 0.85rem; color: var(--text-faint); display: flex; align-items: center; gap: 6px; }
        .status-good { color: var(--success); }
        .status-warn { color: var(--warning); }

        /* ACTION PANELS GRID */
        .action-layout {
            display: grid; grid-template-columns: 1.5fr 1fr; gap: 24px;
        }
        @media (max-width: 1024px) {
            .action-layout { grid-template-columns: 1fr; }
        }

        .panel {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 20px; overflow: hidden; display: flex; flex-direction: column;
        }
        .panel-head {
            padding: 20px 24px; border-bottom: 1px solid var(--border);
            display: flex; justify-content: space-between; align-items: center;
        }
        .panel-head h3 { font-size: 1.1rem; font-weight: 500; color: var(--text); }
        .action-link { font-size: 0.9rem; color: var(--gold-dark); text-decoration: none; display: flex; align-items: center; gap: 4px; transition: gap .2s; }
        .action-link:hover { gap: 8px; }

        /* LISTS */
        .task-list { padding: 8px; }
        .task-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px; border-bottom: 1px solid var(--bg2);
        }
        .task-item:last-child { border-bottom: none; }
        .task-info h4 { font-size: 1rem; margin: 0 0 2px 0; color: var(--text); font-weight: 500; }
        .task-meta { font-size: 0.9rem; color: var(--text-muted); }
        .btn-verify {
            padding: 8px 16px; background: transparent; border: 1px solid var(--border-mid);
            border-radius: 8px; font-size: 0.9rem; color: var(--text); text-decoration: none;
            transition: all .2s; font-weight: 500;
        }
        .btn-verify:hover { border-color: var(--text); background: var(--text); color: var(--bg); }
        
        .all-clear { padding: 40px; text-align: center; color: var(--text-muted); font-size: 0.95rem; }

        /* QUICK NAV */
        .nav-menu { display: flex; flex-direction: column; }
        .menu-link {
            padding: 16px 24px; display: flex; align-items: center; gap: 16px;
            text-decoration: none; border-bottom: 1px solid var(--bg2); transition: background .2s;
        }
        .menu-link:last-child { border-bottom: none; }
        .menu-link:hover { background: var(--bg2); }
        
        .menu-icon { 
            width: 40px; height: 40px; border-radius: 12px; background: var(--bg); 
            color: var(--text); display: flex; align-items: center; justify-content: center; font-size: 1.2rem;
            border: 1px solid var(--border);
        }
        .menu-text h4 { margin: 0; font-size: 0.95rem; font-weight: 500; color: var(--text); }
        .menu-text p { margin: 0; font-size: 0.85rem; color: var(--text-muted); }

        .reveal { opacity:0; transform:translateY(18px); animation:revealUp .6s var(--ease-out) forwards; }
        .r1{animation-delay:.05s}.r2{animation-delay:.12s}.r3{animation-delay:.19s}
        @keyframes revealUp { to{opacity:1;transform:none} }

    </style>
</head>
<body>
<div class="app">

    <!-- ===== SIDEBAR ===== -->
    <aside class="sidebar" role="navigation">
        <a href="#" class="brand">
            <div class="brand-icon"><i class="ph-light ph-shield-check"></i></div>
            <span class="brand-name">J4U Admin</span>
        </a>

        <div class="nav-section">
            <span class="nav-label">Main</span>
            <a href="AdminDashboard" class="nav-item active"><i class="ph-light ph-squares-four"></i> Dashboard</a>
            <a href="ViewCases" class="nav-item"><i class="ph-light ph-folder-notch"></i> Case Allocations</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Approvals</span>
            <a href="ViewCustomers" class="nav-item"><i class="ph-light ph-users"></i> Pending Clients</a>
            <a href="ViewLawyers" class="nav-item"><i class="ph-light ph-gavel"></i> Lawyer Requests</a>
            <a href="ViewInterns" class="nav-item"><i class="ph-light ph-user-plus"></i> Intern Applications</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Directories</span>
            <a href="viewapprovedlawyers.jsp" class="nav-item"><i class="ph-light ph-scales"></i> Active Lawyers</a>
            <a href="viewapprovedinterns.jsp" class="nav-item"><i class="ph-light ph-graduation-cap"></i> Active Interns</a>
        </div>

        <div class="sidebar-footer">
            <div class="theme-row">
                <span>Dark mode</span>
                <button class="theme-toggle" id="themeToggle"></button>
            </div>
            <a href="asignout.jsp" class="logout-btn"><i class="ph-light ph-sign-out"></i> System Logout</a>
        </div>
    </aside>

    <!-- ===== MAIN ===== -->
    <main class="main" role="main">
        
        <div class="topbar reveal r1">
            <div class="topbar-left">
                <h1>Command <em>Center</em></h1>
                <p><i class="ph-light ph-lock-key secure-lock"></i> Secure System Administrator Session</p>
            </div>
        </div>

        <% if (pendingNotification != null && pendingCustomerName != null) { %>
        <div class="insight-banner reveal r2">
            <i class="ph-light ph-info insight-icon"></i>
            <div class="insight-text">
                <h4>Action Required: New Registration</h4>
                <p>Client <strong><%= pendingCustomerName %></strong> (<%= pendingCustomerEmail %>) is pending administrative verification.</p>
            </div>
        </div>
        <% } %>

        <section class="data-grid reveal r2">
            
            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Total Clients</span>
                    <i class="ph-light ph-users metric-icon"></i>
                </div>
                <div class="metric-value"><%= metrics.containsKey("totalClients") ? metrics.get("totalClients") : "0" %></div>
                <div class="metric-context"><span class="status-good"><i class="ph-bold ph-trend-up"></i></span> Database Active</div>
            </div>

            <div class="metric-card" style="border-color: var(--warning);">
                <div class="metric-header">
                    <span class="metric-label">Verify Queue</span>
                    <i class="ph-light ph-user-check metric-icon" style="color:var(--warning)"></i>
                </div>
                <div class="metric-value"><%= metrics.containsKey("verifyQueue") ? metrics.get("verifyQueue") : "0" %></div>
                <div class="metric-context"><span class="status-warn">Action Required</span></div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Lawyer Requests</span>
                    <i class="ph-light ph-briefcase metric-icon"></i>
                </div>
                <div class="metric-value"><%= metrics.containsKey("lawyerRequests") ? metrics.get("lawyerRequests") : "0" %></div>
                <div class="metric-context">Pending Approval</div>
            </div>

            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label">Pending Matches</span>
                    <i class="ph-light ph-handshake metric-icon"></i>
                </div>
                <div class="metric-value"><%= metrics.containsKey("pendingMatches") ? metrics.get("pendingMatches") : "0" %></div>
                <div class="metric-context">Awaiting Assignment</div>
            </div>

        </section>

        <div class="action-layout reveal r3">
            
            <div class="panel">
                <div class="panel-head">
                    <h3>Priority: Pending Clients</h3>
                    <a href="viewcustomers.jsp" class="action-link">Full Registry <i class="ph-light ph-arrow-right"></i></a>
                </div>
                <div class="task-list">
                    <% if (!pendingClients.isEmpty()) { %>
                        <% for(java.util.Map<String, Object> clientMap : pendingClients) { %>
                            <div class="task-item">
                                <div class="task-info">
                                    <h4><%= clientMap.get("name") %></h4>
                                    <div class="task-meta"><%= clientMap.get("email") %></div>
                                </div>
                                <a href="viewcustomers.jsp" class="btn-verify">Review Profile</a>
                            </div>
                        <% } %>
                    <% } else { %>
                        <div class="all-clear">
                            <i class="ph-light ph-check-circle" style="font-size: 2rem; color: var(--success); margin-bottom: 8px;"></i>
                            <p>Queue Clear. No pending verifications.</p>
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="panel">
                <div class="panel-head">
                    <h3>Sub-Modules</h3>
                </div>
                <div class="nav-menu">
                    <a href="ViewCases" class="menu-link">
                        <div class="menu-icon"><i class="ph-light ph-folder-notch"></i></div>
                        <div class="menu-text">
                            <h4>Case Allocation</h4>
                            <p>Assign legal matters</p>
                        </div>
                    </a>
                    <a href="ViewLawyers" class="menu-link">
                        <div class="menu-icon"><i class="ph-light ph-gavel"></i></div>
                        <div class="menu-text">
                            <h4>Lawyer Approval</h4>
                            <p>Review advocate credentials</p>
                        </div>
                    </a>
                    <a href="ViewInterns" class="menu-link">
                        <div class="menu-icon"><i class="ph-light ph-user-plus"></i></div>
                        <div class="menu-text">
                            <h4>Intern Approval</h4>
                            <p>Verify new student interns</p>
                        </div>
                    </a>
                </div>
            </div>

        </div>
    </main>
</div>

<script>
    /* DARK MODE LOGIC */
    const root = document.documentElement;
    const toggle = document.getElementById('themeToggle');
    const saved = localStorage.getItem('j4u-theme');
    const sys = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const init = saved || (sys ? 'dark' : 'light');
    root.setAttribute('data-theme', init);
    if (init === 'dark') toggle.classList.add('on');

    toggle.addEventListener('click', () => {
        const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        toggle.classList.toggle('on', next === 'dark');
        localStorage.setItem('j4u-theme', next);
    });
</script>
</body>
</html>
