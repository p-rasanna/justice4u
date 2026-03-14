<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil"%>
<%@include file="db_connection.jsp" %>
<% 
   try
   {
       String name=request.getParameter("txtname");
       String email=request.getParameter("txtemail");
       String phone=request.getParameter("txtmno");
       String dob=request.getParameter("txtdob");
       String aadhar=request.getParameter("txtadhar");
       String pan=request.getParameter("txtpan");
       String cadd=request.getParameter("txtadd");
       String padd=request.getParameter("txtper");
       String casecat=request.getParameter("txtcasecat");
       String urgency=request.getParameter("txturgency");
       String casedesc=request.getParameter("txtcasedesc");
       String pass=request.getParameter("txtpass");
       String securityQuestion=request.getParameter("txtsecurityquestion");
       String securityAnswer=request.getParameter("txtsecurityanswer");

       // Basic validation
       if (name == null || email == null || pass == null) {
           response.sendRedirect("Register.html?error=Missing required fields");
           return;
       }

       Connection con = getDatabaseConnection();
       
       // Check for existing email to prevent duplicates/errors
       PreparedStatement checkPs = con.prepareStatement("SELECT cid FROM cust_reg WHERE email=?");
       checkPs.setString(1, email);
       ResultSet rs = checkPs.executeQuery();
       if (rs.next()) {
           rs.close();
           checkPs.close();
           con.close();
           response.sendRedirect("Register.html?error=Email already registered");
           return;
       }
       rs.close();
       checkPs.close();

       // Secure Insert matching live DB
       PreparedStatement ps = con.prepareStatement(
           "INSERT INTO cust_reg(cname, name, email, pass, dob, mobno, ano, padd, cadd, verification_status, profile_type) " +
           "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, 'VERIFIED', 'manual')"
       );
       
       ps.setString(1, name);
       ps.setString(2, name); // Map real name to both legacy and new column
       ps.setString(3, email);
       ps.setString(4, PasswordUtil.hashPassword(pass));
       ps.setString(5, dob != null ? dob : "");
       ps.setString(6, phone != null ? phone : "");
       ps.setString(7, aadhar != null ? aadhar : "");
       ps.setString(8, padd != null ? padd : "");
       ps.setString(9, cadd != null ? cadd : "");

       int k = ps.executeUpdate();
       ps.close();
       con.close();

       if(k > 0) {
           response.sendRedirect("cust_login.html?msg=Registration successful. Please login.");
       } else {
           response.sendRedirect("Register.html?error=Registration failed.");
       }
   }
   catch(Exception e)
   {
       e.printStackTrace(); // Log to server console
       response.sendRedirect("Register.html?error=System error: " + e.getMessage());
   }
%>
