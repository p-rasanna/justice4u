<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
    String lEmail = (String) session.getAttribute("lname");
    if (lEmail == null) {
        response.sendRedirect("../auth/Lawyer_login_form.jsp?error=Session expired");
        return;
    }
    String alidStr = request.getParameter("alid");
    if (alidStr == null) { response.sendRedirect("viewcases.jsp?msg=Invalid request"); return; }
    int alid = Integer.parseInt(alidStr);

    Connection con = null;
    try {
        con = DatabaseConfig.getConnection();
        PreparedStatement pst;

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

        // Update allotlawyer
        pst = con.prepareStatement("UPDATE allotlawyer SET status='Rejected' WHERE alid=?");
        pst.setInt(1, alid); pst.executeUpdate(); pst.close();

        // Reset casetb to OPEN
        try {
            pst = con.prepareStatement("UPDATE casetb SET status='OPEN' WHERE cname=? AND title=?");
            pst.setString(1, clientEmail); pst.setString(2, caseTitle);
            pst.executeUpdate(); pst.close();
        } catch (Exception ignored) {}

        // Timeline
        try {
            pst = con.prepareStatement(
                "INSERT INTO case_timeline (alid, event_type, event_description, created_by) VALUES (?,?,?,?)");
            pst.setInt(1, alid);
            pst.setString(2, "CASE_REJECTED");
            pst.setString(3, "Lawyer " + lEmail + " declined this case. Admin will re-assign.");
            pst.setString(4, lEmail);
            pst.executeUpdate(); pst.close();
        } catch (Exception ignored) {}

        // Notify client
        try {
            pst = con.prepareStatement(
                "INSERT INTO notifications (user_email, user_role, message) VALUES (?,?,?)");
            pst.setString(1, clientEmail);
            pst.setString(2, "client");
            pst.setString(3, "Your case '" + caseTitle + "' was declined by the assigned lawyer. Admin will assign a new lawyer soon.");
            pst.executeUpdate(); pst.close();
        } catch (Exception ignored) {}

        response.sendRedirect("Lawyerdashboard.jsp?msg=Case rejected. Admin will be notified.");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewcases.jsp?msg=Error: " + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } finally {
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }
%>
