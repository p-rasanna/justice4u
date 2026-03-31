<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String lawyerEmail=(String)session.getAttribute("lname"); if(lawyerEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
    try(Connection con=DatabaseConfig.getConnection()){
        PreparedStatement ps=con.prepareStatement("INSERT INTO discussion(title,cdate,descr,cemail,lname) VALUES (?,?,?,?,?)");
        ps.setString(1,request.getParameter("title")); ps.setString(2,request.getParameter("cdate")); ps.setString(3,request.getParameter("descr")); ps.setString(4,request.getParameter("cemail")); ps.setString(5,lawyerEmail);
        ps.executeUpdate(); response.sendRedirect("../lawyer/Lawyerdashboard.jsp?msg=Discussion+Added");
    }catch(Exception e){out.print("Error: "+e.getMessage());}
%>


