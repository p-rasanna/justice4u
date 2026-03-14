<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*" %>
    <%@ include file="db_connection.jsp" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Justice4U - Select Case for Chat</title>
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
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                }

                .dashboard h2 {
                    text-align: center;
                    margin-bottom: 20px;
                }

                .welcome-text {
                    color: #dc3545;
                    text-align: center;
                }

                .case-card {
                    border: 1px solid #ddd;
                    border-radius: 8px;
                    padding: 15px;
                    margin-bottom: 15px;
                    background: #f9f9f9;
                }

                .case-title {
                    font-weight: bold;
                    color: #333;
                }

                .case-details {
                    color: #666;
                    font-size: 14px;
                }

                .btn-chat {
                    background: #007bff;
                    color: white;
                    border: none;
                    padding: 8px 16px;
                    border-radius: 5px;
                    text-decoration: none;
                }

                .btn-chat:hover {
                    background: #0056b3;
                    color: white;
                }
            </style>
        </head>

        <body>
            <div class="container">
                <div class="dashboard">
                    <h2>Select Case for Chat</h2>
                    <% String username=(String) session.getAttribute("cname"); if (username==null) {
                        response.sendRedirect("cust_login.html"); return; } %>
                        <p class="welcome-text"><strong>Welcome <%= username %></strong></p>

                        <% try { Connection con=getDatabaseConnection(); // Get cases that have been assigned to lawyers
                            for this client String
                            query="SELECT c.cid, c.title, c.des, c.curdate, c.courttype, c.city, "
                            + "al.lname as lawyer_name, al.alid " + "FROM casetb c "
                            + "JOIN allotlawyer al ON c.cid = al.cid AND c.cname = al.cname " + "WHERE c.cname = ? "
                            + "ORDER BY c.curdate DESC" ; PreparedStatement ps=con.prepareStatement(query);
                            ps.setString(1, username); ResultSet rs=ps.executeQuery(); boolean hasCases=false; while
                            (rs.next()) { hasCases=true; int caseId=rs.getInt("cid"); int alid=rs.getInt("alid"); String
                            title=rs.getString("title"); String description=rs.getString("des"); String
                            date=rs.getString("curdate"); String courtType=rs.getString("courttype"); String
                            city=rs.getString("city"); String lawyerName=rs.getString("lawyer_name"); %>
                            <div class="case-card">
                                <div class="case-title">Case #<%= caseId %>: <%= title %>
                                </div>
                                <div class="case-details">
                                    <p><strong>Description:</strong>
                                        <%= description %>
                                    </p>
                                    <p><strong>Date:</strong>
                                        <%= date %> | <strong>Court:</strong>
                                            <%= courtType %> | <strong>City:</strong>
                                                <%= city %>
                                    </p>
                                    <p><strong>Assigned Lawyer:</strong>
                                        <%= lawyerName %>
                                    </p>
                                </div>
                                <a href="chat.jsp?case=<%= alid %>" class="btn-chat">Chat with Lawyer</a>
                            </div>
                            <% } if (!hasCases) { %>
                                <div class="case-card">
                                    <div class="case-title">No Cases Available for Chat</div>
                                    <div class="case-details">
                                        <p>You don't have any cases assigned to lawyers yet. Once a lawyer is assigned
                                            to your case, you can chat with them here.</p>
                                    </div>
                                </div>
                                <% } rs.close(); ps.close(); con.close(); } catch (Exception e) { %>
                                    <div class="case-card">
                                        <div class="case-title" style="color: red;">Error Loading Cases</div>
                                        <div class="case-details">
                                            <p>There was an error loading your cases: <%= e.getMessage() %>
                                            </p>
                                        </div>
                                    </div>
                                    <% } %>

                                        <div style="text-align: center; margin-top: 20px;">
                                            <a href="customerdashboard.jsp" class="btn btn-secondary">Back to
                                                Dashboard</a>
                                        </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>
