<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    if(session.getAttribute("aname")==null){response.sendRedirect("../auth/Login.jsp");return;}
    String lid=request.getParameter("id"), msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Credential Review"/></jsp:include>
<body class="layout-fixed bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_topbar.jsp" />
        <jsp:include page="../shared/_sidebar.jsp" />
        <main class="app-main p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div><h3 class="text-serif fw-bold mb-0">Record Review</h3><p class="text-muted small">Verify submitted identity documents</p></div>
                <a href="viewlawyers.jsp" class="btn btn-dark btn-sm"><i class="bi bi-arrow-left"></i> Return</a>
            </div>
            <% if(msg!=null){out.print("<div class='alert alert-warning small py-2'>"+msg+"</div>");} %>
            <% try(Connection con=DatabaseConfig.getConnection()){
                 String q="SELECT lid, name, email FROM lawyer_reg WHERE flag=0" + (lid!=null?" AND lid="+lid:"");
                 ResultSet rs=con.createStatement().executeQuery(q);
                 while(rs.next()){ int id=rs.getInt("lid"); %>
                 <div class="card shadow-sm border-0 mb-4 rounded-4">
                    <div class="card-header bg-white border-bottom p-4 d-flex justify-content-between align-items-center">
                        <div><h5 class="fw-bold mb-0 text-dark"><%=rs.getString("name")%></h5><small class="text-muted"><%=rs.getString("email")%></small></div>
                        <div class="btn-group">
                            <a href="user_action.jsp?type=lawyer&action=approve&id=<%=id%>" class="btn btn-gold px-3"><i class="bi bi-check-circle"></i> Approve</a>
                            <a href="user_action.jsp?type=lawyer&action=reject&id=<%=id%>" class="btn btn-outline-danger px-3"><i class="bi bi-x-circle"></i> Reject</a>
                        </div>
                    </div>
                    <div class="card-body row g-3 p-4">
                        <% PreparedStatement ps=con.prepareStatement("SELECT document_type, file_name, file_path, status FROM lawyer_documents WHERE lawyer_id=?"); ps.setInt(1,id);
                           ResultSet drs=ps.executeQuery(); boolean hasD=false; while(drs.next()){ hasD=true; %>
                           <div class="col-md-3">
                               <div class="p-4 border rounded-3 bg-light text-center transition-all shadow-sm">
                                   <i class="bi bi-file-earmark-pdf fs-1 text-gold mb-2 d-block"></i>
                                   <b class="small d-block text-truncate mb-3"><%=drs.getString("document_type")%></b>
                                   <a href="../<%=drs.getString("file_path")%>" target="_blank" class="btn btn-sm btn-dark w-100">View File <i class="bi bi-box-arrow-up-right ms-1"></i></a>
                               </div>
                           </div>
                        <% } if(!hasD){out.print("<div class='text-center p-4 text-muted w-100'>No documents attached to this profile.</div>");} %>
                    </div>
                 </div>
            <% }}catch(Exception e){out.print("<div class='alert alert-danger'>"+e.getMessage()+"</div>");} %>
        </main>
    </div>
</body>
</html>


