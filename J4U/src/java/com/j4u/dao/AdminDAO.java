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

public class AdminDAO {

    public Map<String, Integer> getDashboardMetrics() throws SQLException {
        Map<String, Integer> metrics = new HashMap<>();

        String queryClients = "SELECT COUNT(*) FROM cust_reg";
        String queryVerifyQueue = "SELECT COUNT(*) FROM cust_reg WHERE verification_status='PENDING'";
        String queryPendingMatches = "SELECT COUNT(*) FROM customer_cases WHERE status='PENDING_LAWYER_CONFIRMATION'";
        String queryLawyerReqs = "SELECT COUNT(*) FROM lawyer_reg WHERE flag=0";
        String queryDocVerify = "SELECT COUNT(DISTINCT lawyer_id) FROM lawyer_documents WHERE status='PENDING'";
        String queryInternApps = "SELECT COUNT(*) FROM intern WHERE flag=0";

        try (Connection con = DatabaseConfig.getConnection()) {
            metrics.put("totalClients", executeCountQuery(con, queryClients));
            metrics.put("verifyQueue", executeCountQuery(con, queryVerifyQueue));
            metrics.put("pendingMatches", executeCountQuery(con, queryPendingMatches));
            metrics.put("lawyerRequests", executeCountQuery(con, queryLawyerReqs));
            metrics.put("docVerification", executeCountQuery(con, queryDocVerify));
            metrics.put("internApps", executeCountQuery(con, queryInternApps));
        }
        return metrics;
    }

    private int executeCountQuery(Connection con, String query) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public List<Map<String, Object>> getPendingClients(int limit) throws SQLException {
        List<Map<String, Object>> clients = new ArrayList<>();
        String query = "SELECT cid, cname, email, mobno FROM cust_reg WHERE verification_status='PENDING' ORDER BY cid DESC LIMIT ?";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> client = new HashMap<>();
                    client.put("id", rs.getInt("cid"));
                    client.put("name", rs.getString("cname"));
                    client.put("email", rs.getString("email"));
                    client.put("mobile", rs.getString("mobno"));
                    client.put("registrationDate", "N/A"); // Default since column doesn't exist
                    clients.add(client);
                }
            }
        }
        return clients;
    }
}
