<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig, java.util.Date, java.text.SimpleDateFormat" %>
<%
    String email = (String) session.getAttribute("lname");
    if (email == null) { response.sendRedirect("../auth/Login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="My Hearings"/></jsp:include>
<body>
    <div class="app-layout">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="main-content">
            <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="My"/><jsp:param name="subtitle" value="Hearings"/></jsp:include>
            <div class="p-5">
                <% if(request.getParameter("msg") != null) { %><div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %> <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>
                <div class="row g-4">
                    <div class="col-lg-8">
                        <div class="panel p-0 overflow-hidden mb-4"><div class="panel-head"><h3>Upcoming Hearings</h3></div><div class="list-group list-group-flush">
<%
    boolean hu=false, hp=false; StringBuilder pS = new StringBuilder();
    try(Connection con=DatabaseConfig.getConnection()){
        try(PreparedStatement ps=con.prepareStatement("SELECT h.*, c.title, c.cname, c.cid FROM hearings h JOIN casetb c ON h.case_id=c.cid JOIN allotlawyer al ON al.cid=c.cid WHERE al.lname=? ORDER BY h.hearing_date ASC")){
            ps.setString(1,email); try(ResultSet rs=ps.executeQuery()){
                String tS = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
                while(rs.next()){
                    String hD=rs.getDate("hearing_date").toString(), hT=rs.getTime("hearing_time")!=null?rs.getTime("hearing_time").toString():""; if(hT.length()>5) hT=hT.substring(0,5);
                    boolean isP = hD.compareTo(tS)<0;
                    String bdg=""; if(hD.equals(tS)) bdg="<span class='badge bg-danger'>Today</span>"; else if(!isP) bdg="<span class='badge bg-warning text-dark'>Upcoming</span>";
                    String html="<div class='list-group-item p-4 d-flex justify-content-between align-items-center "+(isP?"bg-light opacity-75":"")+"'><div><h6 class='mb-1 fw-bold'><i class='ph-fill ph-calendar text-primary me-2'></i>"+hD+" at "+hT+" "+bdg+"</h6><p class='small mb-2 fw-bold text-dark'>"+rs.getString("title")+" ("+rs.getString("cname")+")</p><small class='text-muted'><i class='ph-fill ph-bank me-1'></i> "+rs.getString("court_name")+"</small></div>"+(!isP?"<a href='../shared/addHearing.jsp?case_id="+rs.getInt("cid")+"' class='btn btn-sm btn-outline-dark'><i class='ph ph-calendar-plus'></i></a>":"")+"</div>";
                    if(isP){ hp=true; pS.append(html); } else { hu=true; out.println(html); }
                }
            }
        }
    }catch(Exception e){}
    if(!hu) out.println("<div class='p-5 text-center text-muted'>No upcoming hearings.</div>");
%>
                        </div></div>
                        <% if(hp){ %>
                        <div class="panel p-0 overflow-hidden"><div class="panel-head text-muted"><h3>Past Hearings</h3></div><div class="list-group list-group-flush"><%=pS.toString()%></div></div>
                        <% } %>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
