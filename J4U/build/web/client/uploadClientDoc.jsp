<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.io.*,javax.servlet.http.Part" %>
<%
  String email=(String)session.getAttribute("cname"); if(email==null){response.sendRedirect("../auth/Login.jsp");return;}
  String cIdParam=request.getParameter("caseId"), msg="";
  try {
    Part filePart=request.getPart("file"); if(filePart==null||cIdParam==null) throw new Exception("Missing upload data");
    int cId=Integer.parseInt(cIdParam); String fileName=filePart.getSubmittedFileName();
    try(Connection con=com.j4u.DatabaseConfig.getConnection()){
      PreparedStatement ps=con.prepareStatement("SELECT case_id FROM customer_cases cc JOIN cust_reg cr ON cc.customer_id=cr.cid WHERE cr.email=? AND cc.case_id=?");
      ps.setString(1,email); ps.setInt(2,cId); if(!ps.executeQuery().next()) throw new Exception("Unauthorized access");
      String path="C:/J4U_Uploads/case_documents/"; File dir=new File(path); if(!dir.exists()) dir.mkdirs();
      String secName="CASE"+cId+"_CL_"+System.currentTimeMillis()+"_"+fileName; filePart.write(path+secName);
      ps=con.prepareStatement("INSERT INTO case_documents (case_id, uploader_email, uploader_role, file_name, file_path) VALUES (?,?,'client',?,?)");
      ps.setInt(1,cId); ps.setString(2,email); ps.setString(3,fileName); ps.setString(4,path+secName); ps.executeUpdate();
      msg="Document uploaded successfully";
    }
  }catch(Exception e){ msg="Upload failed: "+e.getMessage(); }
  response.sendRedirect("client_case_details.jsp?case_id="+cIdParam+"&msg="+java.net.URLEncoder.encode(msg,"UTF-8"));
%>