
import java.sql.*;
import java.util.*;
import java.io.*;

public class SchemaDumper {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/j4u";
        String user = "root";
        String password = "";

        try (PrintWriter out = new PrintWriter("schema_dump.txt")) {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, password);
            DatabaseMetaData meta = con.getMetaData();

            out.println("--- All Tables ---");
            ResultSet tables = meta.getTables(null, null, "%", new String[] { "TABLE" });
            while (tables.next()) {
                out.println(tables.getString("TABLE_NAME"));
            }

            String[] targetTables = { "customer_cases", "casetb", "lawyer_reg", "payments", "documents", "milestones",
                    "chat", "case_milestones", "case_documents", "case_chats", "messages" };

            for (String tbl : targetTables) {
                out.println("\n--- Columns for " + tbl + " ---");
                ResultSet columns = meta.getColumns(null, null, tbl, null);
                boolean found = false;
                while (columns.next()) {
                    found = true;
                    out.println(columns.getString("COLUMN_NAME") + " (" + columns.getString("TYPE_NAME") + ")");
                }
                if (!found)
                    out.println("(Table not found)");
            }

            con.close();
            System.out.println("Done writing to schema_dump.txt");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
