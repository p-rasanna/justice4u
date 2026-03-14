<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*" %>
<%
    // Minimal session validation in View. Actual validation inside Servlet.
    String username = (String) session.getAttribute("cname");
    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }

    // Retrieve caseList pushed by ClientDashboardServlet
    List<Map<String, Object>> caseList = (List<Map<String, Object>>) request.getAttribute("caseList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Case Portfolio</title>
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
        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* PAGE HEADER */
        .page-header { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-end; }
        .page-header h1 { font-family: 'Playfair Display', serif; font-size: 2.2rem; margin: 0 0 8px 0; color: var(--ink-primary); }
        .page-header p { color: var(--ink-secondary); margin: 0; font-family: 'Inter', sans-serif; font-size: 0.95rem; }

        .btn-new-case {
            display: inline-flex; align-items: center; gap: 8px; background: var(--ink-primary); color: white;
            padding: 12px 24px; border-radius: 8px; font-weight: 500; text-decoration: none; transition: all 0.2s;
        }
        .btn-new-case:hover { background: var(--gold-main); transform: translateY(-2px); box-shadow: 0 8px 16px rgba(198, 167, 94, 0.2); }

        /* PANEL & TABLE */
        .panel {
            background: var(--surface-card); border-radius: 16px; border: 1px solid var(--border-subtle);
            box-shadow: var(--shadow-card); overflow: hidden;
        }

        .panel-head {
            padding: 24px 32px; border-bottom: 1px solid var(--border-subtle);
            background: #FAFAFA; display: flex; justify-content: space-between; align-items: center;
        }
        .panel-head h3 {
            font-family: 'Inter', sans-serif; font-size: 1.1rem; margin: 0; 
            font-weight: 600; color: var(--ink-primary); display: flex; align-items: center; gap: 10px;
        }
        .panel-icon { color: var(--gold-main); font-size: 1.4rem; }

        .table-responsive { width: 100%; overflow-x: auto; }
        .table { margin: 0; width: 100%; border-collapse: collapse; }
        .table thead th {
            background: #FFF; color: var(--ink-secondary);
            font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
            padding: 16px 32px; border-bottom: 1px solid var(--border-subtle);
            font-family: 'Inter', sans-serif; white-space: nowrap;
        }
        .table tbody tr { transition: background 0.2s; border-bottom: 1px solid #FAFAFA; }
        .table tbody tr:hover { background: #FCFCFA; }
        .table tbody td { padding: 20px 32px; font-size: 0.9rem; color: var(--ink-primary); vertical-align: middle; }

        .case-id { font-family: 'Space Grotesk', monospace; color: var(--ink-secondary); font-weight: 600; font-size: 0.85rem; }
        .col-main { font-weight: 600; font-family: 'Inter', sans-serif; color: var(--ink-primary); margin-bottom: 4px; display: block; }
        .col-sub { color: var(--ink-secondary); font-size: 0.8rem; }
        
        .truncate-text { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        /* STATUS BADGES */
        .status-badge {
            display: inline-block; padding: 4px 10px; border-radius: 100px; font-size: 0.75rem; font-weight: 600; white-space: nowrap;
        }
        .status-open { background: #F8FAFC; color: var(--ink-secondary); border: 1px solid var(--border-subtle); }
        .status-assigned { background: #ECFDF5; color: var(--success-green); border: 1px solid #D1FAE5; }
        .status-pending { background: #FFFBEB; color: var(--alert-amber); border: 1px solid #FEF3C7; }
        .status-rejected { background: #FEF2F2; color: var(--danger-red); border: 1px solid #FCA5A5; }

        /* TAG PILLS */
        .tag-pill {
            display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 0.8rem; background: #FAFAFA; border: 1px solid var(--border-subtle);
        }

        /* ACTIONS */
        .action-link {
            font-weight: 500; text-decoration: none; font-size: 0.85rem; display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 6px; transition: all 0.2s;
        }
        .action-select { background: var(--gold-main); color: #fff; }
        .action-select:hover { background: var(--gold-dim); transform: translateY(-1px); }
        
        .action-chat { background: var(--ink-primary); color: #fff; }
        .action-chat:hover { background: var(--gold-main); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(198, 167, 94, 0.2); }

        .empty-state {
            text-align: center; padding: 64px 24px; background: #FAFAFA;
        }
        .empty-state i { font-size: 3rem; color: var(--ink-tertiary); margin-bottom: 16px; }
        .empty-state p { margin: 0 0 16px 0; color: var(--ink-secondary); font-size: 1.1rem; }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .main-content { padding: 24px; }
            .page-header { flex-direction: column; align-items: flex-start; gap: 16px; }
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
                <a href="ClientDashboard" class="nav-link active"><i class="ph-duotone ph-briefcase"></i> My Portfolio</a>
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
            
            <div class="page-header smart-enter d-1">
                <div>
                    <h1>My Cases Registry</h1>
                    <p>View the complete history and status of your legal matters.</p>
                </div>
                <a href="case.jsp" class="btn-new-case"><i class="ph-bold ph-plus"></i> New Inquiry</a>
            </div>

            <div class="panel smart-enter d-2">
                <div class="panel-head">
                    <div class="panel-head-left">
                        <h3><i class="ph-fill ph-folders panel-icon"></i> Submitted Inquiries</h3>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Ref ID</th>
                                <th>Case Details</th>
                                <th>Description</th>
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
                                        String statusClass = "status-pending";
                                        
                                        if (status != null) {
                                            String uStatus = status.toUpperCase();
                                            if (uStatus.contains("REJECTED")) {
                                                displayStatus = "Rejected";
                                                statusClass = "status-rejected";
                                            } else if (uStatus.contains("ASSIGNED") || uStatus.contains("PROGRESS") || uStatus.contains("APPROVED") || uStatus.contains("ACCEPTED")) {
                                                displayStatus = "Approved";
                                                statusClass = "status-assigned";
                                            }
                                        }
                            %>
                                        <tr>
                                            <td class="case-id">#<%= caseItem.get("id") %></td>
                                            <td>
                                                <span class="col-main"><%= com.j4u.Sanitizer.sanitize((String)caseItem.get("title")) %></span>
                                                <span class="col-sub">₹<%= caseItem.get("amount") %> &bull; <%= caseItem.get("paymentMode") %></span>
                                            </td>
                                            <td>
                                                <div class="truncate-text" title="<%= com.j4u.Sanitizer.sanitize((String)caseItem.get("description")) %>">
                                                    <%= com.j4u.Sanitizer.sanitize((String)caseItem.get("description")) %>
                                                </div>
                                            </td>
                                            <td style="white-space:nowrap;"><i class="ph-bold ph-calendar-blank" style="color:var(--ink-tertiary);"></i> <%= caseItem.get("date") %></td>
                                            <td>
                                                <div style="display:flex; flex-direction:column; gap:4px; align-items:flex-start;">
                                                    <span class="tag-pill"><%= caseItem.get("courtType") %></span>
                                                    <span class="col-sub"><i class="ph-fill ph-map-pin"></i> <%= caseItem.get("city") %></span>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="status-badge <%= statusClass %>">
                                                    <%= displayStatus %>
                                                </span>
                                            </td>
                                            <td>
                                                <%
                                                    if (status != null && status.equalsIgnoreCase("OPEN")) {
                                                %>
                                                    <a href="findlawyer.jsp?case_id=<%= caseItem.get("id") %>" class="action-link action-select">Select Counsel</a>
                                                <%
                                                    } else if (status != null && (status.equalsIgnoreCase("ASSIGNED") || status.equalsIgnoreCase("ACCEPTED"))) {
                                                %>
                                                    <a href="client_chat.jsp?case_id=<%= caseItem.get("id") %>" class="action-link action-chat"><i class="ph-bold ph-chat-text"></i> Open Portal</a>
                                                <%
                                                    } else {
                                                %>
                                                    <span style="color:var(--ink-tertiary); font-size:0.85rem; font-weight:500;">Awaiting Review</span>
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
                                                <i class="ph-duotone ph-folder-open"></i>
                                                <p>No cases found in your portfolio.</p>
                                                <a href="case.jsp" class="btn-new-case">Start a New Inquiry</a>
                                            </div>
                                        </td>
                                    </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</body>
</html>
