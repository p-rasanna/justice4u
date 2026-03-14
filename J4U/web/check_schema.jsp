<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.j4u.DatabaseConfig" %>
<html><body>
<h2>Schema Check: customer_cases</h2>
<pre>
<%
    try (Connection con = DatabaseConfig.getConnection();
         Statement stmt = con.createStatement();
         ResultSet rs = stmt.executeQuery("DESCRIBE customer_cases")) {
        while (rs.next()) {
            out.println(rs.getString("Field") + " | " + rs.getString("Type"));
        }
    } catch (Exception e) {
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
</pre>
</body></html>
