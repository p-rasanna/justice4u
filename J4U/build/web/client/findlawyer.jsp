<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String user=(String)session.getAttribute("cname"); 
    if(user==null){ response.sendRedirect("../auth/cust_login.jsp"); return; }
    String q=request.getParameter("q"), cid=request.getParameter("case_id");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Attorney Directory"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="app-main">
            <jsp:include page="components/_topbar.jsp">
                <jsp:param name="title" value="Legal Counsel"/>
                <jsp:param name="subtitle" value="Expert Attorney Directory"/>
            </jsp:include>
            
            <div class="app-content pt-4">
                <div class="container-fluid">
                    <!-- Search Header -->
                    <div class="card border-0 shadow-sm rounded-4 mb-4 overflow-hidden">
                        <div class="card-body p-4 p-md-5 bg-dark text-white position-relative">
                            <div class="position-absolute top-50 end-0 translate-middle-y opacity-10 pe-5 d-none d-lg-block">
                                <i class="bi bi-search" style="font-size: 8rem;"></i>
                            </div>
                            <div class="row position-relative">
                                <div class="col-lg-7 text-start">
                                    <h3 class="fw-bold text-serif mb-3">Find Expert Counsel</h3>
                                    <p class="text-white-50 mb-4">Search across our verified network of specialized attorneys and legal associates.</p>
                                    <form action="findlawyer.jsp" method="get" class="d-flex gap-2">
                                        <input type="hidden" name="case_id" value="<%=cid!=null?cid:""%>">
                                        <div class="input-group input-group-lg shadow-sm">
                                            <span class="input-group-text bg-white border-0 ps-4"><i class="bi bi-search text-muted"></i></span>
                                            <input type="text" name="q" class="form-control border-0 py-3" placeholder="Search by name, expertise, or location..." value="<%=q!=null?q:""%>" aria-label="Search Counsel">
                                            <button type="submit" class="btn btn-gold px-4 fw-bold">Search</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Directory Grid -->
                    <div class="row g-4">
                        <%
                        try(Connection con=DatabaseConfig.getConnection()){
                            String sql="SELECT * FROM lawyer_reg WHERE flag=1 OR document_verification_status='VERIFIED'";
                            if(q!=null && !q.trim().isEmpty()) sql+=" AND (name LIKE ? OR specialization LIKE ? OR cadd LIKE ?)";
                            PreparedStatement ps=con.prepareStatement(sql);
                            if(q!=null && !q.trim().isEmpty()){ 
                                String s="%"+q.trim()+"%"; 
                                ps.setString(1,s); ps.setString(2,s); ps.setString(3,s); 
                            }
                            ResultSet rs=ps.executeQuery(); 
                            boolean none=true;
                            while(rs.next()){ 
                                none=false; 
                                String name=rs.getString("name"), 
                                       email=rs.getString("email"), 
                                       spec=rs.getString("specialization"), 
                                       loc=rs.getString("cadd"), 
                                       exp=rs.getString("experience_years");
                                if(name==null || name.isEmpty()) name=rs.getString("fname")+" "+rs.getString("lname"); 
                        %>
                            <div class="col-xl-4 col-md-6">
                                <div class="card border-0 shadow-sm rounded-4 h-100 attorney-card transition-base overflow-hidden">
                                    <div class="card-body p-4 text-start">
                                        <div class="d-flex align-items-center mb-3">
                                            <div class="bg-gold-subtle text-gold rounded-circle d-flex align-items-center justify-content-center fw-bold text-serif" style="width:48px; height:48px;">
                                                <%= name.charAt(0) %>
                                            </div>
                                            <div class="ms-3">
                                                <h5 class="fw-bold mb-0 text-serif">Adv. <%= name %></h5>
                                                <span class="badge bg-gold-subtle text-gold text-uppercase fw-bold" style="font-size: 0.6rem; letter-spacing: 0.5px;">verified</span>
                                            </div>
                                        </div>
                                        
                                        <div class="mb-4">
                                            <div class="text-muted small fw-bold text-uppercase ls-1 mb-1">Specialization</div>
                                            <div class="text-dark small"><%= spec != null ? spec : "General Jurisprudence" %></div>
                                        </div>

                                        <div class="row g-2 mb-4">
                                            <div class="col-6">
                                                <div class="bg-light rounded-3 p-2 text-center border border-light-subtle">
                                                    <div class="text-muted small text-uppercase" style="font-size: 0.6rem;">Experience</div>
                                                    <div class="fw-bold small text-dark"><%= exp != null ? exp : "0" %>+ Years</div>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="bg-light rounded-3 p-2 text-center border border-light-subtle">
                                                    <div class="text-muted small text-uppercase" style="font-size: 0.6rem;">Location</div>
                                                    <div class="fw-bold small text-dark text-truncate px-1" title="<%= loc != null ? loc : "N/A" %>">
                                                        <%= loc != null ? loc : "Pan India" %>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="d-flex gap-2 mt-auto">
                                            <a href="../lawyer/lawyerprofile.jsp?id=<%= email %>" class="btn btn-sm btn-outline-dark flex-fill rounded-3 py-2 fw-semibold">
                                                View Identity
                                            </a>
                                            <% if(cid!=null && !cid.isEmpty()){ %>
                                                <a href="update_case_lawyer.jsp?case_id=<%= cid %>&lawyer_email=<%= email %>" class="btn btn-sm btn-gold flex-fill rounded-3 py-2 fw-bold shadow-sm border-0">
                                                    Assign File
                                                </a>
                                            <% } else { %>
                                                <a href="../client/requestlawyer.jsp?lawyer_email=<%= email %>" class="btn btn-sm btn-gold flex-fill rounded-3 py-2 fw-bold shadow-sm border-0">
                                                    Request Counsel
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
                                <div class="card border-0 shadow-sm rounded-4 text-center py-5">
                                    <div class="card-body">
                                        <i class="bi bi-person-x display-4 text-muted opacity-25"></i>
                                        <h5 class="mt-3 text-muted">No counsel profiles matched your search parameters.</h5>
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
            <jsp:include page="components/_footer.jsp" />
        </main>
    </div>
</body>
</html>

