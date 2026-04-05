<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
  String role = request.getParameter("role");
  session.invalidate();
  String redirect = "lawyer".equals(role) ? "../auth/Lawyer_login_form.jsp" :
          "intern".equals(role)  ? "../auth/internlogin_form.jsp" :
          "admin".equals(role)   ? "../auth/Login.jsp" :
                      "../auth/cust_login.jsp";
  response.sendRedirect(redirect);
%>