<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String iEmail=(String)session.getAttribute("iname"); 
    if(iEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
    
    String action=request.getParameter("action"), tidS=request.getParameter("task_id");
    if(action!=null && tidS!=null){
        try(Connection con=DatabaseConfig.getConnection()){
            int tid=Integer.parseInt(tidS); 
            String st="accept".equals(action)?"IN_PROGRESS":"REJECTED";
            PreparedStatement ps=con.prepareStatement("UPDATE intern_tasks SET status=? WHERE task_id=? AND intern_email=?");
            ps.setString(1,st); ps.setInt(2,tid); ps.setString(3,iEmail); ps.executeUpdate();
            if("accept".equals(action)){
                PreparedStatement p=con.prepareStatement("SELECT case_alid, title FROM intern_tasks WHERE task_id=?"); 
                p.setInt(1,tid); 
                ResultSet r=p.executeQuery();
                if(r.next()){
                    PreparedStatement pi=con.prepareStatement("INSERT INTO case_timeline (alid,event_type,event_description,created_by) VALUES (?,'TASK_ACCEPTED',?,?)");
                    pi.setInt(1,r.getInt(1)); 
                    pi.setString(2,"Accepted task: "+r.getString(2)); 
                    pi.setString(3,iEmail); 
                    pi.executeUpdate();
                }
            }
        }catch(Exception e){} 
        response.sendRedirect("interndashboard.jsp?msg=Task updated"); 
        return;
    }
    
    int pnd=0, inp=0, cmp=0; 
    java.util.List<String[]> tasks=new java.util.ArrayList<>(), cases=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT status, COUNT(*) FROM intern_tasks WHERE intern_email=? GROUP BY status"); 
        ps.setString(1,iEmail); 
        ResultSet rs=ps.executeQuery();
        while(rs.next()){ 
            String s=rs.getString(1); 
            int c=rs.getInt(2); 
            if(s.toUpperCase().contains("PENDING")) pnd+=c; 
            else if(s.equals("IN_PROGRESS")) inp+=c; 
            else if(s.equals("COMPLETED")) cmp+=c; 
        }
        ps=con.prepareStatement("SELECT task_id, title, due_date, status FROM intern_tasks WHERE intern_email=? AND status!='REJECTED' ORDER BY task_id DESC"); 
        ps.setString(1,iEmail); 
        rs=ps.executeQuery();
        while(rs.next()) tasks.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2), rs.getString(3), rs.getString(4)});
        
        ps=con.prepareStatement("SELECT a.alid, a.title, a.lname, ia.assigned_date FROM intern_assignments ia JOIN allotlawyer a ON ia.alid=a.alid WHERE ia.intern_email=? AND ia.status='ACTIVE'"); 
        ps.setString(1,iEmail); 
        rs=ps.executeQuery();
        while(rs.next()) cases.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2), rs.getString(3), rs.getString(4)});
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Intern Workspace"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_topbar.jsp" />
        <jsp:include page="../shared/_sidebar.jsp" />
        
        <main class="app-main">
            <!-- Content Header -->
            <div class="app-content-header">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-sm-6">
                            <h3 class="mb-0 text-serif">Intern Workspace</h3>
                        </div>
                        <div class="col-sm-6 text-end">
                            <ol class="breadcrumb float-sm-end">
                                <li class="breadcrumb-item"><a href="#" class="text-gold">Home</a></li>
                                <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Body -->
            <div class="app-content">
                <div class="container-fluid">
                    <% if(request.getParameter("msg")!=null){ %>
                        <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-4">
                            <i class="bi bi-info-circle-fill me-2"></i>
                            <%=request.getParameter("msg")%>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <% } %>

                    <!-- Stats Boxes -->
                    <div class="row g-4 mb-4">
                        <div class="col-12 col-sm-6 col-md-4">
                            <div class="info-box shadow-sm">
                                <span class="info-box-icon bg-warning shadow-sm"><i class="bi bi-clock-history"></i></span>
                                <div class="info-box-content">
                                    <span class="info-box-text text-uppercase small fw-bold text-muted">Pending Tasks</span>
                                    <span class="info-box-number h4 mb-0"><%=pnd%></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <div class="info-box shadow-sm">
                                <span class="info-box-icon bg-primary shadow-sm"><i class="bi bi-play-circle-fill"></i></span>
                                <div class="info-box-content">
                                    <span class="info-box-text text-uppercase small fw-bold text-muted">In Progress</span>
                                    <span class="info-box-number h4 mb-0"><%=inp%></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-sm-6 col-md-4">
                            <div class="info-box shadow-sm">
                                <span class="info-box-icon bg-success shadow-sm"><i class="bi bi-check-circle-fill"></i></span>
                                <div class="info-box-content">
                                    <span class="info-box-text text-uppercase small fw-bold text-muted">Completed</span>
                                    <span class="info-box-number h4 mb-0"><%=cmp%></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4">
                        <div class="col-lg-7">
                            <!-- Action Queue Card -->
                            <div class="card shadow-sm mb-4">
                                <div class="card-header border-0 bg-transparent">
                                    <h3 class="card-title text-serif"><i class="bi bi-list-task text-gold me-2"></i> Action Queue</h3>
                                </div>
                                <div class="card-body p-0">
                                    <div class="list-group list-group-flush">
                                        <% 
                                            boolean anyTask = false;
                                            for(String[] t : tasks){ 
                                                boolean isPending = t[3].toUpperCase().contains("PENDING") || t[3].equals("Assigned");
                                                boolean isInProgress = t[3].equals("IN_PROGRESS");
                                                if(isPending || isInProgress){ 
                                                    anyTask = true;
                                        %>
                                            <div class="list-group-item p-4">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <h6 class="mb-1 fw-bold"><%=t[1]%></h6>
                                                        <small class="text-muted"><i class="bi bi-calendar-event text-gold me-1"></i> Due Date: <%=t[2]%></small>
                                                    </div>
                                                    <div class="btn-group">
                                                        <% if(isPending){ %>
                                                            <a href="?action=accept&task_id=<%=t[0]%>" class="btn btn-sm btn-gold px-3">Accept</a>
                                                            <a href="?action=reject&task_id=<%=t[0]%>" class="btn btn-sm btn-outline-danger ms-2">Decline</a>
                                                        <% } else { %>
                                                            <a href="uploadInternWork.jsp?task_id=<%=t[0]%>" class="btn btn-sm btn-dark px-3">
                                                                <i class="bi bi-cloud-upload me-1"></i> Submit Work
                                                            </a>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            </div>
                                        <% 
                                                } 
                                            } 
                                            if(!anyTask){ 
                                        %>
                                            <div class="p-5 text-center text-muted">
                                                <i class="bi bi-check2-all fs-1 d-block mb-2 opacity-25"></i> 
                                                No tasks in your queue currently.
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-5">
                            <!-- Active Cases Card -->
                            <div class="card shadow-sm">
                                <div class="card-header border-0 bg-transparent">
                                    <h3 class="card-title text-serif"><i class="bi bi-briefcase-fill text-gold me-2"></i> Active Cases</h3>
                                </div>
                                <div class="card-body p-0">
                                    <div class="list-group list-group-flush">
                                        <% for(String[] c : cases){ %>
                                            <div class="list-group-item p-4 d-flex align-items-center justify-content-between">
                                                <div>
                                                    <h6 class="mb-1 fw-bold"><%=c[1]%></h6>
                                                    <small class="text-muted"><i class="bi bi-person-badge-fill text-gold me-1"></i> Adv. <%=c[2]%></small>
                                                </div>
                                                <a href="viewcase_intern.jsp?id=<%=c[0]%>" class="btn btn-sm btn-outline-gold border-2" title="View Case Details">
                                                    <i class="bi bi-arrow-right"></i>
                                                </a>
                                            </div>
                                        <% } if(cases.isEmpty()){ %>
                                            <div class="p-5 text-center text-muted">
                                                <i class="bi bi-folder-x fs-1 d-block mb-2 opacity-25"></i>
                                                No cases assigned yet.
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="card-footer bg-light-subtle text-center border-0 py-2">
                                    <a href="intern.jsp" class="text-gold small fw-bold text-decoration-none">View All Assignments</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        
        <jsp:include page="../shared/_footer.jsp" />
    </div>
</body>
</html>

