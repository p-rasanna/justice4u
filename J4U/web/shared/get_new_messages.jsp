<%@page contentType="application/json" pageEncoding="UTF-8" import="java.sql.*, com.google.gson.*"%>
<%@include file="db_connection.jsp" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    String alid = request.getParameter("alid");
    String lastTimestamp = request.getParameter("last_timestamp");
    String mode = request.getParameter("mode"); // 'case_id' or 'alid' (default)
    // SECURE SESSION CHECK
    String sessionUser = null;
    String sessionRole = null;
    if (session.getAttribute("cname") != null) {
        sessionUser = (String) session.getAttribute("cname");
        sessionRole = "client";
    } else if (session.getAttribute("lname") != null) {
        sessionUser = (String) session.getAttribute("lname");
        sessionRole = "lawyer";
    } else if (session.getAttribute("iname") != null) {
        sessionUser = (String) session.getAttribute("iname");
        sessionRole = "intern";
    }
    if (sessionUser == null) {
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("error", "Unauthorized");
        out.print(errorResponse.toString());
        return;
    }
    // Validate required parameters
    if (alid == null) {
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("error", "Missing required parameters");
        out.print(errorResponse.toString());
        return;
    }
    JsonArray messages = new JsonArray();
    long latestTimestamp = 0;
    try {
        Connection con = getDatabaseConnection();
        int caseId = 0;
        if ("case_id".equals(mode)) {
            caseId = Integer.parseInt(alid); // Here alid param is actually identifying the case_id
        } else {
             // Get case_id from allotment
            PreparedStatement ps = con.prepareStatement("SELECT cid FROM allotlawyer WHERE alid = ?");
            ps.setInt(1, Integer.parseInt(alid));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                caseId = rs.getInt("cid");
            }
            rs.close(); 
            ps.close();
        }
        if (caseId == 0) {
             JsonObject errorResponse = new JsonObject();
             errorResponse.addProperty("error", "Invalid ID");
             out.print(errorResponse.toString());
             con.close();
             return;
        }
        // AUTHORIZATION CHECK
        boolean authorized = false;
        PreparedStatement psAuth = con.prepareStatement(
            "SELECT cc.customer_id, cc.assigned_lawyer_id, cr.email AS client_email, lr.email AS lawyer_email " +
            "FROM customer_cases cc " +
            "JOIN cust_reg cr ON cc.customer_id = cr.cid " +
            "LEFT JOIN lawyer_reg lr ON cc.assigned_lawyer_id = lr.lid " +
            "WHERE cc.case_id = ?"
        );
        psAuth.setInt(1, caseId);
        ResultSet rsAuth = psAuth.executeQuery();
        if (rsAuth.next()) {
            String clientEmail = rsAuth.getString("client_email");
            String lawyerEmail = rsAuth.getString("lawyer_email");
            if ("client".equals(sessionRole) && sessionUser.equals(clientEmail)) authorized = true;
            else if ("lawyer".equals(sessionRole) && sessionUser.equals(lawyerEmail)) authorized = true;
            else if ("intern".equals(sessionRole)) {
                 // Check intern assignment
                 PreparedStatement psI = con.prepareStatement("SELECT 1 FROM intern_assignments WHERE intern_email=? AND alid=(SELECT alid FROM allotlawyer WHERE cid=? LIMIT 1) AND status='ACTIVE'");
                 psI.setString(1, sessionUser);
                 psI.setInt(2, caseId);
                 ResultSet rsI = psI.executeQuery();
                 if (rsI.next()) authorized = true;
                 rsI.close(); psI.close();
            }
        }
        rsAuth.close(); psAuth.close();
        if (!authorized) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("error", "Unauthorized access to this case messages");
            out.print(errorResponse.toString());
            con.close();
            return;
        }
        // Get new messages since last timestamp
        // we use > timestamp logic.
        // Assuming timestamp column is TIMESTAMP.
        // Get new messages since last timestamp
        // we use > timestamp logic.
        // Assuming timestamp column is TIMESTAMP/DATETIME.
        String query = "SELECT sender_email, sender_role, message_text, timestamp FROM discussions " +
                      "WHERE case_id = ? AND timestamp > FROM_UNIXTIME(?/1000) " +
                      "ORDER BY timestamp ASC";
        PreparedStatement ps2 = con.prepareStatement(query);
        ps2.setInt(1, caseId);
        ps2.setLong(2, Long.parseLong(lastTimestamp));
        ResultSet rs2 = ps2.executeQuery();
        while (rs2.next()) {
            JsonObject message = new JsonObject();
            message.addProperty("sender_email", rs2.getString("sender_email"));
            message.addProperty("sender_role", rs2.getString("sender_role"));
            message.addProperty("message_text", rs2.getString("message_text"));
            message.addProperty("timestamp", rs2.getString("timestamp"));
            messages.add(message);
            // Track the latest timestamp
            java.sql.Timestamp ts = rs2.getTimestamp("timestamp");
            if (ts != null) {
                latestTimestamp = Math.max(latestTimestamp, ts.getTime());
            }
        }
        rs2.close();
        ps2.close();
        con.close();
    } catch (Exception e) {
        // Log error
        System.err.println("Error in get_new_messages.jsp: " + e.getMessage());
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("error", "Internal server error: " + e.getMessage());
        out.print(errorResponse.toString());
        return;
    }
    JsonObject responseJson = new JsonObject();
    responseJson.add("messages", messages);
    responseJson.addProperty("lastTimestamp", String.valueOf(latestTimestamp));
    out.print(responseJson.toString());
%>
