<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig" %>
<%
  String lawyerEmail = (String) session.getAttribute("lname");
  if (lawyerEmail == null) { response.sendRedirect("../auth/Lawyer_login.jsp"); return; }
  String requestIdStr = request.getParameter("request_id");
  String action       = request.getParameter("action"); // "accept" or "reject"
  if (requestIdStr == null || action == null) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request"); return;
  }
  int requestId;
  try { requestId = Integer.parseInt(requestIdStr); }
  catch (NumberFormatException e) { response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request"); return; }
  try (Connection con = DatabaseConfig.getConnection()) {
    int    caseId      = 0;
    String clientEmail = null;
    String reqLawyer   = null;
    String reqStatus   = null;
    try (PreparedStatement ps = con.prepareStatement(
        "SELECT case_id, client_email, lawyer_email, status FROM lawyer_requests WHERE request_id=?")) {
      ps.setInt(1, requestId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          caseId      = rs.getInt("case_id");
          clientEmail = rs.getString("client_email");
          reqLawyer   = rs.getString("lawyer_email");
          reqStatus   = rs.getString("status");
        }
      }
    }
    if (caseId == 0 || !"PENDING".equals(reqStatus)) {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Request+not+found+or+already+processed"); return;
    }
    if (!lawyerEmail.equals(reqLawyer)) {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Unauthorized"); return;
    }
    String caseTitle = "", caseName = "", caseDes = "", caseCourt = "",
         caseCity  = "", caseMop  = "N/A", caseTid  = "N/A", caseAmt = "0", caseDate = "";
    try (PreparedStatement ps = con.prepareStatement(
        "SELECT title, name, des, courttype, city, mop, tid, amt, curdate FROM casetb WHERE cid=?")) {
      ps.setInt(1, caseId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          caseTitle = rs.getString("title");
          caseName  = rs.getString("name") != null ? rs.getString("name") : "Client";
          caseDes   = rs.getString("des");
          caseCourt = rs.getString("courttype");
          caseCity  = rs.getString("city");
          caseMop   = rs.getString("mop") != null ? rs.getString("mop") : "N/A";
          caseTid   = rs.getString("tid") != null ? rs.getString("tid") : "N/A";
          caseAmt   = rs.getString("amt") != null ? rs.getString("amt") : "0";
          caseDate  = rs.getString("curdate") != null ? rs.getString("curdate") : "";
        }
      }
    }
    if ("accept".equals(action)) {
      try (PreparedStatement ps = con.prepareStatement(
          "UPDATE lawyer_requests SET status='ACCEPTED' WHERE request_id=?")) {
        ps.setInt(1, requestId); ps.executeUpdate();
      }
      try (PreparedStatement ps = con.prepareStatement(
          "UPDATE lawyer_requests SET status='CANCELLED' WHERE case_id=? AND status='PENDING'")) {
        ps.setInt(1, caseId); ps.executeUpdate();
      }
      try (PreparedStatement ps = con.prepareStatement(
          "INSERT INTO allotlawyer (cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, lname) " +
          "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")) {
        ps.setInt(1, caseId);
        ps.setString(2, caseName);
        ps.setString(3, caseTitle);
        ps.setString(4, caseDes);
        ps.setString(5, caseDate);
        ps.setString(6, caseCourt);
        ps.setString(7, caseCity);
        ps.setString(8, caseMop);
        ps.setString(9, caseTid);
        ps.setString(10, caseAmt);
        ps.setString(11, clientEmail);
        ps.setString(12, lawyerEmail);
        ps.executeUpdate();
      }
      try (PreparedStatement ps = con.prepareStatement(
          "UPDATE casetb SET flag=1, case_status='ACTIVE' WHERE cid=?")) {
        ps.setInt(1, caseId); ps.executeUpdate();
      }
      response.sendRedirect("Lawyerdashboard.jsp?msg=Case+accepted+successfully");
    } else if ("reject".equals(action)) {
      try (PreparedStatement ps = con.prepareStatement(
          "UPDATE lawyer_requests SET status='REJECTED' WHERE request_id=?")) {
        ps.setInt(1, requestId); ps.executeUpdate();
      }
      try (PreparedStatement ps = con.prepareStatement(
          "UPDATE casetb SET case_status='SEARCHING' WHERE cid=?")) {
        ps.setInt(1, caseId); ps.executeUpdate();
      }
      response.sendRedirect("Lawyerdashboard.jsp?msg=Request+declined");
    } else {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+action");
    }
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("Lawyerdashboard.jsp?msg=Server+error");
  }
%>