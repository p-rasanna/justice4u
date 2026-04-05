<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.io.*,java.util.*,com.j4u.DatabaseConfig,org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*,org.apache.commons.fileupload.servlet.*,org.apache.commons.io.*"%>
<%
    String user=(String)session.getAttribute("lname"); 
    if(user==null){ response.sendRedirect("../auth/Lawyer_login_form.jsp"); return; }
    
    String msg="", msgT="info";
    if(ServletFileUpload.isMultipartContent(request)){
        try{
            DiskFileItemFactory factory=new DiskFileItemFactory(); 
            ServletFileUpload upload=new ServletFileUpload(factory);
            List<FileItem> items=upload.parseRequest(request); 
            String cid="", date="", court="", rem="", path=null;
            for(FileItem it:items){
                if(it.isFormField()){
                    if("case_id".equals(it.getFieldName())) cid=it.getString("UTF-8");
                    else if("hearing_date".equals(it.getFieldName())) date=it.getString("UTF-8");
                    else if("court_name".equals(it.getFieldName())) court=it.getString("UTF-8");
                    else if("remarks".equals(it.getFieldName())) rem=it.getString("UTF-8");
                } else if(!it.getName().isEmpty()){
                    String name=UUID.randomUUID().toString().substring(0,8)+"_"+new File(it.getName()).getName();
                    File dir = new File(application.getRealPath("/") + "uploads/hearings/");
                    if(!dir.exists()) dir.mkdirs();
                    File f=new File(dir, name); 
                    it.write(f); 
                    path="uploads/hearings/"+name;
                }
            }
            try(Connection con=DatabaseConfig.getConnection()){
                PreparedStatement ps=con.prepareStatement("INSERT INTO hearings (case_id,hearing_date,court_name,notes,created_by,order_copy_path) VALUES (?,?,?,?,?,?)");
                ps.setInt(1,Integer.parseInt(cid)); ps.setString(2,date); ps.setString(3,court); ps.setString(4,rem); ps.setString(5,user); ps.setString(6,path); 
                ps.executeUpdate();
            } 
            msg="Hearing scheduled successfully!";
            msgT="success";
        } catch(Exception e){ 
            msg="Error: "+e.getMessage(); 
            msgT="danger";
        }
    }
    
    java.util.List<String[]> hList=new java.util.ArrayList<>(), cList=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT a.alid, a.title FROM allotlawyer a JOIN case_status cs ON a.alid=cs.alid WHERE a.lname=? AND cs.status IN ('ACCEPTED','IN_PROGRESS','ACTIVE')");
        ps.setString(1,user); 
        ResultSet rs=ps.executeQuery(); 
        while(rs.next()) cList.add(new String[]{String.valueOf(rs.getInt(1)),rs.getString(2)});
        
        ps=con.prepareStatement("SELECT h.*, a.title FROM hearings h JOIN allotlawyer a ON h.case_id=a.cid WHERE h.created_by=? ORDER BY h.hearing_date DESC");
        ps.setString(1,user); 
        rs=ps.executeQuery(); 
        while(rs.next()) hList.add(new String[]{rs.getString("hearing_date"),rs.getString("court_name"),rs.getString("title"),rs.getString("remarks"),rs.getString("order_copy_path")});
    } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Manage Hearings"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="app-main">
            <jsp:include page="components/_topbar.jsp">
                <jsp:param name="title" value="Procedural Management"/>
                <jsp:param name="subtitle" value="Hearing Schedules"/>
            </jsp:include>
            
            <div class="app-content pt-4">
                <div class="container-fluid text-start">
                    <% if(!msg.isEmpty()){ %>
                        <div class="alert alert-<%=msgT%> border-0 shadow-sm mb-4">
                            <i class="bi <%= "success".equals(msgT) ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i>
                            <%=msg%>
                        </div>
                    <% } %>
                    
                    <div class="row g-4">
                        <!-- Scheduling Form -->
                        <div class="col-xl-4 col-lg-5">
                            <div class="card border-0 shadow-sm rounded-4">
                                <div class="card-header bg-white border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif"><i class="bi bi-calendar-plus text-gold me-2"></i>Schedule Proceeding</h5>
                                </div>
                                <div class="card-body p-4 pt-0">
                                    <form method="POST" enctype="multipart/form-data">
                                        <div class="mb-3">
                                            <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2">Subject Matter / Case</label>
                                            <select name="case_id" class="form-select border-light-subtle" required>
                                                <option value="" disabled selected>— Select Active File —</option>
                                                <% for(String[] c:cList){%>
                                                    <option value="<%=c[0]%>"><%=c[1]%></option>
                                                <%}%>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2">Hearing Date</label>
                                            <input type="date" name="hearing_date" class="form-control border-light-subtle" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2">Court / Repository Location</label>
                                            <input type="text" name="court_name" class="form-control border-light-subtle" placeholder="e.g. Supreme Court, Room 4" required>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2">Upload Order Copy (Optional)</label>
                                            <input type="file" name="order_copy" class="form-control border-light-subtle">
                                            <div class="form-text small">Attach the latest judicial order if available.</div>
                                        </div>
                                        <div class="mb-4">
                                            <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2">Internal Remarks</label>
                                            <textarea name="remarks" class="form-control border-light-subtle" rows="2" placeholder="Brief notes for the record..."></textarea>
                                        </div>
                                        <div class="d-grid">
                                            <button type="submit" class="btn btn-gold btn-lg py-3 rounded-3 shadow-sm border-0 fw-bold">
                                                Confirm Schedule <i class="bi bi-send-plus-fill ms-2"></i>
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <!-- Scheduled List -->
                        <div class="col-xl-8 col-lg-7">
                            <div class="card border-0 shadow-sm rounded-4 h-100">
                                <div class="card-header bg-white border-0 py-4 px-4 d-flex justify-content-between align-items-center">
                                    <h5 class="card-title fw-bold mb-0 text-serif"><i class="bi bi-list-columns-reverse text-gold me-2"></i>Scheduled Proceedings</h5>
                                    <span class="badge bg-gold-subtle text-gold px-3"><%= hList.size() %> Active</span>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle mb-0">
                                            <thead class="bg-light">
                                                <tr>
                                                    <th class="ps-4 border-0 text-uppercase small fw-bold text-muted ls-1" style="font-size: 0.75rem;">Subject / Title</th>
                                                    <th class="border-0 text-uppercase small fw-bold text-muted ls-1" style="font-size: 0.75rem;">Date & Venue</th>
                                                    <th class="border-0 text-uppercase small fw-bold text-muted ls-1" style="font-size: 0.75rem;">Remarks</th>
                                                    <th class="pe-4 border-0 text-uppercase small fw-bold text-muted ls-1 text-center" style="font-size: 0.75rem;">Action</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% if(hList.isEmpty()){ %>
                                                    <tr>
                                                        <td colspan="4" class="text-center py-5 text-muted">
                                                            <i class="bi bi-calendar2-x display-4 opacity-10"></i>
                                                            <p class="mt-3 fs-5">No hearings currently scheduled.</p>
                                                        </td>
                                                    </tr>
                                                <% } else { %>
                                                    <% for(String[] h:hList){ %>
                                                        <tr>
                                                            <td class="ps-4">
                                                                <div class="fw-bold text-dark"><%= h[2] %></div>
                                                                <div class="small text-muted">Record ID: <%= UUID.randomUUID().toString().substring(0,6).toUpperCase() %></div>
                                                            </td>
                                                            <td>
                                                                <div class="small fw-bold"><i class="bi bi-calendar-event me-2 text-gold"></i><%= h[0] %></div>
                                                                <div class="small text-muted"><i class="bi bi-bank me-2"></i><%= h[1] %></div>
                                                            </td>
                                                            <td>
                                                                <div class="small text-truncate" style="max-width: 200px;" title="<%= h[3] != null ? h[3] : "" %>">
                                                                    <%= (h[3] != null && !h[3].isEmpty()) ? h[3] : "—" %>
                                                                </div>
                                                            </td>
                                                            <td class="pe-4 text-center">
                                                                <% if(h[4]!=null){%>
                                                                    <a href="../<%=h[4]%>" target="_blank" class="btn btn-sm btn-outline-dark rounded-pill px-3">
                                                                        <i class="bi bi-file-earmark-pdf me-1"></i> View Doc
                                                                    </a>
                                                                <%} else { %>
                                                                    <span class="text-muted opacity-50 small">—</span>
                                                                <% } %>
                                                            </td>
                                                        </tr>
                                                    <% } %>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="components/_footer.jsp" />
        </main>
    </div>
</body>
</html>

