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

public class LawyerDAO {

    /**
     * Gets all unapproved lawyers along with their document verification status.
     */
    public List<Map<String, Object>> getPendingLawyers() throws SQLException {
        List<Map<String, Object>> lawyers = new ArrayList<>();
        String query = "SELECT l.lid, l.name, l.email, l.dob, l.phone, l.ano, l.cadd, l.padd, " +
                "l.mop, l.tid, l.amt, COALESCE(l.document_verification_status, 'PENDING') as doc_status " +
                "FROM lawyer_reg l WHERE l.flag = 0";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> lawyer = new HashMap<>();
                lawyer.put("id", rs.getInt("lid"));
                lawyer.put("name", rs.getString("name"));
                lawyer.put("email", rs.getString("email"));
                lawyer.put("dob", rs.getString("dob"));
                lawyer.put("mobile", rs.getString("phone"));
                lawyer.put("aadhar", rs.getString("ano"));
                lawyer.put("currentAddress", rs.getString("cadd"));
                lawyer.put("permanentAddress", rs.getString("padd"));
                lawyer.put("paymentMode", rs.getString("mop"));
                lawyer.put("txnId", rs.getString("tid"));
                lawyer.put("amount", rs.getString("amt"));
                lawyer.put("docStatus", rs.getString("doc_status"));
                lawyers.add(lawyer);
            }
        }
        return lawyers;
    }
}
