<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String lEmail=(String)session.getAttribute("lname"); 
    if(lEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
%>
<!DOCTYPE html>
<html lang="en">
<title>Associate Directory | Justice4U</title>
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Associate Directory"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_sidebar.jsp" />
        <jsp:include page="../shared/_topbar.jsp" />
        
        <main class="app-main">
            <div class="app-content-header mb-4">
                <div class="container-fluid">
                    <div class="row align-items-center">
                        <div class="col-sm-6">
                            <h2 class="mb-0 text-serif fw-bold">Associate Directory</h2>
                            <p class="text-muted small mb-0">Academic collaborations and legal research associates</p>
                        </div>
                        <div class="col-sm-6 text-end">
                            <a href="../lawyer/Lawyerdashboard.jsp" class="btn btn-outline-dark btn-sm px-3">
                                <i class="bi bi-arrow-left me-1"></i> Dashboard
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="app-content">
                <div class="container-fluid">
                    <div class="card border-0 bg-white">
                        <div class="card-header bg-transparent border-0 py-4 px-4">
                            <h5 class="card-title fw-bold mb-0 text-serif">Talent Pool</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th class="ps-4">Associate Profile</th>
                                            <th>Department</th>
                                            <th>Status Pulse</th>
                                            <th class="text-end pe-4">Protocol</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% try(Connection con=DatabaseConfig.getConnection()){
                                            Integer lid=0; 
                                            PreparedStatement pl=con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?"); 
                                            pl.setString(1,lEmail); 
                                            ResultSet rl=pl.executeQuery(); 
                                            if(rl.next()) lid=rl.getInt("lid");
                                            
                                            java.util.Set<String> team=new java.util.HashSet<>(); 
                                            PreparedStatement pt=con.prepareStatement("SELECT intern_email FROM intern_assignments WHERE alid=? AND status='ACTIVE'"); 
                                            pt.setInt(1,lid); 
                                            ResultSet rt=pt.executeQuery(); 
                                            while(rt.next()) team.add(rt.getString("intern_email"));
                                            
                                            ResultSet rs=con.createStatement().executeQuery("SELECT * FROM intern WHERE flag=1 ORDER BY name ASC"); 
                                            boolean has=false;
                                            while(rs.next()){ 
                                                has=true; 
                                                String email=rs.getString("email"); 
                                                boolean isMy=team.contains(email); 
                                                String nm=rs.getString("name"); 
                                                if(nm==null) nm="Intern"; 
                                        %>
                                        <tr class="border-light">
                                            <td class="ps-4">
                                                <div class="d-flex align-items-center gap-3">
                                                    <div class="bg-dark text-white rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:40px; height:40px; font-size: 0.9rem;">
                                                        <%=nm.charAt(0)%>
                                                    </div>
                                                    <div>
                                                        <div class="fw-semibold text-dark"><%=nm%></div>
                                                        <div class="text-muted" style="font-size: 11px;"><%=email%></div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="small fw-medium text-dark">Legal Research</div>
                                                <div class="text-muted" style="font-size: 11px;"><i class="bi bi-geo-alt me-1"></i> <%=rs.getString("cadd")!=null?rs.getString("cadd"):"Remote"%></div>
                                            </td>
                                            <td>
                                                <span class="badge <%=isMy?"badge-gold-subtle text-dark":"bg-light text-success border"%> px-2 py-1 text-uppercase fw-bold" style="font-size: 0.6rem;">
                                                    <%=isMy?"Collaborating":"Available"%>
                                                </span>
                                            </td>
                                            <td class="text-end pe-4">
                                                <div class="btn-group">
                                                    <a href="assign_intern_case.jsp?intern_email=<%=email%>&intern_name=<%=nm%>" class="btn btn-sm btn-outline-dark border-0 px-2" title="Deploy Associate">
                                                        <i class="bi bi-briefcase"></i>
                                                    </a>
                                                    <% if(isMy){ %>
                                                        <a href="assign_task.jsp?intern_id=<%=rs.getInt("internid")%>" class="btn btn-sm btn-outline-gold border-0 px-2 ms-1" title="Assign Mandate">
                                                            <i class="bi bi-clipboard-check"></i>
                                                        </a>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } if(!has){ %>
                                        <tr>
                                            <td colspan="4" class="text-center py-5 text-muted small opacity-50">
                                                <i class="bi bi-people fs-2 d-block mb-2"></i> No associates currently available.
                                            </td>
                                        </tr>
                                        <% }
                                        }catch(Exception e){out.print("<tr><td colspan='4'>Error: "+e.getMessage()+"</td></tr>");} %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent border-0 text-center py-3">
                            <span class="text-muted small opacity-50">Academic Partnership Program Active</span>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        
        <jsp:include page="../shared/_footer.jsp" />
    </div>
</body>
</html>

