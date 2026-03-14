<%-- 
    Document   : customerdashboard
    Created on : 21 Mar, 2025, 8:05:05 PM
    Author     : ZulkiflMugad
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .dashboard {
            max-width: 900px;
            margin: 30px auto;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .dashboard h2 {
            text-align: center;
            margin-bottom: 20px;
        }
        .list-group-item {
            font-weight: 500;
        }
        .welcome-text {
            color: #dc3545;
            text-align: center;
        }
       
    </style>
</head>
<body>

    <div class="container">
        <div class="dashboard">
            <h2>Customer Dashboard</h2>
           <% 
                String username = (String) session.getAttribute("cname");
                if (username == null) {
                    session.invalidate();
                    response.sendRedirect("customerlogin.html");
                    return;
                }
            %>
            <p class="welcome-text"><strong>Welcome <%= username %></strong></p>
            
            <div class="list-group">
                <a href="case.jsp" class="list-group-item list-group-item-action">Add Case</a>
                <a href="viewlawdetails.jsp" class="list-group-item list-group-item-action">Alloted Lawyer Details</a>
                <a href="viewdisc.jsp" class="list-group-item list-group-item-action ">View Discussions</a>
                <a href="ClientDashboard" class="list-group-item list-group-item-action">View My Cases</a>
                <a href="csignout.jsp" class="list-group-item list-group-item-action text-danger">Sign Out</a>
            </div>

            <!-- Chat with Assigned Lawyers Section -->
            <h4 style="margin-top: 30px; margin-bottom: 15px;">Chat with Assigned Lawyers</h4>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = getDatabaseConnection();

                    // Get cases that have been assigned to lawyers for this client
                    String query = "SELECT c.cid, c.title, al.lname as lawyer_name, al.alid " +
                                 "FROM casetb c " +
                                 "JOIN allotlawyer al ON c.cid = al.cid AND c.cname = al.cname " +
                                 "WHERE c.cname = ? " +
                                 "ORDER BY c.curdate DESC";

                    PreparedStatement ps = con.prepareStatement(query);
                    ps.setString(1, username);
                    ResultSet rs = ps.executeQuery();

                    boolean hasCases = false;
                    while (rs.next()) {
                        hasCases = true;
                        int caseId = rs.getInt("cid");
                        int alid = rs.getInt("alid");
                        String title = rs.getString("title");
                        String lawyerName = rs.getString("lawyer_name");
            %>
            <div class="list-group-item" style="margin-bottom: 10px; border: 1px solid #ddd; border-radius: 5px;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <strong>Case #<%= caseId %>: <%= title %></strong><br>
                        <small class="text-muted">Lawyer: <%= lawyerName %></small>
                    </div>
                    <a href="chat.jsp?case=<%= alid %>" class="btn btn-primary btn-sm">Chat Now</a>
                </div>
            </div>
            <%
                    }

                    if (!hasCases) {
            %>
            <div class="list-group-item text-center text-muted">
                <em>No cases assigned to lawyers yet. Once a lawyer is assigned, you can chat here.</em>
            </div>
            <%
                    }

                    rs.close();
                    ps.close();
                    con.close();
                } catch (Exception e) {
            %>
            <div class="list-group-item text-center text-danger">
                <em>Error loading chat options: <%= e.getMessage() %></em>
            </div>
            <%
                }
            %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
