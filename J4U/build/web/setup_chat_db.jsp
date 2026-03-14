<%@page import="java.sql.*"%>
<%@include file="db_connection.jsp"%>
<%!
    // Helper method to execute update
    public String executeUpdate(Connection con, String sql) {
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(sql);
            return "SUCCESS";
        } catch (SQLException e) {
            return "ERROR: " + e.getMessage();
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        }
    }
%>
<%
    Connection con = null;
    try {
        con = getDatabaseConnection();
        
        // Create discussions table
        String createTableSQL = "CREATE TABLE IF NOT EXISTS discussions (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                "case_id INT NOT NULL, " +
                "sender_email VARCHAR(255) NOT NULL, " +
                "sender_role VARCHAR(20) NOT NULL, " + // 'client' or 'lawyer'
                "receiver_email VARCHAR(255) NOT NULL, " +
                "receiver_role VARCHAR(20) NOT NULL, " +
                "message_text TEXT NOT NULL, " +
                "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "INDEX (case_id), " +
                "INDEX (timestamp) " +
                ")";
        
        String result = executeUpdate(con, createTableSQL);
        out.println("Table Creation Result: " + result + "<br>");
        
    } catch (Exception e) {
        out.println("General Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>
