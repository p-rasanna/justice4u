<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, java.util.*, java.text.*"%>
<%@include file="db_connection.jsp" %>
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

    int customerId = 0;
    try {
        Connection conId = getDatabaseConnection();
        PreparedStatement ps = conId.prepareStatement("SELECT cid FROM cust_reg WHERE email=?");
        ps.setString(1, cemailSession);
        ResultSet rsId = ps.executeQuery();
        if(rsId.next()) customerId = rsId.getInt("cid");
        conId.close();
    } catch(Exception e) { e.printStackTrace(); }
    
    String reqCaseId = request.getParameter("case_id");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Case Intelligence</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --bg-ivory: #FAFAF8;
            --ink-primary: #121212;
            --ink-secondary: #555555;
            --ink-tertiary: #888888;
            
            --gold-main: #C6A75E;
            --gold-dim: #9C824A;
            --success-green: #059669;
            --alert-amber: #D97706;
            --danger-red: #DC2626;
            
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        body {
            margin: 0; background-color: var(--bg-ivory); color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .layout-wrapper { display: flex; min-height: 100vh; }

        /* SIDEBAR NAVIGATION */
        .sidebar {
            width: 260px; background: var(--surface-card); border-right: 1px solid var(--border-subtle);
            padding: 32px 24px; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh;
            flex-shrink: 0;
        }

        .brand { display: flex; align-items: center; gap: 12px; margin-bottom: 48px; text-decoration: none; }
        .brand-icon { font-size: 2rem; color: var(--gold-main); }
        .brand h2 { font-family: 'Playfair Display', serif; margin: 0; color: var(--ink-primary); font-size: 1.5rem; }

        .nav-group { margin-bottom: 32px; }
        .nav-title { font-size: 0.75rem; text-transform: uppercase; color: var(--ink-tertiary); margin-bottom: 12px; font-weight: 600; letter-spacing: 0.05em; }
        .nav-link {
            display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: 8px;
            color: var(--ink-secondary); text-decoration: none; font-weight: 500; transition: all 0.2s; margin-bottom: 4px; border: 1px solid transparent;
        }
        .nav-link:hover, .nav-link.active {
            background: #FAFAFA; color: var(--ink-primary); border-color: var(--border-subtle);
        }
        .nav-link.active { box-shadow: 0 2px 8px rgba(0,0,0,0.02); }
        .nav-link i { font-size: 1.2rem; color: var(--gold-dim); }

        .logout-link {
            display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: 8px;
            color: var(--ink-secondary); text-decoration: none; font-weight: 500; transition: all 0.2s; margin-top: auto;
        }
        .logout-link:hover { background: #FEF2F2; color: var(--danger-red); }
        .logout-link i { font-size: 1.2rem; }

        /* MAIN CONTENT */
        .main-content { flex: 1; padding: 40px 48px; max-width: 1200px; margin: 0 auto; overflow-x: hidden; }

        .smart-enter {
            opacity: 0; transform: translateY(15px);
            /* animation removed */
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }
        .d-3 { animation-delay: 0.3s; }
        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* HERO HEADER */
        .case-header {
            background: var(--surface-card); border-radius: 16px; padding: 32px; margin-bottom: 32px;
            border: 1px solid var(--border-subtle); box-shadow: var(--shadow-card);
            display: flex; justify-content: space-between; align-items: flex-start;
        }

        .ch-main h1 { font-family: 'Playfair Display', serif; font-size: 1.8rem; margin: 8px 0; color: var(--ink-primary); }

        .ch-meta { color: var(--ink-secondary); font-size: 0.9rem; display: flex; gap: 16px; align-items: center; font-family: 'Space Grotesk', monospace; }

        .status-badge {
            padding: 4px 12px; border-radius: 100px; font-size: 0.75rem; font-weight: 600; font-family: 'Inter', sans-serif;
            background: #ECFDF5; color: var(--success-green); border: 1px solid #D1FAE5; display: inline-block;
        }
        
        .feature-badge {
            display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 100px;
            font-size: 0.85rem; font-weight: 500; background: #FAFAFA; color: var(--ink-secondary); border: 1px solid var(--border-subtle);
        }

        /* GRID LAYOUT */
        .dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 32px; align-items: start; }

        /* SECTION CARDS */
        .section-card {
            background: var(--surface-card); border-radius: 16px; border: 1px solid var(--border-subtle); padding: 24px; box-shadow: var(--shadow-card);
        }

        .card-head {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid var(--border-subtle);
        }

        .card-title { font-weight: 600; font-size: 1.1rem; display: flex; align-items: center; gap: 8px; color: var(--ink-primary); }
        .card-title i { color: var(--gold-main); font-size: 1.4rem; }

        /* FINANCIALS */
        .financial-summary { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }

        .finance-box { background: #FAFAFA; padding: 20px; border-radius: 12px; border: 1px solid var(--border-subtle); }

        .fb-label { font-size: 0.75rem; color: var(--ink-secondary); text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600; }
        .fb-value { font-size: 1.6rem; font-weight: 700; margin-top: 8px; color: var(--ink-primary); font-family: 'Space Grotesk', monospace; }
        .fb-sub { font-size: 0.8rem; color: var(--alert-amber); margin-top: 8px; display: inline-block; font-weight: 500;}

        .transaction-list { list-style: none; padding: 0; margin: 0; }
        .transaction-item {
            display: flex; justify-content: space-between; align-items: center; padding: 16px 0; border-bottom: 1px dashed var(--border-subtle);
        }
        .transaction-item:last-child { border-bottom: none; padding-bottom: 0; }

        /* DOCUMENTS */
        .doc-list { display: grid; gap: 12px; }

        .doc-item {
            display: flex; align-items: center; padding: 16px; background: #FAFAFA; border-radius: 12px; border: 1px solid var(--border-subtle); transition: background 0.2s;
        }
        .doc-item:hover { background: #fff; border-color: var(--gold-dim); }

        .doc-icon {
            width: 44px; height: 44px; background: #fff; border: 1px solid var(--border-subtle); border-radius: 8px; display: grid; place-items: center; margin-right: 16px; color: var(--ink-tertiary); font-size: 1.5rem;
        }

        .doc-info { flex-grow: 1; display: flex; flex-direction: column; gap: 4px; }
        .doc-name { font-weight: 500; font-size: 0.95rem; color: var(--ink-primary); }
        .doc-meta { font-size: 0.8rem; color: var(--ink-secondary); display: flex; align-items: center; gap: 8px; }
        
        .doc-tag { font-size: 0.7rem; padding: 2px 8px; border-radius: 4px; background: #fff; border: 1px solid var(--border-subtle); font-weight: 500; }
        .doc-tag.confidential { color: var(--danger-red); border-color: #FECACA; background: #FEF2F2; }

        .btn-action {
            display: inline-flex; align-items: center; gap: 8px; background: var(--ink-primary); color: white;
            padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: 500; transition: all 0.2s; font-size: 0.9rem;
        }
        .btn-action:hover { background: var(--gold-main); transform: translateY(-2px); color: white; }

        /* TIMELINE */
        .timeline-track { position: relative; padding-left: 24px; padding-top: 8px; }
        .timeline-track::before { content: ''; position: absolute; left: 7px; top: 0; bottom: 0; width: 2px; background: var(--border-subtle); }

        .timeline-node { position: relative; margin-bottom: 32px; }
        .timeline-node:last-child { margin-bottom: 0; }

        .node-dot {
            position: absolute; left: -24px; top: 2px; width: 16px; height: 16px; border-radius: 50%;
            background: #FAFAFA; border: 2px solid var(--border-subtle);
        }
        .node-dot.active { background: var(--gold-main); border-color: var(--gold-main); box-shadow: 0 0 0 4px rgba(198, 167, 94, 0.1); }

        .node-date { font-size: 0.8rem; color: var(--ink-secondary); margin-bottom: 4px; font-family: 'Space Grotesk', monospace; font-weight: 500; }
        .node-title { font-weight: 600; font-size: 1rem; color: var(--ink-primary); }
        .node-desc { font-size: 0.9rem; color: var(--ink-secondary); margin-top: 6px; }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .dashboard-grid { grid-template-columns: 1fr; }
            .main-content { padding: 24px; }
        }
        @media (max-width: 768px) {
            .case-header { flex-direction: column; gap: 24px; }
            .financial-summary { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="layout-wrapper">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <a href="clientdashboard_manual.jsp" class="brand">
                <i class="ph-fill ph-scales brand-icon"></i>
                <h2>Justice4U</h2>
            </a>

            <div class="nav-group">
                <div class="nav-title">Client Workspace</div>
                <a href="clientdashboard_manual.jsp" class="nav-link"><i class="ph-duotone ph-squares-four"></i> Console</a>
                <a href="case.jsp" class="nav-link"><i class="ph-duotone ph-file-plus"></i> File Case</a>
                <a href="ClientDashboard" class="nav-link"><i class="ph-duotone ph-briefcase"></i> My Portfolio</a>
            </div>
            
            <div class="nav-group">
                <div class="nav-title">Lawyer Network</div>
                <a href="findlawyer.jsp" class="nav-link"><i class="ph-duotone ph-magnifying-glass"></i> Find Counsel</a>
                <a href="viewlawdetails.jsp" class="nav-link"><i class="ph-duotone ph-identification-card"></i> Assigned Lawyer</a>
            </div>

            <a href="csignout.jsp" class="logout-link"><i class="ph-duotone ph-sign-out"></i> Secure Logout</a>
        </aside>

        <!-- MAIN WINDOW -->
        <main class="main-content">
            
            <div style="margin-bottom: 24px;" class="smart-enter d-1">
                <a href="clientdashboard_manual.jsp" style="text-decoration: none; color: var(--ink-secondary); font-size: 0.9rem; display: inline-flex; align-items: center; gap: 6px; font-weight: 500;">
                    <i class="ph-bold ph-arrow-left"></i> Return to Console
                </a>
            </div>

            <%
                Connection con = getDatabaseConnection();
                try {
                    String fetchSql = "SELECT cc.*, c.title as original_title, c.des, c.curdate, " + 
                                      "l.lname as lawyer_name, l.email as lawyer_email " +
                                      "FROM customer_cases cc " +
                                      "LEFT JOIN casetb c ON cc.case_id = c.cid " +
                                      "LEFT JOIN lawyer_reg l ON cc.assigned_lawyer_id = l.lid " +
                                      "WHERE cc.customer_id = ? ";
                    
                    if(reqCaseId != null && !reqCaseId.isEmpty()) {
                        fetchSql += "AND cc.case_id = " + com.j4u.Sanitizer.sanitize(reqCaseId) + " ";
                    }
                    
                    fetchSql += "ORDER BY cc.case_id DESC LIMIT 1";

                    PreparedStatement psCase = con.prepareStatement(fetchSql);
                    psCase.setInt(1, customerId);
                    ResultSet rs = psCase.executeQuery();

                    if(rs.next()) {
                        int caseId = rs.getInt("case_id");
                        String caseTitle = rs.getString("custom_case_title");
                        if(caseTitle == null || caseTitle.isEmpty()) caseTitle = rs.getString("original_title");
                        
                        String phase = rs.getString("current_phase");
                        if(phase == null) phase = "Case Initiated";
                        
                        String vakalatnama = rs.getString("vakalatnama_status");
                        
                        double totalFee = rs.getDouble("total_fee");
                        double paidAmt = rs.getDouble("paid_amount");
                        double dueAmt = totalFee - paidAmt;
                        
                        java.sql.Date nextDue = rs.getDate("next_payment_due_date");
                        String dueDateStr = (nextDue != null) ? nextDue.toString() : "N/A";
            %>

            <!-- CASE HEADER -->
            <div class="case-header smart-enter d-1">
                <div class="ch-main">
                    <div class="ch-meta">
                        <span class="status-badge">ACTIVE ENGAGEMENT</span>
                        <span>REF #<%= caseId %></span>
                        <span><i class="ph-bold ph-calendar-blank"></i> Since <%= com.j4u.Sanitizer.sanitize(rs.getString("curdate")) %></span>
                    </div>
                    <h1><%= com.j4u.Sanitizer.sanitize(caseTitle) %></h1>
                    
                    <div style="margin-top: 16px; display: flex; gap: 12px; flex-wrap: wrap;">
                        <span class="feature-badge">
                            <i class="ph-fill ph-file-text" style="color:var(--gold-main);"></i> 
                            Vakalatnama: <%= (vakalatnama!=null) ? com.j4u.Sanitizer.sanitize(vakalatnama) : "Pending" %>
                        </span>
                        <span class="feature-badge">
                             <i class="ph-fill ph-trend-up" style="color:var(--ink-primary);"></i> Phase: <%= com.j4u.Sanitizer.sanitize(phase) %>
                        </span>
                    </div>
                </div>
                
                <div style="text-align: right; min-width: 150px; background: #FAFAFA; padding: 16px 20px; border-radius: 12px; border: 1px solid var(--border-subtle);">
                    <div style="font-size: 0.75rem; color: var(--ink-secondary); text-transform:uppercase; letter-spacing:0.05em; margin-bottom: 4px; font-weight:600;">Lead Counsel</div>
                    <div style="font-weight: 600; font-family:'Playfair Display', serif; font-size: 1.2rem; color: var(--ink-primary);"><%= com.j4u.Sanitizer.sanitize(rs.getString("lawyer_name")) %></div>
                    <a href="viewlawdetails.jsp?id=<%= com.j4u.Sanitizer.sanitize(rs.getString("lawyer_email")) %>" style="font-size: 0.85rem; color: var(--gold-dim); text-decoration: none; font-weight: 500; display: inline-flex; align-items:center; gap:4px; margin-top: 8px;">
                        Full Profile <i class="ph-bold ph-arrow-right"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-grid smart-enter d-2">
                
                <!-- LEFT COLUMN -->
                <div style="display:flex; flex-direction:column; gap:32px;">
                    
                    <!-- TIMELINE -->
                    <div class="section-card">
                        <div class="card-head">
                            <div class="card-title"><i class="ph-duotone ph-clock-countdown"></i> Case Timeline</div>
                        </div>
                        
                        <div class="timeline-track">
                            <%
                                PreparedStatement psHist = con.prepareStatement("SELECT * FROM case_history WHERE case_id=? ORDER BY event_date DESC");
                                psHist.setInt(1, caseId);
                                ResultSet rsHist = psHist.executeQuery();
                                boolean hasHist = false;
                                while(rsHist.next()) {
                                    hasHist = true;
                            %>
                            <div class="timeline-node">
                                <div class="node-dot"></div>
                                <div class="node-date"><%= com.j4u.Sanitizer.sanitize(rsHist.getDate("event_date").toString()) %></div>
                                <div class="node-title"><%= com.j4u.Sanitizer.sanitize(rsHist.getString("event_description")) %></div>
                            </div>
                            <%
                                }
                                if(!hasHist) {
                            %>
                            <div class="timeline-node">
                                <div class="node-dot active"></div>
                                <div class="node-date">Just Now</div>
                                <div class="node-title">Dashboard Initialized</div>
                                <div class="node-desc">Your intelligent case tracking system is now active. Processing next steps.</div>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- DOCUMENTS -->
                    <div class="section-card">
                        <div class="card-head">
                            <div class="card-title"><i class="ph-duotone ph-files"></i> Document Centre</div>
                            <a href="upload_case_doc.jsp?case_id=<%= caseId %>" class="btn-action" style="padding:8px 16px; font-size:0.85rem;"><i class="ph-bold ph-upload-simple"></i> Upload</a>
                        </div>

                        <div class="doc-list">
                            <%
                                PreparedStatement psDoc = con.prepareStatement("SELECT * FROM documents WHERE case_id=? ORDER BY upload_date DESC");
                                psDoc.setInt(1, caseId);
                                ResultSet rsDoc = psDoc.executeQuery();
                                boolean hasDocs = false;
                                while(rsDoc.next()) {
                                    hasDocs = true;
                                    String status = rsDoc.getString("doc_status");
                                    boolean conf = rsDoc.getBoolean("is_confidential");
                            %>
                            <div class="doc-item">
                                <div class="doc-icon"><i class="ph-fill ph-file-pdf"></i></div>
                                <div class="doc-info">
                                    <div class="doc-name"><%= com.j4u.Sanitizer.sanitize(rsDoc.getString("document_name")) %></div>
                                    <div class="doc-meta">
                                        Uploaded by <%= com.j4u.Sanitizer.sanitize(rsDoc.getString("uploaded_by")) %>
                                        <% if(conf) { %><span class="doc-tag confidential">Classified</span><% } %>
                                        <span class="doc-tag"><%= status != null ? com.j4u.Sanitizer.sanitize(status) : "Draft" %></span>
                                    </div>
                                </div>
                                <button style="border:none; background:#fff; border:1px solid var(--border-subtle); border-radius:8px; padding:8px 12px; cursor:pointer; color:var(--ink-secondary); transition:all 0.2s;" onmouseover="this.style.borderColor='var(--ink-primary)'; this.style.color='var(--ink-primary)'" onmouseout="this.style.borderColor='var(--border-subtle)'; this.style.color='var(--ink-secondary)'"><i class="ph-bold ph-download-simple"></i></button>
                            </div>
                            <%
                                }
                                if(!hasDocs) {
                            %>
                                <div style="text-align:center; color:var(--ink-tertiary); padding:32px 20px; background:#FAFAFA; border-radius:12px; border:1px dashed var(--border-subtle);">
                                    <i class="ph-duotone ph-folder-open" style="font-size:2rem; margin-bottom:8px;"></i><br>
                                    No documents deposited yet.
                                </div>
                            <% } %>
                        </div>
                    </div>

                </div>

                <!-- RIGHT COLUMN -->
                <div style="display:flex; flex-direction:column; gap:32px;">
                    
                    <!-- FINANCIALS -->
                    <div class="section-card">
                        <div class="card-head">
                            <div class="card-title"><i class="ph-duotone ph-wallet"></i> Ledger & Billing</div>
                        </div>
                        
                        <div class="financial-summary">
                            <div class="finance-box">
                                <div class="fb-label">Total Agreed</div>
                                <div class="fb-value">₹<%= (int)totalFee %></div>
                            </div>
                            <div class="finance-box" style="border-color: rgba(217, 119, 6, 0.3); background: #FFFBEB;">
                                <div class="fb-label">Outstanding Balance</div>
                                <div class="fb-value" style="color:var(--alert-amber)">₹<%= (int)dueAmt %></div>
                                <span class="fb-sub"><i class="ph-bold ph-clock"></i> Due: <%= com.j4u.Sanitizer.sanitize(dueDateStr) %></span>
                            </div>
                        </div>

                        <h4 style="font-size: 0.85rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--ink-secondary); margin: 32px 0 16px 0; font-weight:600;">Recent Transactions</h4>
                        <ul class="transaction-list">
                            <%
                                PreparedStatement psPay = con.prepareStatement("SELECT * FROM payments WHERE case_id=? ORDER BY payment_date DESC LIMIT 5");
                                psPay.setInt(1, caseId);
                                ResultSet rsPay = psPay.executeQuery();
                                boolean hasTrans = false;
                                while(rsPay.next()) {
                                    hasTrans = true;
                            %>
                            <li class="transaction-item">
                                <div>
                                    <div style="font-weight: 600; font-family:'Space Grotesk', monospace;">₹<%= rsPay.getDouble("amount") %></div>
                                    <div style="font-size: 0.8rem; color: var(--ink-secondary);"><%= rsPay.getDate("payment_date") %></div>
                                </div>
                                <span class="status-badge" style="background:#F0FDF4; color:#15803D; border:none; font-size:0.7rem;"><%= com.j4u.Sanitizer.sanitize(rsPay.getString("status")) %></span>
                            </li>
                            <% } 
                               if(!hasTrans) {
                            %>
                               <li style="text-align:center; padding:20px; color:var(--ink-tertiary); font-size:0.9rem;">No payment history recorded.</li>
                            <% } %>
                        </ul>
                    </div>

                    <!-- SECURE COMMUNICATOR -->
                    <div class="section-card">
                        <div class="card-head" style="margin-bottom:16px; border:none; padding:0;">
                            <div class="card-title"><i class="ph-duotone ph-shield-check"></i> Secure Comms</div>
                        </div>
                        <p style="font-size:0.9rem; color:var(--ink-secondary); margin-bottom:24px;">All messages are fully encrypted point-to-point.</p>
                        
                        <div style="display: grid; gap: 12px;">
                            <a href="chat.jsp?case_id=<%= caseId %>" class="btn-action" style="justify-content: center; padding:14px; background:var(--ink-primary);">
                                <i class="ph-bold ph-chats"></i> Launch Secure Chat
                            </a>
                        </div>
                    </div>

                </div>
            </div>

            <%
                    } else {
            %>
                <div class="smart-enter d-1" style="text-align: center; padding: 100px 20px; background:var(--surface-card); border-radius:16px; border:1px solid var(--border-subtle); box-shadow:var(--shadow-card);">
                    <i class="ph-duotone ph-magnifying-glass" style="font-size:4rem; color:var(--ink-tertiary); margin-bottom:24px;"></i>
                    <h2 style="font-family:'Playfair Display', serif; color: var(--ink-primary); margin:0 0 12px 0;">No Intelligence Data Found</h2>
                    <p style="color:var(--ink-secondary); margin:0 0 32px 0;">Select an active case from your portfolio to view its intelligence dashboard.</p>
                    <a href="ClientDashboard" class="btn-action">Return to Portfolio</a>
                </div>
            <%
                    }
                    con.close();
                } catch(Exception e) {
                    e.printStackTrace();
            %>
                <div style="background: #FEF2F2; border: 1px solid #FECACA; color: var(--danger-red); padding: 24px; border-radius: 12px; margin-top: 24px;">
                    <i class="ph-fill ph-warning-circle" style="font-size:1.5rem; float:left; margin-right:12px;"></i>
                    <strong>System Error Encountered:</strong><br>
                    <%= com.j4u.Sanitizer.sanitize(e.getMessage()) %>
                </div>
            <%
                }
            %>

        </main>
    </div>
</body>
</html>
