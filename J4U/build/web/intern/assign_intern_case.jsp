<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String iEmail=request.getParameter("intern_email"), iName=request.getParameter("intern_name"), lEmail=(String)session.getAttribute("lname");
    if(lEmail==null){response.sendRedirect("../auth/Login.jsp");return;} if(iEmail==null){response.sendRedirect("../admin/viewinterns.jsp");return;}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Intern Workspace"/></jsp:include>
<body class="bg-light">
    <div class="container py-5" style="max-width:560px;">
        <div class="panel p-5">
            <div class="text-center mb-4">
                <div class="h1 mb-1">Delegate <em>Case</em></div>
                <p class="text-muted small">Authorize Intern: <strong><%=iName%></strong></p>
            </div>
            <form action="process_assign_intern.jsp" method="post">
                <input type="hidden" name="action" value="assign_case"><input type="hidden" name="intern_email" value="<%=iEmail%>">
                <% 
                    try(Connection con=DatabaseConfig.getConnection()){
                        PreparedStatement ps=con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?"); ps.setString(1,lEmail); ResultSet rs=ps.executeQuery();
                        if(rs.next()){ %><input type="hidden" name="lawyer_id" value="<%=rs.getInt(1)%>"><% }
                %>
                <div class="mb-4">
                    <label class="form-label small fw-bold text-uppercase">Select Active Case</label>
                    <select name="case_id" class="form-select p-3" required>
                        <option value="">-- Choose Case Context --</option>
                        <%
                            ps=con.prepareStatement("SELECT cid, title FROM allotlawyer WHERE lname=? ORDER BY cid DESC"); ps.setString(1,lEmail); rs=ps.executeQuery();
                            while(rs.next()){ %><option value="<%=rs.getInt(1)%>">#<%=rs.getInt(1)%> - <%=rs.getString(2)%></option><% }
                        %>
                    </select>
                </div>
                <div class="d-flex gap-3 mt-5">
                    <a href="../admin/viewinterns.jsp" class="btn btn-outline-dark w-100 p-3">Cancel</a>
                    <button type="submit" class="btn btn-dark w-100 p-3">Authorize Access</button>
                </div>
                <% }catch(Exception e){out.print("<div class='alert alert-danger'>"+e.getMessage()+"</div>");} %>
            </form>
        </div>
    </div>
</body>
</html>
>

