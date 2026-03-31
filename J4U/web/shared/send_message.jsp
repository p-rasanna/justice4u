<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%@ page import="com.j4u.NotificationService" %>
<%
    String senderEmail = null;
    String senderRole = null;
    
    if (session.getAttribute("cname") != null) {
        senderEmail = (String) session.getAttribute("cname");
        senderRole = "client";
    } else if (session.getAttribute("lname") != null) {
        senderEmail = (String) session.getAttribute("lname");
        senderRole = "lawyer";
    } else if (session.getAttribute("iname") != null) {
        senderEmail = (String) session.getAttribute("iname");
        senderRole = "intern";
    } else if (session.getAttribute("aname") != null) {
        senderEmail = (String) session.getAttribute("aname");
        senderRole = "admin";
    }
    
    if (senderEmail == null) {
        out.print("error: Unauthorized");
        return;
    }

    String caseIdStr = request.getParameter("case_id");
    String messageText = request.getParameter("message_text");
    String receiverEmail = request.getParameter("receiver_email");
    String receiverRole = request.getParameter("receiver_role");

    if (caseIdStr == null || messageText == null || messageText.trim().isEmpty()) {
        out.print("error: Missing parameters");
        return;
    }
    if (messageText.length() > 5000) {
        out.print("error: Message too long");
        return;
    }

    int caseId;
    try {
        caseId = Integer.parseInt(caseIdStr);
    } catch (NumberFormatException e) {
        out.print("error: Invalid case ID");
        return;
    }

    try (Connection con = DatabaseConfig.getConnection()) {
        if (receiverEmail == null || receiverEmail.trim().isEmpty()) {
            if ("client".equals(senderRole)) {
                try (PreparedStatement ps = con.prepareStatement("SELECT lname FROM allotlawyer WHERE cid=? LIMIT 1")) {
                    ps.setInt(1, caseId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            receiverEmail = rs.getString("lname");
                            receiverRole = "lawyer";
                        }
                    }
                }
            } else if ("lawyer".equals(senderRole)) {
                try (PreparedStatement ps = con.prepareStatement("SELECT cname FROM casetb WHERE cid=?")) {
                    ps.setInt(1, caseId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String cnameStr = rs.getString("cname");
                            // get client email from cust_reg if cname was name, or if cname IS email use it. Assuming cname is email from specs.
                            receiverEmail = cnameStr;
                            receiverRole = "client";
                        }
                    }
                }
            } else if ("intern".equals(senderRole)) {
                try (PreparedStatement ps = con.prepareStatement("SELECT lr.email FROM intern_assignments ia JOIN lawyer_reg lr ON ia.alid=lr.lid WHERE ia.intern_email=? AND ia.case_id=? LIMIT 1")) {
                    ps.setString(1, senderEmail);
                    ps.setInt(2, caseId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            receiverEmail = rs.getString("email");
                            receiverRole = "lawyer";
                        }
                    }
                }
            }
        }

        if (receiverEmail == null) {
            out.print("error: Receiver not found");
            return;
        }

        int messageId = -1;
        String insertSql = "INSERT INTO discussions (case_id, sender_email, sender_role, receiver_email, receiver_role, message_text) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, caseId);
            ps.setString(2, senderEmail);
            ps.setString(3, senderRole);
            ps.setString(4, receiverEmail);
            ps.setString(5, receiverRole);
            ps.setString(6, messageText);
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    messageId = rs.getInt(1);
                }
            }
        }

        if (messageId != -1) {
            String notifMsg = "";
            if ("client".equals(senderRole)) {
                notifMsg = "New message from your client on case #" + caseId;
            } else if ("lawyer".equals(senderRole)) {
                notifMsg = "Your lawyer sent a message on case #" + caseId;
            } else {
                notifMsg = "Intern message on case #" + caseId;
            }
            NotificationService.create(receiverEmail, notifMsg, "message", "../shared/chat.jsp?case_id=" + caseId);
            out.print("success:" + messageId);
        } else {
            out.print("error: Failed to insert message");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("error: Server error");
    }
%>
