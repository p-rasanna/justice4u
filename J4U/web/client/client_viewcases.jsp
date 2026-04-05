<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String email=(String)session.getAttribute("cname"), filt=request.getParameter("filter");
  if(email==null){ response.sendRedirect("../auth/cust_login.jsp"); return; }
  java.util.List<String[]> list=new java.util.ArrayList<>();
  try(Connection con=DatabaseConfig.getConnection()){
    String sql="SELECT c.cid, c.title, c.des, c.curdate, c.courttype, c.city, c.flag, a.lname FROM casetb c LEFT JOIN allotlawyer a ON a.cid=c.cid WHERE c.cname=?";
    if("active".equals(filt)) sql+=" AND c.flag=1";
    else if("pending".equals(filt)) sql+=" AND c.flag=0";
    else if("closed".equals(filt)) sql+=" AND c.flag=2";
    sql+=" ORDER BY c.cid DESC";
    PreparedStatement ps=con.prepareStatement(sql);
    ps.setString(1,email);
    ResultSet rs=ps.executeQuery();
    while(rs.next()) {
      list.add(new String[]{
        String.valueOf(rs.getInt("cid")),
        rs.getString("title") != null ? rs.getString("title") : "Untitled Case",
        String.valueOf(rs.getInt("flag")),
        rs.getString("curdate") != null ? rs.getString("curdate") : "--",
        rs.getString("lname"),
        rs.getString("courttype") != null ? rs.getString("courttype") : "--",
        rs.getString("city") != null ? rs.getString("city") : "--"
      });
    }
  } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="My Cases"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="../shared/_sidebar.jsp" />
    <main class="app-main">
      <jsp:include page="../shared/_topbar.jsp">
        <jsp:param name="title" value="My Cases"/>
      </jsp:include>
      <div class="app-content pt-4">
        <div class="container-fluid">
          <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
            <div>
              <h3 class="text-serif fw-bold mb-1">Case Registry</h3>
              <p class="text-muted small mb-0"><%= list.size() %> case(s) found</p>
            </div>
            <a href="case.jsp" class="btn btn-sm px-4 py-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
              <i class="bi bi-plus-lg me-2"></i>File New Case
            </a>
          </div>
          <div class="mb-4 d-flex flex-wrap gap-2 align-items-center">
            <span class="text-muted small fw-bold text-uppercase me-2" style="font-size:0.7rem;">Filter:</span>
            <a href="client_viewcases.jsp" class="btn btn-sm rounded-pill px-3 <%= filt == null ? "btn-dark text-white" : "btn-outline-dark" %>">All</a>
            <a href="?filter=active" class="btn btn-sm rounded-pill px-3 <%= "active".equals(filt) ? "btn-dark text-white" : "btn-outline-dark" %>">Active</a>
            <a href="?filter=pending" class="btn btn-sm rounded-pill px-3 <%= "pending".equals(filt) ? "btn-dark text-white" : "btn-outline-dark" %>">Pending</a>
            <a href="?filter=closed" class="btn btn-sm rounded-pill px-3 <%= "closed".equals(filt) ? "btn-dark text-white" : "btn-outline-dark" %>">Closed</a>
          </div>
          <% if(list.isEmpty()){ %>
            <div class="card border-0 text-center py-5">
              <div class="card-body">
                <i class="bi bi-folder2-open display-4 text-muted opacity-25"></i>
                <h5 class="mt-3 text-muted">No cases found.</h5>
                <p class="small text-muted">Start a new case request if you require legal assistance.</p>
                <a href="case.jsp" class="btn px-4 mt-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                  <i class="bi bi-plus-lg me-2"></i>File New Case
                </a>
              </div>
            </div>
          <% } else { %>
            <div class="row g-4">
              <% for(String[] c : list) {
                String statusLabel, badgeClass;
                int flag = Integer.parseInt(c[2]);
                if(flag == 0) { statusLabel = "Pending"; badgeClass = "bg-warning-subtle text-warning"; }
                else if(flag == 1) { statusLabel = "Active"; badgeClass = "bg-success-subtle text-success"; }
                else if(flag == 2) { statusLabel = "Closed"; badgeClass = "bg-secondary-subtle text-secondary"; }
                else { statusLabel = "Processing"; badgeClass = "bg-info-subtle text-info"; }
              %>
                <div class="col-xl-4 col-md-6">
                  <div class="card border-0 h-100">
                    <div class="card-body p-4">
                      <div class="d-flex justify-content-between align-items-start mb-3">
                        <div>
                          <span class="badge <%= badgeClass %> fw-normal px-2 py-1 mb-2" style="font-size: 0.65rem;">
                            <%= statusLabel %>
                          </span>
                          <h5 class="card-title fw-bold mb-1 text-serif"><%= c[1] %></h5>
                        </div>
                        <span class="fw-bold small" style="color:var(--gold);">#<%= c[0] %></span>
                      </div>
                      <div class="d-flex flex-wrap gap-3 text-muted small mb-3 py-2 border-bottom" style="border-color:rgba(0,0,0,0.04) !important;">
                        <span><i class="bi bi-calendar3 me-1"></i><%= c[3] %></span>
                        <span><i class="bi bi-bank me-1"></i><%= c[5] %></span>
                        <span><i class="bi bi-geo-alt me-1"></i><%= c[6] %></span>
                      </div>
                      <div class="small text-muted mb-3">
                        <i class="bi bi-person-badge me-1"></i>
                        <%= c[4] != null ? "Adv. " + c[4] : "Awaiting Assignment" %>
                      </div>
                      <a href="client_case_details.jsp?cid=<%= c[0] %>" class="btn btn-sm btn-outline-dark w-100 py-2 fw-semibold">
                        View Details <i class="bi bi-arrow-right ms-1"></i>
                      </a>
                    </div>
                  </div>
                </div>
              <% } %>
            </div>
          <% } %>
        </div>
      </div>
      <jsp:include page="../shared/_footer.jsp" />
    </main>
  </div>
</body>
</html>