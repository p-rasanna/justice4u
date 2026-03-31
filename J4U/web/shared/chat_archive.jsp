<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
    String userEmail = null;
    String userRole = null;
    
    if (session.getAttribute("cname") != null) {
        userEmail = (String) session.getAttribute("cname");
        userRole = "client";
    } else if (session.getAttribute("lname") != null) {
        userEmail = (String) session.getAttribute("lname");
        userRole = "lawyer";
    }

    if (userEmail == null) {
        response.sendRedirect("../auth/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <% if ("client".equals(userRole)) { %>
        <jsp:include page="../client/components/_head.jsp" />
    <% } else { %>
        <jsp:include page="../lawyer/components/_head.jsp" />
    <% } %>
    <title>Chat Archive - Justice4U</title>
</head>
<body>
    <div class="app-layout">
        <% if ("client".equals(userRole)) { %>
            <jsp:include page="../client/components/_sidebar.jsp" />
        <% } else { %>
            <jsp:include page="../lawyer/components/_sidebar.jsp" />
        <% } %>
        <main class="main-content">
            <div class="container-fluid">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2 class="h3 mb-0 text-gray-800">Message Archive</h2>
                </div>

                <div class="card shadow mb-4">
                    <div class="card-body p-0">
                        <div class="list-group list-group-flush">
<%
    boolean hasDiscussions = false;
    try (Connection con = DatabaseConfig.getConnection()) {
        String sql = "SELECT d.case_id, c.title, MAX(d.timestamp) as last_msg, COUNT(*) as msg_count, " +
                     "(CASE WHEN d.sender_email=? THEN d.receiver_email ELSE d.sender_email END) as other_party " +
                     "FROM discussions d JOIN casetb c ON d.case_id=c.cid " +
                     "WHERE d.sender_email=? OR d.receiver_email=? " +
                     "GROUP BY d.case_id, c.title, other_party " +
                     "ORDER BY last_msg DESC";
                     
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userEmail);
            ps.setString(2, userEmail);
            ps.setString(3, userEmail);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    hasDiscussions = true;
                    int cid = rs.getInt("case_id");
                    String title = rs.getString("title");
                    String otherParty = rs.getString("other_party");
                    String lastMsg = rs.getTimestamp("last_msg").toString();
                    int count = rs.getInt("msg_count");
%>
                            <div class="list-group-item p-4 hover-bg-light">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="d-flex align-items-center">
                                        <div class="bg-light rounded-circle p-3 me-3 text-center" style="width: 60px; height: 60px;">
                                            <i class="ph ph-chat-circle-dots text-primary mt-1 fs-5"></i>
                                        </div>
                                        <div>
                                            <h6 class="mb-1 fw-bold text-dark"><%= title != null ? title : "Case #" + cid %></h6>
                                            <p class="mb-1 text-muted small"><i class="ph ph-user me-1"></i><%= otherParty != null ? otherParty : "Unknown Party" %></p>
                                            <div class="d-flex gap-3 align-items-center">
                                                <span class="badge bg-secondary rounded-pill px-3"><%= count %> messages</span>
                                                <span class="small text-muted"><i class="ph ph-clock me-1"></i>Last active: <%= lastMsg.substring(0, 16) %></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <a href="../shared/chat.jsp?case_id=<%= cid %>" class="btn btn-dark rounded-pill px-4">
                                            Open Chat <i class="ph ph-arrow-right ms-2"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
<%
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    if (!hasDiscussions) {
%>
                            <div class="p-5 text-center text-muted">
                                <i class="ph ph-chat-teardrop-slash text-gray-400 mb-3" style="font-size: 4rem;"></i>
                                <h5>No conversations yet</h5>
                                <p>You haven't participated in any case discussions.</p>
                            </div>
<%
    }
%>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
