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

public class UserDAO {

    /**
     * Complete listing of registered clients for administration view.
     */
    public List<Map<String, Object>> getAllClients() throws SQLException {
        List<Map<String, Object>> clients = new ArrayList<>();
        String query = "SELECT cid, cname, email, verification_status, dob, mobno, ano, cadd, padd, COALESCE(profile_type, 'manual') AS profile_type FROM cust_reg";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> client = new HashMap<>();
                client.put("id", rs.getInt("cid"));
                client.put("name", rs.getString("cname"));
                client.put("email", rs.getString("email"));
                client.put("verificationStatus", rs.getString("verification_status"));
                client.put("profileType", rs.getString("profile_type"));
                client.put("dob", rs.getString("dob"));
                client.put("mobile", rs.getString("mobno"));
                client.put("aadhar", rs.getString("ano"));
                client.put("currentAddress", rs.getString("cadd"));
                client.put("permanentAddress", rs.getString("padd"));
                clients.add(client);
            }
        }
        return clients;
    }

    /**
     * Retrieves targeted Client identification data for email triggers.
     */
    public Map<String, Object> getClientById(int id) throws SQLException {
        String query = "SELECT cname, email FROM cust_reg WHERE cid = ?";
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> client = new HashMap<>();
                    client.put("name", rs.getString("cname"));
                    client.put("email", rs.getString("email"));
                    return client;
                }
            }
        }
        return null;
    }

    /**
     * Updates Client verification status atomically.
     */
    public boolean updateVerificationStatus(int id, String status) throws SQLException {
        String query = "UPDATE cust_reg SET verification_status = ? WHERE cid = ?";
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }
}
