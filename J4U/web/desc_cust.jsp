<%@page contentType="text/plain" pageEncoding="UTF-8" import="java.sql.*" %>
<%@include file="db_connection.jsp" %>
<%
    Connection con = getDatabaseConnection();
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery("DESCRIBE cust_reg");
    while(rs.next()) {
        out.println(rs.getString("Field") + " | " + rs.getString("Type"));
    }
%>
