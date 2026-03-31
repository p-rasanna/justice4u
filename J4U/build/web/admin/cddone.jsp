<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String clientEmail=(String)session.getAttribute("cemail"); if(clientEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("INSERT INTO discussion(title,cdate,descr,cemail,lname) VALUES (?,?,?,?,?)");
        ps.setString(1,request.getParameter("title")); ps.setString(2,request.getParameter("cdate")); ps.setString(3,request.getParameter("descr")); ps.setString(4,clientEmail); ps.setString(5,request.getParameter("lemail"));
        ps.executeUpdate(); response.sendRedirect("../client/clientdashboard.jsp?msg=Message+Sent");
    }catch(Exception e){out.print("Error: "+e.getMessage());}
%>

