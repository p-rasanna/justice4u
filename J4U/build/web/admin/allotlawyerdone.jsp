<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig,com.j4u.NotificationService" %>
<%
    String admin=(String)session.getAttribute("aname"); if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
    try(Connection con=DatabaseConfig.getConnection()){
        String isDirect=request.getParameter("isDirect"), customerName=request.getParameter("customername"), title=request.getParameter("title");
        String description=request.getParameter("description"), currentDate=request.getParameter("currentdate"), courtType=request.getParameter("courtType");
        String city=request.getParameter("city"), amt=request.getParameter("amt"), cname=request.getParameter("cname"), lname=request.getParameter("lname");
        int cid=0;
        if("true".equals(isDirect)){
            PreparedStatement psC=con.prepareStatement("SELECT cid FROM cust_reg WHERE email=?"); psC.setString(1,cname);
            ResultSet rsC=psC.executeQuery(); int customerId=0; if(rsC.next()) customerId=rsC.getInt(1);
            if(customerId==0) throw new Exception("Client not found");
            PreparedStatement psCase=con.prepareStatement("INSERT INTO casetb (cname, name, title, des, curdate, courttype, city, amt, flag, status) VALUES (?,?,?,?,?,?,?,?,1,'ASSIGNED')", Statement.RETURN_GENERATED_KEYS);
            psCase.setString(1,cname); psCase.setString(2,customerName); psCase.setString(3,title); psCase.setString(4,description); psCase.setString(5,currentDate); psCase.setString(6,courtType); psCase.setString(7,city); psCase.setString(8,amt);
            psCase.executeUpdate(); ResultSet rsK=psCase.getGeneratedKeys(); if(rsK.next()) cid=rsK.getInt(1);
            PreparedStatement psCC=con.prepareStatement("INSERT INTO customer_cases (case_id, customer_id, status, title, description, case_type_id) VALUES (?,?,'PENDING_LAWYER_CONFIRMATION',?,?,9)");
            psCC.setInt(1,cid); psCC.setInt(2,customerId); psCC.setString(3,title); psCC.setString(4,description); psCC.executeUpdate();
        } else { 
            cid=Integer.parseInt(request.getParameter("customerid")); 
        }
        
        PreparedStatement psAllot=con.prepareStatement("INSERT INTO allotlawyer(cid,name,title,des,curdate,courttype,city,amt,cname,lname) VALUES(?,?,?,?,?,?,?,?,?,?)");
        psAllot.setInt(1,cid); psAllot.setString(2,customerName); psAllot.setString(3,title); psAllot.setString(4,description); psAllot.setString(5,currentDate); psAllot.setString(6,courtType); psAllot.setString(7,city); psAllot.setString(8,amt); psAllot.setString(9,cname); psAllot.setString(10,lname); psAllot.executeUpdate();
        
        PreparedStatement psL=con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?"); psL.setString(1,lname);
        ResultSet rsL=psL.executeQuery(); if(rsL.next()){
            PreparedStatement psUp=con.prepareStatement("UPDATE customer_cases SET assigned_lawyer_id=?, status='PENDING_LAWYER_CONFIRMATION' WHERE case_id=?");
            psUp.setInt(1,rsL.getInt(1)); psUp.setInt(2,cid); psUp.executeUpdate();
        }
        
        try (PreparedStatement psUpCase = con.prepareStatement("UPDATE casetb SET status='PENDING_ACCEPTANCE', flag=0 WHERE cid=?")) {
            psUpCase.setInt(1, cid);
            psUpCase.executeUpdate();
        }

        NotificationService.create(lname, "You have been assigned a new case: " + title, "case", "../lawyer/Lawyerdashboard.jsp");
        NotificationService.create(cname, "A lawyer has been assigned to your case: " + title, "case", "../client/clientdashboard.jsp");

        response.sendRedirect("admindashboard.jsp?msg=Allotment confirmed");
    } catch(Exception e){ e.printStackTrace(); response.sendRedirect("admindashboard.jsp?msg=Error: "+java.net.URLEncoder.encode(e.getMessage(),"UTF-8")); }
%>
