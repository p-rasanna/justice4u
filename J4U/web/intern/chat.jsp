<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
    String email = (String) session.getAttribute("iname");
    if (email == null) {
        response.sendRedirect("../auth/Login.jsp");
        return;
    }

    String caseIdStr = request.getParameter("case_id");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="components/_head.jsp" />
    <title>Intern Chat - Justice4U</title>
</head>
<body>
    <div class="app-layout">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="main-content">
            <div class="container-fluid">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2 class="h3 mb-0 text-gray-800">Communication with Supervising Lawyer</h2>
                </div>

<%
    try (Connection con = DatabaseConfig.getConnection()) {
        if (caseIdStr != null && !caseIdStr.trim().isEmpty()) {
            int caseId = -1;
            try { caseId = Integer.parseInt(caseIdStr); } catch (Exception e) {}
            
            boolean authorized = false;
            String lawyerEmail = null;
            String lawyerName = null;
            String caseTitle = "Case";
            
            if (caseId != -1) {
                String sql = "SELECT lr.email, COALESCE(lr.name, lr.lname) as lawyer_name, c.title " +
                             "FROM intern_assignments ia " +
                             "JOIN lawyer_reg lr ON ia.alid = lr.lid " +
                             "JOIN casetb c ON ia.case_id = c.cid " +
                             "WHERE ia.intern_email=? AND ia.case_id=? AND ia.status='ACTIVE' LIMIT 1";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, email);
                    ps.setInt(2, caseId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            authorized = true;
                            lawyerEmail = rs.getString("email");
                            lawyerName = rs.getString("lawyer_name");
                            caseTitle = rs.getString("title");
                        }
                    }
                }
            }
            
            if (authorized) {
                // Render the unified chat using iframe to reuse shared chat
%>
                <div class="card shadow border-0" style="height: calc(100vh - 180px);">
                    <div class="card-header bg-white py-3">
                        <h6 class="m-0 font-weight-bold text-dark d-flex align-items-center">
                            <a href="chat.jsp" class="btn btn-sm btn-light border rounded-circle me-3"><i class="ph ph-arrow-left"></i></a>
                            <div>
                                Supervising Lawyer: <%= lawyerName %>
                                <div class="small fw-normal text-muted mt-1"><i class="ph ph-briefcase me-1"></i><%= caseTitle %></div>
                            </div>
                        </h6>
                    </div>
                    <div class="card-body p-0">
                        <iframe src="../shared/chat.jsp?case_id=<%= caseId %>" style="width: 100%; height: 100%; border: none;"></iframe>
                    </div>
                </div>
<%          } else { %>
                <div class="alert alert-danger shadow-sm">
                    <i class="ph ph-warning-circle me-2"></i>You are not assigned to a lawyer for this case, or the case ID is invalid.
                    <br><a href="chat.jsp" class="btn btn-outline-danger mt-3 btn-sm">Return to Case List</a>
                </div>
<%          }
        } else {
%>
                <div class="card shadow mb-4">
                    <div class="card-header bg-white py-3">
                        <h6 class="m-0 font-weight-bold text-dark">Select Case Assignment</h6>
                    </div>
                    <div class="card-body p-0">
                        <div class="list-group list-group-flush">
<%
            boolean hasAssignments = false;
            String sql = "SELECT ia.case_id, c.title, COALESCE(lr.name, lr.lname) as lawyer_name " +
                         "FROM intern_assignments ia " +
                         "JOIN casetb c ON ia.case_id = c.cid " +
                         "JOIN lawyer_reg lr ON ia.alid = lr.lid " +
                         "WHERE ia.intern_email=? AND ia.status='ACTIVE'";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        hasAssignments = true;
%>
                            <div class="list-group-item p-4 hover-bg-light">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="d-flex align-items-center">
                                        <div class="bg-light rounded-circle p-3 me-3 text-center" style="width: 60px; height: 60px;">
                                            <i class="ph ph-chat-circle-dots text-primary mt-1 fs-5"></i>
                                        </div>
                                        <div>
                                            <h6 class="mb-1 fw-bold text-dark">#<%= rs.getInt("case_id") %> <%= rs.getString("title") %></h6>
                                            <p class="mb-0 text-muted small"><i class="ph ph-scales me-1"></i>Supervisor: <%= rs.getString("lawyer_name") %></p>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <a href="chat.jsp?case_id=<%= rs.getInt("case_id") %>" class="btn btn-dark rounded-pill px-4">
                                            Open Chat <i class="ph ph-arrow-right ms-2"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
<%
                    }
                }
            }
            if (!hasAssignments) {
%>
                            <div class="p-5 text-center text-muted">
                                <i class="ph ph-briefcase text-gray-400 mb-3" style="font-size: 4rem;"></i>
                                <h5>No active assignments</h5>
                                <p>You have not been assigned to any cases yet.</p>
                            </div>
<%          } %>
                        </div>
                    </div>
                </div>
<%      }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
            </div>
        </main>
    </div>
</body>
</html>
