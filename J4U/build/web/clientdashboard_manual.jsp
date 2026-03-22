<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.RBACUtil, java.util.Calendar" %>
<%@ include file="db_connection.jsp" %>
<%
    // ==========================================
    // BACKEND LOGIC (STRICTLY PRESERVED)
    // ==========================================
    String username = (String) session.getAttribute("cname");
    String cemailSession = (String) session.getAttribute("cemail");
    if (cemailSession == null && username != null && username.contains("@")) {
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

    Calendar c = Calendar.getInstance();
    int timeOfDay = c.get(Calendar.HOUR_OF_DAY);
    String greeting = (timeOfDay < 12) ? "Good Morning" : (timeOfDay < 16) ? "Good Afternoon" : (timeOfDay < 21) ? "Good Evening" : "Welcome";

    String customerName    = "";
    String assignedLawyerName  = "";
    String assignedLawyerEmail = "";
    String assignedLawyerPhone = "";
    String caseStatus  = "";
    String caseId      = "";
    String caseTitle   = "";
    String caseCategory= "";
    int    totalCases  = 0;

    boolean isAssigned = false;
    boolean isPending  = false;
    boolean isOpen     = false;
    boolean hasCase    = false;

    try {
        Connection con = getDatabaseConnection();

        // 1. Customer details
        PreparedStatement st = con.prepareStatement("SELECT cname FROM cust_reg WHERE email=?");
        st.setString(1, cemailSession != null ? cemailSession : username);
        ResultSet rs = st.executeQuery();
        if (rs.next()) customerName = rs.getString("cname");

        // 2. Latest case + assigned lawyer
        PreparedStatement caseSt = con.prepareStatement(
            "SELECT c.case_id, c.status, c.title, c.category, l.lname, l.email, l.phone "
          + "FROM customer_cases c "
          + "LEFT JOIN lawyer_reg l ON c.assigned_lawyer_id = l.lid "
          + "WHERE c.customer_id = (SELECT cid FROM cust_reg WHERE email=?) "
          + "ORDER BY c.case_id DESC LIMIT 1"
        );
        caseSt.setString(1, cemailSession != null ? cemailSession : username);
        ResultSet caseRs = caseSt.executeQuery();
        if (caseRs.next()) {
            caseId       = caseRs.getString("case_id");
            caseStatus   = caseRs.getString("status");
            caseTitle    = caseRs.getString("title");
            caseCategory = caseRs.getString("category");
            if (caseStatus == null) caseStatus = "OPEN";
            assignedLawyerName  = caseRs.getString("lname");
            assignedLawyerEmail = caseRs.getString("email");
            assignedLawyerPhone = caseRs.getString("phone");
        } else {
            caseStatus = "No active case";
        }

        // 3. Total cases count
        PreparedStatement countSt = con.prepareStatement(
            "SELECT COUNT(*) FROM customer_cases WHERE customer_id = (SELECT cid FROM cust_reg WHERE email=?)"
        );
        countSt.setString(1, cemailSession != null ? cemailSession : username);
        ResultSet countRs = countSt.executeQuery();
        if (countRs.next()) totalCases = countRs.getInt(1);

        isAssigned = "ASSIGNED".equalsIgnoreCase(caseStatus);
        isPending  = "PENDING_LAWYER_CONFIRMATION".equalsIgnoreCase(caseStatus);
        isOpen     = "OPEN".equalsIgnoreCase(caseStatus);
        hasCase    = (caseId != null && !caseId.isEmpty());

        rs.close(); caseRs.close(); countRs.close();
        st.close(); caseSt.close(); countSt.close();
        con.close();
    } catch (Exception e) {
        caseStatus = "Error: " + e.getMessage();
        e.printStackTrace();
    }

    String avatarLetter = (customerName != null && !customerName.isEmpty()) ? String.valueOf(customerName.charAt(0)).toUpperCase() : "U";
    String lawyerAvatarLetter = (assignedLawyerName != null && !assignedLawyerName.isEmpty()) ? String.valueOf(assignedLawyerName.charAt(0)).toUpperCase() : "?";
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U | My Dashboard</title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — CLIENT DASHBOARD (MANUAL LAWYER SELECTION)
           Full 2026 design system — dark mode, grain, sidebar, reveal
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
            --warning:      #B45309;
            --warning-bg:   rgba(180,83,9,0.07);
            --error:        #DC2626;
            --error-bg:     rgba(220,38,38,0.07);
            --info:         #1D4ED8;
            --info-bg:      rgba(29,78,216,0.07);
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
            --gold-glow:    rgba(212,175,55,0.12);
            --success-bg:   rgba(52,211,153,0.08);
            --warning-bg:   rgba(251,191,36,0.08);
            --error-bg:     rgba(220,38,38,0.08);
            --info-bg:      rgba(96,165,250,0.08);
        }

        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        html { scroll-behavior:smooth; }

        body {
            background: var(--bg); color: var(--text);
            font-family: var(--font-sans); line-height:1.6;
            -webkit-font-smoothing: antialiased;
            transition: background .4s var(--ease-out), color .4s var(--ease-out);
            min-height: 100svh;
        }

        /* Grain overlay */
        body::before {
            content:''; position:fixed; inset:0; z-index:9999; pointer-events:none; opacity:.025;
            background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
            background-size:200px;
        }

        /* ---- LAYOUT ---- */
        .app { display:flex; min-height:100svh; }

        /* ---- SIDEBAR ---- */
        .sidebar {
            width: var(--sidebar-w); flex-shrink:0;
            background: var(--surface); border-right:1px solid var(--border);
            display:flex; flex-direction:column;
            position:sticky; top:0; height:100svh;
            padding: 28px 16px; overflow-y:auto;
            transition: background .4s;
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
        .brand-name { font-size:1.1rem; font-weight:700; letter-spacing:-.02em; }

        .nav-section { margin-bottom:24px; }
        .nav-label {
            font-size:.7rem; font-weight:700; letter-spacing:.1em; text-transform:uppercase;
            color:var(--text-faint); padding:0 8px; margin-bottom:6px; display:block;
        }

        .nav-item {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:10px; border:1px solid transparent;
            color:var(--text-muted); text-decoration:none; font-size:.9rem; font-weight:500;
            transition:all .2s var(--ease-out); margin-bottom:2px;
        }
        .nav-item i { font-size:1.1rem; flex-shrink:0; }
        .nav-item:hover { color:var(--text); background:var(--bg2); }
        .nav-item.active {
            color:var(--gold-dark); background:var(--gold-light);
            border-color:rgba(201,162,39,0.2); font-weight:600;
        }
        [data-theme="dark"] .nav-item.active { color:var(--gold); background:rgba(212,175,55,0.1); }

        .sidebar-footer { margin-top:auto; padding-top:16px; border-top:1px solid var(--border); }
        .logout-btn {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:10px;
            color:var(--text-muted); text-decoration:none; font-size:.9rem; font-weight:500;
            transition:all .2s; width:100%;
        }
        .logout-btn:hover { background:var(--error-bg); color:var(--error); }
        .logout-btn i { font-size:1.1rem; }

        /* Theme toggle in sidebar */
        .theme-row {
            display:flex; align-items:center; justify-content:space-between;
            padding:8px 12px; margin-bottom:8px;
        }
        .theme-row span { font-size:.83rem; color:var(--text-muted); }
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

        /* ---- TOPBAR ---- */
        .topbar {
            display:flex; align-items:center; justify-content:space-between;
            margin-bottom:36px;
        }
        .topbar-left h1 {
            font-size:clamp(1.6rem,3vw,2.4rem); font-weight:800;
            letter-spacing:-.035em; line-height:1.1; margin-bottom:5px;
        }
        .topbar-left h1 em { font-family:var(--font-serif); font-style:italic; font-weight:400; color:var(--gold); }
        .topbar-left p { color:var(--text-muted); font-size:.9rem; display:flex; align-items:center; gap:6px; }

        .user-chip {
            display:flex; align-items:center; gap:10px;
            background:var(--surface); border:1px solid var(--border);
            border-radius:100px; padding:6px 16px 6px 6px;
            box-shadow:0 2px 8px rgba(0,0,0,.04);
        }
        .user-avatar {
            width:36px; height:36px; border-radius:50%;
            background:var(--gold-light); color:var(--gold-dark);
            display:flex; align-items:center; justify-content:center;
            font-family:var(--font-serif); font-size:1.1rem; font-weight:700;
        }
        [data-theme="dark"] .user-avatar { background:rgba(212,175,55,0.15); color:var(--gold); }
        .user-info { display:flex; flex-direction:column; }
        .user-name { font-size:.88rem; font-weight:600; line-height:1.2; }
        .user-role { font-size:.75rem; color:var(--text-faint); }

        /* ---- STAT STRIP ---- */
        .stat-strip {
            display:grid; grid-template-columns:repeat(3,1fr); gap:16px;
            margin-bottom:28px;
        }
        .stat-card {
            background:var(--surface); border:1px solid var(--border);
            border-radius:16px; padding:20px 22px;
            display:flex; align-items:center; gap:14px;
            transition:border-color .3s, transform .3s var(--ease-out);
        }
        .stat-card:hover { border-color:var(--border-mid); transform:translateY(-2px); }
        .stat-icon {
            width:42px; height:42px; border-radius:12px;
            display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0;
        }
        .si-gold  { background:rgba(201,162,39,.1); color:var(--gold-dark); border:1px solid rgba(201,162,39,.2); }
        .si-green { background:var(--success-bg); color:var(--success); border:1px solid rgba(4,120,87,.15); }
        .si-blue  { background:var(--info-bg); color:var(--info); border:1px solid rgba(29,78,216,.15); }
        [data-theme="dark"] .si-green { color:#34d399; border-color:rgba(52,211,153,.2); }
        [data-theme="dark"] .si-blue  { color:#60a5fa; border-color:rgba(96,165,250,.2); }
        .stat-num  { font-size:1.5rem; font-weight:800; letter-spacing:-.03em; line-height:1; }
        .stat-label{ font-size:.8rem; color:var(--text-muted); margin-top:3px; }

        /* ---- SECTION TITLE ---- */
        .section-title {
            font-size:1.05rem; font-weight:700; letter-spacing:-.01em;
            margin-bottom:16px; display:flex; align-items:center; gap:8px;
        }
        .section-title i { color:var(--gold); font-size:1.1rem; }

        /* ---- CASE STATUS HERO ---- */
        .case-hero {
            background:var(--surface); border:1px solid var(--border);
            border-radius:20px; padding:28px 32px; margin-bottom:28px;
            position:relative; overflow:hidden;
        }
        .case-hero::before {
            content:''; position:absolute; top:0; left:0; right:0; height:3px;
            background:var(--gold); border-radius:0;
        }
        .case-hero-inner { display:flex; align-items:center; justify-content:space-between; gap:20px; flex-wrap:wrap; }
        .case-hero-left { display:flex; align-items:center; gap:16px; }
        .case-type-badge {
            width:52px; height:52px; border-radius:14px; flex-shrink:0;
            display:flex; align-items:center; justify-content:center; font-size:1.5rem;
        }
        .case-hero h3 { font-size:1.1rem; font-weight:700; margin-bottom:4px; }
        .case-hero-meta { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .meta-chip {
            display:inline-flex; align-items:center; gap:5px;
            font-size:.75rem; font-weight:600; padding:3px 10px; border-radius:100px;
        }

        /* Status chips */
        .chip-open     { background:var(--info-bg); color:var(--info); border:1px solid rgba(29,78,216,.15); }
        .chip-pending  { background:var(--warning-bg); color:var(--warning); border:1px solid rgba(180,83,9,.15); }
        .chip-assigned { background:var(--success-bg); color:var(--success); border:1px solid rgba(4,120,87,.15); }
        .chip-none     { background:var(--bg2); color:var(--text-faint); border:1px solid var(--border); }
        [data-theme="dark"] .chip-open    { color:#60a5fa; }
        [data-theme="dark"] .chip-pending { color:#fbbf24; }
        [data-theme="dark"] .chip-assigned{ color:#34d399; }

        /* ---- GRID AREA ---- */
        .content-grid {
            display:grid; grid-template-columns:1fr 360px; gap:20px; align-items:start;
        }

        /* ---- LAWYER CARD ---- */
        .lawyer-card {
            background:var(--surface); border:1px solid var(--border);
            border-radius:20px; padding:28px;
        }
        .lawyer-avatar-ring {
            width:68px; height:68px; border-radius:50%;
            background:var(--gold-light); color:var(--gold-dark);
            display:flex; align-items:center; justify-content:center;
            font-family:var(--font-serif); font-size:1.8rem; font-weight:700;
            border:2px solid rgba(201,162,39,0.25); margin-bottom:14px;
        }
        [data-theme="dark"] .lawyer-avatar-ring { background:rgba(212,175,55,0.12); color:var(--gold); }
        .lawyer-name { font-size:1.15rem; font-weight:700; letter-spacing:-.02em; margin-bottom:4px; }
        .lawyer-verified {
            display:inline-flex; align-items:center; gap:5px;
            font-size:.78rem; font-weight:600; color:var(--success);
            background:var(--success-bg); padding:3px 10px; border-radius:100px;
            border:1px solid rgba(4,120,87,.15); margin-bottom:18px;
        }
        [data-theme="dark"] .lawyer-verified { color:#34d399; }

        .lawyer-contacts { display:flex; flex-direction:column; gap:8px; margin-bottom:22px; }
        .contact-row {
            display:flex; align-items:center; gap:8px;
            font-size:.85rem; color:var(--text-muted);
        }
        .contact-row i { color:var(--gold); font-size:.95rem; flex-shrink:0; }

        .btn-primary {
            display:inline-flex; align-items:center; justify-content:center; gap:8px;
            background:var(--text); color:var(--bg);
            padding:12px 20px; border-radius:11px; border:none; cursor:pointer;
            font-family:var(--font-sans); font-size:.9rem; font-weight:700;
            text-decoration:none; transition:all .25s var(--ease-out); width:100%;
        }
        .btn-primary:hover { background:var(--gold-dark); transform:translateY(-2px); box-shadow:0 6px 20px var(--gold-glow); }
        .btn-secondary {
            display:inline-flex; align-items:center; justify-content:center; gap:8px;
            background:transparent; color:var(--text-muted);
            padding:10px 20px; border-radius:11px; border:1px solid var(--border-mid); cursor:pointer;
            font-family:var(--font-sans); font-size:.88rem; font-weight:600;
            text-decoration:none; transition:all .2s; width:100%; margin-top:8px;
        }
        .btn-secondary:hover { border-color:var(--text); color:var(--text); background:var(--bg2); }

        /* ---- EMPTY STATE ---- */
        .empty-state {
            text-align:center; padding:40px 24px;
        }
        .empty-icon {
            width:64px; height:64px; border-radius:18px; margin:0 auto 18px;
            display:flex; align-items:center; justify-content:center; font-size:1.8rem;
        }
        .empty-state h4 { font-size:1.05rem; font-weight:700; margin-bottom:8px; }
        .empty-state p { font-size:.88rem; color:var(--text-muted); margin-bottom:22px; line-height:1.6; }

        /* ---- QUICK ACTIONS ---- */
        .actions-col { display:flex; flex-direction:column; gap:12px; }
        .action-card {
            background:var(--surface); border:1px solid var(--border);
            border-radius:16px; padding:18px 20px;
            display:flex; align-items:center; gap:14px;
            text-decoration:none; color:inherit;
            transition:all .25s var(--ease-out);
        }
        .action-card:hover { border-color:var(--gold); transform:translateY(-2px); box-shadow:0 8px 24px rgba(0,0,0,.05); }
        [data-theme="dark"] .action-card:hover { box-shadow:0 8px 24px rgba(0,0,0,.25); }
        .action-icon {
            width:44px; height:44px; border-radius:12px; flex-shrink:0;
            display:flex; align-items:center; justify-content:center; font-size:1.2rem;
            transition:all .2s var(--ease-out);
        }
        .action-card:hover .action-icon { background:var(--gold)!important; color:#fff!important; }
        .action-text strong { font-size:.92rem; font-weight:700; display:block; margin-bottom:2px; }
        .action-text span   { font-size:.8rem; color:var(--text-muted); }
        .action-arrow { margin-left:auto; color:var(--text-faint); font-size:1rem; transition:transform .2s; }
        .action-card:hover .action-arrow { transform:translateX(3px); color:var(--text); }

        /* ---- STEP GUIDE (for no-case state) ---- */
        .step-guide {
            background:var(--surface); border:1px solid var(--border);
            border-radius:20px; padding:28px 32px; margin-bottom:28px;
        }
        .step-list { display:flex; flex-direction:column; gap:0; }
        .step-item {
            display:flex; gap:16px; padding:16px 0;
            border-bottom:1px solid var(--border);
        }
        .step-item:last-child { border-bottom:none; padding-bottom:0; }
        .step-num {
            width:32px; height:32px; border-radius:50%; flex-shrink:0;
            background:var(--gold-light); color:var(--gold-dark);
            display:flex; align-items:center; justify-content:center;
            font-size:.85rem; font-weight:700; margin-top:2px;
            border:1px solid rgba(201,162,39,0.25);
        }
        [data-theme="dark"] .step-num { background:rgba(212,175,55,0.1); color:var(--gold); }
        .step-body strong { font-size:.92rem; font-weight:700; display:block; margin-bottom:3px; }
        .step-body span   { font-size:.83rem; color:var(--text-muted); line-height:1.5; }

        /* ---- REVEAL ANIMATION ---- */
        .reveal { opacity:0; transform:translateY(18px); animation:revealUp .6s var(--ease-out) forwards; }
        .r1 { animation-delay:.05s } .r2 { animation-delay:.12s } .r3 { animation-delay:.19s } .r4 { animation-delay:.26s }
        @keyframes revealUp { to { opacity:1; transform:none; } }
        @media(prefers-reduced-motion:reduce){ .reveal { animation:none; opacity:1; transform:none; } }

        /* ---- RESPONSIVE ---- */
        @media(max-width:900px) {
            .sidebar { display:none; }
            .main { padding:24px 20px; }
            .content-grid { grid-template-columns:1fr; }
            .stat-strip { grid-template-columns:1fr 1fr; }
            .topbar { flex-direction:column; align-items:flex-start; gap:16px; }
        }
        @media(max-width:480px) {
            .stat-strip { grid-template-columns:1fr; }
        }
    </style>
</head>
<body>
<div class="app">

    <!-- ===== SIDEBAR ===== -->
    <aside class="sidebar" role="navigation" aria-label="Main navigation">
        <a href="Home.html" class="brand">
            <div class="brand-icon"><i class="ph-fill ph-scales"></i></div>
            <span class="brand-name">Justice4U</span>
        </a>

        <div class="nav-section">
            <span class="nav-label">My Workspace</span>
            <a href="#" class="nav-item active"><i class="ph-duotone ph-squares-four"></i> Dashboard</a>
            <a href="case.jsp" class="nav-item"><i class="ph-duotone ph-file-plus"></i> Submit Case</a>
            <a href="ClientDashboard" class="nav-item"><i class="ph-duotone ph-folders"></i> My Cases</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Find Representation</span>
            <a href="findlawyer.jsp" class="nav-item"><i class="ph-duotone ph-magnifying-glass"></i> Browse Lawyers</a>
            <a href="viewlawdetails.jsp" class="nav-item"><i class="ph-duotone ph-identification-card"></i> My Lawyer</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Communication</span>
            <a href="viewdisc.jsp" class="nav-item"><i class="ph-duotone ph-chat-circle-dots"></i> Messages</a>
        </div>

        <div class="sidebar-footer">
            <div class="theme-row">
                <span>Dark mode</span>
                <button class="theme-toggle" id="themeToggle" aria-label="Toggle dark mode"></button>
            </div>
            <a href="csignout.jsp" class="logout-btn"><i class="ph-duotone ph-sign-out"></i> Secure Logout</a>
        </div>
    </aside>

    <!-- ===== MAIN ===== -->
    <main class="main" role="main">

        <!-- TOPBAR -->
        <div class="topbar reveal r1">
            <div class="topbar-left">
                <h1><%= greeting %>, <em><%= com.j4u.Sanitizer.sanitize(customerName.isEmpty() ? username : customerName) %></em></h1>
                <p><i class="ph-fill ph-shield-check" style="color:var(--success);font-size:.95rem;"></i> You're in your secure client workspace</p>
            </div>
            <div class="user-chip">
                <div class="user-avatar"><%= avatarLetter %></div>
                <div class="user-info">
                    <span class="user-name"><%= com.j4u.Sanitizer.sanitize(username) %></span>
                    <span class="user-role">Self-select client</span>
                </div>
            </div>
        </div>

        <!-- STAT STRIP -->
        <div class="stat-strip reveal r2">
            <div class="stat-card">
                <div class="stat-icon si-gold"><i class="ph-fill ph-folders"></i></div>
                <div>
                    <div class="stat-num"><%= totalCases %></div>
                    <div class="stat-label">Total cases filed</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon si-green"><i class="ph-fill ph-user-check"></i></div>
                <div>
                    <div class="stat-num"><%= isAssigned ? "1" : "0" %></div>
                    <div class="stat-label">Active lawyers</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon si-blue"><i class="ph-fill ph-chat-circle-dots"></i></div>
                <div>
                    <div class="stat-num"><i class="ph-fill ph-circle" style="font-size:.5rem;color:var(--success);"></i></div>
                    <div class="stat-label">Portal secure</div>
                </div>
            </div>
        </div>

        <!-- CASE STATUS HERO -->
        <% if (hasCase) { %>
        <div class="case-hero reveal r2">
            <div class="case-hero-inner">
                <div class="case-hero-left">
                    <div class="case-type-badge si-gold" style="border-radius:14px; width:52px; height:52px; display:flex; align-items:center; justify-content:center; font-size:1.4rem;">
                        <i class="ph-duotone ph-briefcase"></i>
                    </div>
                    <div>
                        <h3><%= (caseTitle != null && !caseTitle.isEmpty()) ? com.j4u.Sanitizer.sanitize(caseTitle) : "Case #" + caseId %></h3>
                        <div class="case-hero-meta">
                            <span class="meta-chip
                                <% if(isAssigned){ %>chip-assigned<% } else if(isPending){ %>chip-pending<% } else if(isOpen){ %>chip-open<% } else { %>chip-none<% } %>">
                                <i class="ph-fill ph-circle" style="font-size:.45rem;"></i>
                                <%= caseStatus.replace("_", " ") %>
                            </span>
                            <% if(caseCategory != null && !caseCategory.isEmpty()){ %>
                            <span class="meta-chip chip-none"><i class="ph ph-tag"></i> <%= com.j4u.Sanitizer.sanitize(caseCategory) %></span>
                            <% } %>
                            <span class="meta-chip chip-none"><i class="ph ph-hash"></i> Case <%= caseId %></span>
                        </div>
                    </div>
                </div>
                <a href="ClientDashboard" style="display:inline-flex; align-items:center; gap:6px; font-size:.85rem; font-weight:600; color:var(--text-muted); text-decoration:none; white-space:nowrap;">
                    View all cases <i class="ph-bold ph-arrow-right"></i>
                </a>
            </div>
        </div>
        <% } %>

        <!-- MAIN CONTENT GRID -->
        <div class="content-grid reveal r3">

            <!-- LEFT: LAWYER PANEL -->
            <div>
                <div class="section-title"><i class="ph-fill ph-gavel"></i> Your legal counsel</div>

                <div class="lawyer-card">
                    <% if (isAssigned && assignedLawyerName != null && !assignedLawyerName.isEmpty()) { %>
                        <!-- ASSIGNED STATE -->
                        <div class="lawyer-avatar-ring"><%= lawyerAvatarLetter %></div>
                        <div class="lawyer-name">Adv. <%= com.j4u.Sanitizer.sanitize(assignedLawyerName) %></div>
                        <div class="lawyer-verified"><i class="ph-fill ph-seal-check"></i> Verified Attorney</div>

                        <div class="lawyer-contacts">
                            <% if(assignedLawyerEmail != null && !assignedLawyerEmail.isEmpty()){ %>
                            <div class="contact-row"><i class="ph ph-envelope"></i> <%= com.j4u.Sanitizer.sanitize(assignedLawyerEmail) %></div>
                            <% } %>
                            <% if(assignedLawyerPhone != null && !assignedLawyerPhone.isEmpty()){ %>
                            <div class="contact-row"><i class="ph ph-phone"></i> <%= com.j4u.Sanitizer.sanitize(assignedLawyerPhone) %></div>
                            <% } %>
                        </div>

                        <a href="client_chat.jsp?case_id=<%= caseId %>" class="btn-primary">
                            <i class="ph-bold ph-chat-text"></i> Open Secure Chat
                        </a>
                        <a href="viewlawdetails.jsp?id=<%= assignedLawyerEmail %>" class="btn-secondary">
                            <i class="ph ph-identification-card"></i> View Full Profile
                        </a>

                    <% } else if (isPending) { %>
                        <!-- PENDING STATE -->
                        <div class="empty-state">
                            <div class="empty-icon si-gold" style="border-radius:18px;">
                                <i class="ph-duotone ph-hourglass-medium"></i>
                            </div>
                            <h4>Awaiting lawyer response</h4>
                            <p>
                                <% if(assignedLawyerName != null && !assignedLawyerName.isEmpty()){ %>
                                    <strong><%= com.j4u.Sanitizer.sanitize(assignedLawyerName) %></strong> has received your inquiry and will respond shortly.
                                <% } else { %>
                                    Your request has been sent. The lawyer will respond shortly.
                                <% } %>
                            </p>
                            <span class="meta-chip chip-pending" style="margin-bottom:16px; display:inline-flex;">
                                <i class="ph-fill ph-circle" style="font-size:.45rem;"></i> Decision Pending
                            </span>
                            <br>
                            <a href="findlawyer.jsp" class="btn-secondary" style="width:auto; display:inline-flex; margin-top:8px;">
                                <i class="ph ph-magnifying-glass"></i> Browse other lawyers
                            </a>
                        </div>

                    <% } else if (hasCase) { %>
                        <!-- HAS CASE, NO LAWYER YET -->
                        <div class="empty-state">
                            <div class="empty-icon" style="background:rgba(201,162,39,.1); color:var(--gold-dark); border-radius:18px;">
                                <i class="ph-duotone ph-magnifying-glass"></i>
                            </div>
                            <h4>No lawyer selected yet</h4>
                            <p>You have an open case. Browse our verified directory and select the right attorney for your situation.</p>
                            <a href="findlawyer.jsp?case_id=<%= caseId %>" class="btn-primary" style="max-width:260px; margin:0 auto;">
                                <i class="ph-bold ph-users"></i> Browse Lawyers Now
                            </a>
                        </div>

                    <% } else { %>
                        <!-- NO CASE YET -->
                        <div class="empty-state">
                            <div class="empty-icon" style="background:var(--bg2); color:var(--text-faint); border-radius:18px;">
                                <i class="ph-duotone ph-file-dashed"></i>
                            </div>
                            <h4>No active case</h4>
                            <p>File a case first, then browse our verified directory to pick the right lawyer for your needs.</p>
                            <a href="case.jsp" class="btn-primary" style="max-width:240px; margin:0 auto;">
                                <i class="ph-bold ph-file-plus"></i> Submit Your Case
                            </a>
                        </div>
                    <% } %>
                </div>

                <!-- HOW IT WORKS (only shown when no case yet) -->
                <% if (!hasCase) { %>
                <div style="margin-top:20px;">
                    <div class="section-title"><i class="ph-fill ph-list-numbers"></i> How self-select works</div>
                    <div class="step-guide">
                        <div class="step-list">
                            <div class="step-item">
                                <div class="step-num">1</div>
                                <div class="step-body">
                                    <strong>Submit your case</strong>
                                    <span>Describe your legal situation securely. It stays private until you choose a lawyer.</span>
                                </div>
                            </div>
                            <div class="step-item">
                                <div class="step-num">2</div>
                                <div class="step-body">
                                    <strong>Browse the directory</strong>
                                    <span>Filter verified attorneys by practice area, experience, and location.</span>
                                </div>
                            </div>
                            <div class="step-item">
                                <div class="step-num">3</div>
                                <div class="step-body">
                                    <strong>Send a request</strong>
                                    <span>Select a lawyer and send them your case. They'll accept or decline within 24 hours.</span>
                                </div>
                            </div>
                            <div class="step-item">
                                <div class="step-num">4</div>
                                <div class="step-body">
                                    <strong>Connect &amp; resolve</strong>
                                    <span>Once accepted, use the secure portal to chat, share documents, and track progress.</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- RIGHT: QUICK ACTIONS -->
            <div class="actions-col">
                <div class="section-title"><i class="ph-fill ph-lightning"></i> Quick actions</div>

                <a href="case.jsp" class="action-card">
                    <div class="action-icon si-gold"><i class="ph-duotone ph-file-plus"></i></div>
                    <div class="action-text">
                        <strong>Submit a Case</strong>
                        <span>File a new legal matter</span>
                    </div>
                    <i class="ph-bold ph-arrow-right action-arrow"></i>
                </a>

                <a href="findlawyer.jsp<%= hasCase ? "?case_id=" + caseId : "" %>" class="action-card">
                    <div class="action-icon si-green"><i class="ph-duotone ph-users-three"></i></div>
                    <div class="action-text">
                        <strong>Browse Lawyers</strong>
                        <span>Search the verified directory</span>
                    </div>
                    <i class="ph-bold ph-arrow-right action-arrow"></i>
                </a>

                <a href="ClientDashboard" class="action-card">
                    <div class="action-icon si-blue"><i class="ph-duotone ph-folders"></i></div>
                    <div class="action-text">
                        <strong>My Cases</strong>
                        <span>View all filed cases</span>
                    </div>
                    <i class="ph-bold ph-arrow-right action-arrow"></i>
                </a>

                <a href="viewdisc.jsp" class="action-card">
                    <div class="action-icon" style="background:rgba(139,92,246,.08); color:#6d28d9; border:1px solid rgba(109,40,217,.12);">
                        <i class="ph-duotone ph-chat-circle-dots"></i>
                    </div>
                    <div class="action-text">
                        <strong>Messages</strong>
                        <span>View past communications</span>
                    </div>
                    <i class="ph-bold ph-arrow-right action-arrow"></i>
                </a>

                <!-- Tip card -->
                <div style="background:var(--gold-light); border:1px solid rgba(201,162,39,0.25); border-radius:16px; padding:18px 20px; margin-top:4px;">
                    <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">
                        <i class="ph-fill ph-lightbulb" style="color:var(--gold-dark); font-size:1rem;"></i>
                        <span style="font-size:.78rem; font-weight:700; color:var(--gold-dark); text-transform:uppercase; letter-spacing:.06em;">Tip</span>
                    </div>
                    <p style="font-size:.83rem; color:var(--gold-dark); line-height:1.6; margin:0;">
                        <% if (!hasCase) { %>
                            File your case before browsing lawyers — it lets you send your case directly when you find the right attorney.
                        <% } else if (isPending) { %>
                            While waiting, feel free to browse other lawyers as a backup option.
                        <% } else if (isAssigned) { %>
                            Keep your case documents ready. Your lawyer may request them through the secure chat.
                        <% } else { %>
                            Use the practice area filter in the directory to find specialists matched to your case type.
                        <% } %>
                    </p>
                </div>

            </div>
        </div>

    </main>
</div>

<script>
    /* DARK MODE */
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
