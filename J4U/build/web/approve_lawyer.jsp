<%-- Document : approve_lawyer Created on : 2025 Author : Justice4U System --%>

    <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
        <%@ include file="db_connection.jsp" %>

            <% // Simple script to approve a lawyer for testing String email=request.getParameter("email"); String
                message="" ; if (email !=null && !email.trim().isEmpty()) { try { Connection
                con=getDatabaseConnection(); String
                updateQuery="UPDATE lawyer_reg SET flag=1, document_verification_status='VERIFIED' WHERE email=?" ;
                PreparedStatement pst=con.prepareStatement(updateQuery); pst.setString(1, email.trim()); int
                result=pst.executeUpdate(); if (result> 0) {
                message = "Lawyer " + email + " has been approved successfully!";
                } else {
                message = "No lawyer found with email: " + email;
                }

                pst.close();
                con.close();
                } catch (Exception e) {
                message = "Error: " + e.getMessage();
                }
                }
                %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Approve Lawyer | Justice4U</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                </head>

                <body>
                    <div class="container mt-5">
                        <div class="row justify-content-center">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h3>Approve Lawyer Account</h3>
                                    </div>
                                    <div class="card-body">
                                        <% if (!message.isEmpty()) { %>
                                            <div class="alert alert-info">
                                                <%= message %>
                                            </div>
                                            <% } %>

                                                <form method="post">
                                                    <div class="mb-3">
                                                        <label for="email" class="form-label">Lawyer Email</label>
                                                        <input type="email" class="form-control" id="email" name="email"
                                                            required>
                                                    </div>
                                                    <button type="submit" class="btn btn-primary">Approve
                                                        Lawyer</button>
                                                </form>

                                                <hr>
                                                <h5>Registered Lawyers:</h5>
                                                <% try { Connection con=getDatabaseConnection(); String
                                                    query="SELECT email, flag, document_verification_status FROM lawyer_reg"
                                                    ; PreparedStatement pst=con.prepareStatement(query); ResultSet
                                                    rs=pst.executeQuery(); while(rs.next()) { String
                                                    lawyerEmail=rs.getString("email"); int flag=rs.getInt("flag");
                                                    String status=rs.getString("document_verification_status"); %>
                                                    <div class="mb-2">
                                                        <strong>
                                                            <%= lawyerEmail %>
                                                        </strong> - Flag: <%= flag %> - Status: <%= status %>
                                                    </div>
                                                    <% } rs.close(); pst.close(); con.close(); } catch (Exception e) {
                                                        out.println("<div class='alert alert-danger'>Error loading
                                                        lawyers: " + e.getMessage() + "
                                    </div>");
                                    }
                                    %>
                                </div>
                            </div>
                        </div>
                    </div>
                    </div>
                </body>

                </html>