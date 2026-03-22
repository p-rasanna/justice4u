<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%
    String message = request.getParameter("msg");
    // View-layer fallback authentication guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html");
        return;
    }
    String specificLawyerId = request.getParameter("id");
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <title>Justice4U | Document Verification</title>
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

        /* ALERTS */
        .alert-info {
            background: var(--gold-light); border: 1px solid rgba(201,162,39,0.2);
            color: var(--gold-dark); padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 0.95rem;
            display:flex; align-items:center; gap:10px;
        }
        .alert-danger {
            background: var(--error-bg); border: 1px solid rgba(220,38,38,0.2);
            color: var(--error); padding: 16px; border-radius: 12px; margin-bottom: 24px; font-size: 0.95rem;
            display:flex; align-items:center; gap:10px;
        }

        /* LAWYER CARDS */
        .lawyer-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 20px; overflow: hidden; display: flex; flex-direction: column;
            margin-bottom: 32px;
        }
        .lawyer-header {
            padding: 24px; border-bottom: 1px solid var(--border);
            display: flex; justify-content: space-between; align-items: center; background: var(--bg2);
        }
        .lawyer-info h3 { font-size: 1.1rem; font-weight: 500; color: var(--text); display:flex; align-items:center; gap:8px;}
        .lawyer-info p { margin-top: 4px; font-size: 0.85rem; color: var(--text-muted); }

        .status-badge {
            font-size: 0.75rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em;
            padding: 6px 12px; border-radius: 100px;
        }
        .status-pending { background: rgba(217, 119, 6, 0.1); color: var(--warning); border:1px solid rgba(217,119,6,0.2); }
        .status-verified { background: rgba(5, 150, 105, 0.1); color: var(--success); border:1px solid rgba(5, 150, 105, 0.2); }
        .status-rejected { background: var(--error-bg); color: var(--error); border:1px solid rgba(220, 38, 38, 0.2); }

        /* DOCUMENTS GRID */
        .documents-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px; padding: 24px;
        }
        .document-card {
            background: var(--bg2); border: 1px solid var(--border);
            border-radius: 16px; padding: 20px; text-align: center;
        }
        .document-icon {
            width: 54px; height: 54px; margin: 0 auto 16px;
            background: var(--gold-light); color: var(--gold-dark); border-radius: 12px;
            display: flex; align-items: center; justify-content: center; font-size: 1.5rem;
        }
        .document-name { font-size: 0.95rem; font-weight: 500; color: var(--text); margin-bottom: 8px; }
        .document-status {
            font-size: 0.75rem; padding: 4px 10px; border-radius: 100px; display: inline-block; margin-bottom: 16px;
            font-weight:500;
        }

        .document-actions { display: flex; gap: 8px; justify-content: center; flex-wrap: wrap; }
        .btn-view, .btn-approve, .btn-reject {
            display: inline-flex; align-items: center; justify-content: center; gap: 4px;
            padding: 8px 14px; border-radius: 8px; font-size: 0.85rem; font-weight: 500; 
            border: 1px solid transparent; cursor: pointer; transition: all .2s; font-family: var(--font-sans);
            text-decoration: none;
        }
        .btn-view { background: var(--bg); color: var(--text); border-color: var(--border-mid); }
        .btn-view:hover { background: var(--border); }
        .btn-approve { border-color: rgba(5, 150, 105, 0.2); color: var(--success); background: var(--surface); }
        .btn-approve:hover { background: var(--success); color: #fff; transform: translateY(-1px); }
        .btn-reject { border-color: rgba(220, 38, 38, 0.2); color: var(--error); background: var(--surface); }
        .btn-reject:hover { background: var(--error); color: #fff; transform: translateY(-1px); }

        .bulk-actions {
            text-align: center; padding: 20px 24px;
            border-top: 1px solid var(--border); background: var(--bg2);
        }

        /* CUSTOM MODAL */
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.5); backdrop-filter: blur(4px);
            z-index: 9999; display: none; align-items: center; justify-content: center;
            opacity: 0; transition: opacity .3s;
        }
        .modal-overlay.show { display: flex; opacity: 1; }
        .modal-content {
            background: var(--surface); border: 1px solid var(--border); border-radius: 20px;
            width: 90%; max-width: 1000px; max-height: 90vh; display: flex; flex-direction: column;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }
        .modal-header {
            padding: 20px 24px; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center;
            background: var(--bg2); border-radius: 20px 20px 0 0;
        }
        .modal-header h5 {
            font-size: 1.1rem; font-weight: 500; color: var(--text); display: flex; align-items: center; gap: 8px; margin:0;
        }
        .close-btn { background: none; border: none; font-size: 1.2rem; color: var(--text); cursor: pointer; }
        .modal-body {
            padding: 24px; overflow: auto; display: flex; align-items: center; justify-content: center; background: var(--bg);
            min-height: 50vh;
        }
        .modal-footer {
            padding: 16px 24px; border-top: 1px solid var(--border); background: var(--bg2); border-radius: 0 0 20px 20px;
            display: flex; justify-content: flex-end;
        }

        /* FOOTER NAV */
        .footer-nav { display: flex; justify-content: flex-end; gap: 16px; margin-top: 24px; }
        .btn-nav {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px; border-radius: 8px; font-weight: 500; font-size: 0.9rem;
            text-decoration: none; transition: .2s; border: 1px solid var(--border-mid); color: var(--text); background: var(--surface);
        }
        .btn-nav:hover { border-color: var(--text); }

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
                <h1>Document <em>Verification</em></h1>
                <p><i class="ph-light ph-file-search"></i> Inspecting Audit Trails</p>
            </div>
        </div>

        <% if(message != null && !message.isEmpty()) { %>
            <div class="<%= message.contains("Error") || message.contains("Failed") ? "alert-danger" : "alert-info" %> reveal r1">
                <i class="ph-light <%= message.contains("Error") ? "ph-warning-circle" : "ph-info" %>"></i> <span><%= message %></span>
            </div>
        <% } %>

        <%
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection con = getDatabaseConnection();

                // Build query based on whether an explicit ID to filter by was passed or not
                String query = "SELECT DISTINCT l.lid, l.name, l.email, " +
                              "COALESCE(l.document_verification_status, 'PENDING') as doc_status " +
                              "FROM lawyer_reg l " +
                              "WHERE COALESCE(l.document_verification_status, 'PENDING') = 'PENDING' ";
                if (specificLawyerId != null && !specificLawyerId.isEmpty()) {
                    query += "AND l.lid = " + Integer.parseInt(specificLawyerId) + " ";
                }
                query += "ORDER BY l.lid";

                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery(query);

                boolean hasLawyers = false;

                while(rs.next()) {
                    hasLawyers = true;
                    int lawyerId = rs.getInt("lid");
                    String lawyerName = rs.getString("name");
                    String lawyerEmail = rs.getString("email");
                    String overallStatus = rs.getString("doc_status");
        %>

        <div class="lawyer-card reveal r2">
            <div class="lawyer-header">
                <div class="lawyer-info">
                    <h3><i class="ph-light ph-user"></i> <%= lawyerName %></h3>
                    <p><%= lawyerEmail %></p>
                </div>
                <div class="status-badge status-<%= overallStatus.toLowerCase() %>">
                    <%= overallStatus %>
                </div>            </div>

            <div class="documents-grid">
                <%
                    // Get documents for this lawyer
                    PreparedStatement docPst = con.prepareStatement(
                        "SELECT doc_id, document_type, file_name, status FROM lawyer_documents WHERE lawyer_id = ? ORDER BY document_type");
                    docPst.setInt(1, lawyerId);
                    ResultSet docRs = docPst.executeQuery();

                    boolean hasDocs = false;
                    while(docRs.next()) {
                        hasDocs = true;
                        int docId = docRs.getInt("doc_id");
                        String docType = docRs.getString("document_type");
                        String fileName = docRs.getString("file_name");
                        String docStatus = docRs.getString("status");

                        String displayName = "";
                        String icon = "";

                        switch(docType) {
                            case "BAR_CERTIFICATE":
                                displayName = "Bar Council Certificate";
                                icon = "<i class='ph-light ph-scales'></i>";
                                break;
                            case "GOV_ID_PROOF":
                                displayName = "Government ID Proof";
                                icon = "<i class='ph-light ph-identification-card'></i>";
                                break;
                            case "PROFESSIONAL_PHOTO":
                                displayName = "Professional Photograph";
                                icon = "<i class='ph-light ph-camera'></i>";
                                break;
                            case "LIVE_SELFIE":
                                displayName = "Live Selfie";
                                icon = "<i class='ph-light ph-device-mobile-camera'></i>";
                                break;
                            default:
                                displayName = docType;
                                icon = "<i class='ph-light ph-file-text'></i>";
                        }
                %>

                <div class="document-card">
                    <div class="document-icon"><%= icon %></div>
                    <div class="document-name"><%= displayName %></div>
                    <div class="document-status status-<%= docStatus.toLowerCase() %>">
                        <%= docStatus %>
                    </div>

                    <div class="document-actions">
                        <button class="btn-view" onclick="viewDocument('<%= fileName %>')"><i class="ph-bold ph-eye"></i> View</button>
                        <% if("PENDING".equals(docStatus)) { %>
                            <button class="btn-approve" onclick="verifyDocument(<%= docId %>, 'approve', <%= lawyerId %>)"><i class="ph-bold ph-check"></i> Approve</button>
                            <button class="btn-reject" onclick="verifyDocument(<%= docId %>, 'reject', <%= lawyerId %>)"><i class="ph-bold ph-x"></i> Reject</button>
                        <% } %>
                    </div>
                </div>

                <%
                    }
                    if(!hasDocs) {
                %>
                    <div style="grid-column: 1 / -1; text-align: center; padding: 24px;">
                        <span style="color:var(--text-faint); font-weight:500;">No documents uploaded. You can manually force verify this lawyer using the button below.</span>
                    </div>
                <%
                    }
                    docRs.close();
                    docPst.close();
                %>
            </div>

            <div class="bulk-actions">
                <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 16px;"><strong>Bulk Actions:</strong> Approve all pending documents for this lawyer</p>
                <button class="btn-approve" style="padding: 10px 20px;" onclick="approveAllDocuments(<%= lawyerId %>)">
                    <i class="ph-bold ph-checks"></i> Approve All Documents
                </button>
            </div>
        </div>

        <%
                }

                if(!hasLawyers) {
        %>
        <div class="lawyer-card reveal r2">
            <div style="text-align: center; padding: 60px;">
                <i class="ph-light ph-check-circle" style="font-size: 3rem; color: var(--success); margin-bottom: 16px;"></i>
                <h3 style="color: var(--text); font-weight:500;">No Pending Documents</h3>
                <p style="color: var(--text-muted); font-size: 0.95rem;">All lawyer documents have been reviewed.</p>
            </div>
        </div>
        <%
                }

                rs.close();
                st.close();
                con.close();

            } catch(Exception e) {
        %>
            <div class="alert-danger reveal r2">
                <i class="ph-light ph-warning-circle"></i> <span>Error executing database query. <%= e.getMessage() %></span>
            </div>
        <%
            }
        %>
        
        <div class="footer-nav reveal r3">
            <a href="ViewLawyers" class="btn-nav btn-back">
                <i class="ph-light ph-arrow-left"></i> Back to Requests
            </a>
        </div>
    </main>
