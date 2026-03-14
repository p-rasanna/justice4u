<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>J4U · Schema Migration</title>
    <style>
        body { font-family: 'Inter', sans-serif; background: #FAFAF8; padding: 40px; color: #121212; }
        .log { background: #fff; border: 1px solid #E6E6E6; border-radius: 12px; padding: 20px; font-family: monospace; }
        .success { color: #059669; }
        .error { color: #DC2626; }
    </style>
</head>
<body>
    <h2>J4U Schema Migration: <code>intern_tasks</code> update</h2>
    <div class="log">
    <%
        try {
            Connection con = getDatabaseConnection();
            Statement stmt = con.createStatement();
            
            // 1. Check/Update intern_tasks
            out.println("Verifying 'intern_tasks' structure...<br/>");
            // Add assignment_id if missing (though dump says it exists)
            ResultSet rsCol = con.getMetaData().getColumns(null, null, "intern_tasks", "assignment_id");
            if (!rsCol.next()) {
                stmt.execute("ALTER TABLE intern_tasks ADD COLUMN assignment_id INT(11) AFTER task_id");
                out.println("<span class='success'>Added 'assignment_id' to 'intern_tasks'.</span><br/>");
            }
            rsCol.close();

            // 2. Check/Update intern_assignments
            out.println("Verifying 'intern_assignments' structure...<br/>");
            stmt.execute("CREATE TABLE IF NOT EXISTS intern_assignments (" +
                         "assignment_id INT AUTO_INCREMENT PRIMARY KEY, " +
                         "intern_email VARCHAR(200) NOT NULL, " +
                         "case_id INT NOT NULL, " +
                         "alid INT NOT NULL, " +
                         "status VARCHAR(50) DEFAULT 'ACTIVE', " +
                         "assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                         ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            
            // Ensure case_id exists in intern_assignments
            rsCol = con.getMetaData().getColumns(null, null, "intern_assignments", "case_id");
            if (!rsCol.next()) {
                stmt.execute("ALTER TABLE intern_assignments ADD COLUMN case_id INT NOT NULL AFTER intern_email");
                out.println("<span class='success'>Added 'case_id' to 'intern_assignments'.</span><br/>");
            }
            rsCol.close();

            // Ensure alid exists in intern_assignments (replacing assigned_by_lawyer_id if needed)
            rsCol = con.getMetaData().getColumns(null, null, "intern_assignments", "alid");
            if (!rsCol.next()) {
                stmt.execute("ALTER TABLE intern_assignments ADD COLUMN alid INT NOT NULL AFTER case_id");
                out.println("<span class='success'>Added 'alid' to 'intern_assignments'.</span><br/>");
            }
            rsCol.close();

            // Ensure assigned_by exists in intern_assignments
            rsCol = con.getMetaData().getColumns(null, null, "intern_assignments", "assigned_by");
            if (!rsCol.next()) {
                stmt.execute("ALTER TABLE intern_assignments ADD COLUMN assigned_by VARCHAR(200) AFTER alid");
                out.println("<span class='success'>Added 'assigned_by' to 'intern_assignments'.</span><br/>");
            }
            rsCol.close();
            
            stmt.close();
            con.close();
            out.println("<br/><span class='success'>Migration complete.</span>");
        } catch (Exception e) {
            out.println("<br/><span class='error'>Migration failed: " + e.getMessage() + "</span>");
            e.printStackTrace();
        }
    %>
    </div>
    <br/>
    <a href="Lawyerdashboard.jsp">Return to Workspace</a>
</body>
</html>
