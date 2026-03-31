<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<% 
    if(session.getAttribute("aname")==null){response.sendRedirect("../auth/Login.jsp");return;}
    String f = request.getParameter("filter"); if (f == null) f = "all";
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Interns Directory"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Justice4U"/><jsp:param name="subtitle" value="Admin"/></jsp:include>
        <div class="p-5">
            <h5 class="mb-4 text-gold fw-bold">Interns Directory</h5>
            <div class="d-flex gap-2 mb-4">
                <a href="?filter=all" class="btn btn-sm <%="all".equals(f)?"btn-dark":"btn-outline-dark"%> px-4 rounded-pill">All</a>
                <a href="?filter=active" class="btn btn-sm <%="active".equals(f)?"btn-dark":"btn-outline-dark"%> px-4 rounded-pill">Active</a>
                <a href="?filter=pending" class="btn btn-sm <%="pending".equals(f)?"btn-warning":"btn-outline-warning"%> px-4 rounded-pill">Pending</a>
            </div>
            <div class="panel p-0 overflow-hidden text-nowrap">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light"><tr><th class="py-3 px-4">ID</th><th>Name</th><th>Email</th><th>Inst.</th><th>Course</th><th>Mobile</th><th>Status</th><th class="text-end px-4">Action</th></tr></thead>
                        <tbody>
<%
    boolean hs=false; try(Connection con=DatabaseConfig.getConnection()){
        String sql = "SELECT internid as id, iname, email, clz as inst, course, mobile, flag FROM intern" + ("pending".equals(f)?" WHERE flag=0":("active".equals(f)?" WHERE flag=1":"")) + " ORDER BY id DESC";
        try(PreparedStatement ps=con.prepareStatement(sql); ResultSet rs=ps.executeQuery()){
            while(rs.next()){
                hs=true; String id=rs.getString("id"), em=rs.getString("email"), nm=rs.getString("iname"); int flg=rs.getInt("flag");
%>
                            <tr>
                                <td class="px-4 text-muted fw-bold">#<%=id%></td><td class="fw-bold"><%=nm!=null?nm:em%></td><td><%=em%></td><td><span class="badge bg-light text-dark"><%=rs.getString("inst")%></span></td>
                                <td><%=rs.getString("course")%></td><td><%=rs.getString("mobile")%></td><td><span class="badge <%=flg==1?"bg-success":"bg-warning text-dark"%>"><%=flg==1?"Active":"Pending"%></span></td>
                                <td class="text-end px-4">
                                    <% if(flg==0){ %><a href="approve_intern.jsp?id=<%=id%>" class="btn btn-dark btn-sm rounded-pill px-3">Approve</a> <a href="reject_intern.jsp?id=<%=id%>" class="btn btn-outline-danger btn-sm rounded-pill px-3">Reject</a>
                                    <% }else{ %><button class="btn btn-outline-dark btn-sm rounded-pill px-3" disabled>Assigned</button><%}%>
                                </td>
                            </tr>
<% } } }catch(Exception e){} if(!hs){ %><tr><td colspan="8" class="text-center py-5 text-muted">No interns match this filter.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
