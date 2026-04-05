<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String admin=(String)session.getAttribute("aname"); 
    if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
    String msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<title>Lawyer Registry | Justice4U</title>
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Lawyer Registry"/>
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
                            <h2 class="mb-0 text-serif fw-bold">Lawyer Approvals</h2>
                            <p class="text-muted small mb-0">Verify credentials and oversee practitioner onboarding</p>
                        </div>
                        <div class="col-sm-6 text-end">
                            <a href="admindashboard.jsp" class="btn btn-outline-dark btn-sm px-3">
                                <i class="bi bi-arrow-left me-1"></i> Dashboard
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="app-content">
                <div class="container-fluid">
                    <% if(msg!=null){ %>
                        <div class="alert alert-info border-0 small mb-4 py-3">
                            <i class="bi bi-info-circle me-2"></i> <%=msg%>
                        </div>
                    <% } %>

                    <div class="card border-0 bg-white">
                        <div class="card-header bg-transparent border-0 py-4 px-4">
                            <h5 class="card-title fw-bold mb-0 text-serif">Practitioner Registry</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th class="ps-4">Identification</th>
                                            <th>Applicant Details</th>
                                            <th>Verification Status</th>
                                            <th>Authorization Log</th>
                                            <th class="text-end pe-4">Protocol</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% try(Connection con=DatabaseConfig.getConnection()){
                                            ResultSet rs=con.createStatement().executeQuery("SELECT l.*, COALESCE(l.document_verification_status,'PENDING') as doc_status FROM lawyer_reg l WHERE l.flag=0 ORDER BY l.lid DESC"); 
                                            boolean has=false;
                                            while(rs.next()){ 
                                                has=true; 
                                                String ds=rs.getString("doc_status"); 
                                                String nm=rs.getString("lname"); 
                                                if(nm==null) nm=rs.getString("name"); 
                                                if(nm==null) nm="Lawyer"; 
                                                int lid = rs.getInt("lid");
                                        %>
                                        <tr class="border-light">
                                            <td class="ps-4">
                                                <span class="text-muted small">#<%=lid%></span>
                                            </td>
                                            <td>
                                                <div class="fw-semibold text-dark"><%=nm%></div>
                                                <div class="text-muted small overflow-hidden" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; line-clamp: 1;"><%=rs.getString("email")%></div>
                                                <div class="text-gold-dark fw-bold" style="font-size: 10px;">BAR ID: <%=rs.getString("ano")%></div>
                                            </td>
                                            <td>
                                                <span class="badge <%=ds.equals("VERIFIED")?"badge-gold-subtle text-dark":"bg-light text-muted border"%> px-2 py-1 text-uppercase fw-bold" style="font-size: 0.65rem;">
                                                    <%=ds%>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="small fw-medium text-dark">REF: <%=rs.getString("transid")!=null?rs.getString("transid"):"N/A"%></div>
                                                <div class="text-muted" style="font-size: 11px;">VAL: ₹<%=rs.getString("amount")!=null?rs.getString("amount"):"0"%></div>
                                            </td>
                                            <td class="text-end pe-4">
                                                <div class="btn-group">
                                                    <a href="viewlawyerdocuments.jsp?id=<%=lid%>" class="btn btn-sm btn-outline-dark border-0 px-2" title="View Credentials">
                                                        <i class="bi bi-file-earmark-text"></i>
                                                    </a>
                                                    <% if(ds.equals("VERIFIED")){ %>
                                                        <a href="approvel.jsp?lid=<%=lid%>" class="btn btn-sm btn-outline-success border-0 px-2 ms-1" title="Approve Entry">
                                                            <i class="bi bi-check-circle"></i>
                                                        </a>
                                                    <% } %>
                                                    <a href="rejectl.jsp?lid=<%=lid%>" class="btn btn-sm btn-outline-danger border-0 px-2 ms-1" title="Reject Application">
                                                        <i class="bi bi-x-circle"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } if(!has){ %>
                                        <tr>
                                            <td colspan="5" class="text-center py-5 text-muted small opacity-50">
                                                <i class="bi bi-person-slash fs-2 d-block mb-2"></i>
                                                No pending lawyer applications found.
                                            </td>
                                        </tr>
                                        <% }
                                        }catch(Exception e){out.print("<tr><td colspan='5'>Error: "+e.getMessage()+"</td></tr>");} %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent border-0 text-center py-3">
                            <span class="text-muted small opacity-50">Global Regulatory Standards Active</span>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        
        <jsp:include page="../shared/_footer.jsp" />
    </div>
</body>
</html>

