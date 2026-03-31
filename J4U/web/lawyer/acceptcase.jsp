<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
    String lEmail = (String) session.getAttribute("lname");
    if (lEmail == null) {
        response.sendRedirect("../auth/Lawyer_login.html?error=Session expired");
        return;
    }
    String alidStr = request.getParameter("alid");
    if (alidStr == null) { response.sendRedirect("viewcases.jsp?msg=Invalid request"); return; }
    int alid = Integer.parseInt(alidStr);

    Connection con = null;
    try {
        con = DatabaseConfig.getConnection();
        PreparedStatement pst;

        // Verify this case belongs to this lawyer
        pst = con.prepareStatement("SELECT cname, title FROM allotlawyer WHERE alid=? AND lname=?");
        pst.setInt(1, alid); pst.setString(2, lEmail);
        ResultSet rs = pst.executeQuery();
        if (!rs.next()) {
            response.sendRedirect("viewcases.jsp?msg=Case not found or unauthorized");
            return;
        }
        String clientEmail = rs.getString("cname");
        String caseTitle = rs.getString("title");
        rs.close(); pst.close();

        // Update allotlawyer status
        pst = con.prepareStatement("UPDATE allotlawyer SET status='Accepted' WHERE alid=?");
        pst.setInt(1, alid); pst.executeUpdate(); pst.close();

        // Update casetb status (find by title + cname)
        try {
            pst = con.prepareStatement("UPDATE casetb SET status='IN_PROGRESS' WHERE cname=? AND title=?");
            pst.setString(1, clientEmail); pst.setString(2, caseTitle);
            pst.executeUpdate(); pst.close();
        } catch (Exception ignored) {}

        // Insert case_timeline event
        try {
            pst = con.prepareStatement(
                "INSERT INTO case_timeline (alid, event_type, event_description, created_by) VALUES (?,?,?,?)");
            pst.setInt(1, alid);
            pst.setString(2, "CASE_ACCEPTED");
            pst.setString(3, "Lawyer " + lEmail + " accepted the case: " + caseTitle);
            pst.setString(4, lEmail);
            pst.executeUpdate(); pst.close();
        } catch (Exception ignored) {}

        // Notify client
        try {
            pst = con.prepareStatement(
                "INSERT INTO notifications (user_email, user_role, message) VALUES (?,?,?)");
            pst.setString(1, clientEmail);
            pst.setString(2, "client");
            pst.setString(3, "Your case '" + caseTitle + "' has been accepted by your assigned lawyer. Work has begun.");
            pst.executeUpdate(); pst.close();
        } catch (Exception ignored) {}

        response.sendRedirect("Lawyerdashboard.jsp?msg=Case accepted successfully!");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewcases.jsp?msg=Error: " + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } finally {
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }
%>
