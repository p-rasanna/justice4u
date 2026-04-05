<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig, com.j4u.NotificationService" %>
<%
  String email = (String) session.getAttribute("cname");
  String profileType = (String) session.getAttribute("profileType");
  if (profileType == null) profileType = "manual";
  if (email == null) { response.sendRedirect("../auth/Login.jsp"); return; }
  int mC=0, uH=0, uM=0, mD=0;
  try (Connection con = DatabaseConfig.getConnection()) {
    try(PreparedStatement p = con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE cname=?")){
      p.setString(1,email);
      try(ResultSet r = p.executeQuery()){ if(r.next()) mC=r.getInt(1); }
    }
    String activeLawyer = "None";
    int activeCaseId = 0;
    try(PreparedStatement p = con.prepareStatement("SELECT c.cid, COALESCE(lr.name, al.lname) as lawyerName FROM casetb c LEFT JOIN allotlawyer al ON al.cid=c.cid LEFT JOIN lawyer_reg lr ON lr.email=al.lname WHERE c.cname=? AND al.lname IS NOT NULL ORDER BY c.cid DESC LIMIT 1")){
      p.setString(1,email);
      try(ResultSet r = p.executeQuery()){
        if(r.next()) {
          activeCaseId = r.getInt("cid");
          activeLawyer = r.getString("lawyerName");
        }
      }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Client Dashboard | Justice4U</title>
</head>
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Client Dashboard"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="../shared/_topbar.jsp" />
    <jsp:include page="../shared/_sidebar.jsp" />
    <main class="app-main">
      <div class="app-content-header">
        <div class="container-fluid">
          <div class="row">
            <div class="col-sm-6">
              <h2 class="mb-0 text-serif fw-bold">Client Portal</h2>
              <p class="text-muted small mb-0">Manage your casework and upcoming hearings</p>
            </div>
            <div class="col-sm-6 text-end d-none d-sm-block">
              <span class="badge badge-gold-subtle px-3 py-2">
                <i class="bi bi-person-workspace me-1"></i> Client Portal
              </span>
            </div>
          </div>
        </div>
      </div>
      <div class="app-content">
        <div class="container-fluid">
          <% if(request.getParameter("msg")!=null){ %>
            <div class="alert alert-success border-0 shadow-none small mb-4 py-3">
              <i class="bi bi-check-circle-fill me-2 text-success"></i>
              <%=request.getParameter("msg")%>
            </div>
          <% } %>
          <div class="row g-4 mb-5">
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white h-100">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">My Cases</div>
                <div class="h2 fw-bold mb-0 text-serif"><%=mC%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <div class="card p-4 border-0 shadow-none bg-white h-100">
                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Assigned Lawyer</div>
                <div class="fw-bold mb-0 text-serif text-primary text-truncate" style="font-size: 1.5rem;" title="<%=activeLawyer%>"><%=activeLawyer%></div>
              </div>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <a href="case.jsp" class="text-decoration-none">
                <div class="card p-4 border-0 shadow-none text-white h-100 d-flex justify-content-center align-items-center" style="background: var(--gold, #B4975A); border-radius: 8px;">
                  <div class="fw-bold text-uppercase ls-1"><i class="bi bi-plus-circle-fill me-2"></i> File New Case</div>
                </div>
              </a>
            </div>
            <div class="col-12 col-sm-6 col-md-3">
              <a href="<%= activeCaseId > 0 ? "../shared/chat.jsp?case_id=" + activeCaseId : "#" %>" class="text-decoration-none <%= activeCaseId == 0 ? "opacity-50" : "" %>" <%= activeCaseId == 0 ? "onclick=\"alert('You do not have an active assigned case to discuss yet.'); return false;\"" : "" %>>
                <div class="card p-4 border-0 shadow-none bg-white h-100 d-flex justify-content-center align-items-center" style="border: 2px solid var(--success) !important; border-radius: 8px;">
                  <div class="fw-bold text-uppercase ls-1 text-success"><i class="bi bi-chat-dots-fill me-2"></i> Case Discussion</div>
                </div>
              </a>
            </div>
          </div>
          <div class="row g-4">
              <div class="card border-0 bg-white mb-4">
                <div class="card-header bg-transparent border-0 py-4 px-4 d-flex align-items-center gap-2">
                  <i class="bi bi-journal-text text-gold fs-5"></i>
                  <h5 class="card-title fw-bold mb-0 text-serif">Active Case Inquiries</h5>
                </div>
                <div class="card-body p-0">
                  <div class="list-group list-group-flush">
                  <%
                    boolean ha=false;
                    try(PreparedStatement p = con.prepareStatement(
                      "SELECT c.cid, c.title, c.status, c.curdate as cdate, " +
                      "COALESCE(c.assignment_type,'ADMIN') as atype, " +
                      "COALESCE(c.case_status,'PENDING') as cstatus, " +
                      "al.lname as lawyer_email, " +
                      "COALESCE(lr_name.name, lr_name.email) as lawyer_name, " +
                      "lr.request_id, lr.lawyer_email as req_lawyer, lr.status as req_status, " +
                      "COALESCE(lr_req.name, lr_req.email) as req_lawyer_name " +
                      "FROM casetb c " +
                      "LEFT JOIN allotlawyer al ON al.cid=c.cid " +
                      "LEFT JOIN lawyer_reg lr_name ON lr_name.email=al.lname " +
                      "LEFT JOIN lawyer_requests lr ON lr.case_id=c.cid AND lr.status='PENDING' " +
                      "LEFT JOIN lawyer_reg lr_req ON lr_req.email=lr.lawyer_email " +
                      "WHERE c.cname=? ORDER BY c.cid DESC"
                    )) {
                      p.setString(1,email);
                      try(ResultSet r=p.executeQuery()){
                        while(r.next()){
                          ha=true;
                          int    id         = r.getInt("cid");
                          String stat       = r.getString("status");
                          String atype      = r.getString("atype");   // ADMIN or MANUAL
                          String cstatus    = r.getString("cstatus"); // PENDING/SEARCHING/REQUESTED/ACTIVE
                          String lName      = r.getString("lawyer_name");
                          int    reqId      = r.getInt("request_id"); // 0 if none
                          String reqLawyer  = r.getString("req_lawyer_name");
                          String reqStatus  = r.getString("req_status"); // PENDING or null
                          boolean hasLawyer = (lName != null && !lName.isEmpty());
                          boolean isManual  = "MANUAL".equalsIgnoreCase(atype);
                  %>
                    <div class="list-group-item p-4">
                      <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                        <div class="flex-grow-1">
                          <div class="d-flex align-items-center gap-2 mb-1">
                            <h6 class="mb-0 fw-bold">#<%=id%> - <%=r.getString("title")%></h6>
                            <span class="badge <%= isManual ? "bg-info-subtle text-info border border-info" : "bg-secondary-subtle text-secondary border" %> fw-normal py-1 px-2" style="font-size:0.65rem;">
                              <i class="bi <%= isManual ? "bi-person-check" : "bi-shield-check" %> me-1"></i>
                              <%= isManual ? "Manual" : "Admin Assigned" %>
                            </span>
                          </div>
                          <small class="text-muted d-block mb-2"><i class="bi bi-calendar3 me-1"></i><%=r.getString("cdate")%></small>
                          <%-- ── ADMIN FLOW status display ──────────────────────────────── --%>
                          <% if (!isManual) { %>
                            <% if (hasLawyer) { %>
                              <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-person-fill-check text-success"></i>
                                <span class="small fw-semibold text-success">Lawyer Assigned: <%=lName%></span>
                              </div>
                            <% } else { %>
                              <div class="d-flex align-items-center gap-2 p-2 rounded" style="background:rgba(180,151,90,0.08); border:1px dashed var(--gold);">
                                <i class="bi bi-hourglass-split text-gold"></i>
                                <span class="small fw-semibold" style="color:var(--gold);">Waiting for admin to assign your lawyer...</span>
                              </div>
                            <% } %>
                          <%-- ── MANUAL FLOW status display ─────────────────────────────── --%>
                          <% } else { %>
                            <% if ("ACTIVE".equals(cstatus) && hasLawyer) { %>
                              <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-check-circle-fill text-success"></i>
                                <span class="small fw-semibold text-success">Active — Lawyer: <%=lName%></span>
                              </div>
                            <% } else if ("REQUESTED".equals(cstatus) && reqId > 0) { %>
                              <div class="d-flex align-items-center gap-2 p-2 rounded mb-2" style="background:rgba(13,110,253,0.05); border:1px dashed #0d6efd;">
                                <i class="bi bi-send-fill text-primary"></i>
                                <span class="small fw-semibold text-primary">
                                  Request sent to <%= reqLawyer != null ? reqLawyer : "lawyer" %> — Awaiting response
                                </span>
                              </div>
                            <% } else if ("SEARCHING".equals(cstatus)) { %>
                              <div class="d-flex align-items-center gap-2 p-2 rounded" style="background:rgba(255,193,7,0.08); border:1px dashed #ffc107;">
                                <i class="bi bi-search text-warning"></i>
                                <span class="small fw-semibold text-warning">Searching for a lawyer — Choose one below</span>
                              </div>
                            <% } %>
                          <% } %>
                        </div>
                        <%-- ── Action Buttons ──────────────────────────────────────────── --%>
                        <div class="d-flex flex-column gap-2 align-items-end">
                          <% if (hasLawyer && "ACTIVE".equals(cstatus)) { %>
                            <a href="../shared/chat.jsp?case_id=<%=id%>" class="btn btn-sm btn-outline-success px-3 border-2 fw-bold">
                              <i class="bi bi-chat-left-dots-fill me-1"></i>Chat
                            </a>
                          <% } else if (isManual) { %>
                            <% if ("REQUESTED".equals(cstatus) && reqId > 0) { %>
                              <a href="cancel_lawyer_request.jsp?request_id=<%=reqId%>"
                                class="btn btn-sm btn-outline-danger px-3 border-2 fw-bold"
                                onclick="return confirm('Cancel this request? You can choose another lawyer.')">
                                <i class="bi bi-x-circle me-1"></i>Cancel Request
                              </a>
                            <% } %>
                            <% if ("SEARCHING".equals(cstatus) || "REQUESTED".equals(cstatus)) { %>
                              <a href="findlawyer.jsp?case_id=<%=id%>" class="btn btn-sm btn-gold px-3 fw-bold">
                                <i class="bi bi-search me-1"></i><%= "REQUESTED".equals(cstatus) ? "Change Lawyer" : "Find Lawyer" %>
                              </a>
                            <% } %>
                          <% } else { %>
                            <button class="btn btn-sm btn-light border-0 text-muted disabled">
                              <i class="bi bi-hourglass-split me-1"></i>Waiting
                            </button>
                          <% } %>
                          <a href="client_case_details.jsp?id=<%=id%>" class="btn btn-sm btn-outline-secondary px-3 fw-semibold">
                            <i class="bi bi-eye me-1"></i>Details
                          </a>
                        </div>
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
                        <a href="case.jsp" class="btn btn-sm btn-gold px-4">File a Case</a>
                      </div>
                    </div>
                  <% } %>
                  </div>
                </div>
              </div>
            <div class="col-lg-5">
              <div class="card border-0 bg-white">
                <div class="card-header bg-transparent border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">Recent Updates</h5>
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