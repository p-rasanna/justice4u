<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<% 
// Session validation
Integer lawyerId = (Integer) session.getAttribute("lid");
if (lawyerId == null) { 
    response.sendRedirect("Lawyer_login.html?msg=Session expired"); 
    return; 
} 

// Get case ID from parameter 
String caseIdParam = request.getParameter("caseid"); 
if (caseIdParam == null || caseIdParam.isEmpty()) {
    caseIdParam = request.getParameter("case"); // Viewcusdet passes ?case=...
}
if (caseIdParam == null || caseIdParam.isEmpty()) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Case ID required"); 
    return; 
} 

// Verify lawyer has access to this case 
boolean hasAccess = false; 
String caseTitle = ""; 
String clientName = "";
int caseId = 0;

try { 
    caseId = Integer.parseInt(caseIdParam);
    Connection con = getDatabaseConnection(); 
    
    // Check customer_cases
    String accessQuery = "SELECT cc.title, c.cname FROM customer_cases cc JOIN cust_reg c ON cc.customer_id = c.cid WHERE cc.case_id=? AND cc.assigned_lawyer_id=?"; 
    PreparedStatement accessPst = con.prepareStatement(accessQuery); 
    accessPst.setInt(1, caseId);
    accessPst.setInt(2, lawyerId); 
    ResultSet accessRs = accessPst.executeQuery(); 
    if (accessRs.next()) {
        hasAccess = true; 
        caseTitle = accessRs.getString("title"); 
        clientName = accessRs.getString("cname"); 
    }
    accessRs.close(); 
    accessPst.close(); 
    con.close(); 
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("Lawyerdashboard.jsp?msg=Database error"); 
    return; 
} 

if (!hasAccess) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Access denied to this case"); 
    return; 
} 
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Case Timeline | Justice4U</title>
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* ============================
           1. 10/10 INTELLIGENCE THEME
           ============================ */
        :root {
            --bg-ivory: #FAFAF8;
            --ink-primary: #121212;
            --ink-secondary: #555555;
            --ink-tertiary: #888888;
            
            --gold-main: #C6A75E;
            --gold-dim: #9C824A;
            --white-pure: #FFFFFF;
            --success-green: #059669;
            
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background-color: var(--bg-ivory);
            color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .dashboard-shell {
            max-width: 800px; margin: 0 auto; padding: 40px 32px;
        }

        .smart-enter {
            opacity: 0; transform: translateY(15px);
            animation: enterUp 0.6s var(--ease-smart) forwards;
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }

        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* HEADER */
        .admin-header {
            display: flex; justify-content: space-between; align-items: flex-end;
            margin-bottom: 40px; border-bottom: 1px solid var(--border-subtle); padding-bottom: 24px;
        }

        .header-content h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.2rem; margin: 0; color: var(--ink-primary);
        }
        
        .header-meta {
            display: flex; gap: 24px; align-items: center; margin-top: 8px;
            font-family: 'Space Grotesk', monospace; font-size: 0.8rem; color: var(--ink-secondary);
        }
        .meta-item { display: flex; align-items: center; gap: 6px; }

        .btn-back-header {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 8px 16px; border-radius: 100px; font-weight: 600; font-size: 0.85rem;
            text-decoration: none; border: 1px solid var(--border-subtle); background: #fff;
            color: var(--ink-primary); transition: all 0.2s; cursor: pointer;
        }
        .btn-back-header:hover { border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-1px); }

        /* TIMELINE LAYOUT */
        .panel {
            background: var(--surface-card); border: 1px solid var(--border-subtle);
            border-radius: 16px; overflow: hidden; box-shadow: var(--shadow-card);
            padding: 40px;
        }

        .timeline {
            position: relative; padding-left: 32px;
        }

        .timeline::before {
            content: ''; position: absolute; left: 16px; top: 0; bottom: 0;
            width: 2px; background: var(--border-subtle);
        }

        .timeline-item {
            position: relative; margin-bottom: 40px;
        }
        .timeline-item:last-child { margin-bottom: 0; }

        .timeline-icon-wrap {
            position: absolute; left: -32px; top: 0;
            width: 34px; height: 34px; display: flex; align-items: center; justify-content: center;
            background: var(--surface-card); border-radius: 50%;
            transform: translateX(-17px); z-index: 2;
        }

        .timeline-icon {
            width: 24px; height: 24px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            background: var(--gold-main); color: #fff; font-size: 0.8rem;
            box-shadow: 0 0 0 4px var(--surface-card), 0 0 0 5px rgba(198, 167, 94, 0.2);
        }

        .timeline-content {
            background: #FAFAF8; border: 1px solid var(--border-subtle);
            border-radius: 12px; padding: 24px; margin-left: 20px;
            transition: all 0.3s var(--ease-smart);
        }
        .timeline-content:hover {
            background: #fff; border-color: var(--gold-dim); box-shadow: 0 8px 24px rgba(0,0,0,0.03);
            transform: translateY(-2px);
        }

        .event-header {
            display: flex; justify-content: space-between; align-items: flex-start;
            margin-bottom: 12px;
        }

        .event-title {
            font-size: 1.1rem; font-weight: 600; color: var(--ink-primary); margin: 0;
        }

        .event-meta {
            font-family: 'Space Grotesk', monospace; font-size: 0.75rem; color: var(--ink-secondary);
            display: flex; flex-direction: column; align-items: flex-end; gap: 4px;
        }
        .event-meta span { display: flex; align-items: center; gap: 4px; }

        .event-desc {
            font-size: 0.95rem; color: var(--ink-secondary); line-height: 1.6; margin: 0;
        }

        .badge-type {
            display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px;
            background: #F0F0F0; color: var(--ink-secondary); border-radius: 100px;
            font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
            margin-top: 16px;
        }

        /* Empty State */
        .empty-state {
            text-align: center; padding: 60px 0; color: var(--ink-secondary);
        }
        .empty-icon {
            font-size: 3rem; color: var(--border-subtle); margin-bottom: 16px;
        }
    </style>
