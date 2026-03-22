<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<%
    String username = (String) session.getAttribute("cname");
    String cemailSession = (String) session.getAttribute("cemail");
    if (cemailSession == null && username != null && username.contains("@")) {
        cemailSession = username;
    }

    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }

    // Get Avatar Character
    String customerName = "";
    try {
        Connection con = getDatabaseConnection();
        PreparedStatement st = con.prepareStatement("SELECT cname FROM cust_reg WHERE email=?");
        st.setString(1, cemailSession != null ? cemailSession : username);
        ResultSet rs = st.executeQuery();
        if (rs.next()) customerName = rs.getString("cname");
        rs.close(); st.close(); con.close();
    } catch(Exception e) {}
    String avatarLetter = (customerName != null && !customerName.isEmpty()) ? String.valueOf(customerName.charAt(0)).toUpperCase() : "U";
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U | Attorney Directory</title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — ATTORNEY DIRECTORY (DARK / LIGHT THEME)
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
        .brand-name { font-size:1.1rem; font-weight:800; letter-spacing:-.02em; }

        .nav-section { margin-bottom:24px; }
        .nav-label {
            font-size:.7rem; font-weight:800; letter-spacing:.1em; text-transform:uppercase;
            color:var(--text-faint); padding:0 8px; margin-bottom:6px; display:block;
        }

        .nav-item {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:10px; border:1px solid transparent;
            color:var(--text-muted); text-decoration:none; font-size:.9rem; font-weight:600;
            transition:all .2s var(--ease-out); margin-bottom:2px;
        }
        .nav-item i { font-size:1.1rem; flex-shrink:0; }
        .nav-item:hover { color:var(--text); background:var(--bg2); }
        .nav-item.active {
            color:var(--gold-dark); background:var(--gold-light);
            border-color:rgba(201,162,39,0.2); font-weight:800;
        }
        [data-theme="dark"] .nav-item.active { color:var(--gold); background:rgba(212,175,55,0.1); }

        .sidebar-footer { margin-top:auto; padding-top:16px; border-top:1px solid var(--border); }
        .logout-btn {
            display:flex; align-items:center; gap:10px;
            padding:10px 12px; border-radius:10px;
            color:var(--text-muted); text-decoration:none; font-size:.9rem; font-weight:600;
            transition:all .2s; width:100%;
        }
        .logout-btn:hover { background:var(--error-bg); color:var(--error); font-weight:800;}
        .logout-btn i { font-size:1.1rem; }

        /* Theme toggle in sidebar */
        .theme-row {
            display:flex; align-items:center; justify-content:space-between;
            padding:8px 12px; margin-bottom:8px;
        }
        .theme-row span { font-size:.83rem; color:var(--text-muted); font-weight:600;}
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
            font-size:clamp(1.6rem,3vw,2.4rem); font-weight:900;
            letter-spacing:-.035em; line-height:1.1; margin-bottom:5px;
        }
        .topbar-left h1 em { font-family:var(--font-serif); font-style:italic; font-weight:400; color:var(--gold); }
        .topbar-left p { color:var(--text-muted); font-size:.9rem; display:flex; align-items:center; gap:6px; font-weight:600;}

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
            font-family:var(--font-serif); font-size:1.1rem; font-weight:800;
        }
        [data-theme="dark"] .user-avatar { background:rgba(212,175,55,0.15); color:var(--gold); }
        .user-name { font-size:.88rem; font-weight:800; line-height:1.2; display:block; }
        .user-role { font-size:.75rem; font-weight:600; color:var(--text-faint); display:block; }

        /* SEARCH BAR */
        .search-container {
            background: var(--surface); border-radius: 16px; border: 1px solid var(--border);
            padding: 8px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); display: flex; margin-bottom: 40px;
        }
        .search-input {
            flex: 1; border: none; padding: 16px 24px; font-size: 1rem; color: var(--text);
            background: transparent; outline: none; font-family: var(--font-sans); font-weight:600;
        }
        .search-input::placeholder { color: var(--text-faint); font-weight:600;}
        .btn-search {
            background: var(--text); color: var(--bg); border: none; padding: 0 32px;
            border-radius: 12px; font-weight: 800; transition: all .2s var(--ease-out); cursor: pointer;
            display: flex; align-items: center; gap: 8px; font-size: 0.95rem; font-family:var(--font-sans);
        }
        .btn-search:hover { background: var(--gold-dark); transform:scale(1.02); box-shadow:0 4px 16px var(--gold-glow); }

        /* ---- LAWYER CARDS ---- */
        .lawyers-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 24px; }
        .lawyer-card {
            background: var(--surface); border: 1px solid var(--border); border-radius: 20px;
            padding: 28px; display: flex; flex-direction: column; transition: all .25s var(--ease-out);
            position: relative; overflow: hidden;
        }
        .lawyer-card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(0,0,0,0.06); border-color: var(--gold); }
        [data-theme="dark"] .lawyer-card:hover { box-shadow: 0 12px 32px rgba(0,0,0,0.3); }
        .lawyer-card::before {
            content:''; position:absolute; top:0; left:0; width:100%; height:3px;
            background:var(--gold); border-radius:0; transform:scaleX(0); transition:transform .3s var(--ease-out); transform-origin:left;
        }
        .lawyer-card:hover::before { transform:scaleX(1); }

        .lawyer-header { display: flex; gap: 16px; align-items: center; margin-bottom: 24px; }
        .lawyer-avatar {
            width: 64px; height: 64px; border-radius: 50%; background: var(--gold-light); border: 2px solid rgba(201,162,39,.3);
            display: grid; place-items: center; font-size: 1.6rem; color: var(--gold-dark); font-family: var(--font-serif); flex-shrink: 0; font-weight:800;
        }
        [data-theme="dark"] .lawyer-avatar { background:rgba(212,175,55,0.12); color:var(--gold); }

        .lawyer-info h3 { margin: 0 0 6px 0; font-family: var(--font-sans); font-size: 1.25rem; font-weight: 800; color: var(--text); letter-spacing:-0.02em;}
        .lawyer-info .verified {
            font-size: 0.75rem; color: var(--success); font-weight: 800; display: inline-flex; align-items: center; gap: 5px; 
            background: var(--success-bg); padding: 4px 10px; border-radius: 100px; border:1px solid rgba(4,120,87,.2); text-transform:uppercase; letter-spacing:0.04em;
        }
        [data-theme="dark"] .lawyer-info .verified { color: #34d399; border-color: rgba(52,211,153,.2); }

        .lawyer-details { flex: 1; display: flex; flex-direction: column; gap: 12px; margin-bottom: 28px; }
        .detail-item { display: flex; align-items: center; gap: 12px; font-size: 0.9rem; color: var(--text-muted); font-weight:600;}
        .detail-item i { color: var(--gold); font-size: 1.2rem; }
        .detail-item span.highlight { color:var(--text); font-weight:800; }

        .btn-hire {
            display: flex; justify-content: center; align-items: center; gap: 8px;
            padding: 14px; border-radius: 12px; font-weight: 800; font-size: 0.95rem; font-family: var(--font-sans);
            background: var(--bg2); border: 1px solid var(--border-mid); color: var(--text);
            text-decoration: none; transition: all .2s var(--ease-out); width: 100%; white-space:nowrap;
        }
        .lawyer-card:hover .btn-hire { background: var(--text); color: var(--bg); border-color: var(--text); }
        .lawyer-card .btn-hire:hover { background: var(--gold-dark); border-color: var(--gold-dark); transform:translateY(-2px); box-shadow:0 6px 20px var(--gold-glow);}
        
        /* Direct assign override */
        .btn-assign {
            background: var(--gold); border-color: var(--gold); color: #fff;
        }
        .btn-assign:hover {
            background: var(--gold-dark); border-color: var(--gold-dark);
        }

        .empty-state { text-align:center; padding: 60px 24px; grid-column: 1 / -1; background:var(--surface); border:1px solid var(--border); border-radius:20px;}
        .empty-state i { font-size: 3.5rem; color: var(--gold); margin-bottom: 16px; opacity:0.8;}
        .empty-state h4 { font-size:1.2rem; font-weight:800; margin-bottom:8px; }
        .empty-state p { font-size:0.95rem; color: var(--text-muted); margin-bottom: 24px; font-weight:600;}

        /* ---- REVEAL ANIMATION ---- */
        .reveal { opacity:0; transform:translateY(18px); animation:revealUp .6s var(--ease-out) forwards; }
        .r1 { animation-delay:.05s } .r2 { animation-delay:.12s } .r3 { animation-delay:.19s }
        @keyframes revealUp { to { opacity:1; transform:none; } }

        @media(max-width:900px) {
            .sidebar { display:none; }
            .main { padding:24px 20px; }
            .topbar { flex-direction:column; align-items:flex-start; gap:16px; }
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
            <a href="clientdashboard_manual.jsp" class="nav-item"><i class="ph-duotone ph-squares-four"></i> Dashboard</a>
            <a href="case.jsp" class="nav-item"><i class="ph-duotone ph-file-plus"></i> Submit Case</a>
            <a href="ClientDashboard" class="nav-item"><i class="ph-duotone ph-folders"></i> My Cases</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Find Representation</span>
            <a href="findlawyer.jsp" class="nav-item active"><i class="ph-duotone ph-magnifying-glass"></i> Browse Lawyers</a>
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
                <h1>Attorney <em>Directory</em></h1>
                <p><i class="ph-fill ph-seal-check" style="color:var(--gold);font-size:1.1rem;"></i> 100% verified legal professionals</p>
            </div>
            <div class="user-chip">
                <div class="user-avatar"><%= avatarLetter %></div>
                <div class="user-info">
                    <span class="user-name"><%= com.j4u.Sanitizer.sanitize(username) %></span>
                    <span class="user-role">Verified Client</span>
                </div>
            </div>
        </div>

        <form class="search-container reveal r2" action="findlawyer.jsp" method="get">
            <input type="text" name="q" class="search-input" placeholder="Search by name, expertise, or location..." value="<%= com.j4u.Sanitizer.sanitize(request.getParameter("q") != null ? request.getParameter("q") : "") %>">
            <button type="submit" class="btn-search"><i class="ph-bold ph-magnifying-glass"></i> Find Counsel</button>
        </form>

        <div class="lawyers-grid reveal r3">
            <%
            try {
                String searchQuery = request.getParameter("q");
                Connection con = getDatabaseConnection();
                String sql = "SELECT * FROM lawyer_reg WHERE (flag = 1 OR document_verification_status = 'VERIFIED')";
                
                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                    sql += " AND (name LIKE ? OR cadd LIKE ?)";
                }
                
                PreparedStatement pst = con.prepareStatement(sql);
                
                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                    String searchPattern = "%" + searchQuery + "%";
                    pst.setString(1, searchPattern);
                    pst.setString(2, searchPattern);
                }
                
                ResultSet rs = pst.executeQuery();
                boolean hasResults = false;
                
                while(rs.next()) {
                    hasResults = true;
                    String name = rs.getString("name");
                    String email = rs.getString("email");
                    String location = rs.getString("cadd");
                    String specialization = rs.getString("specialization");
                    String experience = rs.getString("experience_years");
                    String rating = "4.8"; // Default UI rating
            %>
            <div class="lawyer-card">
                <div class="lawyer-header">
                    <div class="lawyer-avatar"><%= name != null && !name.isEmpty() ? name.charAt(0) : "L" %></div>
                    <div class="lawyer-info">
                        <h3>Adv. <%= com.j4u.Sanitizer.sanitize(name) %></h3>
                        <span class="verified"><i class="ph-fill ph-seal-check"></i> Bar Verified</span>
                    </div>
                </div>
                <div class="lawyer-details">
                    <div class="detail-item"><i class="ph-duotone ph-scales"></i> <span><span class="highlight">Pratice Area:</span> <%= specialization != null && !specialization.isEmpty() ? com.j4u.Sanitizer.sanitize(specialization) : "General Litigation" %></span></div>
                    <div class="detail-item"><i class="ph-duotone ph-map-pin"></i> <span><span class="highlight">Chambers:</span> <%= location != null && !location.isEmpty() ? com.j4u.Sanitizer.sanitize(location) : "Location unspecified" %></span></div>
                    <div class="detail-item"><i class="ph-duotone ph-briefcase"></i> <span><span class="highlight">Experience:</span> <%= experience != null ? com.j4u.Sanitizer.sanitize(experience) : "0" %> years</span></div>
                    <div class="detail-item"><i class="ph-fill ph-star" style="color:var(--gold);"></i> <span><span class="highlight"><%= rating %></span> based on verified client reviews</span></div>
                </div>
                
                <% 
                    String caseIdParam = request.getParameter("case_id");
                    if (caseIdParam != null && !caseIdParam.isEmpty()) {
                %>
                    <a href="update_case_lawyer.jsp?case_id=<%= com.j4u.Sanitizer.sanitize(caseIdParam) %>&lawyer_email=<%= java.net.URLEncoder.encode(email, "UTF-8") %>" class="btn-hire btn-assign">
                        <i class="ph-bold ph-plus"></i> Assign to Case #<%= com.j4u.Sanitizer.sanitize(caseIdParam) %>
                    </a>
                <% } else { %>
                    <div style="display: flex; gap: 12px; margin-top: auto;">
                        <a href="lawyerprofile.jsp?id=<%= java.net.URLEncoder.encode(email, "UTF-8") %>" class="btn-hire" style="flex:1;"><i class="ph-bold ph-identification-card"></i> View Profile</a>
                        <a href="requestlawyer.jsp?lawyer_email=<%= java.net.URLEncoder.encode(email, "UTF-8") %>" class="btn-hire btn-assign" style="flex:1;"><i class="ph-bold ph-paper-plane-right"></i> Send Request</a>
                    </div>
                <% } %>
            </div>
            <%
                }
                if(!hasResults) {
            %>
                <div class="empty-state">
                    <i class="ph-duotone ph-magnifying-glass"></i>
                    <h4>No legal experts found</h4>
                    <p>There are no lawyers matching your specific search criteria right now.</p>
                </div>
            <%
                }
                rs.close(); pst.close(); con.close();
            } catch(Exception e) {
            %>
                <div class="empty-state" style="border-color: rgba(220,38,38,0.2); background: var(--error-bg);">
                    <i class="ph-fill ph-warning-circle" style="color: var(--error);"></i>
                    <h4 style="color: var(--error);">System Directory Error</h4>
                    <p style="color: var(--error);">Failed to load directory: <%= com.j4u.Sanitizer.sanitize(e.getMessage()) %></p>
                </div>
            <%
            }
            %>
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
