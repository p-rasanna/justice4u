<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.j4u.CSRFTokenUtil" %>
<%
// Generate and include CSRF token in forms
String csrfToken = CSRFTokenUtil.getToken(request);
%>
<input type="hidden" name="<%= CSRFTokenUtil.getTokenParameterName() %>" value="<%= csrfToken %>"/>
