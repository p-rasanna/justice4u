<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lawyer Password Debugger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; padding: 40px; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .table { margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h2 class="mb-4 text-danger">⚠️ DEBUG USE ONLY: Lawyer Passwords</h2>
        <p class="text-muted">This page directly queries the <code>lawyer_reg</code> table to display stored passwords. Ensure this file is removed before production.</p>

        <table class="table table-bordered table-striped">
            <thead class="table-dark">
                <tr>
                    <th>Lawyer ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Stored Password</th>
                    <th>Approved (Flag)</th>
                </tr>
            </thead>
            <tbody>
                <%@include file="db_connection.jsp" %>
                <%
                    try {
                        Connection con = getDatabaseConnection();
                        Statement st = con.createStatement();
                        ResultSet rs = st.executeQuery("SELECT lid, name, email, pass, flag FROM lawyer_reg ORDER BY lid DESC");
                        
                        boolean hasData = false;
                        while(rs.next()) {
                            hasData = true;
                %>
                <tr>
                    <td><%= rs.getInt("lid") %></td>
                    <td><%= com.j4u.Sanitizer.sanitize(rs.getString("name")) %></td>
                    <td><%= com.j4u.Sanitizer.sanitize(rs.getString("email")) %></td>
                    <td class="font-monospace text-primary fw-bold"><%= com.j4u.Sanitizer.sanitize(rs.getString("pass")) %></td>
                    <td><%= rs.getInt("flag") == 1 ? "✅ Yes (1)" : "❌ No (0)" %></td>
                </tr>
                <%
                        }
                        if (!hasData) {
                %>
                <tr>
                    <td colspan="5" class="text-center">No lawyers found in the database.</td>
                </tr>
                <%
                        }
                        rs.close();
                        st.close();
                        con.close();
                    } catch(Exception e) {
                %>
                <tr>
                    <td colspan="5" class="text-danger"><strong>Error:</strong> <%= e.getMessage() %></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        <a href="admindashboard.jsp" class="btn btn-secondary mt-3">Back to Admin Dashboard</a>
    </div>
</body>
</html>
