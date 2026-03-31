<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig,com.j4u.PasswordUtil" %>
<%
    try {
        String name=request.getParameter("txtname"), email=request.getParameter("txtemail"), phone=request.getParameter("txtmno");
        String dob=request.getParameter("txtdob"), aadhar=request.getParameter("txtadhar"), cadd=request.getParameter("txtadd");
        String padd=request.getParameter("txtper"), pass=request.getParameter("txtpass"), passConfirm=request.getParameter("txtpassconfirm");
        String profileType=request.getParameter("assignmentPreference"); if(profileType==null||profileType.isEmpty()) profileType="admin";
        profileType=profileType.trim().toLowerCase(); if(!"admin".equals(profileType) && !"manual".equals(profileType)) profileType="admin";

        if(name==null||name.trim().isEmpty()||email==null||email.trim().isEmpty()||pass==null||pass.trim().isEmpty()){
            response.sendRedirect("customer_form.jsp?error=Missing required fields"); return;
        }
        if(passConfirm!=null && !pass.equals(passConfirm)){ response.sendRedirect("customer_form.jsp?error=Passwords do not match"); return; }
        if(!email.matches("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$")){ response.sendRedirect("customer_form.jsp?error=Invalid email"); return; }
        if(aadhar!=null && !aadhar.isEmpty() && !aadhar.matches("\\d{12}")){ response.sendRedirect("customer_form.jsp?error=Aadhaar must be 12 digits"); return; }

        try(Connection con=DatabaseConfig.getConnection()){
            PreparedStatement cp=con.prepareStatement("SELECT cid FROM cust_reg WHERE email=?"); cp.setString(1,email.trim().toLowerCase());
            if(cp.executeQuery().next()){ response.sendRedirect("customer_form.jsp?error=Email already registered"); return; }
            PreparedStatement ps=con.prepareStatement("INSERT INTO cust_reg(cname, email, pass, dob, mobno, ano, padd, cadd, verification_status, profile_type) VALUES(?,?,?,?,?,?,?,?, 'PENDING', ?)");
            ps.setString(1,name.trim()); ps.setString(2,email.trim().toLowerCase()); ps.setString(3,PasswordUtil.hashPassword(pass));
            ps.setString(4,dob!=null?dob.trim():""); ps.setString(5,phone!=null?phone.trim():""); ps.setString(6,aadhar!=null?aadhar.trim():"");
            ps.setString(7,padd!=null?padd.trim():""); ps.setString(8,cadd!=null?cadd.trim():""); ps.setString(9,profileType);
            if(ps.executeUpdate()>0) response.sendRedirect("../auth/cust_login.jsp?msg=Registration successful. Awaiting verification.");
            else response.sendRedirect("customer_form.jsp?error=Registration failed");
        }
    } catch(Exception e){ e.printStackTrace(); response.sendRedirect("customer_form.jsp?error=System error"); }
%>
