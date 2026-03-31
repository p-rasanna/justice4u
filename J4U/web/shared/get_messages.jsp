<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String myEmail = null;
    String myRole = null;
    if (session.getAttribute("cname") != null) { myEmail = (String) session.getAttribute("cname"); myRole = "client"; }
    else if (session.getAttribute("lname") != null) { myEmail = (String) session.getAttribute("lname"); myRole = "lawyer"; }
    else if (session.getAttribute("iname") != null) { myEmail = (String) session.getAttribute("iname"); myRole = "intern"; }
    else if (session.getAttribute("aname") != null) { myEmail = (String) session.getAttribute("aname"); myRole = "admin"; }

    if (myEmail == null) {
        out.print("[]");
        return;
    }

    String caseIdStr = request.getParameter("case_id");
    String lastIdStr = request.getParameter("last_id");
    
    if (caseIdStr == null || caseIdStr.trim().isEmpty()) {
        out.print("[]");
        return;
    }
    
    int caseId;
    int lastId = 0;
    try {
        caseId = Integer.parseInt(caseIdStr);
        if (lastIdStr != null && !lastIdStr.trim().isEmpty()) {
            lastId = Integer.parseInt(lastIdStr);
        }
    } catch (NumberFormatException e) {
        out.print("[]");
        return;
    }

    try (Connection con = DatabaseConfig.getConnection()) {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT id, sender_email, sender_role, message_text, timestamp FROM discussions WHERE case_id=? AND id>? ORDER BY timestamp ASC")) {
            ps.setInt(1, caseId);
            ps.setInt(2, lastId);
            try (ResultSet rs = ps.executeQuery()) {
                StringBuilder json = new StringBuilder("[");
                boolean first = true;
                SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
                while (rs.next()) {
                    if (!first) {
                        json.append(",");
                    }
                    json.append("{");
                    json.append("\"id\":").append(rs.getInt("id")).append(",");
                    json.append("\"sender\":\"").append(rs.getString("sender_email").replace("\"", "\\\"")).append("\",");
                    json.append("\"role\":\"").append(rs.getString("sender_role")).append("\",");
                    json.append("\"text\":\"").append(rs.getString("message_text").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "")).append("\",");
                    json.append("\"time\":\"").append(sdf.format(rs.getTimestamp("timestamp"))).append("\",");
                    json.append("\"isOwn\":").append(rs.getString("sender_email").equals(myEmail) ? "true" : "false");
                    json.append("}");
                    first = false;
                }
                json.append("]");
                out.print(json.toString());
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("[]");
    }
%>
