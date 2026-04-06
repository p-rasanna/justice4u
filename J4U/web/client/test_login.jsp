<%@ page session="true" %>
<%
  session.setAttribute("cname", "test@example.com");
  session.setAttribute("role", "client");
  session.setAttribute("name", "Test User");
  session.setAttribute("profileType", "admin");
  response.sendRedirect("clientdashboard.jsp");
%>
