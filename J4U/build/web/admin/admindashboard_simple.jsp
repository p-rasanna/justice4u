<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String adminEmail = (String)session.getAttribute("aname");
    if(adminEmail == null) {
        response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard | Justice4U</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
</head>
<body>
    <div class="container py-5">
        <h1>Admin Dashboard</h1>
        <p>Welcome, <%= adminEmail %></p>
        <a href="<%= request.getContextPath() %>/shared/signout.jsp" class="btn btn-danger">Logout</a>
    </div>
</body>
</html>