</div>

<!-- Custom Document Viewer Modal -->
<div class="modal-overlay" id="documentViewerModal">
    <div class="modal-content">
        <div class="modal-header">
            <h5><i class="ph-light ph-file-text" style="color: var(--gold); font-size: 1.4rem;"></i> Document Viewer</h5>
            <button class="close-btn" onclick="closeModal()"><i class="ph-bold ph-x"></i></button>
        </div>
        <div class="modal-body" id="documentViewerContainer">
            <!-- Content will be injected here via JS -->
        </div>
        <div class="modal-footer">
            <button class="btn-view" onclick="closeModal()" style="background:var(--bg); border:1px solid var(--border-mid); color:var(--text); font-size:0.9rem; padding: 10px 20px;">Close Viewer</button>
        </div>
    </div>
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

    /* MODAL LOGIC */
    const modal = document.getElementById('documentViewerModal');
    function viewDocument(fileName) {
        const fileUrl = 'uploads/lawyer_documents/' + fileName;
        const ext = fileName.split('.').pop().toLowerCase();
        const viewerContainer = document.getElementById('documentViewerContainer');
        
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext)) {
            viewerContainer.innerHTML = `<img src="${fileUrl}" style="max-width: 100%; height: auto; border-radius: 12px; border: 1px solid var(--border);" alt="Document">`;
        } else {
            viewerContainer.innerHTML = `<iframe src="${fileUrl}" style="width: 100%; height: 70vh; border: 1px solid var(--border); border-radius: 12px; background:white;"></iframe>`;
        }
        
        modal.classList.add('show');
    }
    
    function closeModal() {
        modal.classList.remove('show');
        document.getElementById('documentViewerContainer').innerHTML = '';
    }

    /* ACTION LOGIC */
    function verifyDocument(docId, action, lawyerId) {
        if(confirm('Are you sure you want to ' + action + ' this document?')) {
            window.location.href = 'verifylawyerdoc.jsp?action=' + action + '&doc_id=' + docId + '&lawyer_id=' + lawyerId;
        }
    }

    function approveAllDocuments(lawyerId) {
        if(confirm('Are you sure you want to approve ALL pending documents for this lawyer?')) {
            window.location.href = 'verifylawyerdoc.jsp?action=approve_all&lawyer_id=' + lawyerId;
        }
    }
</script>
</body>
</html>
