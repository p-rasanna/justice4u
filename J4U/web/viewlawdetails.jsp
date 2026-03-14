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
                name = rs.getString("lname"); // Fixed: using lname instead of name
                email = rs.getString("email");
                phone = rs.getString("mobno"); // Fixed: using mobno instead of phone
                dob = rs.getString("dob");
                aadhar = rs.getString("ano"); // Correct: using ano
                address = rs.getString("cadd"); // Correct: using cadd            
                
                // Flexible handling for optional/extended columns
                try { profilePic = rs.getString("profile_pic"); if(profilePic == null) profilePic = "default_lawyer.jpg"; } catch(Exception e) {}
                try { designation = rs.getString("practice_area"); if(designation == null) designation = "Advocate"; } catch(Exception e) {}
                try { barId = rs.getString("bar_council_number"); if(barId == null) barId = "Not Listed"; } catch(Exception e) {}
                try { courts = rs.getString("practice_area"); if(courts == null) courts = "General Practice"; } catch(Exception e) {}
                try { languages = rs.getString("languages_spoken"); if(languages == null) languages = "English, Hindi"; } catch(Exception e) {}
                
                // Status mapping: if status is APPROVED/VERIFIED, consider it verified
                try { 
                    String status = rs.getString("status");
                    isVerified = "APPROVED".equalsIgnoreCase(status) || "VERIFIED".equalsIgnoreCase(status);
                } catch(Exception e) {}
                
                try { responseTime = rs.getString("response_time_avg"); if(responseTime == null) responseTime = "48 hours"; } catch(Exception e) {}
            }
            rs.close();
            pst.close();
        }
        con.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Assigned Lawyer Profile</title>
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

        /* PROFILE CARD */
        .profile-card {
            background: var(--surface-card); border-radius: 20px; box-shadow: var(--shadow-card);
            overflow: hidden; border: 1px solid var(--border-subtle);
        }

        .profile-header {
            position: relative; background: #FAFAFA; padding: 40px; border-bottom: 1px solid var(--border-subtle);
            display: flex; align-items: flex-end; gap: 32px;
        }

        .avatar-wrapper { position: relative; flex-shrink: 0; }
        .avatar {
            width: 120px; height: 120px; border-radius: 50%; border: 4px solid white; box-shadow: 0 10px 20px rgba(0,0,0,0.05);
            display: grid; place-items: center; background: #fff; border-color: var(--border-subtle); color: var(--ink-primary); font-size: 3rem; font-family: 'Playfair Display', serif;
        }
        .verified-tick {
            position: absolute; bottom: 4px; right: 4px; background: var(--success-green); color: white; width: 32px; height: 32px;
            border-radius: 50%; display: grid; place-items: center; border: 3px solid white; font-size: 1.1rem;
        }

        .header-info h1 { font-family: 'Playfair Display', serif; font-size: 2.2rem; margin: 0 0 12px 0; color: var(--ink-primary); }

        .designation-badge {
            background: #FAFAFA; padding: 6px 16px; border-radius: 100px; font-size: 0.85rem; border: 1px solid var(--border-subtle); color: var(--ink-secondary); font-weight: 500;
        }

        .bar-id { margin-top: 16px; font-size: 0.9rem; color: var(--ink-secondary); display: flex; align-items: center; gap: 6px; font-family: 'Space Grotesk', monospace; }

        /* CONTENT GRID */
        .content-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 40px; padding: 40px; }

        .section-title { font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--ink-tertiary); margin-bottom: 16px; font-weight: 600; }

        .info-group { margin-bottom: 32px; }
        .info-value { font-size: 1rem; color: var(--ink-primary); line-height: 1.6; }

        .pill-container { display: flex; flex-wrap: wrap; gap: 10px; }
        .pill { background: #FAFAFA; color: var(--ink-primary); padding: 8px 16px; border-radius: 8px; font-size: 0.9rem; border: 1px solid var(--border-subtle); }

        /* SIDEBAR ACTIONS IN PROFILE */
        .sidebar-actions { background: #FAFAFA; padding: 32px; border-radius: 16px; height: fit-content; border: 1px solid var(--border-subtle); }

        .action-btn {
            display: flex; align-items: center; justify-content: center; gap: 10px; width: 100%; padding: 14px;
            border: none; border-radius: 10px; font-weight: 600; cursor: pointer; text-decoration: none; transition: all 0.2s; margin-bottom: 16px; font-size: 0.95rem;
        }
        .btn-primary-action { background: var(--ink-primary); color: white; }
        .btn-primary-action:hover { background: var(--gold-main); transform: translateY(-1px); color: white; }
        .btn-secondary-action { background: white; color: var(--ink-primary); border: 1px solid var(--border-subtle); }
        .btn-secondary-action:hover { background: #FAFAFA; border-color: var(--ink-primary); }

        .stat-row { display: flex; justify-content: space-between; padding: 14px 0; border-bottom: 1px dashed var(--border-subtle); font-size: 0.95rem; }
        .stat-row:last-child { border: none; }
        .stat-label { color: var(--ink-secondary); }
        .stat-val { font-weight: 600; color: var(--ink-primary); }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .content-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .profile-header { flex-direction: column; align-items: flex-start; padding: 24px; }
            .content-grid { padding: 24px; gap: 24px; }
            .avatar { width: 100px; height: 100px; }
            .header-info h1 { font-size: 1.8rem; }
            .sidebar-actions { order: -1; margin-bottom: 24px; }
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
                <a href="#" class="nav-link active"><i class="ph-duotone ph-identification-card"></i> Assigned Lawyer</a>
            </div>

            <a href="csignout.jsp" class="logout-link"><i class="ph-duotone ph-sign-out"></i> Secure Logout</a>
        </aside>

        <!-- MAIN WINDOW -->
        <main class="main-content">
            
            <div style="margin-bottom: 32px;" class="smart-enter d-1">
                <a href="javascript:history.back()" style="text-decoration: none; color: var(--ink-secondary); font-size: 0.9rem; display: inline-flex; align-items: center; gap: 6px; font-weight: 500;">
                    <i class="ph-bold ph-arrow-left"></i> Back to Previous
                </a>
            </div>

            <div class="profile-card smart-enter d-2">
                
                <!-- HEADER -->
                <div class="profile-header">
                    <div class="avatar-wrapper">
                        <div class="avatar">
                            <%= name.isEmpty() ? "?" : name.charAt(0) %>
                        </div>
                        <% if(isVerified) { %>
                        <div class="verified-tick" title="Verified Practitioner">
                            <i class="ph-bold ph-check"></i>
                        </div>
                        <% } %>
                    </div>
                    
                    <div class="header-info">
                        <h1><%= safeEncode(name) %></h1>
                        <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
                            <span class="designation-badge"><%= safeEncode(designation) %></span>
                            <% if(isVerified) { %>
                                <span class="designation-badge" style="background:#ECFDF5; border-color:#D1FAE5; color:var(--success-green); font-weight:600;">
                                    <i class="ph-fill ph-shield-check"></i> Justice4U Verified
                                </span>
                            <% } %>
                        </div>
                        <div class="bar-id">
                            <i class="ph-bold ph-identification-card" style="color:var(--gold-main);"></i> 
                            Bar Council ID: <%= safeEncode(barId) %>
                        </div>
                    </div>
                </div>

                <div class="content-grid">
                    
                    <!-- MAIN INFO -->
                    <div class="main-details">
                        
                        <div class="info-group">
                            <div class="section-title">Practicing Courts</div>
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
                                <i class="ph-duotone ph-map-pin" style="color:var(--ink-secondary); margin-right:8px;"></i>
                                <%= safeEncode(address) %>
                                <% if(!address.isEmpty()) { %>
                                    <a href="https://maps.google.com/?q=<%= safeEncode(address) %>" target="_blank" style="font-size:0.85rem; margin-left:8px; color:var(--gold-main); font-weight:500; text-decoration:none;">
                                        (View on Map)
                                    </a>
                                <% } %>
                            </div>
                        </div>

                    </div>

                    <!-- SIDEBAR ACTIONS -->
                    <div class="sidebar-actions">
                        <div class="section-title" style="margin-bottom:24px;">Contact & Availability</div>
                        
                        <div style="margin-bottom:32px;">
                            <div class="stat-row">
                                <span class="stat-label">Status</span>
                                <span class="stat-val" style="color:var(--success-green); display:flex; align-items:center; gap:6px;">
                                    <span style="display:inline-block; width:8px; height:8px; background:var(--success-green); border-radius:50%;"></span>
                                    Available
                                </span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">Avg. Response</span>
                                <span class="stat-val"><%= safeEncode(responseTime) %></span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">Email</span>
                                <span class="stat-val" style="font-size:0.85rem;"><%= safeEncode(email) %></span>
                            </div>
                        </div>

                        <a href="case.jsp?lawyer_email=<%= safeEncode(email) %>&lawyer_name=<%= safeEncode(name) %>" class="action-btn btn-primary-action">
                            Select for New Case <i class="ph-bold ph-arrow-right"></i>
                        </a>
                        
                        <!-- 
                        <button class="action-btn btn-secondary-action" onclick="alert('Video consultation feature coming soon!')">
                            <i class="ph-bold ph-video-camera"></i> Schedule Consult
                        </button>
                        -->

                    </div>

                </div>
            </div>

        </main>
    </div>

</body>
</html>
