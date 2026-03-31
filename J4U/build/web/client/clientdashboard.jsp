<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig, com.j4u.NotificationService" %>
<%
    String email = (String) session.getAttribute("cname");
    String profileType = (String) session.getAttribute("profileType");
    if (profileType == null) profileType = "manual";
    if (email == null) { response.sendRedirect("../auth/Login.jsp"); return; }
    
    int mC=0, uH=0, uM=0, mD=0;
    try (Connection con = DatabaseConfig.getConnection()) {
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM casetb c JOIN cust_reg cr ON c.cname=cr.cname WHERE cr.email=? AND c.case_type=?")){ 
            p.setString(1,email); 
            p.setString(2, profileType);
            try(ResultSet r = p.executeQuery()){ if(r.next()) mC=r.getInt(1); } 
        }
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM hearings h JOIN casetb c ON h.case_id=c.cid JOIN cust_reg cr ON c.cname=cr.cname WHERE cr.email=? AND h.hearing_date >= CURDATE()")){ 
            p.setString(1,email); 
            try(ResultSet r = p.executeQuery()){ if(r.next()) uH=r.getInt(1); } 
        }
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_email=? AND is_read=0")){ 
            p.setString(1,email); 
            try(ResultSet r = p.executeQuery()){ if(r.next()) uM=r.getInt(1); } 
        }
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM case_documents cd JOIN casetb c ON cd.case_id=c.cid JOIN cust_reg cr ON c.cname=cr.cname WHERE cr.email=?")){ 
            p.setString(1,email); 
            try(ResultSet r = p.executeQuery()){ if(r.next()) mD=r.getInt(1); } 
        }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Client Dashboard"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_topbar.jsp" />
        <jsp:include page="../shared/_sidebar.jsp" />
        
        <main class="app-main">
            <!-- Content Header -->
            <div class="app-content-header">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-sm-6">
                            <h3 class="mb-0 text-serif">Client Portal</h3>
                        </div>
                        <div class="col-sm-6 text-end">
                            <ol class="breadcrumb float-sm-end">
                                <li class="breadcrumb-item"><a href="#" class="text-gold">Home</a></li>
                                <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Body -->
            <div class="app-content">
                <div class="container-fluid">
                    <% if(request.getParameter("msg")!=null){ %>
                        <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-4">
                            <i class="bi bi-info-circle-fill me-2"></i>
                            <%=request.getParameter("msg")%>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <!-- Stats Boxes -->
                    <div class="row g-4 mb-4">
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="info-box shadow-sm">
                                <span class="info-box-icon bg-primary shadow-sm"><i class="bi bi-folder-fill"></i></span>
                                <div class="info-box-content">
                                    <span class="info-box-text text-uppercase small fw-bold text-muted">My Cases</span>
                                    <span class="info-box-number h4 mb-0"><%=mC%></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="info-box shadow-sm">
                                <span class="info-box-icon bg-info shadow-sm"><i class="bi bi-calendar-check-fill"></i></span>
                                <div class="info-box-content">
                                    <span class="info-box-text text-uppercase small fw-bold text-muted">Upcoming Hearings</span>
                                    <span class="info-box-number h4 mb-0"><%=uH%></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="info-box shadow-sm">
                                <span class="info-box-icon bg-success shadow-sm"><i class="bi bi-bell-fill"></i></span>
                                <div class="info-box-content">
                                    <span class="info-box-text text-uppercase small fw-bold text-muted">Unread Alerts</span>
                                    <span class="info-box-number h4 mb-0"><%=uM%></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="info-box shadow-sm">
                                <span class="info-box-icon bg-warning shadow-sm"><i class="bi bi-file-earmark-text-fill"></i></span>
                                <div class="info-box-content">
                                    <span class="info-box-text text-uppercase small fw-bold text-muted">Documents</span>
                                    <span class="info-box-number h4 mb-0"><%=mD%></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4">

                            <div class="card shadow-sm mb-4">
                                <div class="card-header border-0 bg-transparent">
                                    <h3 class="card-title text-serif"><i class="bi bi-journal-text text-gold me-2"></i> Active Case Inquiries</h3>
                                </div>
                                <div class="card-body p-0">
                                    <div class="list-group list-group-flush">
                                    <% 
                                        boolean ha=false; 
        try(PreparedStatement p = con.prepareStatement("SELECT c.cid, c.title, c.status, c.cdate, al.lname as lawyer_email, COALESCE(lr.name, lr.lname) as lawyer_name FROM casetb c JOIN cust_reg cr ON c.cname=cr.cname LEFT JOIN allotlawyer al ON al.cid=c.cid LEFT JOIN lawyer_reg lr ON lr.email=al.lname WHERE cr.email=? AND c.case_type=? ORDER BY c.cid DESC")) { 
                                            p.setString(1,email); 
                                            p.setString(2, profileType);
                                            try(ResultSet r=p.executeQuery()){ 
                                                while(r.next()){ 
                                                    ha=true; int id=r.getInt("cid"); 
                                                    String stat=r.getString("status"); 
                                                    String lName=r.getString("lawyer_name"); 
                                                    if(lName==null) lName="Pending Assignment"; 
                                    %>
                                        <div class="list-group-item p-4 d-flex justify-content-between align-items-center">
                                            <div>
                                                <h6 class="mb-1 fw-bold">#<%=id%> - <%=r.getString("title")%></h6>
                                                <div class="d-flex align-items-center gap-2">
                                                    <small class="text-muted"><i class="bi bi-person-badge me-1"></i> <%=lName%></small>
                                                    <span class="ms-2 badge <%="PENDING".equals(stat)?"bg-warning-subtle text-warning border-warning":"bg-dark-subtle text-dark border-dark"%> border fw-normal py-1"><%=stat%></span>
                                                </div>
                                                <small class="text-muted d-block mt-1"><i class="bi bi-calendar3 me-1"></i> <%=r.getString("cdate")%></small>
                                            </div>
                                            <div>
                                                <% if(!"Pending Assignment".equals(lName)){ %>
                                                    <a href="../shared/chat.jsp?case_id=<%=id%>" class="btn btn-sm btn-outline-success px-3 border-2 fw-bold">
                                                        <i class="bi bi-chat-left-dots-fill me-1"></i> Chat
                                                    </a>
                                                <% } else { %>
                                                    <button class="btn btn-sm btn-light border-0 text-muted disabled">
                                                        <i class="bi bi-hourglass-split me-1"></i> Waiting
                                                    </button>
                                                <% } %>
                                            </div>
                                        </div>
                                    <% 
                                                } 
                                            } 
                                        } 
                                        if(!ha){ 
                                    %>
                                        <div class='p-5 text-center text-muted'>
                                            <i class="bi bi-folder-plus fs-1 d-block mb-2 opacity-25"></i>
                                            You haven't initiated any case requests yet.
                                            <div class="mt-3">
                                                <a href="requestlawyer.jsp" class="btn btn-sm btn-gold px-4">Request Consultation</a>
                                            </div>
                                        </div>
                                    <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-5">
                            <!-- Hearings Card -->
                            <div class="card shadow-sm mb-4">
                                <div class="card-header border-0 bg-transparent">
                                    <h3 class="card-title text-serif"><i class="bi bi-calendar3 text-gold me-2"></i> Scheduled Hearings</h3>
                                </div>
                                <div class="card-body p-0">
                                    <div class="list-group list-group-flush">
                                    <% 
                                        boolean hh=false; 
                                        try(PreparedStatement p = con.prepareStatement("SELECT h.hearing_date, h.hearing_time, h.court_name, c.title FROM hearings h JOIN casetb c ON h.case_id=c.cid JOIN cust_reg cr ON cr.cname=c.cname WHERE cr.email=? AND h.hearing_date >= CURDATE() ORDER BY h.hearing_date ASC LIMIT 2")){ 
                                            p.setString(1,email); 
                                            try(ResultSet r=p.executeQuery()){ 
                                                while(r.next()){ 
                                                    hh=true; 
                                    %>
                                        <div class="list-group-item p-3 border-0">
                                            <div class="d-flex w-100 justify-content-between mb-1">
                                                <h6 class="mb-0 fw-bold text-gold"><%=r.getDate("hearing_date")%></h6>
                                                <small class="text-secondary opacity-75 fw-medium"><%=r.getTime("hearing_time")!=null?r.getTime("hearing_time").toString().substring(0,5):""%></small>
                                            </div>
                                            <p class="mb-1 small text-dark fw-medium"><%=r.getString("title")%></p>
                                            <small class="text-secondary fw-bold text-uppercase" style="font-size: 0.7rem;">
                                                <i class="bi bi-bank me-1"></i> <%=r.getString("court_name")%>
                                            </small>
                                        </div>
                                    <% 
                                                } 
                                            } 
                                        } 
                                        if(!hh){ 
                                    %>
                                        <div class='p-4 text-center text-muted border-top'>No upcoming hearings scheduled.</div>
                                    <% } %>
                                    </div>
                                </div>
                                <div class="card-footer bg-light-subtle text-center border-0 py-2">
                                    <a href="hearings.jsp" class="text-gold small fw-bold text-decoration-none">View Full Schedule</a>
                                </div>
                            </div>

                            <!-- Notifications/Alerts Card -->
                            <div class="card shadow-sm">
                                <div class="card-header border-0 bg-transparent">
                                    <h3 class="card-title text-serif"><i class="bi bi-bell-fill text-gold me-2"></i> Recent Updates</h3>
                                </div>
                                <div class="card-body p-0">
                                    <div class="list-group list-group-flush">
                                    <% 
                                        boolean hn=false; 
                                        try(PreparedStatement p = con.prepareStatement("SELECT message, type, link, created_at FROM notifications WHERE user_email=? AND is_read=0 ORDER BY created_at DESC LIMIT 5")){ 
                                            p.setString(1,email); 
                                            try(ResultSet r=p.executeQuery()){ 
                                                while(r.next()){ 
                                                    hn=true; 
                                                    String l=r.getString("link"); 
                                                    String t=r.getString("type"); 
                                                    String ic="bi-bell"; 
                                                    if("case".equals(t)) ic="bi-journal-bookmark-fill text-primary"; 
                                                    else if("message".equals(t)) ic="bi-chat-dots-fill text-success"; 
                                                    else if("hearing".equals(t)) ic="bi-calendar-event-fill text-warning"; 
                                                    else if("document".equals(t)) ic="bi-file-earmark-text-fill text-info"; 
                                    %>
                                        <div class="list-group-item p-3 border-0 border-bottom border-light">
                                            <div class="d-flex gap-3 align-items-start">
                                                <i class="bi <%=ic%> fs-5 pt-1"></i>
                                                <div class="flex-grow-1">
                                                    <% if(l!=null && !l.isEmpty()){ %>
                                                        <a href="<%=l%>" class="text-decoration-none text-dark small d-block mb-1"><%=r.getString("message")%></a>
                                                    <% } else { %>
                                                        <p class="mb-1 small"><%=r.getString("message")%></p>
                                                    <% } %>
                                                    <small class="text-secondary opacity-50" style="font-size:0.7rem"><i class="bi bi-clock me-1"></i><%=r.getTimestamp("created_at")%></small>
                                                </div>
                                            </div>
                                        </div>
                                    <% 
                                                } 
                                            } 
                                        } 
                                        if(!hn){ 
                                    %>
                                        <div class='p-5 text-center text-muted'>
                                            <i class="bi bi-check-all fs-1 d-block mb-2 opacity-25"></i>
                                            All caught up!
                                        </div>
                                    <% } %>
                                    </div>
                                </div>
                                <div class="card-footer bg-light-subtle text-center border-0 py-2">
                                    <a href="notifications.jsp" class="text-gold small fw-bold text-decoration-none">View All Notifications</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        
        <jsp:include page="../shared/_footer.jsp" />
    </div>
</body>
</html>
<% } catch (Exception e) { e.printStackTrace(); } %>
