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
    
    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Case History Logs</title>
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
        .main-content { flex: 1; padding: 40px 48px; max-width: 1200px; margin: 0 auto; }

        .smart-enter {
            opacity: 0; transform: translateY(15px);
            animation: enterUp 0.6s var(--ease-smart) forwards;
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }
        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* PAGE HEADER */
        .page-header { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-end; }
        .page-header h1 { font-family: 'Playfair Display', serif; font-size: 2.2rem; margin: 0 0 8px 0; color: var(--ink-primary); }
        .page-header p { color: var(--ink-secondary); margin: 0; font-family: 'Inter', sans-serif; font-size: 0.95rem; }

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

        .col-main { font-weight: 500; font-family: 'Inter', sans-serif; color: var(--ink-primary); }
        .col-sub { color: var(--ink-secondary); font-size: 0.8rem; margin-top: 4px; }
        
        .empty-state {
            text-align: center; padding: 64px 24px; background: #FAFAFA;
        }
        .empty-state i { font-size: 3rem; color: var(--ink-tertiary); margin-bottom: 16px; }
        .empty-state p { margin: 0; color: var(--ink-secondary); font-size: 1.1rem; }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .main-content { padding: 24px; }
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
            
            <div class="page-header smart-enter d-1">
                <div>
                    <h1>History Logs</h1>
                    <p>Review past legal consultations and discussions regarding your cases.</p>
                </div>
                <a href="clientdashboard_manual.jsp" class="nav-link" style="border:1px solid var(--border-subtle); background:#fff;"><i class="ph ph-arrow-left"></i> Dashboard</a>
            </div>

            <div class="panel smart-enter d-2">
                <div class="panel-head">
                    <div class="panel-head-left">
                        <h3><i class="ph-fill ph-chat-circle-text panel-icon"></i> Discussion Archive</h3>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Ref ID</th>
                                <th>Subject / Title</th>
                                <th>Date Logged</th>
                                <th>Details</th>
                                <th>Counsel Email</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = getDatabaseConnection();
                                    
                                    // Sanitize input to prevent XSS in SQL (though parameter binding handles it)
                                    String safeCname = username.replace("'", "''");
                                    
                                    PreparedStatement pst = con.prepareStatement("SELECT * FROM discussion WHERE cname=? ORDER BY cdate DESC");
                                    pst.setString(1, username);
                                    ResultSet rs = pst.executeQuery();
                                    boolean hasData = false;
                                    
                                    while(rs.next()) {
                                        hasData = true;
                                        int id = rs.getInt(1);
                                        String title = safeEncode(rs.getString(2));
                                        String cdate = safeEncode(rs.getString(3));
                                        String desc = safeEncode(rs.getString(4));
                                        String lawyerEmail = safeEncode(rs.getString(6));
                            %>
                            <tr>
                                <td style="font-family:'Space Grotesk', monospace; color:var(--ink-secondary);">#<%= id %></td>
                                <td class="col-main"><%= title %></td>
                                <td style="white-space:nowrap;"><i class="ph-bold ph-calendar-blank" style="color:var(--ink-tertiary);"></i> <%= cdate %></td>
                                <td><div style="max-width:300px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><%= desc %></div></td>
                                <td><%= lawyerEmail %></td>
                            </tr>
                            <%
                                    }
                                    if(!hasData) {
                            %>
                                    <tr>
                                        <td colspan="5">
                                            <div class="empty-state">
                                                <i class="ph-duotone ph-chat-teardrop-slash"></i>
                                                <p>No discussion history found for your account.</p>
                                            </div>
                                        </td>
                                    </tr>
                            <%
                                    }
                                    rs.close();
                                    pst.close();
                                    con.close();
                                } catch(Exception e) {
                            %>
                                    <tr>
                                        <td colspan="5" style="color:var(--danger-red); text-align:center; padding:20px;">
                                            Error loading history: <%= safeEncode(e.getMessage()) %>
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