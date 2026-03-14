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

public class InternDashboardDAO {

    public int getAssignedCasesCount(String internEmail) throws SQLException {
        String query = "SELECT COUNT(*) FROM intern_assignments WHERE intern_email = ? AND status='ACTIVE'";
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, internEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getPendingTasksCount(String internEmail) {
        String query = "SELECT COUNT(*) FROM intern_tasks it " +
                "JOIN intern_assignments ia ON it.assignment_id = ia.assignment_id " +
                "WHERE ia.intern_email = ? AND it.status='PENDING'";
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, internEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            return 0;
        }
        return 0;
    }

    public List<Map<String, Object>> getAssignedCasesList(String internEmail) throws SQLException {
        List<Map<String, Object>> cases = new ArrayList<>();
        String query = "SELECT c.cid, c.title, c.courttype, l.name as lname " +
                "FROM intern_assignments ia " +
                "JOIN casetb c ON ia.case_id = c.cid " +
                "JOIN lawyer_reg l ON ia.alid = l.lid " +
                "WHERE ia.intern_email = ? AND ia.status = 'ACTIVE'";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, internEmail);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> c = new HashMap<>();
                    c.put("caseId", rs.getInt("cid"));
                    c.put("title", rs.getString("title"));
                    c.put("courtType", rs.getString("courttype"));
                    c.put("lawyerName", rs.getString("lname"));
                    cases.add(c);
                }
            }
        }
        return cases;
    }

    public List<Map<String, Object>> getPendingTasksList(String internEmail) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String query = "SELECT it.task_id, it.title, it.due_date, it.status " +
                "FROM intern_tasks it " +
                "JOIN intern_assignments ia ON it.assignment_id = ia.assignment_id " +
                "WHERE ia.intern_email = ? AND it.status != 'COMPLETED' " +
                "ORDER BY it.due_date ASC LIMIT 5";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, internEmail);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> t = new HashMap<>();
                    t.put("title", rs.getString("title"));
                    t.put("dueDate", rs.getString("due_date"));
                    t.put("status", rs.getString("status"));
                    tasks.add(t);
                }
            }
        } catch (SQLException e) {
            // Log or handle
        }
        return tasks;
    }

    public List<Map<String, Object>> getActiveCasesForUpload(String internEmail) throws SQLException {
        List<Map<String, Object>> uploadCases = new ArrayList<>();
        String query = "SELECT ia.case_id, c.title FROM intern_assignments ia JOIN casetb c ON ia.case_id = c.cid WHERE ia.intern_email = ? AND ia.status='ACTIVE'";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, internEmail);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> uc = new HashMap<>();
                    uc.put("caseId", rs.getInt("case_id"));
                    uc.put("title", rs.getString("title"));
                    uploadCases.add(uc);
                }
            }
        }
        return uploadCases;
    }
}
