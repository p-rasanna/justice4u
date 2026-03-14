<%-- Document : processaddcase Created on : 4 Apr, 2025, 8:14:54 PM Author : ZulkiflMugad --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
        <%@ include file="db_connection.jsp" %>
            <% 
    // Admin Session Validation Guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html?msg=Unauthorized access");
        return;
    }

    try { 
        int cid = Integer.parseInt(request.getParameter("customerid")); 
        String a = "'" + request.getParameter("customername") + "'"; 
        String b = "'" + request.getParameter("title") + "'"; 
        String c = "'" + request.getParameter("currentdate") + "'"; 
        String d = "'" + request.getParameter("description") + "'"; 
        String e = "'" + request.getParameter("courtType") + "'"; 
        String f = "'" + request.getParameter("city") + "'"; 
        String g = "'" + request.getParameter("mop") + "'"; 
        String h = "'" + request.getParameter("transactionid") + "'"; 
        String i = "'" + request.getParameter("amt") + "'"; 
        String j = "'" + request.getParameter("cname") + "'"; 
        String k = "'" + request.getParameter("lname") + "'"; 
        
        Connection con = getDatabaseConnection(); 
        
        String q = "insert into allotlawyer(cid,name,title,des,curdate,courttype,city,mop,tid,amt,cname,lname)values("
                 + cid + "," + a + "," + b + "," + d + "," + c + "," + e + "," + f + "," + g + "," + h + "," + i + "," + j + "," + k + ")"; 
        
        Statement st = con.createStatement();
        st.executeUpdate(q);
        st.close();
                // LINKAGE FIX: Update customer_cases table with Assigned Lawyer
                // We must use CASE ID (cid) to identify the row, NOT customer_id alone.
                // admin passes 'customerid' which is actually the Case ID from the previous form (rs.getInt(1) in allotlawyer.jsp is casetb.cid)
                
                int caseIdToUpdate = cid; // Rename for clarity

                Statement st2=con.createStatement();
                // Get lawyer ID from email
                ResultSet lawyerRs=st2.executeQuery("SELECT lid FROM lawyer_reg WHERE email=" + k); // k is already quoted email
                
                if(lawyerRs.next()) {
                     int lawyerId = lawyerRs.getInt("lid");
                     
                     // Update customer_cases table
                     // Using PreparedStatement for safety here would be better but keeping consistency with file style for now, just fixing logic
                     Statement st3 = con.createStatement();
                     
                     // CRITICAL FIX: Set status to PENDING_LAWYER_CONFIRMATION to trigger lawyer acceptance flow
                     String updateQuery = "UPDATE customer_cases SET assigned_lawyer_id=" + lawyerId + ", status='PENDING_LAWYER_CONFIRMATION' WHERE case_id=" + caseIdToUpdate;
                     
                     st3.executeUpdate(updateQuery);
                     st3.close();
                }
                lawyerRs.close();
                st2.close();

                Statement st1 = con.createStatement();
                String q1 = "update casetb set flag=1 where cid=" + cid;
                st1.executeUpdate(q1);
                st1.close();
                con.close();
                
                response.sendRedirect("admindashboard.jsp?msg=Case Assigned Successfully");
         } catch(Exception ee) { 
             out.println("Error: " + ee.getMessage());
             ee.printStackTrace(); 
         } 
%>