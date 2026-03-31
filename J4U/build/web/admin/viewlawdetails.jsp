<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String clientName=(String)session.getAttribute("cname"), clientEmail=(String)session.getAttribute("cemail");
    if(clientName==null){response.sendRedirect("../auth/Login.jsp");return;}
    String lawyerEmail=request.getParameter("id");
    if(lawyerEmail==null || lawyerEmail.isEmpty()){
        try(Connection con=DatabaseConfig.getConnection()){
            PreparedStatement ps=con.prepareStatement("SELECT l.email FROM lawyer_reg l JOIN customer_cases cc ON l.lid=cc.assigned_lawyer_id JOIN cust_reg c ON cc.customer_id=c.cid WHERE c.email=? LIMIT 1");
            ps.setString(1, clientEmail); ResultSet rs=ps.executeQuery(); if(rs.next()) lawyerEmail=rs.getString(1);
        }catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Admin"/></jsp:include>
<body>
<div class="app">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main"><div class="topbar"><div><h1>Attorney <em>Profile</em></h1><p class="text-muted small">Verified Legal Practitioner</p></div><a href="javascript:history.back()" class="btn btn-outline-dark btn-sm px-3"><i class="ph ph-arrow-left"></i> Back</a></div>
        <% try(Connection con=DatabaseConfig.getConnection()){
            PreparedStatement ps=con.prepareStatement("SELECT * FROM lawyer_reg WHERE email=? OR lid=?"); 
            ps.setString(1, lawyerEmail); try { ps.setInt(2, Integer.parseInt(lawyerEmail)); } catch(Exception e){ ps.setInt(2, -1); }
            ResultSet rs=ps.executeQuery();
            if(rs.next()){ boolean isV=rs.getInt("flag")==1; String nm=rs.getString("name"); if(nm==null) nm=rs.getString("lname"); if(nm==null) nm="Lawyer"; %>
            <div class="panel p-4"><div class="d-flex gap-4 align-items-center mb-4">
                <div class="rounded-circle bg-light d-flex align-items-center justify-content-center fw-bold text-dark border" style="width:80px; height:80px; font-size:2rem;"><%=nm.charAt(0)%></div>
                <div><h2 class="mb-1"><%=nm%> <% if(isV){ %><i class="ph-fill ph-check-circle text-primary" title="Verified"></i><% } %></h2>
                    <p class="text-muted mb-0"><%=rs.getString("specialization")!=null?rs.getString("specialization"):"Advocate"%> · BAR ID: <%=rs.getString("ano")!=null?rs.getString("ano"):rs.getString("bar_council_number")%></p></div>
            </div><hr class="my-4">
            <div class="row g-4">
                <div class="col-md-8"><h5 class="fw-bold mb-3">Professional Summary</h5><p class="text-muted"><%=rs.getString("cadd")!=null?rs.getString("cadd"):"Contact for office details."%></p>
                    <div class="mt-4"><h6 class="small fw-bold text-muted mb-3">PRACTICE AREAS</h6><div class="d-flex gap-2 flex-wrap">
                        <% String s=rs.getString("specialization"); if(s!=null) for(String p:s.split(",")) if(!p.trim().isEmpty()) { %><span class="badge border py-2 px-3"><%=p.trim()%></span><% } %>
                    </div></div></div>
                <div class="col-md-4"><div class="bg-light p-4 rounded-4"><h6 class="fw-bold mb-3">Quick Actions</h6>
                    <div class="d-grid gap-2"><a href="../client/case.jsp?lawyer_email=<%=rs.getString("email")%>" class="btn btn-dark w-100">Select for Case</a><a href="../client/chat.jsp?id=<%=rs.getInt("lid")%>" class="btn btn-outline-dark w-100">Message Lawyer</a></div>
                    <div class="mt-4 pt-3 border-top"><div class="d-flex justify-content-between mb-2 small"><span class="text-muted">Response Time</span><span class="fw-bold">~24 Hours</span></div>
                    <div class="d-flex justify-content-between small"><span class="text-muted">Member Since</span><span class="fw-bold">2024</span></div></div></div></div>
            </div></div>
        <% } else { %><div class="panel p-5 text-center"><i class="ph ph-user-circle-minus display-4 text-muted mb-3"></i><h3>Lawyer Not Found</h3><p class="text-muted">The requested profile is not available.</p></div><% }
        }catch(Exception e){out.print("Error: "+e.getMessage());} %>
    </main>
</div>

</body>
</html>


