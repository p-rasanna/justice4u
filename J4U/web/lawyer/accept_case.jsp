<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%
  String email = (String) session.getAttribute("lname");
  if (email == null) {
    response.sendRedirect("../auth/Login.jsp");
    return;
  }
  String caseIdStr = request.getParameter("case_id");
  String action = request.getParameter("action");
  if (caseIdStr == null || action == null) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
    return;
  }
  int caseId;
  try {
    caseId = Integer.parseInt(caseIdStr);
  } catch (NumberFormatException e) {
    response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
    return;
  }
  try (Connection con = DatabaseConfig.getConnection()) {
    String clientEmail = null;
    String caseTitle = null;
    String customerName = null;
    String description = null;
    String courtType = null;
    String city = null;
    String curdate = null;
    String mop = null;
    String tid = null;
    String amt = null;
    try (PreparedStatement ps = con.prepareStatement("SELECT c.cname as client_email, c.title, c.name, c.des, c.courttype, c.city, c.curdate, c.mop, c.tid, c.amt FROM casetb c WHERE c.cid=?")) {
      ps.setInt(1, caseId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          clientEmail = rs.getString("client_email");
          caseTitle = rs.getString("title");
          customerName = rs.getString("name");
          description = rs.getString("des");
          courtType = rs.getString("courttype");
          city = rs.getString("city");
          curdate = rs.getString("curdate");
          mop = rs.getString("mop");
          tid = rs.getString("tid");
          amt = rs.getString("amt");
        }
      }
    }
    if (clientEmail == null) {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Case+not+found");
      return;
    }
    if ("accept".equals(action)) {
      boolean hasAllotment = false;
      try (PreparedStatement ps = con.prepareStatement("SELECT alid FROM allotlawyer WHERE cid=? AND lname=?")) {
        ps.setInt(1, caseId);
        ps.setString(2, email);
        try (ResultSet rs = ps.executeQuery()) {
          hasAllotment = rs.next();
        }
      }
      if (!hasAllotment) {
        try (PreparedStatement ps = con.prepareStatement(
          "INSERT INTO allotlawyer (cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, lname) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)")) {
          ps.setInt(1, caseId);
          ps.setString(2, customerName != null ? customerName : "Unknown");
          ps.setString(3, caseTitle);
          ps.setString(4, description);
          ps.setString(5, curdate);
          ps.setString(6, courtType);
          ps.setString(7, city);
          ps.setString(8, mop != null ? mop : "N/A");
          ps.setString(9, tid != null ? tid : "N/A");
          ps.setString(10, amt != null ? amt : "0");
          ps.setString(11, clientEmail);
          ps.setString(12, email);
          ps.executeUpdate();
        }
      }
      try (PreparedStatement ps = con.prepareStatement("UPDATE casetb SET flag=1 WHERE cid=?")) {
        ps.setInt(1, caseId);
        ps.executeUpdate();
      }
      response.sendRedirect("Lawyerdashboard.jsp?msg=Case+accepted+successfully");
    } else if ("reject".equals(action)) {
      try (PreparedStatement ps = con.prepareStatement("UPDATE casetb SET status='PENDING', flag=0 WHERE cid=?")) {
        ps.setInt(1, caseId);
        ps.executeUpdate();
      }
      try (PreparedStatement ps = con.prepareStatement("DELETE FROM allotlawyer WHERE cid=?")) {
        ps.setInt(1, caseId);
        ps.executeUpdate();
      }
      response.sendRedirect("Lawyerdashboard.jsp?msg=Case+returned+to+queue");
    } else {
      response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid+request");
    }
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("Lawyerdashboard.jsp?msg=Server+error");
  }
%>