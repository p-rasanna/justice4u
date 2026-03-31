<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig"%>
<%
    String user=(String)session.getAttribute("lname"); if(user==null){response.sendRedirect("../auth/Login.jsp");return;}
    int alid=request.getParameter("alid")!=null?Integer.parseInt(request.getParameter("alid")):0;
    String chatWith="", title="Case #"+alid;
    java.util.List<String[]> list=new java.util.ArrayList<>(), msgs=new java.util.ArrayList<>();
    if("POST".equalsIgnoreCase(request.getMethod()) && alid>0){
        try(Connection con=DatabaseConfig.getConnection()){
            PreparedStatement ps=con.prepareStatement("SELECT cname FROM allotlawyer WHERE alid=?"); ps.setInt(1,alid);
            ResultSet rs=ps.executeQuery(); String c=rs.next()?rs.getString(1):null;
            if(c!=null){
                ps=con.prepareStatement("INSERT INTO discussions (case_id,sender_email,sender_role,receiver_email,receiver_role,message_text) VALUES (?,?,'lawyer',?,'client',?)");
                ps.setInt(1,alid); ps.setString(2,user); ps.setString(3,c); ps.setString(4,request.getParameter("message").trim()); ps.executeUpdate();
            }
        }catch(Exception e){} response.sendRedirect("client_messages.jsp?alid="+alid); return;
    }
    try(Connection con=DatabaseConfig.getConnection()){
        if(alid>0){
            PreparedStatement ps=con.prepareStatement("SELECT cname, title FROM allotlawyer WHERE alid=? AND lname=?"); ps.setInt(1,alid); ps.setString(2,user);
            ResultSet rs=ps.executeQuery(); if(rs.next()){chatWith=rs.getString(1); title=rs.getString(2)!=null?rs.getString(2):title;}
            ps=con.prepareStatement("UPDATE discussions SET is_read=1 WHERE case_id=? AND receiver_email=?"); ps.setInt(1,alid); ps.setString(2,user); ps.executeUpdate();
            ps=con.prepareStatement("SELECT sender_email, message_text, timestamp FROM discussions WHERE case_id=? ORDER BY timestamp ASC"); ps.setInt(1,alid); rs=ps.executeQuery();
            while(rs.next()) msgs.add(new String[]{rs.getString(1),rs.getString(2),rs.getString(3)!=null?rs.getString(3).substring(0,16):""});
        } else {
            PreparedStatement ps=con.prepareStatement("SELECT a.alid, a.cname, a.title, SUM(CASE WHEN d.receiver_email=? AND d.is_read=0 THEN 1 ELSE 0 END) FROM discussions d JOIN allotlawyer a ON d.case_id=a.alid WHERE d.sender_email=? OR d.receiver_email=? GROUP BY a.alid, a.cname, a.title ORDER BY MAX(d.timestamp) DESC");
            ps.setString(1,user); ps.setString(2,user); ps.setString(3,user); ResultSet rs=ps.executeQuery();
            while(rs.next()) list.add(new String[]{String.valueOf(rs.getInt(1)),rs.getString(2),rs.getString(3),String.valueOf(rs.getInt(4))});
        }
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Messages"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp"><jsp:param name="active" value="messages"/></jsp:include>
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Client"/><jsp:param name="subtitle" value="Messages"/></jsp:include>
        <div class="px-4">
            <% if(alid>0){ %>
                <div class="panel d-flex flex-column" style="height:70svh;">
                    <div class="panel-head"><h3><%=chatWith%> <small class="text-muted fw-normal ms-2"><%=title%></small></h3><a href="client_messages.jsp">Back</a></div>
                    <div class="flex-grow-1 p-4 overflow-auto">
                        <% for(String[] m:msgs){ boolean mine=user.equals(m[0]); %>
                            <div class="mb-3 d-flex flex-column <%=mine?"align-items-end":"align-items-start"%>">
                                <div class="p-2 px-3 rounded <%=mine?"bg-dark text-white":"bg-light border text-dark"%>" style="max-width:80%; font-size:0.95rem;"><%=m[1]%></div>
                                <small class="text-muted mt-1" style="font-size:0.7rem;"><%=m[2]%></small>
                            </div>
                        <% } %>
                    </div>
                    <form method="POST" class="p-3 border-top"><div class="input-group"><input type="text" name="message" class="form-control" placeholder="Type a message..." required><button class="btn btn-dark px-4"><i class="ph ph-paper-plane"></i></button></div></form>
                </div>
            <% } else { %>
                <div class="row g-3">
                    <% for(String[] l:list){ %>
                        <div class="col-md-6"><a href="client_messages.jsp?alid=<%=l[0]%>" class="panel p-3 d-flex justify-content-between align-items-center text-decoration-none text-reset">
                            <div><h6 class="mb-0"><%=l[1]%></h6><small class="text-muted"><%=l[2]%></small></div>
                            <% if(!"0".equals(l[3])){ %><span class="badge bg-gold"><%=l[3]%></span><% } %>
                        </a></div>
                    <% } if(list.isEmpty()){ %><div class="col-12 p-5 text-center text-muted">No messages.</div><% } %>
                </div>
            <% } %>
        </div>
    </main>
</div>
</body>
</html>
