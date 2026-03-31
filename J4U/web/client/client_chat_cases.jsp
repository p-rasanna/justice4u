<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String email=(String)session.getAttribute("cname"); if(email==null){response.sendRedirect("../auth/Login.jsp");return;}
    java.util.List<String[]> cases=new java.util.ArrayList<>(); int unreadTotal=0;
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT a.alid, a.title, a.lname, a.status, (SELECT COUNT(*) FROM discussions d WHERE d.case_id=a.alid AND d.receiver_email=? AND d.is_read=0) AS unread FROM allotlawyer a WHERE a.cname=? ORDER BY a.alid DESC");
        ps.setString(1,email); ps.setString(2,email); ResultSet rs=ps.executeQuery();
        while(rs.next()){ int u=rs.getInt("unread"); unreadTotal+=u; cases.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2), rs.getString(3), rs.getString(4), String.valueOf(u)}); }
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Client Portal"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Client"/><jsp:param name="subtitle" value="Portal"/></jsp:include>
        <div class="p-5">
            <div class="panel p-0 overflow-hidden">
                <div class="panel-head"><h3>Message Center</h3><p class="text-muted small mb-0">Direct consultation with your assigned legal team.</p></div>
                <div class="list-group list-group-flush">
                    <% if(cases.isEmpty()){ %>
                        <div class="p-5 text-center text-muted"><i class="ph ph-chat-circle-dots h1 mb-3 d-block opacity-25"></i><p>No active consultations. File a case to start communicating.</p></div>
                    <% } else { for(String[] c:cases){ 
                        int u = Integer.parseInt(c[4]); boolean assigned = c[2]!=null;
                    %>
                        <a href="<%= assigned ? "client_chat.jsp?alid="+c[0] : "#" %>" class="list-group-item list-group-item-action p-4 d-flex align-items-center justify-content-between">
                            <div class="d-flex align-items-center gap-4">
                                <div class="avatar bg-light text-gold"><i class="ph ph-briefcase"></i></div>
                                <div><h5 class="mb-1 <%= u>0?"fw-bold":"" %>"><%= c[1]!=null?c[1]:"Case #"+c[0] %></h5><p class="text-muted small mb-0"><%= assigned?"Adv. "+c[2]:"Awaiting lawyer assignment" %> · Ref: <%=c[0]%></p></div>
                            </div>
                            <div class="text-end">
                                <% if(u>0){ %><span class="badge bg-gold px-3 rounded-pill">New</span><% } %>
                                <i class="ph ph-caret-right text-muted ms-3"></i>
                            </div>
                        </a>
                    <% } } %>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>

