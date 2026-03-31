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

        String queryTotalCases = "SELECT COUNT(*) FROM customer_cases";
        String queryTotalLawyers = "SELECT COUNT(*) FROM lawyer_reg WHERE flag=1";
        String queryPendingLawyers = "SELECT COUNT(*) FROM lawyer_reg WHERE flag=0";
        String queryPendingClients = "SELECT COUNT(*) FROM cust_reg WHERE verification_status='PENDING'";

        try (Connection con = DatabaseConfig.getConnection()) {
            metrics.put("total_cases", executeCountQuery(con, queryTotalCases));
            metrics.put("total_lawyers", executeCountQuery(con, queryTotalLawyers));
            metrics.put("pending_lawyers", executeCountQuery(con, queryPendingLawyers));
            metrics.put("pending_clients", executeCountQuery(con, queryPendingClients));
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
                    client.put("cid", rs.getInt("cid"));
                    client.put("cname", rs.getString("cname"));
                    client.put("email", rs.getString("email"));
                    client.put("mobno", rs.getString("mobno"));
                    clients.add(client);
                }
            }
        }
        return clients;
    }
}
