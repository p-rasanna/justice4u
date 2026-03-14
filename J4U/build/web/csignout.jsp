<%-- 
    Document   : csignout
    Created on : 6 Apr, 2025, 8:14:04 PM
    Author     : ZulkiflMugad
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%

    session.invalidate();
    response.sendRedirect("cust_login.html");
%>