</head>
<body>
    <div class="dashboard-shell">
        <header class="admin-header smart-enter d-1">
            <div class="header-content">
                <h1>Case Timeline</h1>
                <div class="header-meta">
                    <span class="meta-item"><i class="ph-bold ph-scales"></i> <%= com.j4u.Sanitizer.sanitize(caseTitle) %></span>
                    <span class="meta-item"><i class="ph-bold ph-identification-card"></i> Case #<%= caseId %></span>
                </div>
            </div>
            <div>
                <button onclick="history.back()" class="btn-back-header"><i class="ph ph-arrow-left"></i> Back</button>
            </div>
        </header>

        <div class="panel smart-enter d-2">
            <div class="timeline">
<% 
boolean hasEvents = false;
try { 
    Connection con = getDatabaseConnection(); 
    String timelineQuery = "SELECT * FROM case_timeline WHERE alid=? ORDER BY event_date DESC"; 
    PreparedStatement timelinePst = con.prepareStatement(timelineQuery); 
    timelinePst.setInt(1, caseId);
    ResultSet timelineRs = timelinePst.executeQuery(); 
    
    while(timelineRs.next()) {
        hasEvents = true; 
        String eventType = timelineRs.getString("event_type"); 
        String eventDescription = timelineRs.getString("event_description"); 
        String eventDate = timelineRs.getString("event_date"); 
        String createdBy = timelineRs.getString("performed_by"); 
        
        String iconHtml = "" ; 
        switch(eventType) { 
            case "CASE_FILED": iconHtml="<i class='ph-bold ph-file-text'></i>"; break; 
            case "LAWYER_ASSIGNED": iconHtml="<i class='ph-bold ph-user-plus'></i>"; break; 
            case "ACCEPTED": iconHtml="<i class='ph-bold ph-check'></i>"; break; 
            case "DOCUMENTS_UPLOADED": iconHtml="<i class='ph-bold ph-folder-simple-plus'></i>"; break; 
            case "INTERN_ASSIGNED": iconHtml="<i class='ph-bold ph-graduation-cap'></i>"; break; 
            case "HEARING_SCHEDULED": iconHtml="<i class='ph-bold ph-gavel'></i>"; break; 
            case "CLOSED": iconHtml="<i class='ph-bold ph-lock'></i>"; break; 
            default: iconHtml="<i class='ph-bold ph-clock'></i>"; break; 
        } 
%>
                <div class="timeline-item">
                    <div class="timeline-icon-wrap">
                        <div class="timeline-icon">
                            <%= iconHtml %>
                        </div>
                    </div>
                    <div class="timeline-content">
                        <div class="event-header">
                            <h3 class="event-title"><%= eventType.replace("_", " " ) %></h3>
                            <div class="event-meta">
                                <span><i class="ph-bold ph-calendar"></i> <%= eventDate %></span>
                                <span><i class="ph-bold ph-user"></i> <%= createdBy %></span>
                            </div>
                        </div>
                        <p class="event-desc"><%= com.j4u.Sanitizer.sanitize(eventDescription) %></p>
                        <div class="badge-type">Audit Log</div>
                    </div>
                </div>
<% 
    } 
    timelineRs.close(); 
    timelinePst.close(); 
    
    // If no timeline events, show default case filed event
    if (!hasEvents) { 
        String defaultQuery = "SELECT cc.created_date FROM customer_cases cc WHERE cc.case_id=?"; 
        PreparedStatement defaultPst = con.prepareStatement(defaultQuery); 
        defaultPst.setInt(1, caseId); 
        ResultSet defaultRs = defaultPst.executeQuery(); 
        if (defaultRs.next()) {
            String filedDate = defaultRs.getString("created_date"); 
%>
                <div class="timeline-item">
                    <div class="timeline-icon-wrap">
                        <div class="timeline-icon" style="background:var(--ink-secondary)">
                            <i class='ph-bold ph-file-text'></i>
                        </div>
                    </div>
                    <div class="timeline-content">
                        <div class="event-header">
                            <h3 class="event-title">Case Formalized</h3>
                            <div class="event-meta">
                                <span><i class="ph-bold ph-calendar"></i> <%= filedDate %></span>
                                <span><i class="ph-bold ph-user"></i> System Generator</span>
                            </div>
                        </div>
                        <p class="event-desc">Case was formalized in the central repository by <%= com.j4u.Sanitizer.sanitize(clientName) %>.</p>
                        <div class="badge-type">Genesis</div>
                    </div>
                </div>
<% 
        } 
        defaultRs.close(); 
        defaultPst.close(); 
    } 
    con.close(); 
} catch(Exception e) { 
%>
                <div style="padding: 24px; background: rgba(220, 38, 38, 0.05); color: #DC2626; border-radius: 12px; border: 1px solid rgba(220, 38, 38, 0.2);">
                    <i class="ph-fill ph-warning-circle"></i> Error loading timeline: <%= e.getMessage() %>
                </div>
<% 
} 
%>
            </div>

<% if (!hasEvents) { %>
            <div class="empty-state">
                <i class="ph-duotone ph-clock-counter-clockwise empty-icon"></i>
                <div style="font-weight:600; font-size:1.1rem; color:var(--ink-primary); margin-bottom:8px;">Awaiting Milestones</div>
                <div>Events like physical court hearings and document payloads will automatically populate here in zero-latency real-time.</div>
            </div>
<% } %>
        </div>
    </div>
</body>
</html>