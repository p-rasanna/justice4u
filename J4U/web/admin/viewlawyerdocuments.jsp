<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String admin=(String)session.getAttribute("aname"); if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
    String lid=request.getParameter("id"), msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Admin"/></jsp:include>
<body>
<div class="app">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main"><div class="topbar"><div><h1>Document <em>Verification</em></h1><p class="text-muted small">Inspecting Professional Credentials</p></div><a href="viewlawyers.jsp" class="btn btn-outline-dark btn-sm px-3"><i class="ph ph-arrow-left"></i> Back</a></div>
        <% if(msg!=null){ %><div class="alert alert-info py-2 px-3 small border mb-4"><i class="ph-fill ph-info"></i> <%=msg%></div><% } %>
        <% try(Connection con=DatabaseConfig.getConnection()){
            String q="SELECT lid, name, email FROM lawyer_reg WHERE flag=0"; if(lid!=null && !lid.isEmpty()) q+=" AND lid="+Integer.parseInt(lid);
            ResultSet rs=con.createStatement().executeQuery(q);
            while(rs.next()){ int currentLid=rs.getInt("lid"); String nm=rs.getString("name"); if(nm==null) nm="Lawyer Applicant"; %>
            <div class="panel mb-4 shadow-sm border-0">
                <div class="panel-head d-flex justify-content-between align-items-center bg-light border-bottom p-4 rounded-top-3">
                    <div><h3 class="mb-0 fw-bold"><%=nm%></h3><p class="text-muted small mb-0"><%=rs.getString("email")%> (LID: <%=currentLid%>)</p></div>
                    <div class="d-flex gap-2">
                        <a href="approvel.jsp?lid=<%=currentLid%>" class="btn btn-dark px-4" onclick="return confirm('Verify this lawyer?')"><i class="ph-fill ph-check-circle"></i> Verify</a>
                        <a href="rejectl.jsp?lid=<%=currentLid%>" class="btn btn-outline-danger px-4" onclick="return confirm('Reject application?')"><i class="ph-fill ph-x-circle"></i> Reject</a>
                    </div>
                </div>
                <div class="row g-4 p-4">
                    <% PreparedStatement psd=con.prepareStatement("SELECT * FROM lawyer_documents WHERE lawyer_id=?"); psd.setInt(1,currentLid); ResultSet drs=psd.executeQuery(); boolean has=false;
                       while(drs.next()){ has=true; %>
                        <div class="col-md-4">
                            <div class="doc-card border rounded-4 bg-white p-3 text-center transition-all hover-translate-y">
                                <div class="doc-icon mx-auto mb-3 bg-light text-primary rounded-circle d-flex align-items-center justify-content-center" style="width:56px; height:56px; font-size:1.5rem;"><i class="ph-fill ph-file-pdf"></i></div>
                                <h6 class="fw-bold mb-1 text-truncate" title="<%=drs.getString("document_type")%>"><%=drs.getString("document_type")%></h6>
                                <p class="text-muted small mb-3">Status: <span class="badge bg-soft-primary text-primary"><%=drs.getString("status")%></span></p>
                                <button data-file="<%=java.net.URLEncoder.encode(drs.getString("file_name"), "UTF-8")%>" class="btn btn-sm btn-outline-dark w-100 rounded-3 preview-btn">Preview File</button>
                            </div>
                        </div>
                    <% } if(!has){ %><div class="col-12 text-center p-5 text-muted bg-light rounded-4 border-dashed">No professional credentials uploaded for this applicant.</div><% } %>
                </div>
            </div>
        <% } } catch(Exception e) { out.print("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>"); } %>
    </main>
</div>
<div id="docModal" class="modal d-none position-fixed top-0 start-0 w-100 h-100 bg-dark-overlay d-flex align-items-center justify-content-center" style="z-index:9999; backdrop-filter:blur(4px);">
    <div class="modal-content bg-white p-2 rounded-4 position-relative" style="max-width:90%; box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);">
        <button type="button" class="btn-close position-absolute top-0 end-0 m-3" onclick="closeModal()"></button>
        <div id="modalBody" class="overflow-auto" style="max-height:85vh; min-width:300px;"></div>
    </div>
</div>
<script>
    document.querySelectorAll('.preview-btn').forEach(function(btn){
        btn.onclick = function(){
            var file = decodeURIComponent(btn.getAttribute('data-file'));
            var url = '../uploads/' + encodeURIComponent(file);
            var body = document.getElementById('modalBody');
            body.innerHTML = '';
            if(file.toLowerCase().endsWith('.pdf')){
                body.innerHTML = '<iframe src="' + url + '" style="width:800px; height:600px; border:0;"></iframe>';
            } else {
                body.innerHTML = '<img src="' + url + '" style="max-width:100%; height:auto; ">';
            }
            document.getElementById('docModal').classList.remove('d-none');
            document.getElementById('docModal').classList.add('d-flex');
        };
    });
    function closeModal(){
        document.getElementById('docModal').classList.add('d-none');
        document.getElementById('docModal').classList.remove('d-flex');
    }
</script>

</body>
</html>


