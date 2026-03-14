<%@page import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<!DOCTYPE html>
<html>
<head><title>Schema Check</title></head>
<body>
    <pre>
<%
    try {
        Connection con = getDatabaseConnection();
        DatabaseMetaData meta = con.getMetaData();
        
        // List all tables
        out.println("--- All Tables ---");
        ResultSet tables = meta.getTables(null, null, "%", new String[] {"TABLE"});
        while (tables.next()) {
            out.println(tables.getString("TABLE_NAME"));
        }
        
        String[] targetTables = {"customer_cases", "casetb", "lawyer_reg", "payments", "documents", "milestones", "chat"};
        
        for (String tbl : targetTables) {
            out.println("\n--- Columns for " + tbl + " ---");
            ResultSet columns = meta.getColumns(null, null, tbl, null);
            boolean found = false;
            while (columns.next()) {
                found = true;
                out.println(columns.getString("COLUMN_NAME") + " (" + columns.getString("TYPE_NAME") + ")");
            }
            if (!found) out.println("(Table not found)");
        }
        
        con.close();
    } catch (Exception e) {
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
    </pre>
</body>
</html>
