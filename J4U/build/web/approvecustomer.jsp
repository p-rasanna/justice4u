<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String query = request.getQueryString();
    String target = "admin/approvecustomer.jsp";
    if (query != null && !query.isEmpty()) {
        target += "?" + query;
    }
    response.sendRedirect(target);
%>
