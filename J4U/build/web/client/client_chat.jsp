<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String email=(String)session.getAttribute("cname"); if(email==null){response.sendRedirect("../auth/Login.jsp");return;}
    int alid=Integer.parseInt(request.getParameter("alid")); String lEmail=null, title="Case #"+alid;
    if("POST".equalsIgnoreCase(request.getMethod())){
        String msg=request.getParameter("message");
        if(msg!=null && !msg.trim().isEmpty()){
            try(Connection con=DatabaseConfig.getConnection()){
                PreparedStatement ps=con.prepareStatement("SELECT lname FROM allotlawyer WHERE alid=?"); ps.setInt(1,alid); ResultSet rs=ps.executeQuery();
                if(rs.next()){
                    lEmail=rs.getString(1);
                    ps=con.prepareStatement("INSERT INTO discussions (case_id, sender_email, sender_role, receiver_email, receiver_role, message_text) VALUES (?,?,'client',?,'lawyer',?)");
                    ps.setInt(1,alid); ps.setString(2,email); ps.setString(3,lEmail); ps.setString(4,msg.trim()); ps.executeUpdate();
                }
            }catch(Exception e){}
        }
        response.sendRedirect("client_chat.jsp?alid="+alid); return;
    }
    java.util.List<String[]> msgs=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT title, lname FROM allotlawyer WHERE alid=?"); ps.setInt(1,alid); ResultSet rs=ps.executeQuery();
        if(rs.next()){ title=rs.getString(1); lEmail=rs.getString(2); }
        ps=con.prepareStatement("UPDATE discussions SET is_read=1 WHERE case_id=? AND receiver_email=?"); ps.setInt(1,alid); ps.setString(2,email); ps.executeUpdate();
        ps=con.prepareStatement("SELECT sender_email, message_text, timestamp FROM discussions WHERE case_id=? ORDER BY timestamp ASC"); ps.setInt(1,alid); rs=ps.executeQuery();
        while(rs.next()) msgs.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3).substring(0,16)});
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
            <div class="panel p-5">
                <div class="chat-scroll mb-4 d-flex flex-column" id="chatbox">
                    <% if(msgs.isEmpty()){ %><div class="m-auto text-center text-muted opacity-50"><i class="ph ph-chat-circle-text h1 d-block mb-3"></i><p>Initiate your legal consultation.</p></div><% } else { for(String[] m:msgs){ boolean mine=email.equals(m[0]); %>
                        <div class="msg-bubble <%= mine?"msg-mine":"msg-theirs border" %>">
                            <p class="mb-1"><%=m[1]%></p><time class="x-small opacity-75 d-block text-end"><%=m[2]%></time>
                        </div>
                    <% } } %>
                </div>
                <% if(lEmail!=null){ %>
                    <form action="client_chat.jsp?alid=<%=alid%>" method="POST" class="mt-4 pt-4 border-top">
                        <div class="input-group"><input type="text" name="message" class="form-control p-4 border-0 bg-light" placeholder="Describe your query..." required autocomplete="off"><button type="submit" class="btn btn-dark px-5">Send <i class="ph-fill ph-paper-plane-tilt ms-2"></i></button></div>
                    </form>
                <% } else { %><div class="alert alert-warning text-center border-0 small">Messaging will be enabled once a lawyer is assigned to your case.</div><% } %>
            </div>
        </div>
    </main>
</div>
<script>const c=document.getElementById('chatbox'); if(c) c.scrollTop=c.scrollHeight;</script>
</body>
</html>

