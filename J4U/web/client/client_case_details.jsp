<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String email=(String)session.getAttribute("cname"); if(email==null){response.sendRedirect("../auth/Login.jsp");return;}
    int cid=Integer.parseInt(request.getParameter("cid")), alid=Integer.parseInt(request.getParameter("alid"));
    String title="", desc="", status="", date="", court="", lawyer=null;
    java.util.List<String[]> tl=new java.util.ArrayList<>(), docs=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT * FROM casetb WHERE cid=? AND cname=?"); ps.setInt(1,cid); ps.setString(2,email);
        ResultSet rs=ps.executeQuery(); if(rs.next()){ title=rs.getString("title"); desc=rs.getString("des"); status=rs.getString("status"); date=rs.getString("curdate"); court=rs.getString("courttype"); }
        if(alid>0){
            ps=con.prepareStatement("SELECT name FROM lawyer_reg WHERE email=(SELECT lname FROM allotlawyer WHERE alid=?)"); ps.setInt(1,alid);
            rs=ps.executeQuery(); if(rs.next()) lawyer=rs.getString(1);
            ps=con.prepareStatement("SELECT event_type, event_description, created_at FROM case_timeline WHERE alid=? ORDER BY created_at DESC"); ps.setInt(1,alid);
            rs=ps.executeQuery(); while(rs.next()) tl.add(new String[]{rs.getString(1),rs.getString(2),rs.getString(3)});
            ps=con.prepareStatement("SELECT file_name, file_path, uploaded_at FROM case_documents WHERE case_id=?"); ps.setInt(1,cid);
            rs=ps.executeQuery(); while(rs.next()) docs.add(new String[]{rs.getString(1),rs.getString(3),rs.getString(2)});
        }
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Client Portal"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Client"/><jsp:param name="subtitle" value="Portal"/></jsp:include>
        <div class="p-5">
            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="panel p-5 mb-4"><h3 class="panel-head border-bottom-0 p-0 mb-4">Case Summary</h3><p class="lh-lg mb-0"><%=desc%></p></div>
                    <div class="panel p-5"><h3 class="panel-head border-bottom-0 p-0 mb-4">Procedural Timeline</h3>
                        <% if(tl.isEmpty()){ %><div class="text-center py-4 text-muted small">No procedural events recorded yet.</div><% } else { %>
                            <div class="timeline mt-4">
                                <% for(String[] t:tl){ %>
                                    <div class="timeline-item mb-4 ps-4 border-start" style="position:relative;">
                                        <div class="timeline-dot" style="position:absolute; left:-6px; top:0; width:12px; height:12px; background:var(--gold); border-radius:50%;"></div>
                                        <div class="fw-bold mb-1"><%=t[0]%></div><p class="small text-muted mb-2"><%=t[1]%></p><time class="small opacity-50"><%=t[2]%></time>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="panel p-5 mb-4"><h3 class="panel-head border-bottom-0 p-0 mb-4">Legal Representative</h3>
                        <% if(lawyer!=null){ %>
                            <div class="d-flex align-items-center gap-3"><div class="avatar bg-light text-gold"><%=lawyer.substring(0,1)%></div><div><h5 class="mb-0">Adv. <%=lawyer%></h5><p class="text-muted small mb-0">Assigned Counsel</p></div></div>
                        <% } else { %><p class="text-muted small mb-0">Awaiting lawyer assignment.</p><% } %>
                    </div>
                    <div class="panel p-5"><h3 class="panel-head border-bottom-0 p-0 mb-4">Case Documents</h3>
                        <div class="d-grid gap-3 mt-4">
                            <% if(docs.isEmpty()){ %><p class="text-muted small">No documents linked to this case.</p><% } else { for(String[] d:docs){ %>
                                <a href="<%=d[2]%>" target="_blank" class="d-flex align-items-center p-3 border rounded text-decoration-none text-dark transition-all">
                                    <i class="ph ph-file-pdf text-gold h3 mb-0 me-3"></i><div class="overflow-hidden"><p class="small fw-bold mb-0 text-truncate"><%=d[0]%></p><p class="x-small text-muted mb-0"><%=d[1]%></p></div>
                                </a>
                            <% } } %>
                        </div>
                        <a href="uploadClientDoc.jsp?cid=<%=cid%>" class="btn btn-outline-dark w-100 mt-4 py-2">Add Document</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>

