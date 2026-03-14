<%-- Document : lddone Created on : 6 Apr, 2025, 6:40:35 PM Author : ZulkiflMugad --%>

  <%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
    <%@ include file="db_connection.jsp" %>
      <% try { Connection con=getDatabaseConnection(); Statement st=con.createStatement(); String a="'"
        +request.getParameter("title")+"'"; String b="'" +request.getParameter("cdate")+"'"; String c="'"
        +request.getParameter("descr")+"'"; String d="'" +request.getParameter("cname")+"'"; String e="'"
        +request.getParameter("lemail")+"'"; String q="insert into discussion(title,cdate,descr,cname,lname)values("
        +a+","+b+","+c+","+d+","+e+")"; out.println(q); st.executeUpdate(q); st.close(); con.close();
        response.sendRedirect("customerdashboard.jsp"); } catch(Exception ee) { out.println(ee); } %>