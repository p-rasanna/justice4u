<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig, com.j4u.NotificationService" %>
<%
    String email = (String) session.getAttribute("lname");
if (email == null) { response.sendRedirect("${pageContext.request.contextPath}/auth/Login.jsp"); return; }
    
    int tC=0, pA=0, uH=0, uM=0;
    try (Connection con = DatabaseConfig.getConnection()) {
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM allotlawyer WHERE lname=?")){ 
            p.setString(1,email); 
            try(ResultSet r = p.executeQuery()){ if(r.next()) tC=r.getInt(1); } 
        }
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM casetb c JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? AND c.status='ASSIGNED'")){ 
            p.setString(1,email); 
            try(ResultSet r = p.executeQuery()){ if(r.next()) pA=r.getInt(1); } 
        }
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM hearings h JOIN allotlawyer al ON al.cid=h.case_id WHERE al.lname=? AND h.hearing_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)")){ 
            p.setString(1,email); 
            try(ResultSet r = p.executeQuery()){ if(r.next()) uH=r.getInt(1); } 
        }
        try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_email=? AND is_read=0 AND type='message'")){ 
            p.setString(1,email); 
            try(ResultSet r = p.executeQuery()){ if(r.next()) uM=r.getInt(1); } 
        }
%>
<!DOCTYPE html>
<html lang="en">
<title>Lawyer Dashboard | Justice4U</title>
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Lawyer Dashboard"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_topbar.jsp" />
        <jsp:include page="../shared/_sidebar.jsp" />
        
        <main class="app-main">
            <!-- Content Header -->
            <div class="app-content-header mb-4">
                <div class="container-fluid">
                    <div class="row align-items-center">
                        <div class="col-sm-6">
                            <h2 class="mb-0 text-serif fw-bold">Attorney Portal</h2>
                            <p class="text-muted small mb-0">Manage your active casework and procedural calendar</p>
                        </div>
                        <div class="col-sm-6 text-end d-none d-sm-block">
                            <span class="badge badge-gold-subtle px-3 py-2">
                                <i class="bi bi-person-workspace me-1"></i> Active Practice
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Body -->
            <div class="app-content">
                <div class="container-fluid">
                    <% if(request.getParameter("msg")!=null){ %>
                        <div class="alert alert-success border-0 shadow-none small mb-4 py-3">
                            <i class="bi bi-check-circle-fill me-2 text-success"></i>
                            <%=request.getParameter("msg")%>
                        </div>
                    <% } %>

                    <!-- Stats Grid -->
                    <div class="row g-4 mb-5">
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="card p-4 border-0 shadow-none bg-white">
                                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Total Matters</div>
                                <div class="h2 fw-bold mb-0 text-serif"><%=tC%></div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="card p-4 border-0 shadow-none bg-white">
                                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Pending Acceptance</div>
                                <div class="h2 fw-bold mb-0 text-serif text-gold"><%=pA%></div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="card p-4 border-0 shadow-none bg-white">
                                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Upcoming Hearings</div>
                                <div class="h2 fw-bold mb-0 text-serif text-primary"><%=uH%></div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-3">
                            <div class="card p-4 border-0 shadow-none bg-white">
                                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">New Messages</div>
                                <div class="h2 fw-bold mb-0 text-serif text-success"><%=uM%></div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4">
                        <div class="col-lg-8">
                            <!-- Case Requests -->
                            <div class="card border-0 bg-white mb-4">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Pending Authorizations</h5>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table align-middle mb-0">
                                            <thead>
                                                <tr>
                                                    <th class="ps-4">Matter Title</th>
                                                    <th>Client Identity</th>
                                                    <th class="text-end pe-4">Protocol</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <% 
                                                boolean pB=false; 
                                                try(PreparedStatement p = con.prepareStatement("SELECT c.cid, c.title, c.cname as client, c.cdate FROM casetb c JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? AND c.status='ASSIGNED' ORDER BY c.cid DESC")) { 
                                                    p.setString(1,email); 
                                                    try(ResultSet r=p.executeQuery()){ 
                                                        while(r.next()){ 
                                                            pB=true; int id=r.getInt("cid"); 
                                            %>
                                                <tr class="border-light">
                                                    <td class="ps-4">
                                                        <div class="fw-semibold text-dark"><%=r.getString("title")%></div>
                                                        <div class="text-muted small" style="font-size: 0.7rem;">#<%=id%> · Submitted <%=r.getString("cdate")%></div>
                                                    </td>
                                                    <td>
                                                        <div class="small fw-medium text-dark"><%=r.getString("client")%></div>
                                                    </td>
                                                    <td class="text-end pe-4">
                                                        <div class="btn-group">
                                                            <a href="accept_case.jsp?case_id=<%=id%>&action=accept" class="btn btn-sm btn-gold px-3">Accept</a>
                                                            <a href="accept_case.jsp?case_id=<%=id%>&action=reject" class="btn btn-sm btn-link text-danger text-decoration-none small ms-2">Reject</a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% 
                                                        } 
                                                    } 
                                                } 
                                                if(!pB){ 
                                            %>
                                                <tr>
                                                    <td colspan="3" class="text-center py-5 text-muted small opacity-50">
                                                        <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                                        Queue Cleared. No pending items.
                                                    </td>
                                                </tr>
                                            <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <!-- Active Engagement -->
                            <div class="card border-0 bg-white">
                                <div class="card-header bg-transparent border-0 py-4 px-4 d-flex justify-content-between align-items-center">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Active Practice Matters</h5>
                                    <a href="viewcases.jsp" class="text-gold small fw-bold text-decoration-none">Full Registry <i class="bi bi-arrow-right ms-1"></i></a>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table align-middle mb-0">
                                            <thead>
                                                <tr>
                                                    <th class="ps-4">Casework Reference</th>
                                                    <th>Status Pulse</th>
                                                    <th class="text-end pe-4">Instruments</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <% 
                                                boolean aB=false; 
                                                try(PreparedStatement p = con.prepareStatement("SELECT c.cid, c.title, c.cname as client, c.status FROM casetb c JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? AND c.status IN ('ACCEPTED','IN_PROGRESS','HEARING_SCHEDULED') ORDER BY c.cid DESC LIMIT 8")) { 
                                                    p.setString(1,email); 
                                                    try(ResultSet r=p.executeQuery()){ 
                                                        while(r.next()){ 
                                                            aB=true; int id=r.getInt("cid"); 
                                                            String status = r.getString("status");
                                            %>
                                                <tr class="border-light">
                                                    <td class="ps-4">
                                                        <a href="viewcase.jsp?id=<%=id%>" class="text-dark fw-bold text-decoration-none"><%=r.getString("title")%></a>
                                                        <div class="text-muted small" style="font-size: 0.7rem;">Reference ID: #<%=id%> · Client: <%=r.getString("client")%></div>
                                                    </td>
                                                    <td>
                                                        <span class="badge badge-gold-subtle px-2 py-1 text-uppercase fw-bold" style="font-size: 0.6rem;"><%=status%></span>
                                                    </td>
                                                    <td class="text-end pe-4">
                                                        <div class="btn-group">
                                                            <a href="update_case_status.jsp?case_id=<%=id%>" class="btn btn-sm btn-outline-dark border-0 px-2" title="Update"><i class="bi bi-arrow-repeat"></i></a>
                                                            <a href="../shared/addHearing.jsp?case_id=<%=id%>" class="btn btn-sm btn-outline-gold border-0 px-2" title="Schedule"><i class="bi bi-calendar-plus"></i></a>
                                                            <a href="../shared/chat.jsp?case_id=<%=id%>" class="btn btn-sm btn-outline-success border-0 px-2" title="Chat"><i class="bi bi-chat-dots-fill"></i></a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% 
                                                        } 
                                                    } 
                                                } 
                                                if(!aB){ 
                                            %>
                                                <tr>
                                                    <td colspan="3" class="text-center py-5 text-muted small opacity-50">
                                                        <i class="bi bi-briefcase fs-2 d-block mb-2"></i>
                                                        No active casework recorded.
                                                    </td>
                                                </tr>
                                            <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <!-- Procedural Calendar -->
                            <div class="card border-0 bg-white mb-4">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Procedural Calendar</h5>
                                </div>
                                <div class="card-body p-0">
                                    <div class="px-4 pb-2">
                                    <% 
                                        boolean hb=false; 
                                        try(PreparedStatement p = con.prepareStatement("SELECT h.hearing_date, h.hearing_time, h.court_name, c.title FROM hearings h JOIN casetb c ON h.case_id=c.cid JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? AND h.hearing_date >= CURDATE() ORDER BY h.hearing_date ASC LIMIT 4")){ 
                                            p.setString(1,email); 
                                            try(ResultSet r=p.executeQuery()){ 
                                                while(r.next()){ 
                                                    hb=true; 
                                    %>
                                        <div class="d-flex gap-3 mb-4 last-child-mb-0">
                                            <div class="text-gold opacity-50 small"><i class="bi bi-calendar3" style="font-size: 14px;"></i></div>
                                            <div class="flex-grow-1">
                                                <div class="d-flex justify-content-between align-items-start mb-1">
                                                    <span class="fw-bold small text-dark"><%=r.getDate("hearing_date")%></span>
                                                    <span class="text-muted" style="font-size: 10px;"><%=r.getTime("hearing_time")!=null?r.getTime("hearing_time").toString().substring(0,5):""%></span>
                                                </div>
                                                <p class="mb-1 text-dark small fw-medium" style="font-size: 11px;"><%=r.getString("title")%></p>
                                                <div class="text-gold fw-bold" style="font-size: 9px;"><i class="bi bi-bank me-1"></i> <%=r.getString("court_name")%></div>
                                            </div>
                                        </div>
                                    <% 
                                                } 
                                            } 
                                        } 
                                        if(!hb){ 
                                    %>
                                        <div class='pb-4 text-center text-muted small opacity-50'>No immediate hearings scheduled.</div>
                                    <% } %>
                                    </div>
                                </div>
                                <div class="card-footer bg-transparent border-0 text-center py-3">
                                    <a href="hearings.jsp" class="text-gold small fw-bold text-decoration-none">Full Schedule <i class="bi bi-chevron-right ms-1"></i></a>
                                </div>
                            </div>

                            <!-- Practice Alerts -->
                            <div class="card border-0 bg-white">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Practice Pulse</h5>
                                </div>
                                <div class="card-body p-0">
                                    <div class="px-4 pb-2">
                                    <% 
                                        boolean nb=false; 
                                        try(PreparedStatement p = con.prepareStatement("SELECT message, type, link, created_at FROM notifications WHERE user_email=? ORDER BY created_at DESC LIMIT 5")){ 
                                            p.setString(1,email); 
                                            try(ResultSet r=p.executeQuery()){ 
                                                while(r.next()){ 
                                                    nb=true; 
                                                    String l=r.getString("link"); 
                                                    String t=r.getString("type"); 
                                                    String color="var(--gold)"; 
                                                    if("hearing".equals(t)) color="var(--primary)"; 
                                                    else if("message".equals(t)) color="var(--success)"; 
                                    %>
                                        <div class="d-flex gap-3 mb-4 last-child-mb-0">
                                            <div class="small pt-1">
                                                <i class="bi bi-record-circle-fill" style="font-size: 8px; opacity: 0.7; color: <%= "var(--gold)".equals(color) ? "#C19B4C" : ("var(--primary)".equals(color) ? "#1A1A1A" : "#28a745") %>;"></i>
                                            </div>
                                            <div class="flex-grow-1 border-start ps-3">
                                                <% if(l!=null && !l.isEmpty()){ %>
                                                    <a href="<%=l%>" class="text-decoration-none text-dark fw-semibold d-block mb-1 small" style="font-size: 11px;"><%=r.getString("message")%></a>
                                                <% } else { %>
                                                    <p class="mb-1 text-dark fw-semibold small" style="font-size: 11px;"><%=r.getString("message")%></p>
                                                <% } %>
                                                <div class="text-muted opacity-50" style="font-size: 9px;"><%=r.getTimestamp("created_at")%></div>
                                            </div>
                                        </div>
                                    <% 
                                                } 
                                            } 
                                        } 
                                        if(!nb){ 
                                    %>
                                        <div class='pb-4 text-center text-muted small opacity-50'>Practice registry clear.</div>
                                    <% } %>
                                    </div>
                                </div>
                                <div class="card-footer bg-transparent border-0 text-center py-3">
                                    <span class="small text-muted opacity-50">Global Alert Synchronization Active</span>
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
