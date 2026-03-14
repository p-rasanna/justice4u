<%@page import="java.sql.*"%>
<%@include file="db_connection.jsp"%>
<%!
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
        
        // 1. Intern Profiles
        String sql1 = "CREATE TABLE IF NOT EXISTS intern_profiles (" +
                "profile_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "intern_email VARCHAR(200) NOT NULL, " +
                "college_name VARCHAR(255), " +
                "degree_program VARCHAR(100), " +
                "current_year VARCHAR(50), " +
                "student_id_number VARCHAR(100), " +
                "areas_of_interest TEXT, " +
                "skills TEXT, " +
                "preferred_city VARCHAR(100), " +
                "availability_duration VARCHAR(50), " +
                "internship_mode VARCHAR(50), " +
                "id_card_front_path VARCHAR(255), " +
                "id_card_back_path VARCHAR(255), " +
                "bonafide_cert_path VARCHAR(255), " +
                "verification_status VARCHAR(50) DEFAULT 'UNVERIFIED', " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "INDEX (intern_email)" +
                // "FOREIGN KEY (intern_email) REFERENCES intern(email) ON DELETE CASCADE" + // Optional: strict FK
                ")";
        
        // 2. Intern Assignments
        String sql2 = "CREATE TABLE IF NOT EXISTS intern_assignments (" +
                "assignment_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "intern_email VARCHAR(200) NOT NULL, " +
                "case_id INT NOT NULL, " +
                "assigned_by_lawyer_id INT NOT NULL, " +
                "assignment_status VARCHAR(50) DEFAULT 'ACTIVE', " +
                "assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "INDEX (intern_email), " +
                "INDEX (case_id)" +
                ")";

        // 3. Case Documents (Proper table for case-specific files)
        String sql3 = "CREATE TABLE IF NOT EXISTS case_documents (" +
                "doc_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "case_id INT NOT NULL, " +
                "uploader_email VARCHAR(200) NOT NULL, " +
                "uploader_role VARCHAR(50) NOT NULL, " + // 'lawyer', 'client', 'intern'
                "file_name VARCHAR(255) NOT NULL, " +
                "file_path VARCHAR(255) NOT NULL, " +
                "uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "INDEX (case_id)" +
                ")";

        String result1 = executeUpdate(con, sql1);
        String result2 = executeUpdate(con, sql2);
        String result3 = executeUpdate(con, sql3);
        
        out.println("Intern Profiles: " + result1 + "<br>");
        out.println("Intern Assignments: " + result2 + "<br>");
        out.println("Case Documents: " + result3 + "<br>");
        
    } catch (Exception e) {
        out.println("General Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    } finally {
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>
