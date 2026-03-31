<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig"%>
<%
    String user=(String)session.getAttribute("lname"); if(user==null){response.sendRedirect("../auth/Login.jsp");return;}
    String cid=request.getParameter("caseId"); if(cid==null){response.sendRedirect("Lawyerdashboard.jsp");return;}
    int id=Integer.parseInt(cid); String title="Case #"+id; boolean access=false;
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT title FROM allotlawyer WHERE lname=? AND cid=?"); ps.setString(1,user); ps.setInt(2,id);
        ResultSet rs=ps.executeQuery(); if(rs.next()){ access=true; title=rs.getString(1); }
    }catch(Exception e){} if(!access){response.sendRedirect("Lawyerdashboard.jsp?msg=Unauthorized");return;}
    java.util.List<String[]> docs=new java.util.ArrayList<>();
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("SELECT * FROM case_documents WHERE case_id=? ORDER BY uploaded_at DESC"); ps.setInt(1,id);
        ResultSet rs=ps.executeQuery(); while(rs.next()) docs.add(new String[]{rs.getString("file_name"),rs.getString("uploader_role"),rs.getString("uploader_email"),rs.getString("uploaded_at").substring(0,16)});
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Case Documents"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp"><jsp:param name="active" value="cases"/></jsp:include>
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Case"/><jsp:param name="subtitle" value="Documents"/></jsp:include>
        <div class="px-4">
            <div class="panel p-0">
                <div class="panel-head"><h3>Documents <small class="text-muted fw-normal ms-2"><%=title%></small></h3><a href="viewcase.jsp?alid=<%=id%>">Back</a></div>
                <% for(String[] d:docs){ %>
                    <div class="p-3 border-bottom d-flex align-items-center justify-content-between">
                        <div><h6 class="mb-0"><%=d[0]%></h6><small class="text-muted"><%=d[3]%> · by <%=d[1]%></small></div>
                        <a href="../shared/download_case_doc.jsp?file=<%=java.net.URLEncoder.encode(d[0],"UTF-8")%>" class="btn btn-sm btn-outline-dark">Download</a>
                    </div>
                <% } if(docs.isEmpty()){ %><div class="p-5 text-center text-muted">No documents found.</div><% } %>
            </div>
        </div>
    </main>
</div>
</body>
</html>
