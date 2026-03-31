<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String admin=(String)session.getAttribute("aname"); if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
    String type=request.getParameter("type"), action=request.getParameter("action"), idStr=request.getParameter("id");
    if(type==null||action==null||idStr==null){response.sendRedirect("admindashboard.jsp?msg=Invalid request");return;}
    String redir="admindashboard.jsp", table="", idCol="", emailCol="";
    int id=Integer.parseInt(idStr), flagStatus="approve".equals(action)?1:2;
    String vs="approve".equals(action)?"VERIFIED":"REJECTED";
    
    if("client".equals(type)){ table="cust_reg"; idCol="cid"; emailCol="email"; redir="viewcustomers.jsp"; }
    else if("lawyer".equals(type)){ table="lawyer_reg"; idCol="lid"; redir="viewlawyers.jsp"; }
    else if("intern".equals(type)){ table="intern"; idCol="internid"; emailCol="email"; redir="viewinterns.jsp"; }
    
    try(Connection con=DatabaseConfig.getConnection()){
        String email=null;
        if(emailCol!=null && !emailCol.isEmpty()){
            PreparedStatement ps=con.prepareStatement("SELECT "+emailCol+" FROM "+table+" WHERE "+idCol+"=?"); ps.setInt(1,id);
            ResultSet rs=ps.executeQuery(); if(rs.next()) email=rs.getString(1);
        }
        
        if("client".equals(type)){
            PreparedStatement ps1 = con.prepareStatement("UPDATE cust_reg SET flag=?, verification_status=? WHERE cid=?"); ps1.setInt(1, flagStatus); ps1.setString(2, vs); ps1.setInt(3, id); ps1.executeUpdate();
            if(email!=null){
                PreparedStatement np=con.prepareStatement("INSERT INTO notifications (user_email, user_role, message) VALUES (?,'client',?)");
                np.setString(1,email); np.setString(2,"approve".equals(action)?"Your account has been verified. You can now access full platform features.":"Your account configuration requires further review or has been rejected."); np.executeUpdate();
            }
        }else if("lawyer".equals(type)){
            PreparedStatement ps1 = con.prepareStatement("UPDATE lawyer_reg SET flag=? WHERE lid=?"); ps1.setInt(1, flagStatus); ps1.setInt(2, id); ps1.executeUpdate();
        }else if("intern".equals(type)){
            con.prepareStatement("UPDATE intern SET flag="+flagStatus+" WHERE internid="+id).executeUpdate();
            if(email!=null) con.prepareStatement("UPDATE intern_profiles SET verification_status='"+vs+"' WHERE intern_email='"+email+"'").executeUpdate();
        }
        response.sendRedirect(redir+"?msg="+type+" "+action+"d successfully");
    }catch(Exception e){response.sendRedirect(redir+"?msg=Error: "+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));}
%>
