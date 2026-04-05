<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String lEmail = (String) session.getAttribute("lname");
  if (lEmail == null) {
    response.sendRedirect("../auth/Login.jsp");
    return;
  }
  String act = request.getParameter("action");
  String iEmail = request.getParameter("intern_email");
  String lIdS = request.getParameter("lawyer_id");
  String msg = "";
  String target = "../admin/viewinterns.jsp";
  try (Connection con = DatabaseConfig.getConnection()) {
    int lid = Integer.parseInt(lIdS);
    if ("assign_case".equals(act)) {
      int cid = Integer.parseInt(request.getParameter("case_id"));
      PreparedStatement psAlid = con.prepareStatement("SELECT alid FROM allotlawyer WHERE cid = ? AND lname = ?");
      psAlid.setInt(1, cid);
      psAlid.setString(2, lEmail);
      ResultSet rsAlid = psAlid.executeQuery();
      int alid = 0;
      if (rsAlid.next()) {
        alid = rsAlid.getInt(1);
      }
      if (alid > 0) {
        PreparedStatement ps = con.prepareStatement(
          "INSERT INTO intern_assignments (intern_email, case_id, alid, assigned_by, status) " +
          "SELECT ?, ?, ?, ?, 'ACTIVE' FROM DUAL " +
          "WHERE NOT EXISTS (SELECT 1 FROM intern_assignments WHERE intern_email = ? AND case_id = ?)"
        );
        ps.setString(1, iEmail);
        ps.setInt(2, cid);
        ps.setInt(3, alid);
        ps.setString(4, lEmail);
        ps.setString(5, iEmail);
        ps.setInt(6, cid);
        ps.executeUpdate();
        msg = "Case delegated successfully.";
      } else {
        msg = "Error: Could not find case allocation.";
      }
    } else if ("assign_task".equals(act)) {
      int cid = Integer.parseInt(request.getParameter("case_id"));
      PreparedStatement ps = con.prepareStatement(
        "SELECT ia.assignment_id, al.alid FROM intern_assignments ia " +
        "JOIN allotlawyer al ON ia.alid = al.alid " +
        "WHERE ia.intern_email = ? AND al.cid = ?"
      );
      ps.setString(1, iEmail);
      ps.setInt(2, cid);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        int assignmentId = rs.getInt(1);
        int caseAlid = rs.getInt(2);
        PreparedStatement pi = con.prepareStatement(
          "INSERT INTO intern_tasks (assignment_id, title, due_date, status, intern_email, case_alid, assigned_by_lawyer_id) " +
          "VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        pi.setInt(1, assignmentId);
        pi.setString(2, request.getParameter("title"));
        pi.setString(3, request.getParameter("due_date"));
        pi.setString(4, "PENDING");
        pi.setString(5, iEmail);
        pi.setInt(6, caseAlid);
        pi.setInt(7, lid);
        pi.executeUpdate();
        msg = "Task assigned successfully.";
      } else {
        msg = "Error: Intern not assigned to this case context.";
      }
    }
  } catch (Exception e) {
    msg = "Error: " + e.getMessage();
    e.printStackTrace();
  }
  response.sendRedirect(target + "?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
%>