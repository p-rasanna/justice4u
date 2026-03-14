<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%
    // STRICT ROLE CHECK (LAWYER ONLY)
    String lawyerEmail = (String) session.getAttribute("lname");
    if (lawyerEmail == null) {
        response.sendRedirect("Lawyer_login.html");
        return;
    }

    String action = request.getParameter("action");
    String internEmail = request.getParameter("intern_email");
    String lawyerIdStr = request.getParameter("lawyer_id");
    
    if (lawyerIdStr == null || lawyerIdStr.isEmpty()) {
         response.sendRedirect("viewinternl.jsp?msg=Error:Lawyer%20ID%20Missing");
         return;
    }
    int lawyerId = Integer.parseInt(lawyerIdStr);
    
    try {
        Connection con = getDatabaseConnection();
        
        if ("assign_case".equals(action)) {
            String caseIdStr = request.getParameter("case_id");
            if (caseIdStr == null || caseIdStr.isEmpty()) throw new Exception("Case ID missing");
            int caseId = Integer.parseInt(caseIdStr);
            
            // Check if already assigned
            PreparedStatement check = con.prepareStatement(
                "SELECT assignment_id FROM intern_assignments WHERE intern_email=? AND case_id=?"
            );
            check.setString(1, internEmail);
            check.setInt(2, caseId);
            ResultSet rs = check.executeQuery();
            
            if (!rs.next()) {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO intern_assignments (intern_email, case_id, alid, assigned_by, status) VALUES (?, ?, ?, ?, 'ACTIVE')"
                );
                ps.setString(1, internEmail);
                ps.setInt(2, caseId);
                ps.setInt(3, lawyerId);
                ps.setString(4, lawyerEmail);
                ps.executeUpdate();
                ps.close();
            }
            check.close();
            
        } else if ("assign_task".equals(action)) {
            String title = request.getParameter("title");
            String dueDate = request.getParameter("due_date");
            String caseIdStr = request.getParameter("case_id");
            int caseId = (caseIdStr != null && !caseIdStr.isEmpty()) ? Integer.parseInt(caseIdStr) : 0;
            
            // First find the assignment_id
            int assignmentId = 0;
            PreparedStatement getAssign = con.prepareStatement(
                "SELECT assignment_id FROM intern_assignments WHERE intern_email=? AND case_id=?"
            );
            getAssign.setString(1, internEmail);
            getAssign.setInt(2, caseId);
            ResultSet rsAssign = getAssign.executeQuery();
            if (rsAssign.next()) {
                assignmentId = rsAssign.getInt("assignment_id");
            }
            rsAssign.close();
            getAssign.close();

            if (assignmentId > 0) {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO intern_tasks (assignment_id, title, due_date, status) VALUES (?, ?, ?, 'PENDING')"
                );
                ps.setInt(1, assignmentId);
                ps.setString(2, title);
                ps.setString(3, dueDate);
                ps.executeUpdate();
                ps.close();
            } else {
                throw new Exception("Intern must be assigned to case before delegating tasks.");
            }
        }
        
        con.close();
        // Redirect back with success message
        response.sendRedirect("viewinternl.jsp?msg=Assignment%20successful");
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewinternl.jsp?msg=Error:%20" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    }
%>
