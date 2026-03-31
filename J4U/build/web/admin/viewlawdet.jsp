<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String admin=(String)session.getAttribute("aname"); if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
    String lIdParam=request.getParameter("lid"); if(lIdParam==null) lIdParam=request.getParameter("id");
    if(lIdParam==null){response.sendRedirect("viewlawyers.jsp");return;}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Admin"/></jsp:include>
<body>
<div class="app">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main"><div class="topbar"><div><h1>Lawyer <em>Profile</em></h1><p class="text-muted small">Professional Credentials & Record</p></div><a href="javascript:history.back()" class="btn btn-outline-dark btn-sm px-3"><i class="ph ph-arrow-left"></i> Back</a></div>
        <% try(Connection con=DatabaseConfig.getConnection()){
            PreparedStatement ps=con.prepareStatement("SELECT * FROM lawyer_reg WHERE lid=? OR email=?"); 
            try { ps.setInt(1, Integer.parseInt(lIdParam)); ps.setString(2, ""); } catch(Exception e){ ps.setInt(1, -1); ps.setString(2, lIdParam); }
            ResultSet rs=ps.executeQuery();
            if(rs.next()){ String nm=rs.getString("lname"); if(nm==null) nm=rs.getString("name"); if(nm==null) nm="Lawyer"; %>
            <div class="row g-4">
                <div class="col-md-4"><div class="panel p-4 text-center">
                    <div class="rounded-circle bg-light d-flex align-items-center justify-content-center fw-bold text-dark border mx-auto mb-3" style="width:80px; height:80px; font-size:2rem;"><%=nm.charAt(0)%></div>
                    <h3 class="mb-1"><%=nm%></h3><p class="text-muted small">ID: #<%=rs.getInt("lid")%></p>
                    <div class="text-start mt-4 small">
                        <div class="mb-2"><span class="text-muted">Email</span><br><strong><%=rs.getString("email")%></strong></div>
                        <div class="mb-2"><span class="text-muted">Specialization</span><br><strong><%=rs.getString("specialization")%></strong></div>
                        <div class="mb-2"><span class="text-muted">Bar ID</span><br><strong><%=rs.getString("ano")%></strong></div>
                    </div>
                </div></div>
                <div class="col-md-8"><div class="panel p-4"><h5 class="fw-bold mb-4">Contact Information</h5>
                    <div class="row g-3">
                        <div class="col-6"><span class="text-muted small d-block">Phone</span><div><%=rs.getString("mobno")%></div></div>
                        <div class="col-6"><span class="text-muted small d-block">DOB</span><div><%=rs.getString("dob")%></div></div>
                        <div class="col-12"><span class="text-muted small d-block">Current Address</span><div><%=rs.getString("cadd")%></div></div>
                        <div class="col-12"><span class="text-muted small d-block">Permanent Address</span><div><%=rs.getString("padd")%></div></div>
                    </div>
                </div></div>
            </div>
        <% } }catch(Exception e){out.print("Error: "+e.getMessage());} %>
    </main>
</div>
</body>
</html>


