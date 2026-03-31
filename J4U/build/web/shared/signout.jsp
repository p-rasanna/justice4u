<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
  String role = request.getParameter("role");
  session.invalidate();
  String redirect = "lawyer".equals(role) ? "../auth/Lawyer_login.jsp" :
                    "intern".equals(role)  ? "../auth/internlogin.jsp" :
                    "admin".equals(role)   ? "../auth/Login.jsp" :
                                            "../auth/cust_login.html";
  response.sendRedirect(redirect);
%>
