<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String iEmail=(String)session.getAttribute("iname"); if(iEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
    String tidS=request.getParameter("task_id"), msg=request.getParameter("msg");
    if("POST".equalsIgnoreCase(request.getMethod())){
        String notes=request.getParameter("notes"), tid2=request.getParameter("task_id");
        if(tid2!=null){
            try(Connection con=DatabaseConfig.getConnection()){
                PreparedStatement ps=con.prepareStatement("UPDATE intern_tasks SET status='COMPLETED' WHERE task_id=? AND intern_email=?");
                ps.setInt(1,Integer.parseInt(tid2)); ps.setString(2,iEmail); ps.executeUpdate();
                con.prepareStatement("INSERT INTO intern_work_submissions (task_id, intern_email, notes, status) VALUES ("+tid2+",'"+iEmail+"','"+notes+"','SUBMITTED')").executeUpdate();
                ps=con.prepareStatement("SELECT case_alid, title FROM intern_tasks WHERE task_id=?"); ps.setInt(1,Integer.parseInt(tid2)); ResultSet r=ps.executeQuery();
                if(r.next()){
                    PreparedStatement pi=con.prepareStatement("INSERT INTO case_timeline (alid,event_type,event_description,created_by) VALUES (?,'WORK_SUBMITTED',?,?)");
                    pi.setInt(1,r.getInt(1)); pi.setString(2,"Work submitted for: "+r.getString(2)); pi.setString(3,iEmail); pi.executeUpdate();
                }
                response.sendRedirect("interndashboard.jsp?msg=Work submitted"); return;
            }catch(Exception e){msg="Error: "+e.getMessage();}
        }
    }
    java.util.List<String[]> tasks=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT task_id, title FROM intern_tasks WHERE intern_email=? AND status='IN_PROGRESS'"); ps.setString(1,iEmail); ResultSet rs=ps.executeQuery();
        while(rs.next()) tasks.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2)});
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Intern Workspace"/></jsp:include>
<body>
<div class="container" style="max-width:600px;">
    <div class="panel p-5">
        <a href="interndashboard.jsp" class="btn btn-sm btn-outline-dark mb-4"><i class="ph ph-arrow-left"></i> Back</a>
        <h1 class="mb-1">Submit <em>Work</em></h1>
        <p class="text-muted small mb-5">Finalize your research or task deliverables.</p>
        <% if(msg!=null){ %><div class="alert alert-info mb-4"><%=msg%></div><% } %>
        <% if(tasks.isEmpty()){ %><div class="text-center p-4 text-muted border rounded">No active tasks to submit.</div>
        <% } else { %>
        <form method="POST">
            <div class="mb-4"><label class="form-label small fw-bold text-uppercase" for="task_id">Target Task</label>
                <select id="task_id" name="task_id" class="form-select p-3" required>
                    <option value="">-- Choose Task --</option>
                    <% for(String[] t : tasks){ %><option value="<%=t[0]%>" <%=t[0].equals(tidS)?"selected":""%>><%=t[1]%></option><% } %>
                </select></div>
            <div class="mb-4"><label class="form-label small fw-bold text-uppercase" for="notes">Submission Notes</label>
                <textarea id="notes" name="notes" class="form-control p-3" style="min-height:120px;" placeholder="Describe your findings or deliverables..." required></textarea></div>
            <button type="submit" class="btn btn-dark w-100 p-3 mt-3">Finalize Submission <i class="ph-fill ph-check-circle ms-2"></i></button>
        </form><% } %>
    </div>
</div>
</body>
</html>

