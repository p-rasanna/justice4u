<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, com.j4u.DatabaseConfig" %>
<%
  String clientEmail = (String) session.getAttribute("cname");
  if (clientEmail == null) { response.sendRedirect("../auth/cust_login.jsp"); return; }
  if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect("clientdashboard.jsp?msg=Invalid+request");
    return;
  }
  String caseIdStr   = request.getParameter("case_id");
  String lawyerEmail = request.getParameter("lawyer_email");
  if (caseIdStr == null || lawyerEmail == null || caseIdStr.trim().isEmpty() || lawyerEmail.trim().isEmpty()) {
    response.sendRedirect("clientdashboard.jsp?msg=Missing+parameters");
    return;
  }
  int caseId;
  try { caseId = Integer.parseInt(caseIdStr.trim()); }
  catch (NumberFormatException e) { response.sendRedirect("clientdashboard.jsp?msg=Invalid+case"); return; }
  try (Connection con = DatabaseConfig.getConnection()) {
    String caseStatus = null;
    String assignType = null;
    try (PreparedStatement ps = con.prepareStatement(
        "SELECT case_status, COALESCE(assignment_type,'ADMIN') as atype FROM casetb WHERE cid=? AND cname=?")) {
      ps.setInt(1, caseId);
      ps.setString(2, clientEmail);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          caseStatus = rs.getString("case_status");
          assignType = rs.getString("atype");
        }
      }
    }
    if (caseStatus == null) {
      response.sendRedirect("clientdashboard.jsp?msg=Case+not+found");
      return;
    }
    if (!"MANUAL".equalsIgnoreCase(assignType)) {
      response.sendRedirect("clientdashboard.jsp?msg=This+case+uses+admin+assignment");
      return;
    }
    if (!"SEARCHING".equalsIgnoreCase(caseStatus)) {
      response.sendRedirect("clientdashboard.jsp?msg=Request+already+pending+or+case+is+active");
      return;
    }
    boolean lawyerExists = false;
    try (PreparedStatement ps = con.prepareStatement(
        "SELECT email FROM lawyer_reg WHERE email=? AND (flag=1 OR document_verification_status='VERIFIED')")) {
      ps.setString(1, lawyerEmail);
      try (ResultSet rs = ps.executeQuery()) { lawyerExists = rs.next(); }
    }
    if (!lawyerExists) {
      response.sendRedirect("findlawyer.jsp?case_id=" + caseId + "&msg=Lawyer+not+found");
      return;
    }
    try (PreparedStatement ps = con.prepareStatement(
        "UPDATE lawyer_requests SET status='CANCELLED' WHERE case_id=? AND status='PENDING'")) {
      ps.setInt(1, caseId); ps.executeUpdate();
    }
    try (PreparedStatement ps = con.prepareStatement(
        "INSERT INTO lawyer_requests (case_id, client_email, lawyer_email, status) VALUES (?,?,?,'PENDING')")) {
      ps.setInt(1, caseId);
      ps.setString(2, clientEmail);
      ps.setString(3, lawyerEmail);
      ps.executeUpdate();
    }
    try (PreparedStatement ps = con.prepareStatement(
        "UPDATE casetb SET case_status='REQUESTED' WHERE cid=?")) {
      ps.setInt(1, caseId); ps.executeUpdate();
    }
    response.sendRedirect("clientdashboard.jsp?msg=Request+sent+successfully!+Waiting+for+lawyer+response.");
  } catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("clientdashboard.jsp?msg=Server+error:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
  }
%>