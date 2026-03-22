<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    String message = request.getParameter("msg");
    // View-layer fallback authentication guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <title>Justice4U | Lawyer Requests</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* =====================================================================
           JUSTICE4U — ADMIN COMMAND CENTER (LAWYER REQUESTS)
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

        /* ALERTS */
        .alert-info {
            background: var(--gold-light); border: 1px solid rgba(201,162,39,0.2);
            color: var(--gold-dark); padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 0.95rem;
            display:flex; align-items:center; gap:10px;
        }

        /* ACTION PANELS GRID */
        .panel {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 20px; overflow: hidden; display: flex; flex-direction: column;
            margin-bottom: 32px;
        }
        .panel-head {
            padding: 20px 24px; border-bottom: 1px solid var(--border);
            display: flex; justify-content: space-between; align-items: center; background: var(--bg2);
        }
        .panel-head h3 { font-size: 1.1rem; font-weight: 500; color: var(--text); display:flex; align-items:center; gap:8px;}
        .panel-icon { color: var(--gold); font-size:1.3rem; }
        .tag-info {
            font-size: 0.75rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
            color: var(--text-muted); background: var(--bg); padding: 4px 10px; border-radius: 100px;
            border: 1px solid var(--border);
        }

        /* DATA TABLE */
        .table-responsive {
            max-height: 600px; overflow: auto; width: 100%;
        }
        .table {
            width: 100%; border-collapse: collapse; text-align: left;
        }
        .table th {
            font-size: 0.75rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
            color: var(--text-muted); padding: 16px 20px; border-bottom: 1px solid var(--border);
            background: var(--bg2); position: sticky; top: 0; z-index: 5; white-space: nowrap;
        }
        .table td {
            padding: 16px 20px; font-size: 0.9rem; color: var(--text);
            border-bottom: 1px solid var(--border); vertical-align: middle; white-space: nowrap;
        }
        .table tr:last-child td { border-bottom: none; }
        .table tr:hover { background: var(--bg); }
        .wrap-cell { white-space: normal !important; min-width: 250px; line-height:1.5; color:var(--text-muted) !important;}

        /* STATUS PILLS */
        .status-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 12px; border-radius: 100px; font-size: 0.8rem; font-weight: 500;
        }
        .status-pending { background: rgba(217, 119, 6, 0.1); color: var(--warning); }
        .status-verified { background: rgba(5, 150, 105, 0.1); color: var(--success); }
        .status-rejected { background: var(--error-bg); color: var(--error); }

        /* BUTTONS */
        .action-flex { display: flex; gap: 8px; align-items: center; }
        .btn-action {
            display: inline-flex; align-items: center; justify-content: center; gap: 6px;
            padding: 8px 16px; border-radius: 8px; font-size: 0.85rem; font-weight: 500; 
            border: 1px solid transparent; cursor: pointer; transition: all .2s; font-family: var(--font-sans);
            background: var(--bg2); color: var(--text); text-decoration: none;
        }
        .btn-approve { border-color: rgba(5, 150, 105, 0.2); color: var(--success); }
        .btn-approve:hover { background: var(--success); color: #fff; transform: translateY(-1px); }
        .btn-reject { border-color: rgba(220, 38, 38, 0.2); color: var(--error); }
        .btn-reject:hover { background: var(--error); color: #fff; transform: translateY(-1px); }

        .text-muted-note { color: var(--text-faint); font-weight: 500; display:flex; align-items:center; gap:4px; font-size:0.85rem;}

        /* FOOTER NAV */
        .footer-nav { display: flex; justify-content: flex-end; gap: 16px; margin-top: 24px; }
        .btn-nav {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px; border-radius: 8px; font-weight: 500; font-size: 0.9rem;
            text-decoration: none; transition: .2s; border: 1px solid var(--border-mid); color: var(--text);
        }
        .btn-nav:hover { border-color: var(--text); }
        .btn-danger { background: var(--error); color: #fff; border: none; }
        .btn-danger:hover { background: #B91C1C; }

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
            <a href="AdminDashboard" class="nav-item"><i class="ph-light ph-squares-four"></i> Dashboard</a>
            <a href="ViewCases" class="nav-item"><i class="ph-light ph-folder-notch"></i> Case Allocations</a>
        </div>

        <div class="nav-section">
            <span class="nav-label">Approvals</span>
            <a href="ViewCustomers" class="nav-item"><i class="ph-light ph-users"></i> Pending Clients</a>
            <a href="ViewLawyers" class="nav-item active"><i class="ph-light ph-gavel"></i> Lawyer Requests</a>
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
                <h1>Lawyer <em>Requests</em></h1>
                <p><i class="ph-light ph-gavel"></i> Personnel Identity & Credential Verification</p>
            </div>
        </div>

        <c:if test="${not empty param.msg}">
            <div class="alert alert-info reveal r1">
                <i class="ph-light ph-info"></i> <span><c:out value="${param.msg}" /></span>
            </div>
        </c:if>

        <div class="panel reveal r2">
            <div class="panel-head">
                <h3><i class="ph-light ph-users panel-icon"></i> Incoming Lawyer Applications</h3>
                <span class="tag-info">Approval Queue</span>
            </div>

            <div class="table-responsive">
                <table class="table">
              <thead>
                <tr>
                  <th>Lawyer Id</th>
                  <th>Name</th>
                  <th>Email</th>
                  <th>DOB</th>
                  <th>Mobile</th>
                  <th>Aadhar</th>
                  <th>Current Address</th>
                  <th>Permanent Address</th>
                  <th>Payment Mode</th>
                  <th>Txn ID</th>
                  <th>Amount</th>
                  <th>Document Status</th>
                  <th>Approve</th>
                  <th>Reject</th>
                </tr>
              </thead>
              <tbody>
              <c:choose>
                <c:when test="${not empty pendingLawyers}">
                  <c:forEach var="lawyer" items="${pendingLawyers}">
                    <c:set var="statusClass" value="status-pending" />
                    <c:set var="statusText" value="Pending Docs" />
                    
                    <c:if test="${lawyer.docStatus == 'VERIFIED'}">
                      <c:set var="statusClass" value="status-verified" />
                      <c:set var="statusText" value="Verified" />
                    </c:if>
                    <c:if test="${lawyer.docStatus == 'REJECTED'}">
                      <c:set var="statusClass" value="status-rejected" />
                      <c:set var="statusText" value="Rejected" />
                    </c:if>

                    <tr>
                      <td><c:out value="${lawyer.id}" /></td>
                      <td style="font-weight:500;"><c:out value="${lawyer.name}" /></td>
                      <td><c:out value="${lawyer.email}" /></td>
                      <td><c:out value="${lawyer.dob}" /></td>
                      <td><c:out value="${lawyer.mobile}" /></td>
                      <td><c:out value="${lawyer.aadhar}" /></td>
                      <td><c:out value="${lawyer.currentAddress}" /></td>
                      <td><c:out value="${lawyer.permanentAddress}" /></td>
                      <td><c:out value="${lawyer.paymentMode}" /></td>
                      <td><c:out value="${lawyer.txnId}" /></td>
                      <td style="font-weight:500;"><c:out value="${lawyer.amount}" /></td>
                      <td>
                        <span class="status-pill ${statusClass}">
                          <c:if test="${statusClass == 'status-pending'}"><i class='ph-light ph-clock'></i> </c:if>
                          <c:if test="${statusClass == 'status-verified'}"><i class='ph-light ph-check-circle'></i> </c:if>
                          <c:if test="${statusClass == 'status-rejected'}"><i class='ph-light ph-x-circle'></i> </c:if>
                          <c:out value="${statusText}" />
                        </span>
                      </td>
                      <td>
                        <div class="action-flex">
                        <c:choose>
                          <c:when test="${lawyer.docStatus == 'VERIFIED'}">
                            <a href="approvel.jsp?id=${lawyer.id}" class="btn-action btn-approve" onclick="return confirm('Officially approve this lawyer?')">
                              <i class="ph-bold ph-check"></i> Approve
                            </a>
                          </c:when>
                          <c:otherwise>
                            <a href="viewlawyerdocuments.jsp?id=${lawyer.id}" class="btn-action" style="border-color: rgba(217, 119, 6, 0.2); color: var(--warning);">
                              <i class="ph-bold ph-file-search"></i> Verify Docs
                            </a>
                          </c:otherwise>
                        </c:choose>
                        </div>
                      </td>
                      <td>
                        <div class="action-flex">
                          <a href="rejectl.jsp?id=${lawyer.id}" class="btn-action btn-reject" onclick="return confirm('Reject lawyer application?')">
                            <i class="ph-bold ph-x"></i> Reject
                          </a>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="14" style="text-align: center; padding: 40px; color: var(--text-faint);">No pending lawyer applications right now.</td>
                  </tr>
                </c:otherwise>
              </c:choose>
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
