<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig" %>
<%
    String email = (String) session.getAttribute("cname");
    if (email == null) { response.sendRedirect("../auth/Login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="My Documents"/></jsp:include>
<body>
    <div class="app-layout">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="main-content">
            <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="My"/><jsp:param name="subtitle" value="Documents"/></jsp:include>
            <div class="p-5">
                <div class="row g-4">
                <% boolean hD=false; try(Connection con = DatabaseConfig.getConnection()){ try(PreparedStatement p = con.prepareStatement("SELECT cd.id, cd.file_name, cd.file_type, cd.uploader_role, cd.uploaded_at, c.title as case_title FROM case_documents cd JOIN casetb c ON cd.case_id = c.cid JOIN cust_reg cr ON c.cname = cr.cname WHERE cr.email = ? ORDER BY cd.uploaded_at DESC")){ p.setString(1,email); try(ResultSet r=p.executeQuery()){ while(r.next()){ hD=true; %>
                    <div class="col-md-6 col-xl-4"><div class="panel p-4 h-100 d-flex flex-column">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <div class="avatar bg-light text-primary"><i class="ph-fill ph-file-text"></i></div>
                            <div style="word-break: break-all"><h6 class="mb-0 fw-bold"><%=r.getString("file_name")%></h6><small class="text-muted"><%=r.getString("case_title")%></small></div>
                        </div>
                        <div class="mt-auto d-flex justify-content-between align-items-center border-top pt-3 border-light">
                            <small class="text-muted"><span class="badge bg-dark fw-normal"><%=r.getString("uploader_role").toUpperCase()%></span> <%=r.getTimestamp("uploaded_at").toString().substring(0,16)%></small>
                            <a href="../shared/downloadDoc.jsp?id=<%=r.getInt("id")%>" class="btn btn-sm btn-outline-dark px-3"><i class="ph ph-download-simple"></i> Download</a>
                        </div>
                    </div></div>
                <% } } } } catch(Exception e){} if(!hD){ %><div class="col-12 p-5 text-center text-muted"><i class="ph-fill ph-folder-open h1 opacity-25 d-block mb-3"></i> No documents uploaded.</div><% } %>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
