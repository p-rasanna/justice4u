package com.j4u.dao;
import com.j4u.DatabaseConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
public class LawyerDashboardDAO {
  public int getLawyerIdByEmail(String email) throws SQLException, ClassNotFoundException {
    String query = "SELECT lid FROM lawyer_reg WHERE email = ?";
    try (Connection con = DatabaseConfig.getConnection();
        PreparedStatement ps = con.prepareStatement(query)) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return rs.getInt("lid");
        }
      }
    }
    return 0;
  }
  private String getLawyerEmailById(int lawyerId) throws SQLException, ClassNotFoundException {
    String query = "SELECT email FROM lawyer_reg WHERE lid = ?";
    try (Connection con = DatabaseConfig.getConnection();
        PreparedStatement ps = con.prepareStatement(query)) {
      ps.setInt(1, lawyerId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return rs.getString("email");
        }
      }
    }
    return null;
  }
  public List<Map<String, Object>> getPendingRequests(int lawyerId) throws SQLException, ClassNotFoundException {
    List<Map<String, Object>> requests = new ArrayList<>();
    String lawyerEmail = getLawyerEmailById(lawyerId);
    if (lawyerEmail == null)
      return requests;
    String query = "SELECT a.cid as case_id, a.title, a.name as cname, a.cname as email " +
        "FROM allotlawyer a JOIN casetb c ON a.cid = c.cid " +
        "WHERE a.lname = ? AND c.flag = 1 ORDER BY a.cid DESC";
    try (Connection con = DatabaseConfig.getConnection();
        PreparedStatement ps = con.prepareStatement(query)) {
      ps.setString(1, lawyerEmail);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String, Object> req = new HashMap<>();
          req.put("caseId", rs.getInt("case_id"));
          req.put("clientName", rs.getString("cname") != null ? rs.getString("cname") : "Unknown Client");
          req.put("title", rs.getString("title") != null ? rs.getString("title")
              : "Case Request #" + rs.getInt("case_id"));
          req.put("clientEmail", rs.getString("email"));
          req.put("status", "PENDING_LAWYER_CONFIRMATION");
          requests.add(req);
        }
      }
    }
    return requests;
  }
  public List<Map<String, Object>> getAssignedClients(int lawyerId, int limit) throws SQLException, ClassNotFoundException {
    List<Map<String, Object>> clients = new ArrayList<>();
    String lawyerEmail = getLawyerEmailById(lawyerId);
    if (lawyerEmail == null)
      return clients;
    String query = "SELECT a.cid as case_id, a.title, a.name as cname, cr.cid as client_id " +
        "FROM allotlawyer a " +
        "JOIN casetb c ON a.cid = c.cid " +
        "JOIN cust_reg cr ON a.cname = cr.email " +
        "WHERE a.lname = ? AND c.flag >= 1 ORDER BY a.cid DESC LIMIT ?";
    try (Connection con = DatabaseConfig.getConnection();
        PreparedStatement ps = con.prepareStatement(query)) {
      ps.setString(1, lawyerEmail);
      ps.setInt(2, limit);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String, Object> client = new HashMap<>();
          client.put("caseId", rs.getInt("case_id"));
          client.put("clientName", rs.getString("cname"));
          client.put("title", rs.getString("title") != null ? rs.getString("title") : "Case Details Pending");
          client.put("clientId", rs.getInt("client_id"));
          clients.add(client);
        }
      }
    }
    return clients;
  }
  public List<Map<String, Object>> getAssignedInterns(int lawyerId) throws SQLException, ClassNotFoundException {
    List<Map<String, Object>> interns = new ArrayList<>();
    String query = "SELECT DISTINCT i.name, i.email, ia.status " +
        "FROM intern i " +
        "JOIN intern_assignments ia ON i.email = ia.intern_email " +
        "WHERE ia.alid = ? AND ia.status = 'ACTIVE'";
    try (Connection con = DatabaseConfig.getConnection();
        PreparedStatement ps = con.prepareStatement(query)) {
      ps.setInt(1, lawyerId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String, Object> intern = new HashMap<>();
          intern.put("name", rs.getString("name"));
          intern.put("email", rs.getString("email"));
          intern.put("status", rs.getString("status"));
          interns.add(intern);
        }
      }
    }
    return interns;
  }
  public List<Map<String, Object>> getPendingInternWork(int lawyerId) throws SQLException, ClassNotFoundException {
    List<Map<String, Object>> work = new ArrayList<>();
    String query = "SELECT it.title as file_name, it.created_at as uploaded_at, i.name as intern_name, c.title as case_title "
        +
        "FROM intern_tasks it " +
        "JOIN intern_assignments ia ON it.assignment_id = ia.assignment_id " +
        "JOIN intern i ON ia.intern_email = i.email " +
        "JOIN casetb c ON ia.case_id = c.cid " +
        "WHERE ia.alid = ? AND it.status = 'PENDING' " +
        "ORDER BY it.created_at DESC LIMIT 5";
    try (Connection con = DatabaseConfig.getConnection();
        PreparedStatement ps = con.prepareStatement(query)) {
      ps.setInt(1, lawyerId);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String, Object> item = new HashMap<>();
          item.put("fileName", rs.getString("file_name"));
          item.put("uploadedAt", rs.getString("uploaded_at"));
          item.put("internName", rs.getString("intern_name"));
          item.put("caseTitle", rs.getString("case_title"));
          work.add(item);
        }
      }
    }
    return work;
  }
}