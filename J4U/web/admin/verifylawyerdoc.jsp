<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String admin=(String)session.getAttribute("aname"); if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
  String action=request.getParameter("action"), docId=request.getParameter("doc_id"), lid=request.getParameter("lawyer_id"), msg="";
  try(Connection con=DatabaseConfig.getConnection()){
    if("approve".equals(action) && docId!=null){
      PreparedStatement ps=con.prepareStatement("UPDATE lawyer_documents SET status='VERIFIED', admin_review_date=NOW() WHERE doc_id=?"); ps.setInt(1,Integer.parseInt(docId)); ps.executeUpdate(); msg="Document verified.";
    } else if("reject".equals(action) && docId!=null){
      PreparedStatement ps=con.prepareStatement("UPDATE lawyer_documents SET status='REJECTED', admin_review_date=NOW() WHERE doc_id=?"); ps.setInt(1,Integer.parseInt(docId)); ps.executeUpdate(); msg="Document rejected.";
    } else if("approve_all".equals(action) && lid!=null){
      PreparedStatement ps1 = con.prepareStatement("UPDATE lawyer_documents SET status='VERIFIED', admin_review_date=NOW() WHERE lawyer_id=? AND status='PENDING'"); ps1.setInt(1, Integer.parseInt(lid)); ps1.executeUpdate();
      PreparedStatement ps2 = con.prepareStatement("UPDATE lawyer_reg SET document_verification_status='VERIFIED' WHERE lid=?"); ps2.setInt(1, Integer.parseInt(lid)); ps2.executeUpdate(); msg="All documents verified.";
    }
    if(lid!=null){
      PreparedStatement ps3 = con.prepareStatement("SELECT COUNT(*) FROM lawyer_documents WHERE lawyer_id=? AND status='PENDING'"); ps3.setInt(1, Integer.parseInt(lid));
      ResultSet rs=ps3.executeQuery(); if(rs.next() && rs.getInt(1)==0){
        PreparedStatement ps4 = con.prepareStatement("UPDATE lawyer_reg SET document_verification_status='VERIFIED' WHERE lid=?"); ps4.setInt(1, Integer.parseInt(lid)); ps4.executeUpdate();
      }
    }
  }catch(Exception e){msg="Error: "+e.getMessage();}
  response.sendRedirect("viewlawyerdocuments.jsp?msg="+java.net.URLEncoder.encode(msg,"UTF-8")+"&id="+lid);
%>