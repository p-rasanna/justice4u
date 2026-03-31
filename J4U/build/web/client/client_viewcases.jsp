<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String email=(String)session.getAttribute("cname"), filt=request.getParameter("filter"); 
    if(email==null){ response.sendRedirect("../auth/cust_login.jsp"); return; }
    java.util.List<String[]> list=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        String profileType = (String)session.getAttribute("profileType");
        if (profileType == null) profileType = "manual";

        if("active".equals(filt)) sql+=" AND c.status IN('ASSIGNED','IN_PROGRESS')";
        else if("completed".equals(filt)) sql+=" AND c.status IN('COMPLETED','CLOSED')";
        PreparedStatement ps=con.prepareStatement(sql+" ORDER BY c.cid DESC"); ps.setString(1,email); ps.setString(2,profileType);
        ResultSet rs=ps.executeQuery(); 
        while(rs.next()) {
            list.add(new String[]{
                String.valueOf(rs.getInt("cid")),
                rs.getString("title"),
                rs.getString("status"),
                rs.getString("curdate"),
                rs.getString("lname"),
                rs.getString("alid")
            });
        }
    } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="My Case Activity"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="app-main">
            <jsp:include page="components/_topbar.jsp">
                <jsp:param name="title" value="Legal Archive"/>
                <jsp:param name="subtitle" value="Full Case Records"/>
            </jsp:include>
            
            <div class="app-content pt-4">
                <div class="container-fluid">
                    <!-- Filters -->
                    <div class="mb-4 d-flex flex-wrap gap-2 align-items-center">
                        <span class="text-muted small fw-bold text-uppercase ls-1 me-2">Displaying:</span>
                        <a href="client_viewcases.jsp" class="btn btn-sm btn-outline-dark rounded-pill px-4 <%= filt == null ? "active btn-dark text-white" : "" %>">All Activity</a>
                        <a href="?filter=active" class="btn btn-sm btn-outline-dark rounded-pill px-4 <%= "active".equals(filt) ? "active btn-dark text-white" : "" %>">Ongoing Litigation</a>
                        <a href="?filter=completed" class="btn btn-sm btn-outline-dark rounded-pill px-4 <%= "completed".equals(filt) ? "active btn-dark text-white" : "" %>">Resolved Files</a>
                    </div>

                    <!-- Case Cards -->
                    <div class="row g-4">
                        <% if(list.isEmpty()){ %>
                            <div class="col-12">
                                <div class="card border-0 shadow-sm rounded-4 text-center py-5">
                                    <div class="card-body">
                                        <i class="bi bi-folder2-open display-4 text-muted opacity-25"></i>
                                        <h5 class="mt-3 text-muted">No cases found matching your criteria.</h5>
                                        <p class="small text-muted">Start a new case request if you require legal assistance.</p>
                                        <a href="requestlawyer.jsp" class="btn btn-gold px-4 mt-2">Open New File</a>
                                    </div>
                                </div>
                            </div>
                        <% } else { %>
                            <% for(String[] c : list) { %>
                                <div class="col-xl-4 col-md-6">
                                    <div class="card border-0 shadow-sm rounded-4 h-100 case-card-hover transition-base">
                                        <div class="card-body p-4">
                                            <div class="d-flex justify-content-between align-items-start mb-3">
                                                <div>
                                                    <span class="badge bg-gold-subtle text-gold px-3 mb-2 text-uppercase fw-bold" style="font-size: 0.65rem; letter-spacing: 0.5px;">
                                                        <%= c[2] %>
                                                    </span>
                                                    <h5 class="card-title fw-bold mb-1 text-serif"><%= c[1] %></h5>
                                                </div>
                                                <div class="text-muted small fw-bold">#<%= c[0] %></div>
                                            </div>
                                            
                                            <div class="d-flex align-items-center gap-3 text-muted small mb-4 py-2 border-bottom border-light">
                                                <span><i class="bi bi-calendar3 me-2"></i><%= c[3] %></span>
                                                <span><i class="bi bi-person-badge me-2"></i><%= c[4] != null ? "Adv. " + c[4] : "Awaiting Selection" %></span>
                                            </div>
                                            
                                            <div class="d-grid mt-auto">
                                                <a href="client_case_details.jsp?cid=<%= c[0] %>&alid=<%= c[5] %>" class="btn btn-outline-dark rounded-3 py-2 fw-semibold">
                                                    Examine Case File <i class="bi bi-arrow-right ms-2"></i>
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
            <jsp:include page="components/_footer.jsp" />
        </main>
    </div>
</body>
</html>

