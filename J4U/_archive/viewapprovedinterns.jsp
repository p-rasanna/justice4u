<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String admin=(String)session.getAttribute("aname"); if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
    String msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Admin"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main-content"><div class="topbar"><div><h1>Active <em>Interns</em></h1><p class="text-muted small">Verified Student Directory</p></div></div>
        <% if(msg!=null){ %><div class="alert alert-info py-2 px-3 small border mb-4"><i class="ph-fill ph-info"></i> <%=msg%></div><% } %>
        <div class="panel">
            <div class="panel-head"><h3><i class="ph-fill ph-users"></i> Student Roster</h3></div>
            <div class="table-responsive"><table class="table text-nowrap"><thead><tr><th>ID</th><th>Intern</th><th>Email</th><th>Institution</th><th>Course</th><th>Mobile</th><th>Status</th></tr></thead><tbody class="small">
                <% try(Connection con=DatabaseConfig.getConnection()){
                    PreparedStatement ps=con.prepareStatement("SELECT internid, name, email, institution, course, mobile FROM intern WHERE flag=1 ORDER BY internid DESC");
                    ResultSet rs=ps.executeQuery(); boolean none=true;
                    while(rs.next()){ none=false; %>
                    <tr><td><%=rs.getInt("internid")%></td><td class="fw-bold"><%=rs.getString("name")%></td><td><%=rs.getString("email")%></td><td><%=rs.getString("institution")%></td><td><%=rs.getString("course")%></td><td><%=rs.getString("mobile")%></td>
                        <td><span class="badge border text-success"><i class="ph-fill ph-check-circle"></i> Active</span></td></tr>
                <% } if(none){ %><tr><td colspan="7" class="text-center p-5 text-muted">No active student practitioners in the directory.</td></tr><% }
                }catch(Exception e){out.print("Error: "+e.getMessage());} %>
            </tbody></table></div>
        </div>
    </main>
</div>

</body>
</html>


