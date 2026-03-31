<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>

    
    String name="Member", ver="PENDING", lName=null, lStat=null, profileType="manual"; 
    int total=0, act=0, unread=0;
    
    try(Connection con=DatabaseConfig.getConnection()){
        // Get profile type from session first
        String sessionProfileType = (String) session.getAttribute("profileType");
        if(sessionProfileType != null) profileType = sessionProfileType;
        // Check verification & name
        PreparedStatement ps=con.prepareStatement("SELECT cname, verification_status FROM cust_reg WHERE email=?"); 
        ps.setString(1,email); 
        ResultSet rs=ps.executeQuery();
        if(rs.next()){
            name=rs.getString(1); 
            ver=rs.getString(2);
        } 
        
        if(!"VERIFIED".equalsIgnoreCase(ver)){
            response.sendRedirect("../auth/cust_login.jsp?msg=Identity Verification Pending"); 
            return;
        }
        
        // Summary Metrics
        ps=con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE cname=? AND case_type=?"); 
        ps.setString(1,email); 
        ps.setString(2,profileType);
        rs=ps.executeQuery(); 
        if(rs.next()) total=rs.getInt(1);
        
        ps=con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE cname=? AND status IN('ASSIGNED','IN_PROGRESS')"); 
        ps.setString(1,email); 
        rs=ps.executeQuery(); 
        if(rs.next()) act=rs.getInt(1);
        
        // Latest Legal Counsel
        
        ps=con.prepareStatement("SELECT lname, status FROM allotlawyer WHERE cname=? ORDER BY alid DESC LIMIT 1"); 
        ps.setString(1,email); 
        rs=ps.executeQuery(); 
        if(rs.next()){
            lName=rs.getString(1); 
            lStat=rs.getString(2);
        }
        
        // Unread Discussions
        ps=con.prepareStatement("SELECT COUNT(*) FROM discussions WHERE receiver_email=? AND is_read=0"); 
        ps.setString(1,email); 
        rs=ps.executeQuery(); 
        if(rs.next()) unread=rs.getInt(1);
        
    } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Client Registry Dashboard"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_sidebar.jsp" />
        <main class="app-main">
            <jsp:include page="../shared/_topbar.jsp">
                <jsp:param name="title" value="Member Suite"/>
                <jsp:param name="subtitle" value="Executive Dashboard"/>
            </jsp:include>

            <div class="app-content pt-4">
                <div class="container-fluid">
                    <!-- Dashboard Greeting -->
                    <div class="row align-items-center mb-5">
                        <div class="col-lg-8">
                            <h1 class="text-serif fw-bold mb-2 h2">Welcome, <span class="text-gold"><%= name %></span></h1>
                            <p class="text-muted mb-0">Advancing your legal objectives with precision and procedural integrity.</p>
                        </div>
                        <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                            <span class="badge badge-gold-subtle px-3 py-2 text-uppercase fw-bold ls-1" style="font-size: 0.7rem;">
                                <i class="bi bi-shield-check me-1"></i> Verified Member
                            </span>
                        </div>
                    </div>

                    <!-- Metrics Grid -->
                    <div class="row g-4 mb-5">
                        <div class="col-12 col-md-4">
                            <div class="card p-4 border-0 shadow-none bg-white h-100">
                                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Total Matters</div>
                                <div class="h2 fw-bold mb-0 text-serif"><%= total %></div>
                            </div>
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="card p-4 border-0 shadow-none bg-white h-100 position-relative">
                                <% if(unread > 0) { %>
                                    <span class="position-absolute top-0 end-0 m-3 badge rounded-pill bg-gold text-dark border border-white" style="font-size: 0.65rem;"><%= unread %></span>
                                <% } %>
                                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">New Dispatches</div>
                                <div class="h2 fw-bold mb-0 text-serif text-gold"><%= unread %></div>
                            </div>
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="card p-4 border-0 shadow-none bg-white h-100">
                                <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Active Mandates</div>
                                <div class="h2 fw-bold mb-0 text-serif text-success"><%= act %></div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4">
                        <!-- Counsel Representation -->
                        <div class="col-lg-8">
                            <div class="card border-0 bg-white h-100">
                                <div class="card-header bg-transparent border-0 py-4 px-4 d-flex justify-content-between align-items-center">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Primary Legal Counsel</h5>
                                    <span class="small text-muted fw-bold text-uppercase" style="font-size: 0.65rem;">Status: <%= lStat != null ? lStat : "Pending Allocation" %></span>
                                </div>
                                <div class="card-body p-4 pt-0">
                                    <% if(lName != null) { %>
                                        <div class="d-flex align-items-center gap-4 bg-light border border-light rounded-4 p-4">
                                            <div class="bg-dark text-white rounded-circle d-flex align-items-center justify-content-center shadow-sm text-serif fw-bold" style="width:72px; height:72px; font-size:1.5rem;">
                                                <%= lName.substring(0,1).toUpperCase() %>
                                            </div>
                                            <div class="flex-grow-1">
                                                <h4 class="mb-1 text-serif h5">Adv. <%= lName %></h4>
                                                <p class="text-muted small mb-3">Allocated Representative · High Court Practice</p>
                                                <div class="d-flex gap-2">
                                                    <a href="../shared/chat.jsp?receiver=<%= lName %>" class="btn btn-gold btn-sm px-4">
                                                        Communicate
                                                    </a>
                                                    <a href="#" class="btn btn-outline-dark btn-sm px-3">Profile</a>
                                                </div>
                                            </div>
                                        </div>
                                    <% } else { %>
                                        <div class="text-center py-5">
                                            <div class="mb-3 opacity-25">
                                                <i class="bi bi-person-badge-fill" style="font-size: 4rem;"></i>
                                            </div>
                                            <h6 class="fw-bold text-serif">Assignment in Progress</h6>
                                            <p class="text-muted small mx-auto mb-4" style="max-width: 380px;">The High Command is currently assigning the optimal expert for your specific legal matter.</p>
                                            <% if(!"admin".equals(profileType)) { %><a href="findlawyer.jsp" class="btn btn-outline-gold btn-sm rounded-pill px-4">Explore Directory</a><% } %>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- Directive Hub -->
                        <div class="col-lg-4">
                            <div class="card border-0 bg-white h-100">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Directive Hub</h5>
                                </div>
                                <div class="card-body px-4 pt-0">
                                    <div class="d-grid gap-2">
                                        <a href="case.jsp" class="btn btn-gold btn-sm py-3 mb-1">
                                            <i class="bi bi-plus-lg me-2"></i> File New Mandate
                                        </a>
                                        <div class="row g-2">
                                            <div class="col-6">
                                                <a href="client_viewcases.jsp" class="btn btn-outline-dark btn-sm w-100 py-3 text-center">
                                                    Registry
                                                </a>
                                            </div>
                                            <div class="col-6">
                                                <a href="hearings.jsp" class="btn btn-outline-dark btn-sm w-100 py-3 text-center">
                                                    Calendar
                                                </a>
                                            </div>
                                        </div>
                                        <% if(!"admin".equals(profileType)) { %><a href="findlawyer.jsp" class="btn btn-primary btn-sm py-3 mt-1">
                                            Expert Repository
                                        </a><% } %>
                                    </div>
                                </div>
                                <div class="card-footer bg-transparent border-0 text-center py-4">
                                    <p class="small text-muted mb-0" style="font-size: 0.7rem;">
                                        <i class="bi bi-patch-check-fill text-gold me-1"></i> Legal Compliance Standards 2.0
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <jsp:include page="../shared/_footer.jsp" />
        </main>
    </div>
    
    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/assets/js/adminlte.min.js"></script>
</body>
</html>

