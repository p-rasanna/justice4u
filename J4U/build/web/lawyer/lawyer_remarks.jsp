<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig"%>
<%
    String user=(String)session.getAttribute("lname"); if(user==null){response.sendRedirect("../auth/Login.jsp");return;}
    String msg="";
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT status FROM lawyer_reg WHERE email=?"); ps.setString(1,user);
        ResultSet rs=ps.executeQuery(); if(!rs.next() || (!"VERIFIED".equals(rs.getString(1)) && !"APPROVED".equals(rs.getString(1)))){ response.sendRedirect("Lawyerdashboard.jsp?msg=Account not approved"); return; }
    }catch(Exception e){}
    if("POST".equalsIgnoreCase(request.getMethod())){
        try(Connection con=DatabaseConfig.getConnection()){
            PreparedStatement ps=con.prepareStatement("INSERT INTO lawyer_remarks (alid,lawyer_email,remark_text,visibility) VALUES (?,?,?,?)");
            ps.setInt(1,Integer.parseInt(request.getParameter("case_id"))); ps.setString(2,user); ps.setString(3,request.getParameter("remark_text")); ps.setString(4,request.getParameter("visibility")); ps.executeUpdate(); msg="Remark added!";
        }catch(Exception e){msg="Error: "+e.getMessage();}
    }
    java.util.List<String[]> rList=new java.util.ArrayList<>(), cList=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT a.alid, a.title FROM allotlawyer a JOIN case_status cs ON a.alid=cs.alid WHERE a.lname=? AND cs.status IN ('ACCEPTED','IN_PROGRESS')");
        ps.setString(1,user); ResultSet rs=ps.executeQuery(); while(rs.next()) cList.add(new String[]{String.valueOf(rs.getInt(1)),rs.getString(2)});
        ps=con.prepareStatement("SELECT lr.*, a.title FROM lawyer_remarks lr JOIN allotlawyer a ON lr.alid=a.alid WHERE lr.lawyer_email=? ORDER BY lr.created_at DESC");
        ps.setString(1,user); rs=ps.executeQuery(); while(rs.next()) rList.add(new String[]{rs.getString("title"),rs.getString("remark_text"),rs.getString("visibility"),rs.getString("created_at")});
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Case Remarks"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp"><jsp:param name="active" value="messages"/></jsp:include>
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Case"/><jsp:param name="subtitle" value="Remarks"/></jsp:include>
        <div class="px-4">
            <% if(!msg.isEmpty()){ %><div class="p-3 mb-4 border rounded bg-light small"><%=msg%></div><% } %>
            <div class="row g-4">
                <div class="col-md-5">
                    <form method="POST" class="panel p-4">
                        <h6 class="mb-3">New Remark</h6>
                        <div class="mb-3"><label class="small fw-bold mb-1">Case</label><select name="case_id" class="form-select" required><option value="">Select Case</option><% for(String[] c:cList){%><option value="<%=c[0]%>"><%=c[1]%></option><%}%></select></div>
                        <div class="mb-3"><label class="small fw-bold mb-1">Visibility</label><select name="visibility" class="form-select"><option value="INTERNAL">Internal</option><option value="CLIENT_VISIBLE">Client Visible</option></select></div>
                        <div class="mb-3"><textarea name="remark_text" class="form-control" rows="3" required placeholder="Details..."></textarea></div>
                        <button type="submit" class="btn btn-dark w-100">Add Remark</button>
                    </form>
                </div>
                <div class="col-md-7">
                    <div class="panel h-100">
                        <div class="panel-head"><h3>History</h3></div>
                        <% for(String[] r:rList){ %>
                            <div class="p-3 border-bottom">
                                <div class="d-flex justify-content-between"><strong><%=r[0]%></strong><span class="badge border small"><%=r[2]%></span></div>
                                <p class="small mb-1 mt-1"><%=r[1]%></p>
                                <small class="text-muted" style="font-size:0.7rem;"><%=r[3]%></small>
                            </div>
                        <% } if(rList.isEmpty()){ %><div class="p-4 text-center text-muted">No remarks.</div><% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>

