<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<%
    String username = (String) session.getAttribute("cname");
    
    // Check if the user is authenticated 
    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }
    
    // Default fallback name
    String displayName = username;
    
    // Try to get real name from DB if c_full_name session is missing or just to be safe
    try {
        Connection con = getDatabaseConnection();
        PreparedStatement ps = con.prepareStatement("SELECT name FROM cust_reg WHERE email=?");
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        if(rs.next() && rs.getString("name") != null && !rs.getString("name").isEmpty()) {
            displayName = rs.getString("name");
        }
        rs.close();
        ps.close();
        con.close();
    } catch(Exception e) {
        // Fallback to username 
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <title>Justice4U | Client Conselor (Assigned)</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — CLIENT DASHBOARD (ADMIN ASSIGNED MODE)
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
            line-height:1.1; margin-bottom:5px; color:var(--gold);
        }
        .topbar-left h1 em { font-family:var(--font-sans); font-style:normal; font-weight:500; color:var(--text); letter-spacing:-0.03em;}
        .topbar-left p { color:var(--text-muted); font-size:.95rem; display:flex; align-items:center; gap:6px; font-weight:400;}

        /* WELCOME BANNER FOR ADMIN ASSIGNED */
        .hero-banner {
            background: var(--surface); border: 1px solid var(--border-mid);
            border-radius: 20px; padding: 40px; margin-bottom: 24px;
            display:flex; flex-direction:column; gap:20px; justify-content:center; align-items:flex-start;
            position:relative; overflow:hidden;
        }
        .hero-banner::after {
            content:''; position:absolute; right:0; top:0; bottom:0; width:50%;
            background:linear-gradient(90deg, transparent, var(--gold-light)); opacity:0.3; pointer-events:none;
        }
        .hero-banner h2 { font-size:1.8rem; font-weight:500; font-family:var(--font-serif); color:var(--text); line-height:1.2; z-index:2;}
        .hero-banner p { font-size:1.05rem; color:var(--text-muted); max-width:600px; line-height:1.6; z-index:2; font-weight:400;}
        
        div.hero-actions { display:flex; gap:16px; margin-top:10px; z-index:2;}
        
        .btn {
            display:inline-flex; align-items:center; gap:10px; padding:12px 24px;
            border-radius:10px; font-size:1rem; font-weight:500; text-decoration:none;
            transition:all .2s var(--ease-out); border:none; cursor:pointer; font-family:var(--font-sans);
        }
        .btn-primary { background:var(--text); color:var(--bg); }
        .btn-primary:hover { background:var(--gold-dark); transform:translateY(-2px); }
        .btn-outline { background:transparent; border:1px solid var(--border-mid); color:var(--text); }
        .btn-outline:hover { border-color:var(--text); }

        /* GRID WIDGETS */
        .widget-grid {
            display:grid; grid-template-columns:1fr 1fr; gap:24px;
        }
        
        .widget {
            background:var(--surface); border:1px solid var(--border);
            border-radius:20px; padding:32px;
            display:flex; flex-direction:column; gap:16px;
            transition:border-color .3s;
        }
        .widget:hover { border-color:var(--border-mid); }
        
        .widget-icon {
            width:48px; height:48px; border-radius:14px;
            background:var(--bg2); color:var(--gold); display:flex; align-items:center; justify-content:center;
            font-size:1.6rem; margin-bottom:8px;
        }
        .widget h3 { font-size:1.2rem; font-weight:500; color:var(--text); }
        .widget p { font-size:.95rem; color:var(--text-muted); line-height:1.5; flex:1;}
        .widget a.link { color:var(--gold-dark); font-weight:500; text-decoration:none; display:flex; align-items:center; gap:6px; margin-top:10px;}
        .widget a.link:hover { color:var(--gold); gap:10px; transition:gap .2s; }

        .reveal { opacity:0; transform:translateY(18px); animation:revealUp .6s var(--ease-out) forwards; }
        .r1{animation-delay:.05s}.r2{animation-delay:.12s}.r3{animation-delay:.19s}
        @keyframes revealUp { to{opacity:1;transform:none} }

        @media (max-width: 992px) {
            .sidebar { display:none; }
            .main { padding:24px 20px; }
            .widget-grid { grid-template-columns:1fr; }
        }
    </style>
</head>
<body>
<div class="app">

    <!-- ===== SIDEBAR ===== -->
    <aside class="sidebar" role="navigation">
        <a href="#" class="brand">
            <div class="brand-icon"><i class="ph-light ph-scales"></i></div>
            <span class="brand-name">Justice4U</span>
        </a>

        <div class="nav-section">
            <span class="nav-label">My Workspace</span>
            <a href="customerdashboard.jsp" class="nav-item active"><i class="ph-light ph-squares-four"></i> Console</a>
            <a href="case.jsp" class="nav-item"><i class="ph-light ph-file-plus"></i> Submit Case</a>
            <a href="ClientDashboard" class="nav-item"><i class="ph-light ph-folders"></i> My Cases</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Representation Status</span>
            <!-- BROWSE LAWYERS REMOVED: Since they opted for Admin Assignment -->
            <a href="viewlawdetails.jsp" class="nav-item"><i class="ph-light ph-identification-card"></i> Assigned Lawyer</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Communication</span>
            <a href="viewdisc.jsp" class="nav-item"><i class="ph-light ph-chat-circle-dots"></i> Messages</a>
        </div>

        <div class="sidebar-footer">
            <div class="theme-row">
                <span>Dark mode</span>
                <button class="theme-toggle" id="themeToggle"></button>
            </div>
            <a href="csignout.jsp" class="logout-btn"><i class="ph-light ph-sign-out"></i> Secure Logout</a>
        </div>
    </aside>

    <!-- ===== MAIN ===== -->
    <main class="main" role="main">
        
        <div class="topbar reveal r1">
            <div class="topbar-left">
                <h1>Overview <em>Console</em></h1>
                <p><i class="ph-light ph-user-circle"></i> Logged in securely as <%= com.j4u.Sanitizer.sanitize(displayName) %></p>
            </div>
        </div>

        <!-- REVISED BANNER (ADMIN ASSIGNED MODE) -->
        <div class="hero-banner reveal r2">
            <h2>Welcome to your secure legal portal.</h2>
            <p>You have chosen our premium <strong>Administrative Assignment</strong> workflow. Our system administrators will carefully review any cases you submit and pair you with the most qualified legal counsel for your specific needs.</p>
            <div class="hero-actions">
                <a href="case.jsp" class="btn btn-primary">File a Case <i class="ph-light ph-arrow-right"></i></a>
            </div>
        </div>

        <div class="widget-grid reveal r3">
            
            <div class="widget">
                <div class="widget-icon"><i class="ph-light ph-folders"></i></div>
                <h3>Track Submitted Cases</h3>
                <p>Monitor the status of your reported issues and wait for our administration to assign the appropriate counsel to represent you.</p>
                <a href="ClientDashboard" class="link">View Cases <i class="ph-light ph-arrow-right"></i></a>
            </div>

            <div class="widget">
                <div class="widget-icon" style="color:var(--text);"><i class="ph-light ph-identification-badge"></i></div>
                <h3>Assigned Representation</h3>
                <p>View the professional details, contact information, and credentials of the lawyer our administrators have assigned to your active cases.</p>
                <a href="viewlawdetails.jsp" class="link">Check Advocate <i class="ph-light ph-arrow-right"></i></a>
            </div>

        </div>

    </main>
</div>

<script>
    /* DARK MODE */
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
