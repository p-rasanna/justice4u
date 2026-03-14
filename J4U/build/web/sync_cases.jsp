<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="db_connection.jsp" %>
<html>
<body>
<h2>Syncing Missing Cases</h2>
<%
    Connection con = getDatabaseConnection();
    try {
        // 1. Find cases in casetb that are NOT in customer_cases
        String findMissingSql = "SELECT c.cid, c.cname, c.title, c.des FROM casetb c " +
                                "LEFT JOIN customer_cases cc ON c.cid = cc.case_id " +
                                "WHERE cc.case_id IS NULL";
        
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery(findMissingSql);
        
        int syncedCount = 0;
        
        PreparedStatement insertPs = con.prepareStatement(
            "INSERT INTO customer_cases (case_id, customer_id, status, title, description, case_type_id) " +
            "VALUES (?, ?, 'OPEN', ?, ?, 9)" // Default type 9 (Other)
        );
        
        PreparedStatement getCustIdPs = con.prepareStatement("SELECT cid FROM cust_reg WHERE email = ?");

        while (rs.next()) {
            int caseId = rs.getInt("cid");
            String email = rs.getString("cname");
            String title = rs.getString("title");
            String desc = rs.getString("des");
            
            // Get Customer ID
            int custId = -1;
            getCustIdPs.setString(1, email);
            ResultSet rsCust = getCustIdPs.executeQuery();
            if (rsCust.next()) {
                custId = rsCust.getInt("cid");
            }
            rsCust.close();
            
            if (custId != -1) {
                insertPs.setInt(1, caseId);
                insertPs.setInt(2, custId);
                insertPs.setString(3, title != null ? title : "Untitled Case");
                insertPs.setString(4, desc != null ? desc : "");
                
                insertPs.executeUpdate();
                out.println("Synced Case #" + caseId + " for User ID " + custId + "<br/>");
                syncedCount++;
            } else {
                out.println("Skipped Case #" + caseId + " (User email " + email + " not found in cust_reg)<br/>");
            }
        }
        
        if (syncedCount == 0) {
            out.println("All cases are already synced.<br/>");
        } else {
            out.println("<b>Successfully synced " + syncedCount + " cases.</b><br/>");
        }
        
        con.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
<br/>
<a href="clientdashboard_manual.jsp">Return to Dashboard</a>
</body>
</html>
