<%--
    Document   : closecase
    Created on : 21 Mar, 2025
    Author     : ZulkiflMugad
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>

<%
  String lname = (String) session.getAttribute("lname");
  if (lname == null) {
    response.sendRedirect("Lawyerlogin.html");
    return;
  }

  String idParam = request.getParameter("id");
  String remarks = request.getParameter("remarks");

  if (idParam == null || idParam.isEmpty()) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid case ID");
    return;
  }

  if (remarks == null || remarks.trim().isEmpty()) {
    // Show form to enter closing remarks
%>
<!DOCTYPE html>
<html>
<head>
    <title>Close Case - Justice4U</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header">
                    <h5>Close Case</h5>
                </div>
                <div class="card-body">
                    <form action="closecase.jsp" method="post">
                        <input type="hidden" name="id" value="<%= idParam %>">
                        <div class="mb-3">
                            <label for="remarks" class="form-label">Closing Remarks</label>
                            <textarea class="form-control" id="remarks" name="remarks" rows="4" required
                                      placeholder="Please provide closing remarks and summary..."></textarea>
                        </div>
                        <button type="submit" class="btn btn-success">Close Case</button>
                        <a href="Lawyerdashboard.jsp" class="btn btn-secondary">Cancel</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
<%
    return;
  }

  int alid = Integer.parseInt(idParam);

  try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = getDatabaseConnection();

    // Check if case belongs to this lawyer and is active
    PreparedStatement checkStmt = con.prepareStatement(
      "SELECT COUNT(*) FROM allotlawyer a " +
      "JOIN case_status cs ON a.alid = cs.alid " +
      "WHERE a.alid=? AND a.lname=? AND cs.status IN ('ACCEPTED', 'IN_PROGRESS')"
    );
    checkStmt.setInt(1, alid);
    checkStmt.setString(2, lname);
    ResultSet checkRs = checkStmt.executeQuery();
    checkRs.next();
    if (checkRs.getInt(1) == 0) {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Unauthorized or invalid case");
      return;
    }
    checkRs.close();
    checkStmt.close();

    // Update case status to CLOSED
    PreparedStatement statusStmt = con.prepareStatement(
      "UPDATE case_status SET status='CLOSED', updated_by=?, updated_at=CURRENT_TIMESTAMP, remarks=? WHERE alid=?"
    );
    statusStmt.setString(1, lname);
    statusStmt.setString(2, "Closed: " + remarks);
    statusStmt.setInt(3, alid);
    statusStmt.executeUpdate();
    statusStmt.close();

    con.close();

    response.sendRedirect("Lawyerdashboard.jsp?msg=Case closed successfully");

  } catch(Exception e) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Error closing case: " + e.getMessage());
  }
%>
