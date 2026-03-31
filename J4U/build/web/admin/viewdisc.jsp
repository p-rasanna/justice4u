<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String clientEmail=(String)session.getAttribute("cname"); 
    if(clientEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
%>
<!DOCTYPE html>
<html lang="en">
<title>Correspondence Archive | Justice4U</title>
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Correspondence Archive"/>
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
                            <h2 class="mb-0 text-serif fw-bold">Communication Archive</h2>
                            <p class="text-muted small mb-0">Track and monitor your historical attorney correspondence</p>
                        </div>
                        <div class="col-sm-6 text-end">
                            <a href="../client/clientdashboard.jsp" class="btn btn-outline-dark btn-sm px-3">
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
                            <h5 class="card-title fw-bold mb-0 text-serif">Discussion History</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th class="ps-4">Reference</th>
                                            <th>Subject Matter</th>
                                            <th>Timestamp</th>
                                            <th>Message Preview</th>
                                            <th class="text-end pe-4">Counsel</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% try(Connection con=DatabaseConfig.getConnection()){
                                            PreparedStatement pst=con.prepareStatement("SELECT * FROM discussion WHERE cemail=? ORDER BY cdate DESC"); 
                                            pst.setString(1, clientEmail); 
                                            ResultSet rs=pst.executeQuery(); 
                                            boolean has=false;
                                            while(rs.next()){ 
                                                has=true; 
                                        %>
                                        <tr class="border-light">
                                            <td class="ps-4 small text-muted font-monospace">#<%=String.format("%05d",rs.getInt(1))%></td>
                                            <td class="fw-semibold text-dark text-nowrap"><%=rs.getString(2)%></td>
                                            <td class="small text-muted text-nowrap"><%=rs.getString(3)%></td>
                                            <td class="text-wrap" style="max-width: 300px;">
                                                <div class="text-muted small overflow-hidden" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; line-clamp: 1;">
                                                    <%=rs.getString(4)%>
                                                </div>
                                            </td>
                                            <td class="text-end pe-4">
                                                <% String le=rs.getString(6); 
                                                   if(le!=null && !le.isEmpty()){ %>
                                                    <span class="badge badge-gold-subtle text-dark px-2 py-1 fw-bold" style="font-size: 0.6rem;"><%=le%></span>
                                                <% }else{ %>-<% } %>
                                            </td>
                                        </tr>
                                        <% } if(!has){ %>
                                        <tr>
                                            <td colspan="5" class="text-center py-5 text-muted small opacity-50">
                                                <i class="bi bi-chat-left-dots fs-2 d-block mb-2"></i>
                                                No discussion records found.
                                            </td>
                                        </tr>
                                        <% }
                                        }catch(Exception e){out.print("<tr><td colspan='5'>Error: "+e.getMessage()+"</td></tr>");} %>
                                    </tbody>
                                </table>
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


