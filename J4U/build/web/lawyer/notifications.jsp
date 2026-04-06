<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("lname");
  if (email == null) { response.sendRedirect("../auth/Login.jsp"); return; }
  try(Connection con=DatabaseConfig.getConnection()){
    try(PreparedStatement ps=con.prepareStatement("UPDATE notifications SET is_read=1 WHERE user_email=?")){ps.setString(1,email); ps.executeUpdate();}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Notifications"/></jsp:include>
<body>
  <div class="app-layout">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main-content">
      <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="My"/><jsp:param name="subtitle" value="Alerts"/></jsp:include>
      <div class="p-5">
        <div class="row g-4"><div class="col-lg-8">
          <div class="panel p-0 overflow-hidden">
            <div class="panel-head"><h3>All Notifications</h3></div>
            <div class="list-group list-group-flush">
<%
    boolean hN=false; try(PreparedStatement ps=con.prepareStatement("SELECT * FROM notifications WHERE user_email=? ORDER BY created_at DESC LIMIT 50")){
      ps.setString(1,email); try(ResultSet rs=ps.executeQuery()){
        while(rs.next()){
          hN=true; String t=rs.getString("type"), l=rs.getString("link"), ic="ph-bell";
          if("case".equals(t)) ic="ph-scales"; else if("message".equals(t)) ic="ph-chat-circle-text"; else if("hearing".equals(t)) ic="ph-calendar"; else if("document".equals(t)) ic="ph-file-text";
          String html="<div class='list-group-item p-4 d-flex gap-3 align-items-center'><div class='avatar bg-light text-primary flex-shrink-0'><i class='ph-fill "+ic+"'></i></div><div class='flex-grow-1'><p class='mb-0 fw-bold'>"+rs.getString("message")+"</p><small class='text-muted'>"+rs.getTimestamp("created_at")+"</small></div></div>";
          if(l!=null&&!l.isEmpty()) out.println("<a href='"+l+"' class='text-decoration-none text-dark hover-bg-light'>"+html+"</a>"); else out.println(html);
        }
      }
    }
    if(!hN) out.println("<div class='p-5 text-center text-muted'>All caught up!</div>");
%>
            </div>
          </div>
        </div></div>
      </div>
    </main>
  </div>
</body>
</html>
<% }catch(Exception e){ response.sendRedirect("../shared/error.jsp"); } %>