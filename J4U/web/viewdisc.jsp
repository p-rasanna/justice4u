<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<%!
    String safeEncode(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
    }
%>
<%
    String username = (String) session.getAttribute("cname");
    String cemailSession = (String) session.getAttribute("cemail"); 
    if(cemailSession == null && username != null && username.contains("@")) {
        cemailSession = username;
    }
    
    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <title>Justice4U | Discussion Archive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — MESSAGES / DISCUSSIONS ARCHIVE
           Full 2026 design system — dark mode, grain, sidebar, elegant list
           Using light typography weights (400, 500) per user preference
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
            --gold-glow:    rgba(201,162,39,0.15);
            --success:      #047857;
            --success-bg:   rgba(4,120,87,0.07);
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

        body::before {
            content:''; position:fixed; inset:0; z-index:9999; pointer-events:none; opacity:.025;
            background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
            background-size:200px;
        }

        /* ---- LAYOUT & SIDEBAR ---- */
        .app { display:flex; min-height:100svh; }

        .sidebar {
            width: var(--sidebar-w); flex-shrink:0;
            background: var(--surface); border-right:1px solid var(--border);
            display:flex; flex-direction:column;
            position:sticky; top:0; height:100svh;
            padding: 28px 16px; overflow-y:auto;
        }

        .brand {
            display:flex; align-items:center; gap:10px;
            text-decoration:none; color:var(--text);
            padding: 0 8px; margin-bottom:36px;
        }
        .brand-icon {
            width:36px; height:36px; border-radius:10px;
            background:var(--gold); display:flex; align-items:center; justify-content:center;
            color:#fff; font-size:1.1rem; flex-shrink:0;
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

        /* ---- MAIN ---- */
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
            line-height:1.1; margin-bottom:5px; color:var(--gold);
        }
        .topbar-left h1 em { font-family:var(--font-sans); font-style:normal; font-weight:500; color:var(--text); letter-spacing:-0.03em;}
        .topbar-left p { color:var(--text-muted); font-size:.95rem; display:flex; align-items:center; gap:6px; font-weight:400;}

        /* MESSAGES PANEL */
        .panel {
            background: var(--surface); border-radius: 20px; border: 1px solid var(--border); box-shadow: 0 4px 20px rgba(0,0,0,0.02);
            overflow: hidden; margin-bottom: 40px;
        }
        
        .panel-head {
            padding: 24px 32px; border-bottom: 1px solid var(--border-mid);
            background: var(--bg2); display: flex; justify-content: space-between; align-items: center;
        }
        .panel-head h3 {
            font-family: var(--font-sans); font-size: 1.15rem; margin: 0; 
            font-weight: 500; color: var(--text); display: flex; align-items: center; gap: 10px; letter-spacing:-0.01em;
        }
        .panel-icon { color: var(--gold); font-size: 1.4rem; }

        .table-responsive { width: 100%; overflow-x: auto; }
        .table { margin: 0; width: 100%; border-collapse: collapse; text-align: left; }
        .table thead th {
            background: transparent; color: var(--text-faint);
            font-size: 0.8rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
            padding: 20px 32px; border-bottom: 1px solid var(--border);
            font-family: var(--font-sans); white-space: nowrap;
        }
        .table tbody tr { transition: background .2s var(--ease-out); border-bottom: 1px solid var(--border); }
        .table tbody tr:hover { background: var(--bg2); }
        .table tbody tr:last-child { border-bottom:none; }
        
        .table tbody td { padding: 24px 32px; font-size: 0.95rem; color: var(--text); vertical-align: middle; font-weight:400; }

        .col-ref { font-family: 'Courier New', Courier, monospace; color: var(--text-muted); font-size:0.9rem;}
        .col-main { font-weight: 500; color: var(--text); font-size:1rem; }
        
        .date-chip { 
            display:inline-flex; align-items:center; gap:6px; color:var(--text-muted); font-size:0.9rem;
        }
        
        .msg-preview {
            max-width:320px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
            color:var(--text-muted);
        }

        .lawyer-chip {
            background:var(--bg2); border:1px solid var(--border-mid); padding:6px 12px; border-radius:100px;
            font-size:0.85rem; color:var(--text); display:inline-flex; align-items:center; gap:6px; font-weight:500;
        }
        .lawyer-chip i { color:var(--gold); }

        .empty-state { text-align:center; padding: 80px 24px; background:transparent;}
        .empty-state h2 { font-family:var(--font-serif); font-size:2.2rem; font-weight:400; margin-bottom:10px; color:var(--text); }
        .empty-state p { font-size:1rem; color:var(--text-muted); font-weight:400; max-width:400px; margin:0 auto;}
        .empty-icon { font-size:4rem; color:var(--gold); opacity:0.8; margin-bottom:20px; }

        /* ---- REVEAL ANIMATION ---- */
        .reveal { opacity:0; transform:translateY(18px); animation:revealUp .6s var(--ease-out) forwards; }
        .r1 { animation-delay:.05s } .r2 { animation-delay:.12s }
        @keyframes revealUp { to { opacity:1; transform:none; } }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .main { padding: 24px 20px; }
            .topbar { flex-direction:column; align-items:flex-start; gap:16px; margin-bottom:24px; }
        }
    </style>
