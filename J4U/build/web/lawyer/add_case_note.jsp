<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig"%>
<%
    String user=(String)session.getAttribute("lname"); if(user==null){response.sendRedirect("../auth/Login.jsp");return;}
    String alidStr=request.getParameter("alid"); if(alidStr==null){response.sendRedirect("viewcases.jsp");return;}
    int id=Integer.parseInt(alidStr); String msg="", title="Case #"+id;
    if("POST".equalsIgnoreCase(request.getMethod())){
        String note=request.getParameter("note");
        try(Connection con=DatabaseConfig.getConnection()){
            PreparedStatement ps=con.prepareStatement("INSERT INTO lawyer_remarks (alid,lawyer_email,remark_text) VALUES (?,?,?)");
            ps.setInt(1,id); ps.setString(2,user); ps.setString(3,note); ps.executeUpdate();
            ps=con.prepareStatement("INSERT INTO case_timeline (alid,event_type,event_description,created_by) VALUES (?,?,?,?)");
            ps.setInt(1,id); ps.setString(2,"CASE_UPDATE"); ps.setString(3,note); ps.setString(4,user); ps.executeUpdate();
            msg="Update saved & client notified!";
        }catch(Exception e){msg="Error: "+e.getMessage();}
    }
    java.util.List<String[]> notes=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT title FROM allotlawyer WHERE alid=? AND lname=?"); ps.setInt(1,id); ps.setString(2,user); ResultSet rs=ps.executeQuery(); if(rs.next()) title=rs.getString(1);
        ps=con.prepareStatement("SELECT remark_text, created_at FROM lawyer_remarks WHERE alid=? ORDER BY created_at DESC"); ps.setInt(1,id); rs=ps.executeQuery();
        while(rs.next()) notes.add(new String[]{rs.getString(1),rs.getString(2).substring(0,16)});
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Case Updates"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp"><jsp:param name="active" value="cases"/></jsp:include>
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Case"/><jsp:param name="subtitle" value="Updates"/></jsp:include>
        <div class="px-4">
            <% if(!msg.isEmpty()){ %><div class="p-3 mb-4 border rounded bg-light small"><%=msg%></div><% } %>
            <div class="row g-4">
                <div class="col-md-5">
                    <form method="POST" class="panel p-4">
                        <h6 class="mb-3">New Entry</h6>
                        <textarea name="note" class="form-control mb-3" rows="4" required placeholder="Details..."></textarea>
                        <button type="submit" class="btn btn-dark w-100">Save Update</button>
                    </form>
                </div>
                <div class="col-md-7">
                    <div class="panel h-100">
                        <div class="panel-head"><h3>Recent Notes <small class="text-muted fw-normal ms-2"><%=title%></small></h3><a href="viewcase.jsp?alid=<%=id%>">Back</a></div>
                        <% for(String[] n:notes){ %>
                            <div class="p-3 border-bottom"><p class="mb-1" style="font-size:0.9rem;"><%=n[0]%></p><small class="text-muted" style="font-size:0.7rem;"><%=n[1]%></small></div>
                        <% } if(notes.isEmpty()){ %><div class="p-4 text-center text-muted">No notes found.</div><% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
