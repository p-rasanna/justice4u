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
    
    // Allow public or client viewing of profiles, so no strict redirect if not logged in
    boolean isLoggedIn = (username != null);
    
    String lawyerEmail = request.getParameter("id");
    if(lawyerEmail == null || lawyerEmail.isEmpty()) {
        response.sendRedirect("findlawyer.jsp");
        return;
    }

    String name = "Legal Professional";
    String spec = "General Practice";
    String exp = "0";
    String loc = "Location unspecified";
    String bar = "Not Provided";
    String about = "";
    
    try(Connection con = getDatabaseConnection();
        PreparedStatement ps = con.prepareStatement("SELECT * FROM lawyer_reg WHERE email=?")) {
        ps.setString(1, lawyerEmail);
        try(ResultSet rs = ps.executeQuery()) {
            if(rs.next()) {
                name = rs.getString("name");
                if (name == null || name.isEmpty()) name = rs.getString("fname") + " " + rs.getString("lname");
                spec = rs.getString("specialization");
                loc = rs.getString("cadd");
                bar = rs.getString("bar_council_number");
                exp = rs.getString("experience_years");
                
                String sanitizeLoc = loc != null && !loc.isEmpty() ? loc : "the region";
                String sanitizeSpec = spec != null && !spec.isEmpty() ? spec : "various practice areas";
                about = name + " is a highly dedicated independent legal professional practicing out of " + sanitizeLoc + 
                        ". With significant focus across " + sanitizeSpec + ", they guarantee personalized, confidential, and comprehensive legal solutions tailored to each client's specific demands.";
            } else {
                 response.sendRedirect("findlawyer.jsp?error=Lawyer not found");
                 return;
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U | Advocate <%= safeEncode(name) %></title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — LAWYER PUBLIC DIRECTORY PROFILE (NO BOLD WEIGHTS)
           Full 2026 design system — dark mode, grain, sidebar, reveal
           Matches viewlawdetails.jsp logic perfectly using max font-weight 500
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
            --success-bg:   rgba(52,211,153,0.08);
        }

        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        html { scroll-behavior:smooth; }

        body {
            background: var(--bg); color: var(--text);
            font-family: var(--font-sans); line-height:1.6;
            -webkit-font-smoothing: antialiased; font-weight: 400; /* No bold */
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

        /* PROFILE CARD STRUCTURE */
        .profile-card {
            background: var(--surface); border-radius: 20px; border: 1px solid var(--border); box-shadow: 0 4px 20px rgba(0,0,0,0.02);
            overflow: hidden; margin-bottom: 40px;
        }

        .profile-header {
            position: relative; background: var(--bg2); padding: 40px; border-bottom: 1px solid var(--border-mid);
            display: flex; align-items: flex-end; gap: 32px;
        }

        .avatar-wrapper { position: relative; flex-shrink: 0; }
        .avatar {
            width: 120px; height: 120px; border-radius: 50%; border: 4px solid var(--surface); box-shadow: 0 10px 20px rgba(0,0,0,0.03);
            display: grid; place-items: center; background: var(--gold-light); color: var(--gold-dark); font-size: 2.8rem; font-family: var(--font-serif); font-weight: 400;
        }
        [data-theme="dark"] .avatar { background: rgba(212,175,55,0.12); color: var(--gold); border-color: var(--surface); }
        
        .verified-tick {
            position: absolute; bottom: 4px; right: 4px; background: var(--success); color: white; width: 32px; height: 32px;
            border-radius: 50%; display: grid; place-items: center; border: 3px solid var(--surface); font-size: 1.1rem;
        }
        [data-theme="dark"] .verified-tick { background: #34d399; color: var(--surface); }

        .header-info h2 { font-family: var(--font-serif); font-size: 2.4rem; font-weight: 400; margin: 0 0 12px 0; color: var(--text); }
        
        .designation-badge {
            background: var(--surface); padding: 6px 16px; border-radius: 100px; font-size: 0.9rem; border: 1px solid var(--border); color: var(--text-muted); font-weight: 400; display:inline-flex; align-items:center; gap:6px;
        }
        .designation-badge i { color:var(--gold); }
        
        .verified-badge {
            background: var(--success-bg); padding: 6px 16px; border-radius: 100px; font-size: 0.9rem; border: 1px solid rgba(4,120,87,.2); color: var(--success); font-weight: 500; display:inline-flex; align-items:center; gap:6px;
        }
        [data-theme="dark"] .verified-badge { color: #34d399; border-color: rgba(52,211,153,.2); }

        /* CONTENT GRID */
        .content-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 40px; padding: 40px; }

        .section-title { font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-faint); margin-bottom: 20px; font-weight: 500; border-bottom:1px solid var(--border); padding-bottom:10px;}

        .info-group { margin-bottom: 32px; }
        .info-value { font-size: 1.05rem; color: var(--text); line-height: 1.6; font-weight:400; display:flex; gap:10px; align-items:flex-start;}

        .pill-container { display: flex; flex-wrap: wrap; gap: 10px; }
        .pill { background: var(--bg2); color: var(--text); padding: 10px 18px; border-radius: 12px; font-size: 0.95rem; border: 1px solid var(--border); font-weight: 400; }

        .about-text { font-size:1.05rem; color:var(--text-muted); font-weight:400; line-height:1.7; display:block;}

        /* SIDEBAR ACTIONS IN PROFILE */
        .sidebar-actions { background: var(--bg2); padding: 32px; border-radius: 16px; height: fit-content; border: 1px solid var(--border-mid); }

        .action-btn {
            display: flex; align-items: center; justify-content: center; gap: 10px; width: 100%; padding: 16px;
            border: none; border-radius: 12px; font-weight: 500; cursor: pointer; text-decoration: none; transition: all .2s; margin-bottom: 16px; font-size: 1rem; font-family: var(--font-sans);
        }
        .btn-primary-action { background: var(--text); color: var(--bg); }
        .btn-primary-action:hover { background: var(--gold-dark); transform: translateY(-2px); box-shadow:0 4px 12px var(--gold-glow); }
        .btn-secondary-action { background: var(--surface); color: var(--text); border:1px solid var(--border-mid); }
        .btn-secondary-action:hover { border-color:var(--text); }

        .stat-row { display: flex; justify-content: space-between; padding: 16px 0; border-bottom: 1px dashed var(--border); font-size: 0.95rem; font-weight:400;}
        .stat-row:last-child { border: none; padding-bottom:0;}
        .stat-label { color: var(--text-muted); }
        .stat-val { font-weight: 500; color: var(--text); }

        .stars { display:inline-flex; gap:2px; color:var(--gold); font-size:1rem;}
        
        /* ---- REVEAL ANIMATION ---- */
        .reveal { opacity:0; transform:translateY(18px); animation:revealUp .6s var(--ease-out) forwards; }
        .r1 { animation-delay:.05s } .r2 { animation-delay:.12s } .r3 { animation-delay:.19s }
        @keyframes revealUp { to { opacity:1; transform:none; } }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .content-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .profile-header { flex-direction: column; align-items: flex-start; padding: 24px; }
            .content-grid { padding: 24px; gap: 24px; }
            .avatar { width: 100px; height: 100px; font-size:2.2rem;}
            .header-info h2 { font-size: 2rem; }
            .sidebar-actions { order: -1; margin-bottom: 24px; }
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

        <% if(isLoggedIn) { %>
        <div class="nav-section">
            <span class="nav-label">My Workspace</span>
            <a href="clientdashboard_manual.jsp" class="nav-item"><i class="ph-light ph-squares-four"></i> Console</a>
            <a href="case.jsp" class="nav-item"><i class="ph-light ph-file-plus"></i> Submit Case</a>
            <a href="ClientDashboard" class="nav-item"><i class="ph-light ph-folders"></i> My Cases</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Find Representation</span>
            <a href="findlawyer.jsp" class="nav-item active"><i class="ph-light ph-magnifying-glass"></i> Browse Lawyers</a>
            <a href="viewlawdetails.jsp" class="nav-item"><i class="ph-light ph-identification-card"></i> Assigned Lawyer</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Communication</span>
            <a href="viewdisc.jsp" class="nav-item"><i class="ph-light ph-chat-circle-dots"></i> Messages</a>
        </div>
        
        <div class="sidebar-footer">
            <div class="theme-row">
                <span>Dark mode</span>
                <button class="theme-toggle" id="themeToggle" aria-label="Toggle dark mode"></button>
            </div>
            <a href="csignout.jsp" class="logout-btn"><i class="ph-light ph-sign-out"></i> Secure Logout</a>
        </div>
        <% } else { %>
        <div class="nav-section">
            <span class="nav-label">Public Access</span>
            <a href="Home.html" class="nav-item"><i class="ph-light ph-house"></i> Home</a>
            <a href="findlawyer.jsp" class="nav-item active"><i class="ph-light ph-magnifying-glass"></i> Directory</a>
        </div>
        <div class="sidebar-footer">
            <div class="theme-row">
                <span>Dark mode</span>
                <button class="theme-toggle" id="themeToggle" aria-label="Toggle dark mode"></button>
            </div>
            <a href="cust_login.html" class="logout-btn"><i class="ph-light ph-sign-in"></i> Client Login</a>
        </div>
        <% } %>
    </aside>

    <!-- ===== MAIN ===== -->
    <main class="main" role="main">
        
        <div style="margin-bottom: 24px;" class="reveal r1">
            <a href="findlawyer.jsp" style="text-decoration: none; color: var(--text-muted); font-size: 0.95rem; display: inline-flex; align-items: center; gap: 6px; font-weight: 400; transition: color .2s;">
                <i class="ph-light ph-arrow-left"></i> Return to Directory
            </a>
        </div>

        <div class="profile-card reveal r2">
            
            <!-- HEADER -->
            <div class="profile-header">
                <div class="avatar-wrapper">
                    <div class="avatar">
                        <%= name.isEmpty() ? "?" : name.charAt(0) %>
                    </div>
                </div>
                
                <div class="header-info">
                    <h2>Adv. <%= safeEncode(name) %></h2>
                    <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
                        <span class="designation-badge"><i class="ph-light ph-scales"></i> <%= safeEncode(spec) %></span>
                        <span class="verified-badge">
                            <i class="ph-fill ph-shield-check"></i> Registration Verified
                        </span>
                    </div>
                </div>
            </div>

            <div class="content-grid">
                
                <!-- MAIN INFO -->
                <div class="main-details">
                    
                    <div class="info-group">
                        <div class="section-title">Professional Statement</div>
                        <span class="about-text"><%= safeEncode(about) %></span>
                    </div>
                    
                    <div class="info-group" style="margin-top:40px;">
                        <div class="section-title">Credentials & Practice Areas</div>
                        <div class="pill-container">
                            <% 
                                String[] specsList = spec.split(",");
                                for(String c : specsList) {
                                    if(!c.trim().isEmpty()) {
                            %>
                                <span class="pill"><%= safeEncode(c.trim()) %></span>
                            <%      }
                                }
                            %>
                            <span class="pill">Active Trial Strategy</span>
                        </div>
                    </div>

                    <div class="info-group" style="margin-top:40px;">
                        <div class="section-title">Office Location</div>
                        <div class="info-value">
                            <i class="ph-light ph-map-pin" style="color:var(--gold); font-size:1.4rem; margin-top:2px;"></i>
                            <div>
                                <%= safeEncode(loc) %>
                                <% if(loc != null && !loc.isEmpty()) { %>
                                    <div style="margin-top:6px;">
                                        <a href="https://maps.google.com/?q=<%= safeEncode(loc) %>" target="_blank" style="font-size:0.9rem; color:var(--gold); font-weight:400; text-decoration:none;">
                                            View on Map <i class="ph-light ph-arrow-square-out"></i>
                                        </a>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- SIDEBAR ACTIONS -->
                <div class="sidebar-actions">
                    <div class="section-title">Lawyer Availability</div>
                    
                    <div style="margin-bottom:32px;">
                        <div class="stat-row">
                            <span class="stat-label">System Status</span>
                            <span class="stat-val" style="color:var(--success); display:flex; align-items:center; gap:8px;">
                                <span style="display:inline-block; width:8px; height:8px; background:currentColor; border-radius:50%;"></span>
                                Available
                            </span>
                        </div>
                        <div class="stat-row">
                            <span class="stat-label">Bar Affiliation</span>
                            <span class="stat-val"><%= safeEncode(bar) %></span>
                        </div>
                        <div class="stat-row">
                            <span class="stat-label">Experience</span>
                            <span class="stat-val"><%= safeEncode(exp) %> Years</span>
                        </div>
                        <div class="stat-row">
                            <span class="stat-label">Average Ratings</span>
                            <span class="stat-val stars" style="display:flex; align-items:center; gap:6px;">
                                5.0 
                                <span style="display:inline-flex;">
                                    <i class="ph-fill ph-star"></i><i class="ph-fill ph-star"></i><i class="ph-fill ph-star"></i><i class="ph-fill ph-star"></i><i class="ph-fill ph-star"></i>
                                </span>
                            </span>
                        </div>
                    </div>

                    <% if (isLoggedIn) { %>
                        <a href="requestlawyer.jsp?lawyer_email=<%= java.net.URLEncoder.encode(lawyerEmail, "UTF-8") %>" class="action-btn btn-primary-action">
                            Request as Counsel <i class="ph-light ph-paper-plane-right"></i>
                        </a>
                        <a href="viewdisc.jsp" class="action-btn btn-secondary-action">
                            <i class="ph-light ph-chat-circle-dots"></i> Message Firm
                        </a>
                    <% } else { %>
                        <a href="cust_login.html?msg=Login to request lawyer" class="action-btn btn-primary-action">
                            Login to Request Counsel
                        </a>
                    <% } %>

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
    const sys   = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const init  = saved || (sys ? 'dark' : 'light');
    root.setAttribute('data-theme', init);
    if (init === 'dark') toggle.classList.add('on');

    if(toggle) {
        toggle.addEventListener('click', () => {
            const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
            root.setAttribute('data-theme', next);
            toggle.classList.toggle('on', next === 'dark');
            localStorage.setItem('j4u-theme', next);
        });
    }
</script>
</body>
</html>
