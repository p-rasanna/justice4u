<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String lEmail=(String)session.getAttribute("lname"), iId=request.getParameter("intern_id"), iName="", iMail="";
  if(lEmail==null){response.sendRedirect("../auth/Login.jsp");return;} if(iId==null){response.sendRedirect("../admin/viewinterns.jsp");return;}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Intern Workspace"/></jsp:include>
<body class="bg-light">
  <div class="container py-5" style="max-width:560px;">
    <div class="panel p-5">
      <%
        try(Connection con=DatabaseConfig.getConnection()){
          PreparedStatement ps=con.prepareStatement("SELECT name, email FROM intern WHERE internid=?"); ps.setInt(1,Integer.parseInt(iId)); ResultSet rs=ps.executeQuery();
          if(rs.next()){ iName=rs.getString(1); iMail=rs.getString(2); }
      %>
      <div class="text-center mb-4">
        <div class="h1 mb-1">Direct <em>Tasking</em></div>
        <p class="text-muted small">Targeting Associate: <strong><%=iName%></strong></p>
      </div>
      <form action="process_assign_intern.jsp" method="post">
        <input type="hidden" name="action" value="assign_task"><input type="hidden" name="intern_email" value="<%=iMail%>">
        <input type="hidden" name="lawyer_id" value="<%=session.getAttribute("lid")%>">
        <div class="mb-4">
          <label class="form-label small fw-bold text-uppercase" for="case_id">Select Active Case</label>
          <select id="case_id" name="case_id" class="form-select p-3" required>
            <option value="">-- Select Linked Case --</option>
            <%
              ps=con.prepareStatement("SELECT cid, title FROM allotlawyer WHERE lname=?"); ps.setString(1,lEmail); rs=ps.executeQuery();
              while(rs.next()){ %><option value="<%=rs.getInt(1)%>">#<%=rs.getInt(1)%> - <%=rs.getString(2)%></option><% }
            %>
          </select>
        </div>
        <div class="mb-4">
          <label class="form-label small fw-bold text-uppercase" for="title">Task Brief</label>
          <input id="title" type="text" name="title" class="form-control p-3" required placeholder="e.g. Research Recent IT Precedents">
        </div>
        <div class="mb-4">
          <label class="form-label small fw-bold text-uppercase" for="due_date">Due Date</label>
          <input id="due_date" type="date" name="due_date" class="form-control p-3" required>
        </div>
        <div class="d-flex gap-3 mt-5">
          <a href="../admin/viewinterns.jsp" class="btn btn-outline-dark w-100 p-3">Cancel</a>
          <button type="submit" class="btn btn-dark w-100 p-3">Create Task</button>
        </div>
      </form>
      <% }catch(Exception e){out.print("<div class='alert alert-danger'>"+e.getMessage()+"</div>");} %>
    </div>
  </div>
</body>
</html>
>