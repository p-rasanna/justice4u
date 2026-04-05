<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig,com.j4u.NotificationService" %>
<%
  String admin=(String)session.getAttribute("aname");
  if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
  String internEmail=request.getParameter("intern_email");
  String lawyerEmail=request.getParameter("lawyer_email");
  if(internEmail==null || lawyerEmail==null || internEmail.trim().isEmpty() || lawyerEmail.trim().isEmpty()){
    response.sendRedirect("assign_intern_to_lawyer.jsp?msg=Error: Missing required fields");
    return;
  }
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement check=con.prepareStatement(
      "SELECT id FROM intern_lawyer_assignments WHERE intern_email=? AND status IN ('PENDING','ACCEPTED')"
    );
    check.setString(1, internEmail.trim());
    ResultSet rs=check.executeQuery();
    if(rs.next()){
      response.sendRedirect("assign_intern_to_lawyer.jsp?msg=Error: This intern already has an active or pending assignment");
      return;
    }
    PreparedStatement ps=con.prepareStatement(
      "INSERT INTO intern_lawyer_assignments (intern_email, lawyer_email, assigned_by, status) VALUES (?,?,?,'PENDING')"
    );
    ps.setString(1, internEmail.trim());
    ps.setString(2, lawyerEmail.trim());
    ps.setString(3, admin);
    ps.executeUpdate();
    try {
      NotificationService.create(lawyerEmail.trim(),
        "A new intern has been assigned to you for approval.",
        "intern",
        "../lawyer/Lawyerdashboard.jsp");
    } catch(Exception ne){}
    try {
      NotificationService.create(internEmail.trim(),
        "You have been assigned to a lawyer. Waiting for their approval.",
        "assignment",
        "../intern/interndashboard.jsp");
    } catch(Exception ne){}
    response.sendRedirect("assign_intern_to_lawyer.jsp?msg=Intern assigned to lawyer successfully. Awaiting lawyer approval.");
  }catch(Exception e){
    e.printStackTrace();
    response.sendRedirect("assign_intern_to_lawyer.jsp?msg=Error: "+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));
  }
%>