</head>
<body>
<div class="app">

    <!-- ===== SIDEBAR ===== -->
    <aside class="sidebar" role="navigation" aria-label="Main navigation">
        <a href="Home.html" class="brand">
            <div class="brand-icon"><i class="ph-light ph-scales"></i></div>
            <span class="brand-name">Justice4U</span>
        </a>

        <div class="nav-section">
            <span class="nav-label">My Workspace</span>
            <a href="clientdashboard_manual.jsp" class="nav-item"><i class="ph-light ph-squares-four"></i> Console</a>
            <a href="case.jsp" class="nav-item"><i class="ph-light ph-file-plus"></i> Submit Case</a>
            <a href="ClientDashboard" class="nav-item"><i class="ph-light ph-folders"></i> My Cases</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Find Representation</span>
            <a href="findlawyer.jsp" class="nav-item"><i class="ph-light ph-magnifying-glass"></i> Browse Lawyers</a>
            <a href="viewlawdetails.jsp" class="nav-item"><i class="ph-light ph-identification-card"></i> Assigned Lawyer</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Communication</span>
            <a href="viewdisc.jsp" class="nav-item active"><i class="ph-light ph-chat-circle-dots"></i> Messages</a>
        </div>

        <div class="sidebar-footer">
            <div class="theme-row">
                <span>Dark mode</span>
                <button class="theme-toggle" id="themeToggle" aria-label="Toggle dark mode"></button>
            </div>
            <a href="csignout.jsp" class="logout-btn"><i class="ph-light ph-sign-out"></i> Secure Logout</a>
        </div>
    </aside>

    <!-- ===== MAIN ===== -->
    <main class="main" role="main">
        
        <div class="topbar reveal r1">
            <div class="topbar-left">
                <h1>Communication <em>Archive</em></h1>
                <p>Track, review, and monitor your attorney correspondence and case logs.</p>
            </div>
        </div>

        <div class="panel reveal r2">
            <div class="panel-head">
                <h3><i class="ph-fill ph-chat-circle-text panel-icon"></i> Discussion History</h3>
            </div>
            
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Ref #</th>
                            <th>Subject / Thread</th>
                            <th>Date Logged</th>
                            <th>Message Preview</th>
                            <th>Counsel Contact</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = getDatabaseConnection();
                                
                                PreparedStatement pst = con.prepareStatement("SELECT * FROM discussion WHERE cname=? ORDER BY cdate DESC");
                                pst.setString(1, username);
                                ResultSet rs = pst.executeQuery();
                                boolean hasData = false;
                                
                                while(rs.next()) {
                                    hasData = true;
                                    int id = rs.getInt(1);
                                    String title = safeEncode(rs.getString(2));
                                    String cdate = safeEncode(rs.getString(3));
                                    String desc = safeEncode(rs.getString(4));
                                    String lawyerEmail = safeEncode(rs.getString(6));
                        %>
                        <tr>
                            <td class="col-ref"><%= String.format("%05d", id) %></td>
                            <td class="col-main"><%= title %></td>
                            <td>
                                <span class="date-chip">
                                    <i class="ph-light ph-calendar-blank"></i> <%= cdate %>
                                </span>
                            </td>
                            <td><div class="msg-preview"><%= desc %></div></td>
                            <td>
                                <% if(lawyerEmail != null && !lawyerEmail.isEmpty()) { %>
                                    <span class="lawyer-chip"><i class="ph-fill ph-user-circle"></i> <%= lawyerEmail %></span>
                                <% } else { %>
                                    <span style="color:var(--text-faint);">Unassigned</span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                                if(!hasData) {
                        %>
                                <tr>
                                    <td colspan="5">
                                        <div class="empty-state">
                                            <i class="ph-light ph-envelope-simple-open empty-icon"></i>
                                            <h2>Your inbox is quiet</h2>
                                            <p>No discussion history or attorney logs exist for your account yet. Messages will appear here as your case progresses.</p>
                                        </div>
                                    </td>
                                </tr>
                        <%
                                }
                                rs.close();
                                pst.close();
                                con.close();
                            } catch(Exception e) {
                        %>
                                <tr>
                                    <td colspan="5" style="color:var(--error); text-align:center; padding:40px;">
                                        System error fetching logs: <%= safeEncode(e.getMessage()) %>
                                    </td>
                                </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<script>
    /* DARK MODE LOGIC */
    const root = document.documentElement;
    const toggle = document.getElementById('themeToggle');
    const saved = localStorage.getItem('j4u-theme');
    const sys   = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const init  = saved || (sys ? 'dark' : 'light');
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
