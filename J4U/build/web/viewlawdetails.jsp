<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, java.util.*"%>
<%@include file="db_connection.jsp" %>
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
        response.sendRedirect("cust_login.html");
        return;
    }

    // Avatar character
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

    String lawyerEmail = request.getParameter("id");
    
    String name = "", email = "", phone = "", address = "", dob = "", aadhar = "";
    String profilePic = "default_lawyer.jpg", designation = "Senior Counsel", barId = "Not Verified";
    String courts = "", languages = "", responseTime = "";
    boolean isVerified = false;
    int lid = 0;

    try {
        Connection con = getDatabaseConnection();
        
        // Fallback: If no lawyer ID is provided, find the assigned lawyer for this client
        if (lawyerEmail == null || lawyerEmail.isEmpty()) {
            PreparedStatement getAssignedPst = con.prepareStatement(
                "SELECT l.email FROM lawyer_reg l " +
                "JOIN customer_cases cc ON l.lid = cc.assigned_lawyer_id " +
                "JOIN cust_reg c ON cc.customer_id = c.cid " +
                "WHERE c.email = ? LIMIT 1"
            );
            getAssignedPst.setString(1, cemailSession != null ? cemailSession : username);
            ResultSet assignedRs = getAssignedPst.executeQuery();
            if (assignedRs.next()) {
                lawyerEmail = assignedRs.getString("email");
            }
            assignedRs.close();
            getAssignedPst.close();
        }

        if (lawyerEmail != null && !lawyerEmail.isEmpty()) {
            PreparedStatement pst = con.prepareStatement("SELECT * FROM lawyer_reg WHERE email=?");
            pst.setString(1, lawyerEmail);
            ResultSet rs = pst.executeQuery();
            
            if (rs.next()) {
                lid = rs.getInt("lid");
                name = rs.getString("name"); // Corrected to match table schema
                if (name == null || name.isEmpty()) name = rs.getString("lname");
                email = rs.getString("email");
                phone = rs.getString("mobno");
                dob = rs.getString("dob");
                aadhar = rs.getString("ano");
                address = rs.getString("cadd");            
                
                try { designation = rs.getString("specialization"); if(designation == null || designation.isEmpty()) designation = rs.getString("practice_area"); } catch(Exception e) {}
                if(designation == null) designation = "Advocate";
                
                try { barId = rs.getString("bar_council_number"); if(barId == null) barId = "Not Listed"; } catch(Exception e) {}
                try { courts = rs.getString("practice_area"); if(courts == null) courts = "General Practice"; } catch(Exception e) {}
                try { languages = rs.getString("languages_spoken"); if(languages == null) languages = "English, Hindi"; } catch(Exception e) {}
                
                try { 
                    String status = rs.getString("document_verification_status");
                    if (status == null) status = rs.getString("status");
                    isVerified = "APPROVED".equalsIgnoreCase(status) || "VERIFIED".equalsIgnoreCase(status) || rs.getInt("flag") == 1;
                } catch(Exception e) {}
                
                try { responseTime = rs.getString("response_time_avg"); if(responseTime == null) responseTime = "48 hours"; } catch(Exception e) {}
            }
            rs.close();
            pst.close();
        }
        con.close();
    } catch (Exception e) {}
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U | Attorney Profile</title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — ATTORNEY PROFILE (NO BOLD WEIGHTS)
           Full 2026 design system — dark mode, grain, sidebar, reveal
           Using max font-weight 500 for elegance and strict matching.
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
        .topbar-left h1 {
            font-size:clamp(1.6rem,3vw,2.4rem); font-weight:400; font-family:var(--font-serif); font-style:italic;
            line-height:1.1; margin-bottom:5px; color:var(--gold);
        }
        .topbar-left h1 em { font-family:var(--font-sans); font-style:normal; font-weight:500; color:var(--text); letter-spacing:-0.03em;}
        .topbar-left p { color:var(--text-muted); font-size:.9rem; display:flex; align-items:center; gap:6px; font-weight:400;}

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
            background: var(--surface); padding: 6px 16px; border-radius: 100px; font-size: 0.9rem; border: 1px solid var(--border); color: var(--text-muted); font-weight: 400;
        }
        
        .verified-badge {
            background: var(--success-bg); padding: 6px 16px; border-radius: 100px; font-size: 0.9rem; border: 1px solid rgba(4,120,87,.2); color: var(--success); font-weight: 500; display:inline-flex; align-items:center; gap:6px;
        }
        [data-theme="dark"] .verified-badge { color: #34d399; border-color: rgba(52,211,153,.2); }

        .bar-id { margin-top: 16px; font-size: 0.95rem; color: var(--text-muted); display: flex; align-items: center; gap: 6px; font-weight:400; }

        /* CONTENT GRID */
        .content-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 40px; padding: 40px; }

        .section-title { font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-faint); margin-bottom: 20px; font-weight: 500; border-bottom:1px solid var(--border); padding-bottom:10px;}

        .info-group { margin-bottom: 32px; }
        .info-value { font-size: 1.05rem; color: var(--text); line-height: 1.6; font-weight:400; display:flex; gap:10px; align-items:flex-start;}

        .pill-container { display: flex; flex-wrap: wrap; gap: 10px; }
        .pill { background: var(--bg2); color: var(--text); padding: 10px 18px; border-radius: 12px; font-size: 0.95rem; border: 1px solid var(--border); font-weight: 400; }

        /* SIDEBAR ACTIONS IN PROFILE */
        .sidebar-actions { background: var(--bg2); padding: 32px; border-radius: 16px; height: fit-content; border: 1px solid var(--border-mid); }

        .action-btn {
            display: flex; align-items: center; justify-content: center; gap: 10px; width: 100%; padding: 16px;
            border: none; border-radius: 12px; font-weight: 500; cursor: pointer; text-decoration: none; transition: all .2s; margin-bottom: 16px; font-size: 1rem; font-family: var(--font-sans);
        }
        .btn-primary-action { background: var(--text); color: var(--bg); }
        .btn-primary-action:hover { background: var(--gold-dark); transform: translateY(-2px); box-shadow:0 4px 12px var(--gold-glow); }

        .stat-row { display: flex; justify-content: space-between; padding: 16px 0; border-bottom: 1px dashed var(--border); font-size: 0.95rem; font-weight:400;}
        .stat-row:last-child { border: none; padding-bottom:0;}
        .stat-label { color: var(--text-muted); }
        .stat-val { font-weight: 500; color: var(--text); }

        .empty-state { text-align:center; padding: 80px 24px; background:var(--surface); border:1px solid var(--border); border-radius:20px;}
        .empty-state h2 { font-family:var(--font-serif); font-size:2.2rem; font-weight:400; margin-bottom:10px; color:var(--text); }
        .empty-state p { font-size:1rem; color:var(--text-muted); font-weight:400;}

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

        <div class="nav-section">
            <span class="nav-label">My Workspace</span>
            <a href="clientdashboard_manual.jsp" class="nav-item"><i class="ph-light ph-squares-four"></i> Console</a>
            <a href="case.jsp" class="nav-item"><i class="ph-light ph-file-plus"></i> Submit Case</a>
            <a href="ClientDashboard" class="nav-item"><i class="ph-light ph-folders"></i> My Cases</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Find Representation</span>
            <a href="findlawyer.jsp" class="nav-item"><i class="ph-light ph-magnifying-glass"></i> Browse Lawyers</a>
            <a href="#" class="nav-item active"><i class="ph-light ph-identification-card"></i> Assigned Lawyer</a>
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
    </aside>

    <!-- ===== MAIN ===== -->
    <main class="main" role="main">
        
        <div style="margin-bottom: 24px;" class="reveal r1">
            <a href="javascript:history.back()" style="text-decoration: none; color: var(--text-muted); font-size: 0.95rem; display: inline-flex; align-items: center; gap: 6px; font-weight: 400; transition: color .2s;">
                <i class="ph-light ph-arrow-left"></i> Return to Previous
            </a>
        </div>

        <% if (name != null && !name.isEmpty()) { %>
        <div class="profile-card reveal r2">
            
            <!-- HEADER -->
            <div class="profile-header">
                <div class="avatar-wrapper">
                    <div class="avatar">
                        <%= name.isEmpty() ? "?" : name.charAt(0) %>
                    </div>
                    <% if(isVerified) { %>
                    <div class="verified-tick" title="Verified Practitioner">
                        <i class="ph-light ph-check"></i>
                    </div>
                    <% } %>
                </div>
                
                <div class="header-info">
                    <h2><%= safeEncode(name) %></h2>
                    <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
                        <span class="designation-badge"><%= safeEncode(designation) %></span>
                        <% if(isVerified) { %>
                            <span class="verified-badge">
                                <i class="ph-fill ph-shield-check"></i> Justice4U Verified
                            </span>
                        <% } %>
                    </div>
                    <div class="bar-id">
                        <i class="ph-light ph-identification-card" style="color:var(--gold);"></i> 
                        Bar Council ID: <%= safeEncode(barId) %>
                    </div>
                </div>
            </div>

            <div class="content-grid">
                
                <!-- MAIN INFO -->
                <div class="main-details">
                    
                    <div class="info-group">
                        <div class="section-title">Practicing Courts & Specializations</div>
                        <div class="pill-container">
                            <% 
                                String[] courtList = courts.split(",");
                                for(String c : courtList) {
                                    if(!c.trim().isEmpty()) {
                            %>
                                <span class="pill"><%= c.trim() %></span>
                            <%      }
                                }
                            %>
                        </div>
                    </div>

                    <div class="info-group">
                        <div class="section-title">Languages Spoken</div>
                        <div class="pill-container">
                            <% 
                                String[] langList = languages.split(",");
                                for(String l : langList) {
                                    if(!l.trim().isEmpty()) {
                            %>
                                <span class="pill"><%= l.trim() %></span>
                            <%      }
                                }
                            %>
                        </div>
                    </div>

                    <div class="info-group">
                        <div class="section-title">Office Address</div>
                        <div class="info-value">
                            <i class="ph-light ph-map-pin" style="color:var(--gold); font-size:1.4rem; margin-top:2px;"></i>
                            <div>
                                <%= safeEncode(address) %>
                                <% if(!address.isEmpty()) { %>
                                    <div style="margin-top:6px;">
                                        <a href="https://maps.google.com/?q=<%= safeEncode(address) %>" target="_blank" style="font-size:0.9rem; color:var(--gold); font-weight:400; text-decoration:none;">
                                            View on map <i class="ph-light ph-arrow-square-out"></i>
                                        </a>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- SIDEBAR ACTIONS -->
                <div class="sidebar-actions">
                    <div class="section-title">Contact & Availability</div>
                    
                    <div style="margin-bottom:32px;">
                        <div class="stat-row">
                            <span class="stat-label">Status</span>
                            <span class="stat-val" style="color:var(--success); display:flex; align-items:center; gap:8px;">
                                <span style="display:inline-block; width:8px; height:8px; background:currentColor; border-radius:50%;"></span>
                                Available
                            </span>
                        </div>
                        <div class="stat-row">
                            <span class="stat-label">Response Time</span>
                            <span class="stat-val"><%= safeEncode(responseTime) %></span>
                        </div>
                        <div class="stat-row">
                            <span class="stat-label">Contact</span>
                            <span class="stat-val" style="font-size:0.9rem;"><%= safeEncode(email) %></span>
                        </div>
                        <div class="stat-row">
                            <span class="stat-label">Phone</span>
                            <span class="stat-val" style="font-size:0.9rem;"><%= safeEncode(phone) %></span>
                        </div>
                    </div>

                    <a href="case.jsp?lawyer_email=<%= safeEncode(email) %>&lawyer_name=<%= safeEncode(name) %>" class="action-btn btn-primary-action">
                        Select for Case <i class="ph-light ph-arrow-right"></i>
                    </a>

                </div>

            </div>
        </div>
        <% } else { %>
            <div class="empty-state reveal r2">
                <h2>No Assigned Counsel</h2>
                <p>You currently do not have a specific lawyer assigned to your profile.<br>Please select an attorney from the directory or file a case to begin.</p>
                <div style="margin-top:30px;">
                    <a href="findlawyer.jsp" style="background:var(--text); color:var(--bg); padding:14px 28px; border-radius:12px; text-decoration:none; font-weight:500; font-size:1rem; display:inline-flex; align-items:center; gap:8px;">
                        Browse Directory <i class="ph-light ph-arrow-right"></i>
                    </a>
                </div>
            </div>
        <% } %>

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
