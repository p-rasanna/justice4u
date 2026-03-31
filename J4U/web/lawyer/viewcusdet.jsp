<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
    String email = (String) session.getAttribute("lname");
    if (email == null) {
        response.sendRedirect("../auth/Login.jsp");
        return;
    }

    String clientIdStr = request.getParameter("id");
    if (clientIdStr == null || clientIdStr.trim().isEmpty()) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+client+ID");
        return;
    }
    int clientId;
    try { clientId = Integer.parseInt(clientIdStr); } catch (NumberFormatException e) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+client+ID");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="components/_head.jsp" />
    <title>Client Details - Justice4U</title>
</head>
<body>
    <div class="app-layout">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="main-content">
            <div class="container-fluid">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2 class="h3 mb-0 text-gray-800">Assigned Client Profile</h2>
                    <a href="Lawyerdashboard.jsp" class="btn btn-outline-dark btn-sm"><i class="ph ph-arrow-left me-1"></i> Back to Dashboard</a>
                </div>

                <div class="row">
                    <div class="col-md-4 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header bg-white py-3">
                                <h6 class="m-0 font-weight-bold text-dark"><i class="ph ph-user text-primary me-2"></i>Profile</h6>
                            </div>
                            <div class="card-body">
<%
    String clientEmailStr = "";
    try (Connection con = DatabaseConfig.getConnection()) {
        String sqlC = "SELECT name, email, mobile, city, state, address, aadhar, dob, gender FROM cust_reg WHERE cid=?";
        try (PreparedStatement ps = con.prepareStatement(sqlC)) {
            ps.setInt(1, clientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    clientEmailStr = rs.getString("email");
%>
                                <div class="text-center mb-4">
                                    <div class="bg-light rounded-circle d-inline-block p-4 mb-3 shadow-sm border border-secondary" style="border-width:2px !important;">
                                        <i class="ph ph-user text-muted" style="font-size: 3rem;"></i>
                                    </div>
                                    <h5 class="fw-bold text-dark"><%= rs.getString("name") %></h5>
                                    <span class="badge bg-success rounded-pill px-3">Active Client</span>
                                </div>
                                <hr>
                                <dl class="row mb-0 mt-3 small">
                                    <dt class="col-sm-4 text-muted">Email</dt><dd class="col-sm-8 fw-bold"><%= rs.getString("email") %></dd>
                                    <dt class="col-sm-4 text-muted">Phone</dt><dd class="col-sm-8 fw-bold"><%= rs.getString("mobile") %></dd>
                                    <dt class="col-sm-4 text-muted">DOB</dt><dd class="col-sm-8"><%= rs.getString("dob") %></dd>
                                    <dt class="col-sm-4 text-muted">Gender</dt><dd class="col-sm-8"><%= rs.getString("gender") %></dd>
                                    <dt class="col-sm-4 text-muted mt-2">ID (Aadhar)</dt><dd class="col-sm-8 mt-2 font-monospace"><%= rs.getString("aadhar") %></dd>
                                    <dt class="col-sm-4 text-muted mt-2">Location</dt>
                                    <dd class="col-sm-8 mt-2">
                                        <%= rs.getString("city") %>, <%= rs.getString("state") %><br>
                                        <small class="text-muted"><%= rs.getString("address") %></small>
                                    </dd>
                                </dl>
<%
                } else {
                    out.println("<p class='text-danger text-center'>Client profile not found.</p>");
                }
            }
        }

%>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-8 mb-4">
                        <div class="card shadow h-100">
                            <div class="card-header bg-white py-3">
                                <h6 class="m-0 font-weight-bold text-dark"><i class="ph ph-briefcase text-dark me-2"></i>Cases Represented by You</h6>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="bg-light text-muted small">
                                            <tr>
                                                <th class="ps-4">Case Details</th>
                                                <th>Court Info</th>
                                                <th>Status</th>
                                                <th class="text-end pe-4">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
<%
        boolean hasCases = false;
        if (!clientEmailStr.isEmpty()) {
            String sqlCases = "SELECT c.cid, c.title, c.courttype, c.city, c.status, c.cdate " +
                              "FROM casetb c JOIN allotlawyer al ON c.cid=al.cid " +
                              "WHERE c.cname=? AND al.lname=? ORDER BY c.cid DESC";
            try (PreparedStatement ps = con.prepareStatement(sqlCases)) {
                ps.setString(1, clientEmailStr);
                ps.setString(2, email);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        hasCases = true;
                        int c_id = rs.getInt("cid");
                        String badge = "bg-secondary";
                        String stat = rs.getString("status");
                        if ("ACCEPTED".equals(stat) || "IN_PROGRESS".equals(stat)) badge = "bg-primary";
                        else if ("HEARING_SCHEDULED".equals(stat)) badge = "bg-warning text-dark";
                        else if ("CLOSED".equals(stat)) badge = "bg-success";
%>
                                            <tr>
                                                <td class="ps-4">
                                                    <a href="viewcase.jsp?id=<%= c_id %>" class="fw-bold text-dark text-decoration-none d-block">#<%= c_id %> <%= rs.getString("title") %></a>
                                                    <small class="text-muted"><i class="ph ph-calendar-blank me-1 text-primary"></i>Filed: <%= rs.getString("cdate") %></small>
                                                </td>
                                                <td>
                                                    <span class="d-block text-dark fw-bold"><i class="ph ph-bank me-1 text-muted"></i><%= rs.getString("courttype") %></span>
                                                    <small class="text-muted"><%= rs.getString("city") %></small>
                                                </td>
                                                <td><span class="badge <%= badge %> rounded-pill px-2 py-1"><%= stat %></span></td>
                                                <td class="text-end pe-4 text-nowrap">
                                                    <a href="update_case_status.jsp?case_id=<%= c_id %>" class="btn btn-sm btn-light border" title="Update Status"><i class="ph ph-arrows-clockwise text-dark"></i></a>
                                                    <a href="../shared/chat.jsp?case_id=<%= c_id %>" class="btn btn-sm btn-light border ms-1" title="Chat with Client"><i class="ph ph-chat-circle-dots text-success"></i></a>
                                                    <a href="viewcase.jsp?id=<%= c_id %>" class="btn btn-sm btn-dark ms-1">View Detail <i class="ph ph-arrow-right ms-1"></i></a>
                                                </td>
                                            </tr>
<%
                    }
                }
            }
        }
        if (!hasCases) {
            out.println("<tr><td colspan='4' class='text-center py-5 text-muted'><i class='ph ph-folder-open text-gray-300 d-block mb-2' style='font-size:3rem'></i>No active cases found for this client under your representation.</td></tr>");
        }
%>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
