<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*, java.sql.*, com.j4u.RBACUtil, java.util.Calendar" %>
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
    if (!RBACUtil.isValidClient(username)) {
        session.invalidate();
        response.sendRedirect("cust_login.html?msg=Invalid Access");
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

    List<Map<String, Object>> caseList = (List<Map<String, Object>>) request.getAttribute("caseList");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U | My Cases</title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — MY CASES PORTFOLIO (BOLD TYPOGRAPHY)
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

        .btn-new-case {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            background: var(--text); color: var(--bg);
            padding: 12px 24px; border-radius: 12px; font-weight: 800; font-family: var(--font-sans);
            text-decoration: none; transition: all .25s var(--ease-out); border: none; font-size:0.95rem;
        }
        .btn-new-case:hover { background: var(--gold-dark); transform: translateY(-3px); box-shadow: 0 8px 24px var(--gold-glow); }

        /* ---- TABLE VIEW ---- */
        .table-wrap {
            background: var(--surface); border: 1px solid var(--border); border-radius: 20px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.02); overflow: auto;
        }
        .table-head {
            padding: 24px 32px; border-bottom: 1px solid var(--border-mid);
            background: var(--bg2); display: flex; justify-content: space-between; align-items: center;
        }
        .table-head h3 {
            font-family: var(--font-sans); font-size: 1.15rem; margin: 0; 
            font-weight: 800; color: var(--text); display: flex; align-items: center; gap: 10px; letter-spacing:-0.01em;
        }
        .table-head i { color: var(--gold); font-size: 1.4rem; }

        .dataTable { width: 100%; border-collapse: collapse; text-align: left; }
        .dataTable th {
            padding: 18px 32px; font-size: 0.75rem; font-weight: 900; text-transform: uppercase; letter-spacing: 0.08em;
            color: var(--text-faint); border-bottom: 2px solid var(--border); background: var(--surface); white-space:nowrap;
        }
        .dataTable td {
            padding: 24px 32px; border-bottom: 1px solid var(--border-mid); vertical-align: middle; color:var(--text);
        }
        .dataTable tr:last-child td { border-bottom: none; }
        .dataTable tr { transition: background .2s var(--ease-out); }
        .dataTable tr:hover { background: var(--bg2); }

        /* Data cells bold emphasis */
        .c-id { font-family: var(--font-serif); font-size: 1.4rem; font-weight: 800; color: var(--gold-dark); font-style:italic;}
        [data-theme="dark"] .c-id { color: var(--gold); }
        
        .c-title { display:block; font-size: 1.1rem; font-weight: 800; color: var(--text); margin-bottom: 4px; letter-spacing:-0.01em;}
        .c-sub { display:block; font-size: 0.8rem; font-weight: 700; color: var(--text-muted); }
        
        .c-desc { max-width:240px; font-size: 0.85rem; font-weight: 500; color: var(--text-muted); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; line-height:1.5;}
        
        .c-date { font-weight: 700; font-size:0.85rem; color:var(--text); display:flex; align-items:center; gap:6px; white-space:nowrap;}
        .c-date i { color:var(--gold); }
        
        .c-tag { display:inline-flex; padding:4px 10px; background:var(--bg); border:1px solid var(--border); border-radius:6px; font-size:0.75rem; font-weight:800; color:var(--text-muted); margin-bottom:6px;}

        /* Statuses */
        .status-chip { display:inline-flex; align-items:center; gap:6px; padding:6px 14px; border-radius:100px; font-size:0.75rem; font-weight:800; white-space:nowrap; text-transform:uppercase; letter-spacing:0.04em; }
        .sc-pending { background:var(--warning-bg); color:var(--warning); border:1px solid rgba(180,83,9,.2); }
        .sc-approved { background:var(--success-bg); color:var(--success); border:1px solid rgba(4,120,87,.2); }
        .sc-rejected { background:var(--error-bg); color:var(--error); border:1px solid rgba(220,38,38,.2); }
        .sc-open { background:var(--info-bg); color:var(--info); border:1px solid rgba(29,78,216,.2); }
        [data-theme="dark"] .sc-pending { color:#fbbf24; }
        [data-theme="dark"] .sc-approved { color:#34d399; }
        [data-theme="dark"] .sc-rejected { color:#f87171; }
        [data-theme="dark"] .sc-open { color:#60a5fa; }

        /* Action Buttons */
        .btn-action {
            display:inline-flex; align-items:center; justify-content:center; gap:6px;
            padding:8px 16px; border-radius:8px; font-size:0.8rem; font-weight:800;
            text-decoration:none; transition:all .2s var(--ease-out); border:none; cursor:pointer; font-family:var(--font-sans); white-space:nowrap;
        }
        .btn-counsel { background:var(--gold); color:#FFF; }
        .btn-counsel:hover { background:var(--gold-dark); transform:translateY(-2px); box-shadow:0 4px 12px var(--gold-glow); }
        .btn-portal { background:var(--text); color:var(--bg); }
        .btn-portal:hover { background:var(--gold-dark); transform:translateY(-2px); box-shadow:0 4px 12px var(--gold-glow); }
        .lbl-await { font-size:0.8rem; font-weight:800; color:var(--text-faint); display:inline-flex; align-items:center; gap:4px; }

        .empty-state { text-align:center; padding: 60px 24px; }
        .empty-state i { font-size: 3rem; color: var(--gold); margin-bottom: 16px; opacity:0.8;}
        .empty-state h4 { font-size:1.2rem; font-weight:800; margin-bottom:8px; }
        .empty-state p { font-size:0.9rem; color: var(--text-muted); margin-bottom: 24px; font-weight:500;}

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
            <a href="ClientDashboard" class="nav-item active"><i class="ph-duotone ph-folders"></i> My Cases</a>
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
                <h1>My Case <em>Portfolio</em></h1>
                <p><i class="ph-fill ph-check-circle" style="color:var(--success);font-size:1.1rem;"></i> Confidentially tracking your legal progress</p>
            </div>
            <div style="display:flex; align-items:center; gap:20px;">
                <a href="case.jsp" class="btn-new-case"><i class="ph-bold ph-plus"></i> New Inquiry</a>
                <div class="user-chip" style="margin:0;">
                    <div class="user-avatar"><%= avatarLetter %></div>
                    <div class="user-info">
                        <span class="user-name"><%= com.j4u.Sanitizer.sanitize(username) %></span>
                        <span class="user-role">Verified Client</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- TABLE VIEW -->
        <div class="table-wrap reveal r2">
            <div class="table-head">
                <h3><i class="ph-duotone ph-briefcase"></i> All Submitted Cases</h3>
            </div>
            
            <table class="dataTable">
                <thead>
                    <tr>
                        <th>Ref#</th>
                        <th>Case Details</th>
                        <th>Summary</th>
                        <th>Date Filed</th>
                        <th>Jurisdiction</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (caseList != null && !caseList.isEmpty()) {
                            for (Map<String, Object> caseItem : caseList) {
                                String status = (String) caseItem.get("status");
                                String displayStatus = "Pending";
                                String statusClass = "sc-pending";
                                
                                if (status != null) {
                                    String uStatus = status.toUpperCase();
                                    if (uStatus.contains("REJECTED")) {
                                        displayStatus = "Rejected";
                                        statusClass = "sc-rejected";
                                    } else if (uStatus.contains("ASSIGNED") || uStatus.contains("PROGRESS") || uStatus.contains("APPROVED") || uStatus.contains("ACCEPTED")) {
                                        displayStatus = "Approved";
                                        statusClass = "sc-approved";
                                    } else if (uStatus.equals("OPEN")) {
                                        displayStatus = "Open";
                                        statusClass = "sc-open";
                                    } else if (uStatus.equals("REQUESTED")) {
                                        displayStatus = "Requested";
                                        statusClass = "sc-pending";
                                    }
                                }
                    %>
                                <tr>
                                    <td class="c-id">#<%= caseItem.get("id") %></td>
                                    <td>
                                        <span class="c-title"><%= com.j4u.Sanitizer.sanitize((String)caseItem.get("title")) %></span>
                                        <span class="c-sub">Retainer: ₹<%= caseItem.get("amount") %> &bull; <%= caseItem.get("paymentMode") %></span>
                                    </td>
                                    <td>
                                        <div class="c-desc" title="<%= com.j4u.Sanitizer.sanitize((String)caseItem.get("description")) %>">
                                            <%= com.j4u.Sanitizer.sanitize((String)caseItem.get("description")) %>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="c-date"><i class="ph-fill ph-calendar-blank"></i> <%= caseItem.get("date") %></span>
                                    </td>
                                    <td>
                                        <span class="c-tag"><%= caseItem.get("courtType") %></span>
                                        <span class="c-sub" style="font-weight:700;"><i class="ph-fill ph-map-pin" style="color:var(--text-faint);"></i> <%= caseItem.get("city") %></span>
                                    </td>
                                    <td>
                                        <span class="status-chip <%= statusClass %>">
                                            <i class="ph-fill ph-circle" style="font-size:0.5rem;"></i> <%= displayStatus %>
                                        </span>
                                    </td>
                                    <td>
                                        <%
                                            if (status != null && status.equalsIgnoreCase("OPEN")) {
                                        %>
                                            <a href="findlawyer.jsp?case_id=<%= caseItem.get("id") %>" class="btn-action btn-counsel"><i class="ph-bold ph-plus"></i> Select Counsel</a>
                                        <%
                                            } else if (status != null && (status.equalsIgnoreCase("ASSIGNED") || status.equalsIgnoreCase("ACCEPTED"))) {
                                        %>
                                            <a href="client_chat.jsp?case_id=<%= caseItem.get("id") %>" class="btn-action btn-portal"><i class="ph-bold ph-chat-text"></i> Verify Status</a>
                                        <%
                                            } else {
                                        %>
                                            <span class="lbl-await"><i class="ph-duotone ph-hourglass-medium"></i> Awaiting</span>
                                        <%
                                            }
                                        %>
                                    </td>
                                </tr>
                    <%
                            }
                        } else {
                    %>
                            <tr>
                                <td colspan="7">
                                    <div class="empty-state">
                                        <i class="ph-duotone ph-folder-dashed"></i>
                                        <h4>No cases filed yet</h4>
                                        <p>You haven't initiated any inquiries on the platform.</p>
                                        <a href="case.jsp" class="btn-new-case">Start an Inquiry Now</a>
                                    </div>
                                </td>
                            </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
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
