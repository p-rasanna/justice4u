<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig"%>
<%
    String user=(String)session.getAttribute("lname"); if(user==null){response.sendRedirect("../auth/Login.jsp");return;}
    String cid=request.getParameter("caseid")!=null?request.getParameter("caseid"):request.getParameter("case");
    if(cid==null){response.sendRedirect("Lawyerdashboard.jsp");return;}
    String title="", client=""; int id=Integer.parseInt(cid); boolean access=false;
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT title FROM allotlawyer WHERE alid=? AND lname=?");
        ps.setInt(1,id); ps.setString(2,user); ResultSet rs=ps.executeQuery();
        if(rs.next()){ access=true; title=rs.getString(1); }
    }catch(Exception e){} if(!access){response.sendRedirect("Lawyerdashboard.jsp?msg=Access denied");return;}
    java.util.List<String[]> events=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT * FROM case_timeline WHERE alid=? ORDER BY created_at DESC"); ps.setInt(1,id);
        ResultSet rs=ps.executeQuery(); while(rs.next()) events.add(new String[]{rs.getString("event_type"),rs.getString("event_description"),rs.getString("created_at")});
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Case Timeline"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp"><jsp:param name="active" value="cases"/></jsp:include>
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Case"/><jsp:param name="subtitle" value="Timeline"/></jsp:include>
        <div class="px-4">
            <div class="panel p-0">
                <div class="panel-head"><h3>Timeline <small class="text-muted fw-normal ms-2"><%=title%></small></h3><a href="viewcase.jsp?alid=<%=id%>">Back</a></div>
                <div class="p-4">
                    <% for(String[] e:events){ %>
                        <div class="mb-4 border-start ps-3 pb-2">
                            <h6 class="mb-1 small text-uppercase fw-bold text-gold"><%=e[0].replace("_"," ")%></h6>
                            <p class="mb-1 small"><%=e[1]%></p>
                            <small class="text-muted"><%=e[2]%></small>
                        </div>
                    <% } if(events.isEmpty()){ %><div class="p-5 text-center text-muted">No events recorded.</div><% } %>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>

