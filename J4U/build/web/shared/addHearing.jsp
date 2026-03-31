<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%@ page import="com.j4u.NotificationService" %>
<%
    String lname = (String) session.getAttribute("lname");
    String aname = (String) session.getAttribute("aname");
    
    if (lname == null && aname == null) {
        response.sendRedirect("../auth/Login.jsp");
        return;
    }
    
    String myEmail = lname != null ? lname : aname;
    String myRole = lname != null ? "lawyer" : "admin";

    String caseIdStr = request.getParameter("case_id");
    if (caseIdStr == null || caseIdStr.trim().isEmpty()) {
        response.sendRedirect("../shared/error.jsp");
        return;
    }

    int caseId;
    try {
        caseId = Integer.parseInt(caseIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("../shared/error.jsp");
        return;
    }

    String caseTitle = "";
    String clientEmail = "";
    String getMethod = request.getMethod();
    String msg = "";

    try (Connection con = DatabaseConfig.getConnection()) {
        
        // Verify case access
        if ("lawyer".equals(myRole)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT c.title, c.cname FROM casetb c JOIN allotlawyer al ON c.cid=al.cid WHERE c.cid=? AND al.lname=?")) {
                ps.setInt(1, caseId);
                ps.setString(2, myEmail);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        caseTitle = rs.getString("title");
                        clientEmail = rs.getString("cname");
                    } else {
                        response.sendRedirect("../lawyer/Lawyerdashboard.jsp?msg=Unauthorized+access");
                        return;
                    }
                }
            }
        } else {
            // Admin can bypass
            try (PreparedStatement ps = con.prepareStatement("SELECT title, cname FROM casetb WHERE cid=?")) {
                ps.setInt(1, caseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        caseTitle = rs.getString("title");
                        clientEmail = rs.getString("cname");
                    }
                }
            }
        }

        if ("POST".equalsIgnoreCase(getMethod)) {
            String date = request.getParameter("hearing_date");
            String time = request.getParameter("hearing_time");
            String courtName = request.getParameter("court_name");
            String courtAddress = request.getParameter("court_address");
            String notes = request.getParameter("notes");
            
            if (date != null && !date.isEmpty() && courtName != null && !courtName.isEmpty()) {
                String sql = "INSERT INTO hearings (case_id, hearing_date, hearing_time, court_name, court_address, notes, created_by, created_role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, caseId);
                    ps.setString(2, date);
                    ps.setString(3, time != null && !time.isEmpty() ? time : "10:00:00");
                    ps.setString(4, courtName);
                    ps.setString(5, courtAddress);
                    ps.setString(6, notes);
                    ps.setString(7, myEmail);
                    ps.setString(8, myRole);
                    ps.executeUpdate();
                }
                
                NotificationService.create(clientEmail, "A hearing has been scheduled for your case '" + caseTitle + "' on " + date + " at " + courtName, "hearing", "../client/hearings.jsp");
                
                if ("lawyer".equals(myRole)) {
                    response.sendRedirect("../lawyer/hearings.jsp?msg=Hearing+scheduled+successfully");
                } else {
                    response.sendRedirect("../admin/admindashboard.jsp?msg=Hearing+scheduled+successfully");
                }
                return;
            } else {
                msg = "Please fill all required fields.";
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        msg = "Server Error. Please try again.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <% if ("lawyer".equals(myRole)) { %>
        <jsp:include page="../lawyer/components/_head.jsp" />
    <% } else { %>
        <jsp:include page="../admin/components/_head.jsp" />
    <% } %>
    <title>Add Hearing</title>
</head>
<body>
    <div class="app-layout">
        <% if ("lawyer".equals(myRole)) { %>
            <jsp:include page="../lawyer/components/_sidebar.jsp" />
        <% } else { %>
            <jsp:include page="../admin/components/_sidebar.jsp" />
        <% } %>
        <main class="main-content">
            <div class="container-fluid">
                <div class="card shadow" style="max-width: 600px; margin: 0 auto; margin-top: 50px;">
                    <div class="card-header bg-white">
                        <h5 class="m-0 font-weight-bold text-dark">Schedule Hearing</h5>
                        <small class="text-muted"><%= caseTitle %></small>
                    </div>
                    <div class="card-body">
                        <% if (!msg.isEmpty()) { %>
                            <div class="alert alert-danger"><%= msg %></div>
                        <% } %>
                        <form method="POST" action="addHearing.jsp?case_id=<%= caseId %>">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label form-label-required">Date</label>
                                    <input type="date" class="form-control" name="hearing_date" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Time</label>
                                    <input type="time" class="form-control" name="hearing_time" value="10:00">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label form-label-required">Court Name</label>
                                <input type="text" class="form-control" name="court_name" required placeholder="High Court">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Court Address</label>
                                <textarea class="form-control" name="court_address" rows="2" placeholder="Street layout/room number..."></textarea>
                            </div>
                            <div class="mb-4">
                                <label class="form-label">Notes</label>
                                <textarea class="form-control" name="notes" rows="3" placeholder="Any internal notes or memos..."></textarea>
                            </div>
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-dark">Schedule Hearing</button>
                                <a href="javascript:history.back()" class="btn btn-outline-secondary">Go Back</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
