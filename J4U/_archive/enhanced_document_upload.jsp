<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, java.io.*, java.util.*, com.j4u.DatabaseConfig, com.j4u.FileUploadUtil"%>
<%@include file="db_connection.jsp" %><%@include file="csrf_token.jsp" %>
<%
    String user=(String)session.getAttribute("lname");
    if(user==null){response.sendRedirect("Lawyer_login_form.jsp");return;}

    String caseIdParam = request.getParameter("caseId");
    String msg="", msgT="";
    if("POST".equalsIgnoreCase(request.getMethod()) && CSRFTokenUtil.validateToken(request)){
        try {
            String path = application.getRealPath("/")+"uploads/docs/";
            new File(path).mkdirs();
            Part file = request.getPart("document_file");
            if(file!=null && file.getSize()>0){
                FileUploadUtil.ValidationResult val = FileUploadUtil.validateFile(file);
                if(val.isValid()){
                    FileUploadUtil.UploadResult res = FileUploadUtil.saveFile(file, path);
                    if(res.isSuccess()){
                        try(Connection con=DatabaseConfig.getConnection()){
                            String cId=request.getParameter("case_id"), dTy=request.getParameter("doc_type");
                            PreparedStatement ps = con.prepareStatement("INSERT INTO lawyer_documents(alid,uploaded_by,doc_type,file_name,file_path) VALUES(?,?,?,?,?)");
                            ps.setInt(1,Integer.parseInt(cId)); ps.setString(2,user); ps.setString(3,dTy); ps.setString(4,res.getFileName()); ps.setString(5,"uploads/docs/"+res.getFileName());
                            ps.executeUpdate();
                            msg="Uploaded!"; msgT="success";
                        }
                    } else { msg=res.getMessage(); msgT="danger"; }
                } else { msg=val.getMessage(); msgT="warning"; }
            }
        } catch(Exception e){ msg=e.getMessage(); msgT="danger"; }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Upload · Justice4U</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="justice4u-tokens.css">
    
</head>
<body>
<div class="card">
    <div class="d-flex justify-content-between mb-4"><h2><i class="ph-fill ph-file-arrow-up"></i> Documents</h2><a href="Lawyerdashboard.jsp" class="btn btn-sm btn-outline-dark">Back</a></div>
    <% if(!msg.isEmpty()){ %><div class="alert alert-<%=msgT%>"><%=msg%></div><% } %>
    <form method="post" enctype="multipart/form-data">
        <%@include file="csrf_token.jsp" %>
        <div class="row g-3">
            <div class="col-md-6"><label class="form-label">Case</label><select name="case_id" class="form-select" required>
                <% try(Connection con=DatabaseConfig.getConnection()){
                    PreparedStatement ps=con.prepareStatement("SELECT alid,title FROM allotlawyer WHERE lname=?"); ps.setString(1,user); ResultSet rs=ps.executeQuery();
                    while(rs.next()){ %><option value="<%=rs.getInt(1)%>"><%=rs.getString(2)%></option><% }
                } catch(Exception ignored){} %>
            </select></div>
            <div class="col-md-6"><label class="form-label">Type</label><select name="doc_type" class="form-select"><option>DRAFT</option><option>NOTICE</option><option>ORDER</option></select></div>
            <div class="col-12"><div class="p-5 border-dashed text-center" style="border:2px dashed var(--border);cursor:pointer;" onclick="document.getElementById('fi').click()">
                <i class="ph ph-cloud-arrow-up ph-2x text-muted"></i><p>Click to select document</p><input type="file" id="fi" name="document_file" class="d-none" required>
            </div></div>
            <div class="col-12"><button type="submit" class="btn btn-dark w-100">Upload Document</button></div>
        </div>
    </form>
    <hr class="my-5"><h4><i class="ph-fill ph-clock-counter-clockwise"></i> History</h4><div class="row mt-3">
    <% try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT * FROM lawyer_documents WHERE uploaded_by=? ORDER BY upload_date DESC");
        ps.setString(1,user); ResultSet rs=ps.executeQuery();
        while(rs.next()){ %>
            <div class="col-md-6 mb-3"><div class="p-3 border rounded"><strong><%=rs.getString("file_name")%></strong><br><small class="text-muted"><%=rs.getString("doc_type")%> · <%=rs.getString("upload_date")%></small><div class="mt-2"><a href="<%=rs.getString("file_path")%>" target="_blank" class="btn btn-sm btn-light">View</a></div></div></div>
        <% }
    } catch(Exception ignored){} %></div>
</div>
</body>
</html>

