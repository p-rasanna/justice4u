<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String user=(String)session.getAttribute("cname"); 
    if(user==null){ response.sendRedirect("../auth/cust_login.jsp"); return; }
    String q=request.getParameter("q"), cid=request.getParameter("case_id");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Attorney Directory"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_sidebar.jsp" />
        <main class="app-main">
            <jsp:include page="../shared/_topbar.jsp">
                <jsp:param name="title" value="Find Lawyer"/>
            </jsp:include>
            
            <div class="app-content pt-4">
                <div class="container-fluid">
                    <!-- Search Header -->
                    <div class="card border-0 mb-4 overflow-hidden">
                        <div class="card-body p-4 p-md-5 text-white position-relative" style="background: linear-gradient(135deg, #111827 0%, #1f2937 100%);">
                            <div class="row position-relative">
                                <div class="col-lg-7">
                                    <h3 class="fw-bold text-serif mb-2">Find Expert Counsel</h3>
                                    <p class="opacity-75 mb-4 small">Search across our verified network of specialized attorneys.</p>
                                    <form action="findlawyer.jsp" method="get" class="d-flex gap-2">
                                        <% if(cid!=null && !cid.isEmpty()) { %>
                                        <input type="hidden" name="case_id" value="<%=cid%>">
                                        <% } %>
                                        <div class="input-group shadow-sm">
                                            <span class="input-group-text bg-white border-0 ps-3"><i class="bi bi-search text-muted"></i></span>
                                            <input type="text" name="q" class="form-control border-0 py-2" placeholder="Search by name, specialization, or location..." value="<%=q!=null?q:""%>">
                                            <button type="submit" class="btn px-4 fw-semibold" style="background:var(--gold);color:#111827;border:none;">Search</button>
                                        </div>
                                    </form>
                                    <% if(cid!=null && !cid.isEmpty()) { %>
                                    <div class="mt-3">
                                        <span class="badge bg-primary-subtle text-primary border border-primary px-3 py-2">
                                            <i class="bi bi-link-45deg me-1"></i>Selecting lawyer for Case #<%=cid%>
                                        </span>
                                        <a href="clientdashboard.jsp" class="btn btn-sm btn-outline-secondary ms-2">Cancel</a>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Directory Grid -->
                    <div class="row g-4">
                        <%
                        try(Connection con=DatabaseConfig.getConnection()){
                            String sql="SELECT name, email, practice_area, experience_years, cadd FROM lawyer_reg WHERE flag=1";
                            if(q!=null && !q.trim().isEmpty()) sql+=" AND (name LIKE ? OR practice_area LIKE ? OR cadd LIKE ?)";
                            PreparedStatement ps=con.prepareStatement(sql);
                            if(q!=null && !q.trim().isEmpty()){ 
                                String s="%"+q.trim()+"%"; 
                                ps.setString(1,s); ps.setString(2,s); ps.setString(3,s); 
                            }
                            ResultSet rs=ps.executeQuery(); 
                            boolean none=true;
                            while(rs.next()){ 
                                none=false; 
                                String lname=rs.getString("name"), 
                                       lemail=rs.getString("email"), 
                                       spec=rs.getString("practice_area"), 
                                       loc=rs.getString("cadd"), 
                                       exp=rs.getString("experience_years");
                                if(lname==null || lname.isEmpty()) lname="Attorney";
                                String desig = null; // designation column does not exist — removed
                        %>
                            <div class="col-xl-4 col-md-6">
                                <div class="card border-0 h-100">
                                    <div class="card-body p-4">
                                        <div class="d-flex align-items-center mb-3">
                                            <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold text-serif" style="width:48px; height:48px; background:var(--gold-light); color:var(--gold-dark);">
                                                <%= lname.charAt(0) %>
                                            </div>
                                            <div class="ms-3">
                                                <h6 class="fw-bold mb-0 text-serif">Adv. <%= lname %></h6>
                                                <span class="badge fw-normal px-2 py-1" style="font-size: 0.65rem; background:var(--gold-light); color:var(--gold-dark);">
                                                    <i class="bi bi-patch-check-fill me-1"></i>Verified
                                                </span>
                                            </div>
                                        </div>
                                        
                                        <% if(desig != null && !desig.isEmpty()) { %>
                                        <p class="small text-muted mb-3"><%= desig %></p>
                                        <% } %>

                                        <div class="mb-3">
                                            <div class="text-muted small fw-bold text-uppercase mb-1" style="font-size:0.65rem; letter-spacing:0.5px;">Specialization</div>
                                            <div class="small"><%= spec != null ? spec : "General Practice" %></div>
                                        </div>

                                        <div class="row g-2 mb-3">
                                            <div class="col-6">
                                                <div class="rounded-3 p-2 text-center" style="background:var(--bg);">
                                                    <div class="text-muted" style="font-size: 0.6rem; text-transform:uppercase;">Experience</div>
                                                    <div class="fw-bold small"><%= exp != null ? exp : "0" %>+ Yrs</div>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="rounded-3 p-2 text-center" style="background:var(--bg);">
                                                    <div class="text-muted" style="font-size: 0.6rem; text-transform:uppercase;">Location</div>
                                                    <div class="fw-bold small text-truncate" title="<%= loc != null ? loc : "N/A" %>"><%= loc != null ? loc : "N/A" %></div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="d-flex gap-2">
                                            <% if(cid!=null && !cid.isEmpty()){ %>
                                                <%-- Case exists: send REQUEST directly to this lawyer for the existing case --%>
                                                <form action="send_lawyer_request.jsp" method="post" class="flex-fill">
                                                    <input type="hidden" name="case_id" value="<%=cid%>">
                                                    <input type="hidden" name="lawyer_email" value="<%= lemail %>">
                                                    <button type="submit" class="btn btn-sm w-100 py-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                                                        <i class="bi bi-send me-1"></i>Send Request
                                                    </button>
                                                </form>
                                            <% } else { %>
                                                <%-- No case yet: go to case filing form with lawyer pre-selected --%>
                                                <a href="case.jsp?lawyer_email=<%= lemail %>&lawyer_name=<%= lname %>" class="btn btn-sm flex-fill py-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                                                    <i class="bi bi-file-plus me-1"></i>File & Request
                                                </a>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% 
                            } 
                            if(none){ 
                        %>
                            <div class="col-12">
                                <div class="card border-0 text-center py-5">
                                    <div class="card-body">
                                        <i class="bi bi-person-x display-4 text-muted opacity-25"></i>
                                        <h5 class="mt-3 text-muted">No counsel profiles matched your search.</h5>
                                        <p class="small text-muted">Try using broader keywords or clearing the search filter.</p>
                                        <a href="findlawyer.jsp" class="btn btn-outline-dark px-4 mt-2">Clear Filter</a>
                                    </div>
                                </div>
                            </div>
                        <% 
                            }
                        } catch(Exception e){ e.printStackTrace(); } 
                        %>
                    </div>
                </div>
            </div>
            <jsp:include page="../shared/_footer.jsp" />
        </main>
    </div>
</body>
</html>
