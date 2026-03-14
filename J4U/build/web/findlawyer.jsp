<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
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
    <title>Justice4U · Find Counsel</title>
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
        .d-3 { animation-delay: 0.3s; }
        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* PAGE HEADER */
        .page-header { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-end; }
        .page-header h1 { font-family: 'Playfair Display', serif; font-size: 2.2rem; margin: 0 0 8px 0; color: var(--ink-primary); }
        .page-header p { color: var(--ink-secondary); margin: 0; font-family: 'Inter', sans-serif; font-size: 0.95rem; }

        /* SEARCH BAR */
        .search-container {
            background: var(--surface-card); border-radius: 16px; border: 1px solid var(--border-subtle);
            padding: 8px; box-shadow: var(--shadow-card); display: flex; margin-bottom: 40px;
        }
        .search-input {
            flex: 1; border: none; padding: 16px 24px; font-size: 1rem; color: var(--ink-primary);
            background: transparent; outline: none; font-family: 'Inter', sans-serif;
        }
        .search-input::placeholder { color: var(--ink-tertiary); }
        .btn-search {
            background: var(--ink-primary); color: #fff; border: none; padding: 0 32px;
            border-radius: 10px; font-weight: 600; transition: all 0.2s; cursor: pointer;
            display: flex; align-items: center; gap: 8px; font-size: 0.95rem;
        }
        .btn-search:hover { background: var(--gold-main); }

        /* LAWYERS GRID */
        .lawyers-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 24px;
        }

        .lawyer-card {
            background: var(--surface-card); border-radius: 16px; border: 1px solid var(--border-subtle);
            padding: 24px; display: flex; flex-direction: column; transition: all 0.3s var(--ease-smart);
            position: relative; overflow: hidden;
        }
        .lawyer-card:hover {
            transform: translateY(-4px); box-shadow: 0 12px 24px rgba(198, 167, 94, 0.08); border-color: var(--gold-dim);
        }

        .lawyer-header { display: flex; gap: 16px; align-items: center; margin-bottom: 20px; }
        .lawyer-avatar {
            width: 56px; height: 56px; border-radius: 50%; background: #FAFAFA; border: 1px solid var(--border-subtle);
            display: grid; place-items: center; font-size: 1.4rem; color: var(--ink-primary); font-family: 'Playfair Display', serif; flex-shrink: 0;
        }
        .lawyer-card:hover .lawyer-avatar { background: #FFFAF0; color: var(--gold-main); border-color: rgba(198, 167, 94, 0.3); }

        .lawyer-info h3 { margin: 0 0 4px 0; font-family: 'Playfair Display', serif; font-size: 1.25rem; color: var(--ink-primary); }
        .lawyer-info .verified {
            font-size: 0.75rem; color: var(--success-green); font-weight: 600; display: inline-flex; align-items: center; gap: 4px; background: rgba(5, 150, 105, 0.1); padding: 2px 8px; border-radius: 100px;
        }

        .lawyer-details { flex: 1; display: flex; flex-direction: column; gap: 12px; margin-bottom: 24px; }
        .detail-item { display: flex; align-items: center; gap: 10px; font-size: 0.9rem; color: var(--ink-secondary); }
        .detail-item i { color: var(--gold-dim); font-size: 1.1rem; }

        .btn-hire {
            display: flex; justify-content: center; align-items: center; gap: 8px;
            padding: 12px; border-radius: 8px; font-weight: 500; font-size: 0.95rem;
            background: #FAFAFA; border: 1px solid var(--border-subtle); color: var(--ink-primary);
            text-decoration: none; transition: all 0.2s; width: 100%;
        }
        .lawyer-card:hover .btn-hire { background: var(--ink-primary); color: #fff; border-color: var(--ink-primary); }
        .lawyer-card .btn-hire:hover { background: var(--gold-main); border-color: var(--gold-main); }
        
        .empty-state {
            grid-column: 1 / -1; text-align: center; padding: 64px 24px; background: #FAFAFA; border-radius: 16px; border: 1px solid var(--border-subtle);
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
                <a href="#" class="nav-link active"><i class="ph-duotone ph-magnifying-glass"></i> Find Counsel</a>
                <a href="viewlawdetails.jsp" class="nav-link"><i class="ph-duotone ph-identification-card"></i> Assigned Lawyer</a>
            </div>

            <a href="csignout.jsp" class="logout-link"><i class="ph-duotone ph-sign-out"></i> Secure Logout</a>
        </aside>

        <!-- MAIN WINDOW -->
        <main class="main-content">
            
            <div class="page-header smart-enter d-1">
                <div>
                    <h1>Find Your Legal Expert</h1>
                    <p>Browse our network of verified professionals available for immediate consultation.</p>
                </div>
            </div>

            <form class="search-container smart-enter d-2" action="findlawyer.jsp" method="get">
                <input type="text" name="q" class="search-input" placeholder="Search by name, expertise, or location..." value="<%= com.j4u.Sanitizer.sanitize(request.getParameter("q") != null ? request.getParameter("q") : "") %>">
                <button type="submit" class="btn-search"><i class="ph-bold ph-magnifying-glass"></i> Search</button>
            </form>

            <div class="lawyers-grid smart-enter d-3">
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
                %>
                <div class="lawyer-card">
                    <div class="lawyer-header">
                        <div class="lawyer-avatar"><%= name != null && !name.isEmpty() ? name.charAt(0) : "L" %></div>
                        <div class="lawyer-info">
                            <h3><%= com.j4u.Sanitizer.sanitize(name) %></h3>
                            <span class="verified"><i class="ph-fill ph-seal-check"></i> Verified Attorney</span>
                        </div>
                    </div>
                    <div class="lawyer-details">
                        <div class="detail-item"><i class="ph-fill ph-map-pin"></i> <%= location != null ? com.j4u.Sanitizer.sanitize(location) : "Location unspecified" %></div>
                        <div class="detail-item"><i class="ph-fill ph-envelope-simple"></i> <%= com.j4u.Sanitizer.sanitize(email) %></div>
                        <div class="detail-item"><i class="ph-fill ph-briefcase"></i> Accepting New Cases</div>
                    </div>
                    
                    <% 
                        String caseIdParam = request.getParameter("case_id");
                        if (caseIdParam != null && !caseIdParam.isEmpty()) {
                    %>
                        <a href="update_case_lawyer.jsp?case_id=<%= com.j4u.Sanitizer.sanitize(caseIdParam) %>&lawyer_email=<%= com.j4u.Sanitizer.sanitize(email) %>" class="btn-hire">Assign to Case #<%= com.j4u.Sanitizer.sanitize(caseIdParam) %></a>
                    <% } else { %>
                        <a href="case.jsp?lawyer_email=<%= com.j4u.Sanitizer.sanitize(email) %>&lawyer_name=<%= com.j4u.Sanitizer.sanitize(name) %>" class="btn-hire">Target for Inquiry <i class="ph-bold ph-arrow-right"></i></a>
                    <% } %>
                </div>
                <%
                    }
                    if(!hasResults) {
                %>
                    <div class="empty-state">
                        <i class="ph-duotone ph-magnifying-glass"></i>
                        <p>No legal experts found matching your criteria. Try adjusting your search.</p>
                    </div>
                <%
                    }
                    rs.close(); pst.close(); con.close();
                } catch(Exception e) {
                %>
                    <div class="empty-state" style="border-color: #FECACA; background: #FEF2F2;">
                        <i class="ph-fill ph-warning-circle" style="color: #DC2626;"></i>
                        <p style="color: #DC2626;">System error while searching: <%= com.j4u.Sanitizer.sanitize(e.getMessage()) %></p>
                    </div>
                <%
                }
                %>
            </div>

        </main>
    </div>
</body>
</html>
