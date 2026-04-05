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
    <main class="main-content"><div class="topbar"><div><h1>Active <em>Lawyers</em></h1><p class="text-muted small">Verified Professional Directory</p></div></div>
        <% if(msg!=null){ %><div class="alert alert-info py-2 px-3 small border mb-4"><i class="ph-fill ph-info"></i> <%=msg%></div><% } %>
        <div class="panel">
            <div class="panel-head"><h3><i class="ph-fill ph-users"></i> Professional Roster</h3></div>
            <div class="table-responsive"><table class="table text-nowrap"><thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Specialization</th><th>Mobile</th><th>Experience</th><th>Status</th></tr></thead><tbody class="small">
                <% try(Connection con=DatabaseConfig.getConnection()){
                    PreparedStatement ps=con.prepareStatement("SELECT lid, COALESCE(lname, name) as display_name, email, specialization, mobno, experience_years FROM lawyer_reg WHERE flag=1 ORDER BY lid DESC");
                    ResultSet rs=ps.executeQuery(); boolean none=true;
                    while(rs.next()){ none=false; %>
                    <tr><td><%=rs.getInt("lid")%></td><td class="fw-bold"><%=rs.getString("display_name")%></td><td><%=rs.getString("email")%></td><td><%=rs.getString("specialization")%></td><td><%=rs.getString("mobno")%></td><td><%=rs.getString("experience_years")%> Yrs</td>
                        <td><span class="badge border text-success"><i class="ph-fill ph-check-circle"></i> Verified</span></td></tr>
                <% } if(none){ %><tr><td colspan="7" class="text-center p-5 text-muted">No verified legal practitioners found in the directory.</td></tr><% }
                }catch(Exception e){out.print("Error: "+e.getMessage());} %>
            </tbody></table></div>
        </div>
    </main>
</div>

</body>
</html>


