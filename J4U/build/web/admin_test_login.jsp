<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig, com.j4u.Sanitizer" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login Diagnostics - Justice4U</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: 'Inter', sans-serif; padding-top: 50px; }
        .diagnostic-card { background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .error-box { background: #ffebee; border-left: 4px solid #f44336; padding: 15px; margin-bottom: 20px; color: #b71c1c; }
        .success-box { background: #e8f5e9; border-left: 4px solid #4caf50; padding: 15px; margin-bottom: 20px; color: #1b5e20; }
        .code-block { background: #263238; color: #eceff1; padding: 15px; border-radius: 6px; font-family: monospace; white-space: pre-wrap; font-size: 0.85rem; }
        h4 { color: #333; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h2 class="mb-4 text-center">Admin Login Diagnostics Tool</h2>

        <!-- 1. Error Reporting Section -->
        <div class="diagnostic-card">
            <h4>1. Login Response</h4>
            <%
                String error = request.getParameter("error");
                String msg = request.getParameter("msg");
                
                if (error != null) {
            %>
                <div class="error-box">
                    <strong>Authentication Failed:</strong> <%= Sanitizer.sanitize(error) %>
                </div>
            <%
                } else if (msg != null) {
            %>
                 <div class="error-box">
                    <strong>Message:</strong> <%= Sanitizer.sanitize(msg) %>
                </div>
            <%
                } else {
            %>
                <p class="text-muted">No login attempt made yet. Please use the form below.</p>
            <%
                }
            %>
        </div>

        <!-- 2. Test Login Form -->
        <div class="diagnostic-card">
            <h4>2. Test Login Form</h4>
            <p class="text-muted small">This form submits directly to <code>LoginServlet</code> just like the real Login.html page.</p>
            
            <form action="LoginServlet" method="post">
                <input type="hidden" name="role" value="admin">
                
                <div class="mb-3">
                    <label class="form-label" for="email">Admin Email</label>
                    <input type="email" class="form-control" name="email" id="email" value="admin@gmail.com" required>
                </div>
                
                <div class="mb-3">
                    <label class="form-label" for="password">Password</label>
                    <input type="password" class="form-control" name="password" id="password" value="12345678" required>
                </div>
                
                <button type="submit" class="btn btn-primary w-100">Test Admin Login</button>
            </form>
        </div>

        <!-- 3. System Diagnostics (Database & Session) -->
        <div class="diagnostic-card">
            <h4>3. System Health Check</h4>
            
            <div class="row">
                <div class="col-md-6">
                    <h5>Active Session Data</h5>
                    <div class="code-block">
<%
    if (session != null && session.getAttribute("role") != null) {
        out.println("Status: LOGGED IN");
        out.println("Session ID: " + session.getId());
        out.println("Role: " + session.getAttribute("role"));
        out.println("User: " + session.getAttribute("user"));
        out.println("Admin Name (aname): " + session.getAttribute("aname"));
    } else {
        out.println("Status: NOT LOGGED IN");
        out.println("No active role found in session.");
    }
%>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <h5>Database Connection Check</h5>
                    <div class="code-block">
<%
    Connection con = null;
    try {
        con = DatabaseConfig.getConnection();
        if (con != null && !con.isClosed()) {
            out.println("Status: CONNECTED \u2714\uFE0F");
            
            // Check admin table structure
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT email, pass FROM admin LIMIT 1");
            if (rs.next()) {
                out.println("\nAdmin Record Found:");
                out.println("Email: " + rs.getString("email"));
                out.println("Pass Hash Length: " + rs.getString("pass").length());
                out.println("Hash starts with: " + rs.getString("pass").substring(0, Math.min(10, rs.getString("pass").length())) + "...");
            } else {
                out.println("\nWARNING: No records found in 'admin' table!");
            }
            rs.close();
            stmt.close();
        } else {
            out.println("Status: FAILED \u274C");
            out.println("Connection object is null or closed.");
        }
    } catch (Exception e) {
        out.println("Status: ERROR \u274C");
        out.println("Exception: " + e.getMessage());
    } finally {
        if (con != null) {
            try { con.close(); } catch(Exception e){}
        }
    }
%>
                    </div>
                </div>
            </div>
        </div>

    </div>
</body>
</html>
