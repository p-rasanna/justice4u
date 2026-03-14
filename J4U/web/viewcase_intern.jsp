<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<%
    String internEmail = (String) session.getAttribute("iname");
    if (internEmail == null) {
        response.sendRedirect("internlogin.html");
        return;
    }

    String cidParam = request.getParameter("cid");
    if (cidParam == null || cidParam.isEmpty()) {
        response.sendRedirect("interndashboard.jsp?msg=Invalid Case ID");
        return;
    }

    int cid = Integer.parseInt(cidParam);
    String title="", description="", court="", city="", status="", lawyerName="";
    boolean isAssigned = false;

    try {
        Connection con = getDatabaseConnection();

        // 1. Verify Assignment
        PreparedStatement psCheck = con.prepareStatement(
            "SELECT ia.status FROM intern_assignments ia WHERE ia.intern_email=? AND ia.case_id=? AND ia.status='ACTIVE'"
        );
        psCheck.setString(1, internEmail);
        psCheck.setInt(2, cid);
        ResultSet rsCheck = psCheck.executeQuery();
        if(rsCheck.next()) {
            isAssigned = true;
        }
        rsCheck.close();
        psCheck.close();

        if(!isAssigned) {
            con.close();
            response.sendRedirect("interndashboard.jsp?msg=Access Denied: You are not assigned to this case.");
            return;
        }

        // 2. Get Case Details
        PreparedStatement psCase = con.prepareStatement(
            "SELECT c.title, c.description, c.courttype, c.city, c.curdate, l.name as lname " +
            "FROM casetb c " +
            "JOIN intern_assignments ia ON c.cid = ia.case_id " +
            "JOIN lawyer_reg l ON ia.assigned_by_lawyer_id = l.lid " +
            "WHERE c.cid=?"
        );
        psCase.setInt(1, cid);
        ResultSet rsCase = psCase.executeQuery();
        if(rsCase.next()) {
            title = rsCase.getString("title");
            description = rsCase.getString("description");
            court = rsCase.getString("courttype");
            city = rsCase.getString("city");
            lawyerName = rsCase.getString("lname");
        }
        rsCase.close(); psCase.close();

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Case #<%= cid %> | Intern View</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f9f9f9; padding: 20px; }
        .case-header { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .doc-list { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
    </style>
</head>
<body>
    <div class="container">
        <a href="interndashboard.jsp" class="btn btn-outline-secondary mb-3">&larr; Back to Dashboard</a>
        
        <div class="case-header">
            <h3>Case #<%= cid %>: <%= title %></h3>
            <span class="badge bg-success">Active Assignment</span>
            <hr>
            <div class="row">
                <div class="col-md-6">
                    <p><strong>Court:</strong> <%= court %></p>
                    <p><strong>City:</strong> <%= city %></p>
                </div>
                <div class="col-md-6">
                    <p><strong>Supervising Lawyer:</strong> <%= lawyerName %></p>
                </div>
            </div>
            <p><strong>Description:</strong><br><%= description %></p>
            
            <a href="chat.jsp?case_id=<%= cid %>" class="btn btn-primary">
                View Case Chat (Read-Only)
            </a>
        </div>

        <div class="doc-list">
            <h4>Case Documents</h4>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>File Name</th>
                        <th>Uploaded By</th>
                        <th>Role</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        PreparedStatement psDocs = con.prepareStatement(
                            "SELECT file_name, file_path, uploader_email, uploader_role, uploaded_at FROM case_documents WHERE case_id=? ORDER BY uploaded_at DESC"
                        );
                        psDocs.setInt(1, cid);
                        ResultSet rsDocs = psDocs.executeQuery();
                        boolean hasDocs = false;
                        while(rsDocs.next()) {
                            hasDocs = true;
                    %>
                    <tr>
                        <td><%= com.j4u.Sanitizer.sanitize(rsDocs.getString("file_name")) %></td>
                        <td><%= com.j4u.Sanitizer.sanitize(rsDocs.getString("uploader_email")) %></td>
                        <td><span class="badge bg-secondary"><%= com.j4u.Sanitizer.sanitize(rsDocs.getString("uploader_role")) %></span></td>
                        <td><%= com.j4u.Sanitizer.sanitize(rsDocs.getString("uploaded_at")) %></td>
                        <td>
                            <a href="<%= com.j4u.Sanitizer.sanitize(rsDocs.getString("file_path")) %>" target="_blank" class="btn btn-sm btn-outline-primary">Download</a>
                        </td>
                    </tr>
                    <%
                        }
                        if(!hasDocs) {
                    %>
                    <tr><td colspan="5" class="text-muted">No documents uploaded for this case yet.</td></tr>
                    <%
                        }
                        rsDocs.close(); psDocs.close();
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
<%
        con.close();
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
