<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.RBACUtil, java.util.Calendar" %>
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

    Calendar c = Calendar.getInstance();
    int timeOfDay = c.get(Calendar.HOUR_OF_DAY);
    String greeting = (timeOfDay < 12) ? "Good Morning" : (timeOfDay < 16) ? "Good Afternoon" : (timeOfDay < 21) ? "Good Evening" : "Welcome";

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
    <title>Justice4U | Submit Legal Case</title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — SUBMIT CASE
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

        /* ---- FORM COMPONENTS ---- */
        .form-section {
            background: var(--surface); border: 1px solid var(--border); border-radius: 20px;
            padding: 36px 40px; margin-bottom: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.02);
            position: relative; overflow: hidden;
        }
        .form-section::before {
            content:''; position:absolute; top:0; left:0; width:4px; height:100%;
            background:var(--gold); border-radius:0;
        }
        .form-section-head { margin-bottom: 32px; display: flex; align-items: center; gap: 12px; border-bottom:1px solid var(--border); padding-bottom:16px;}
        .form-section-head i { font-size: 1.6rem; color: var(--gold); }
        .form-section-head h4 { font-family: var(--font-serif); font-size: 1.8rem; font-weight: 500; font-style: italic; margin: 0; letter-spacing: 0.02em;}

        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; align-items: start; }
        .form-group { margin-bottom: 24px; }
        .form-label { font-size: .85rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .08em; margin-bottom: 10px; display: block; }
        
        .form-control, .form-select {
            width: 100%; padding: 14px 18px; border-radius: 12px; border: 1px solid var(--border-mid);
            background: var(--bg2); color: var(--text); font-family: var(--font-sans); font-size: 1rem;
            transition: all .2s var(--ease-out); outline: none; appearance: none;
        }
        .form-select { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23C9A227' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 16px center; padding-right: 48px; }
        .form-control:focus, .form-select:focus { border-color: var(--gold); box-shadow: 0 0 0 3px var(--gold-glow); background: var(--surface); }
        .form-control::placeholder { color: var(--text-faint); }
        textarea.form-control { min-height: 140px; resize: vertical; line-height:1.6;}
        
        input[type="file"].form-control { padding: 10px 18px; }
        input[readonly].form-control { background:var(--bg); border:none; border-bottom:2px dashed var(--gold); border-radius:0; padding:14px 0; color:var(--text); font-weight:700;}

        .checkbox-label { display: flex; align-items: flex-start; gap: 12px; font-size: 1rem; color: var(--text-muted); cursor: pointer; margin-top: 16px; margin-bottom: 32px;}
        .checkbox-label input[type="checkbox"] { width: 22px; height: 22px; accent-color: var(--gold-dark); cursor: pointer; flex-shrink:0; margin-top:2px;}

        /* RECIPIENT BANNER */
        .recipient-banner {
            background: var(--bg2); border: 1px solid var(--border-mid); border-radius: 16px; padding: 24px;
            margin-bottom: 32px; display: flex; align-items: center; gap: 20px;
        }
        .recipient-banner.direct { border-color: var(--gold); background: var(--gold-light); }
        [data-theme="dark"] .recipient-banner.direct { background: rgba(212,175,55,0.08); }
        
        .banner-icon {
            width: 64px; height: 64px; background: var(--surface); border: 1px solid var(--border); color: var(--text);
            border-radius: 50%; display: grid; place-items: center; font-size: 1.8rem; font-family: var(--font-serif);
        }
        .recipient-banner.direct .banner-icon { color: var(--gold-dark); border-color: var(--gold); background: var(--surface); }
        [data-theme="dark"] .recipient-banner.direct .banner-icon { color: var(--gold); }

        .banner-text h4 { margin: 0 0 6px 0; color: var(--text); font-size: 1.25rem; font-weight: 700; letter-spacing:-0.02em; }
        .banner-text p { margin: 0; font-size: .95rem; color: var(--text-muted); }

        /* BUTTONS */
        .btn-action {
            display: inline-flex; align-items: center; justify-content: center; gap: 10px;
            padding: 16px 32px; border-radius: 14px; font-weight: 700; font-size: 1.05rem;
            transition: all .25s var(--ease-out); text-decoration: none; border: none; cursor: pointer; font-family: var(--font-sans);
        }
        .btn-primary { background: var(--text); color: var(--bg); }
        .btn-primary:hover { background: var(--gold-dark); transform: translateY(-3px); box-shadow: 0 8px 24px var(--gold-glow); }
        .btn-secondary { background: transparent; border: 1px solid var(--border-mid); color: var(--text-muted); }
        .btn-secondary:hover { border-color: var(--text); color: var(--text); background: var(--bg2); }

        .error-alert {
            background: var(--error-bg); border: 1px solid rgba(220,38,38,0.2); color: var(--error);
            padding: 18px 24px; border-radius: 14px; margin-bottom: 32px; display: flex; align-items: center; gap: 16px; font-size: 1rem; font-weight:500;
        }

        /* ---- REVEAL ANIMATION ---- */
        .reveal { opacity:0; transform:translateY(18px); animation:revealUp .6s var(--ease-out) forwards; }
        .r1 { animation-delay:.05s } .r2 { animation-delay:.12s } .r3 { animation-delay:.19s }
        @keyframes revealUp { to { opacity:1; transform:none; } }

        @media(max-width:900px) {
            .sidebar { display:none; }
            .main { padding:24px 20px; }
            .form-row { grid-template-columns: 1fr; gap: 0; }
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
            <a href="case.jsp" class="nav-item active"><i class="ph-duotone ph-file-plus"></i> Submit Case</a>
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
                <h1>New Case <em>Intake</em></h1>
                <p><i class="ph-fill ph-clock" style="color:var(--text-faint);font-size:1.1rem;"></i> Estimated Time: 3-5 minutes • Secure & Encrypted</p>
            </div>
            <div class="user-chip">
                <div class="user-avatar"><%= avatarLetter %></div>
                <div class="user-info">
                    <span class="user-name"><%= com.j4u.Sanitizer.sanitize(username) %></span>
                    <span class="user-role">Self-select client</span>
                </div>
            </div>
        </div>

        <div class="reveal r2" style="max-width: 900px;">
            <form action="ProcessCaseRequestServlet" method="post" enctype="multipart/form-data">
                
                <%-- Error Handling --%>
                <%
                  String errorParam = request.getParameter("error");
                  String errorMessage = (String) session.getAttribute("errorMessage");
                  if ("1".equals(errorParam) && errorMessage != null) {
                    session.removeAttribute("errorMessage");
                %>
                <div class="error-alert">
                    <i class="ph-fill ph-warning-circle" style="font-size:2rem;"></i>
                    <div><strong>Error Found:</strong> <br><%= com.j4u.Sanitizer.sanitize(errorMessage) %></div>
                </div>
                <% } %>

                <%-- Dynamic Lawyer Selection Header --%>
                <%
                  String selectedLawyerEmail = request.getParameter("lawyer_email");
                  String selectedLawyerName = request.getParameter("lawyer_name");
                  
                  if (selectedLawyerEmail != null && !selectedLawyerEmail.isEmpty()) {
                %>
                    <div class="recipient-banner direct">
                        <div class="banner-icon"><%= selectedLawyerName != null && !selectedLawyerName.isEmpty() ? selectedLawyerName.charAt(0) : "L" %></div>
                        <div class="banner-text">
                            <h4>Direct Request to <%= com.j4u.Sanitizer.sanitize(selectedLawyerName) %></h4>
                            <p>This case will be immediately sent to your chosen counsel for priority review.</p>
                        </div>
                        <input type="hidden" name="selected_lawyer_email" value="<%= com.j4u.Sanitizer.sanitize(selectedLawyerEmail) %>">
                    </div>
                <% } else { %>
                    <div class="recipient-banner">
                        <div class="banner-icon"><i class="ph-duotone ph-globe-hemisphere-west"></i></div>
                        <div class="banner-text">
                            <h4>Open Marketplace Case</h4>
                            <p>Your case will be filed securely. You can browse the directory to link an attorney later.</p>
                        </div>
                    </div>
                <% } %>

                <div class="form-section">
                    <div class="form-section-head">
                        <i class="ph-duotone ph-file-text"></i>
                        <h4>Case Details</h4>
                    </div>

                    <div class="form-group">
                        <label for="caseTitle" class="form-label">Case Title</label>
                        <input type="text" id="caseTitle" class="form-control" name="title" placeholder="e.g., Property Dispute regarding land boundary" required>
                    </div>

                    <div class="form-group">
                        <label for="caseDescription" class="form-label">Detailed Description</label>
                        <textarea id="caseDescription" class="form-control" name="description" placeholder="Describe the incident, key dates, names of involved parties, and what legal outcome you are looking for..." required></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="caseCategory" class="form-label">Legal Category</label>
                            <select id="caseCategory" class="form-select" name="category" required>
                                <option value="" disabled selected>Select practice area</option>
                                <option>Criminal Defense</option>
                                <option>Civil Litigation</option>
                                <option>Family & Divorce</option>
                                <option>Property & Real Estate</option>
                                <option>Corporate Law</option>
                                <option>Cyber Crime</option>
                                <option>Consumer Protection</option>
                                <option>Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="caseUrgency" class="form-label">Urgency Level</label>
                            <select id="caseUrgency" class="form-select" name="urgency" required>
                                <option value="" disabled selected>Select priority</option>
                                <option>Standard (Reply within 48h)</option>
                                <option>High (Reply within 24h)</option>
                                <option>Critical (Immediate Attention)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <div class="form-section-head">
                        <i class="ph-duotone ph-map-pin-line"></i>
                        <h4>Jurisdiction & Logistics</h4>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="courtType" class="form-label">Target Court Level</label>
                            <select id="courtType" class="form-select" name="courtType" required>
                                <option value="" disabled selected>Select jurisdiction</option>
                                <option>District / Sessions Court</option>
                                <option>High Court</option>
                                <option>Supreme Court</option>
                                <option>Tribunal / Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="city" class="form-label">Location / City</label>
                            <input type="text" id="city" class="form-control" name="city" placeholder="e.g. Mumbai, Maharashtra" required>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="language" class="form-label">Preferred Communication Language</label>
                            <input type="text" id="language" class="form-control" name="language" placeholder="English, Hindi, Marathi, etc." required>
                        </div>
                        <div class="form-group">
                            <label for="consultMode" class="form-label">Consultation Mode</label>
                            <select id="consultMode" class="form-select" name="consultMode" required>
                                <option value="" disabled selected>Select preference</option>
                                <option>Virtual Video Call</option>
                                <option>Phone Call</option>
                                <option>In-Person Meeting</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <div class="form-section-head">
                        <i class="ph-duotone ph-paperclip"></i>
                        <h4>Evidence & Retainer</h4>
                    </div>

                    <div class="form-group">
                        <label for="documents" class="form-label">Support Documents (PDF, JPG, PNG)</label>
                        <input type="file" id="documents" class="form-control" name="documents" accept=".pdf,.jpg,.png" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                             <label for="regFee" class="form-label">Platform Intake Retainer</label>
                             <input type="text" id="regFee" class="form-control" value="₹ 500.00" readonly>
                        </div>
                        <div class="form-group">
                             <label for="paymentMode" class="form-label">Payment Method</label>
                             <select id="paymentMode" class="form-select" name="paymentMode" required>
                                 <option>UPI (PhonePe / GPay / Paytm)</option>
                                 <option>Credit / Debit Card</option>
                                 <option>Net Banking</option>
                             </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="transactionId" class="form-label">Transaction Reference Code</label>
                        <input type="text" id="transactionId" class="form-control" name="transactionId" placeholder="Enter UPI Ref ID or Bank Trace ID" required pattern="[A-Za-z0-9]{8,20}">
                    </div>
                </div>

                <label class="checkbox-label">
                    <input type="checkbox" required>
                    <span>I confirm that the details provided are accurate under penalty of perjury and authorize the Justice4U platform to process and encrypt this legal request.</span>
                </label>

                <div style="display: flex; gap: 16px; margin-bottom: 60px;">
                    <button type="submit" class="btn-action btn-primary" style="flex:1;">
                        Encrypt & Submit Case <i class="ph-bold ph-arrow-right"></i>
                    </button>
                    <a href="clientdashboard_manual.jsp" class="btn-action btn-secondary" style="flex:1;">Discard Request</a>
                </div>
            </form>
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
