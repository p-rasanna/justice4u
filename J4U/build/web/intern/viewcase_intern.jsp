<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String iEmail=(String)session.getAttribute("iname");
    if(iEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
    
    String cidS=request.getParameter("cid");
    if(cidS==null){response.sendRedirect("interndashboard.jsp");return;}
    int cid=Integer.parseInt(cidS);
    
    String title="", desc="", court="", city="", clientName="", lawyerName="", lawyerEmail="", curdate="";
    boolean hasAccess=false;
    
    try(Connection con=DatabaseConfig.getConnection()){
        // Access check: intern must have ACCEPTED assignment with a lawyer who has this case
        PreparedStatement psAccess=con.prepareStatement(
            "SELECT ila.lawyer_email, lr.name as lawyer_name " +
            "FROM intern_lawyer_assignments ila " +
            "JOIN lawyer_reg lr ON ila.lawyer_email=lr.email " +
            "WHERE ila.intern_email=? AND ila.status='ACCEPTED'"
        );
        psAccess.setString(1, iEmail);
        ResultSet rsAccess=psAccess.executeQuery();
        if(rsAccess.next()){
            lawyerEmail=rsAccess.getString("lawyer_email");
            lawyerName=rsAccess.getString("lawyer_name");
            
            // Check if this lawyer has this case
            PreparedStatement psCase=con.prepareStatement(
                "SELECT c.title, c.des, c.courttype, c.city, c.cname, c.curdate " +
                "FROM casetb c JOIN allotlawyer al ON al.cid=c.cid " +
                "WHERE c.cid=? AND al.lname=? AND c.flag>=1"
            );
            psCase.setInt(1, cid);
            psCase.setString(2, lawyerEmail);
            ResultSet rsCase=psCase.executeQuery();
            if(rsCase.next()){
                hasAccess=true;
                title=rsCase.getString("title") != null ? rsCase.getString("title") : "";
                desc=rsCase.getString("des") != null ? rsCase.getString("des") : "";
                court=rsCase.getString("courttype") != null ? rsCase.getString("courttype") : "";
                city=rsCase.getString("city") != null ? rsCase.getString("city") : "";
                clientName=rsCase.getString("cname") != null ? rsCase.getString("cname") : "";
                curdate=rsCase.getString("curdate") != null ? rsCase.getString("curdate") : "";
            }
        }
        
        if(!hasAccess){
            response.sendRedirect("interndashboard.jsp?msg=Access denied - you do not have permission to view this case");
            return;
        }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Case Details"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_topbar.jsp" />
        <jsp:include page="../shared/_sidebar.jsp" />
        
        <main class="app-main">
            <div class="app-content-header mb-4">
                <div class="container-fluid">
                    <div class="row align-items-center">
                        <div class="col-sm-6">
                            <h2 class="mb-0 text-serif fw-bold">Case #<%=cid%></h2>
                            <p class="text-muted small mb-0"><%=title%></p>
                        </div>
                        <div class="col-sm-6 text-end">
                            <a href="interndashboard.jsp" class="btn btn-sm btn-outline-dark px-3">
                                <i class="bi bi-arrow-left me-1"></i> Back to Dashboard
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="app-content">
                <div class="container-fluid">
                    <div class="row g-4">
                        <!-- Case Details -->
                        <div class="col-lg-8">
                            <div class="card border-0 bg-white mb-4">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">
                                        <i class="bi bi-file-earmark-text text-gold me-2"></i>Case Information
                                    </h5>
                                </div>
                                <div class="card-body px-4 pb-4 pt-0">
                                    <div class="row g-3 mb-4">
                                        <div class="col-md-6">
                                            <div class="text-muted small fw-bold text-uppercase ls-1 mb-1">Court Type</div>
                                            <div class="fw-medium"><%=court%></div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="text-muted small fw-bold text-uppercase ls-1 mb-1">City / Jurisdiction</div>
                                            <div class="fw-medium"><%=city%></div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="text-muted small fw-bold text-uppercase ls-1 mb-1">Client</div>
                                            <div class="fw-medium"><%=clientName%></div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="text-muted small fw-bold text-uppercase ls-1 mb-1">Filed Date</div>
                                            <div class="fw-medium"><%=curdate%></div>
                                        </div>
                                    </div>
                                    <div class="border-top pt-3">
                                        <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Case Description</div>
                                        <p class="mb-0 lh-lg text-dark" style="font-size:0.9rem;"><%=desc%></p>
                                    </div>
                                </div>
                            </div>

                            <!-- Case Documents -->
                            <div class="card border-0 bg-white">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">
                                        <i class="bi bi-paperclip text-gold me-2"></i>Case Documents
                                    </h5>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table align-middle mb-0">
                                            <thead>
                                                <tr>
                                                    <th class="ps-4">File Name</th>
                                                    <th>Uploaded By</th>
                                                    <th>Date</th>
                                                    <th class="text-end pe-4">Action</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            <%
                                                boolean hasDocs=false;
                                                PreparedStatement pd=con.prepareStatement("SELECT file_name, file_path, uploader_email, uploaded_at FROM case_documents WHERE case_id=? ORDER BY uploaded_at DESC");
                                                pd.setInt(1,cid);
                                                ResultSet rd=pd.executeQuery();
                                                while(rd.next()){ hasDocs=true;
                                            %>
                                                <tr class="border-light">
                                                    <td class="ps-4 fw-medium"><%= rd.getString(1) %></td>
                                                    <td class="small text-muted"><%= rd.getString(3) %></td>
                                                    <td class="small text-muted"><%= rd.getString(4) != null ? rd.getString(4).substring(0,10) : "" %></td>
                                                    <td class="text-end pe-4">
                                                        <a href="<%= rd.getString(2) %>" target="_blank" class="btn btn-sm btn-outline-dark px-3">View</a>
                                                    </td>
                                                </tr>
                                            <% } if(!hasDocs){ %>
                                                <tr>
                                                    <td colspan="4" class="text-center py-4 text-muted small opacity-50">
                                                        No documents uploaded yet.
                                                    </td>
                                                </tr>
                                            <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Sidebar Info -->
                        <div class="col-lg-4">
                            <div class="card border-0 bg-white mb-4">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Supervising Lawyer</h5>
                                </div>
                                <div class="card-body px-4 pb-4 pt-0">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="bg-gold-light text-gold rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:40px; height:40px;">
                                            <%= lawyerName.substring(0,1).toUpperCase() %>
                                        </div>
                                        <div>
                                            <div class="fw-bold"><%= lawyerName %></div>
                                            <div class="text-muted small"><%= lawyerEmail %></div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card border-0 bg-white">
                                <div class="card-header bg-transparent border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif">Quick Actions</h5>
                                </div>
                                <div class="card-body px-4 pb-4 pt-0">
                                    <div class="d-grid gap-2">
                                        <a href="<%=request.getContextPath()%>/shared/caseDiscussion.jsp?case_id=<%=cid%>" class="btn btn-gold btn-sm py-2">
                                            <i class="bi bi-chat-dots-fill me-1"></i> Open Discussion
                                        </a>
                                        <a href="interndashboard.jsp" class="btn btn-outline-dark btn-sm py-2">
                                            <i class="bi bi-arrow-left me-1"></i> Back to Dashboard
                                        </a>
                                    </div>
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
<% }catch(Exception e){
    e.printStackTrace();
    out.println("<div style='color:white;background:red;padding:20px;'><pre>"+e.toString()+"</pre></div>");
} %>