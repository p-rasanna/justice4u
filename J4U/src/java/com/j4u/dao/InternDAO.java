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

public class InternDAO {

    /**
     * Gets all unapproved interns.
     */
    public List<Map<String, Object>> getPendingInterns() throws SQLException {
        List<Map<String, Object>> interns = new ArrayList<>();
        String query = "SELECT i.internid, i.name, i.email, i.dob, i.mobno, i.ano, i.cadd, i.padd, " +
                "i.mop, i.tid, i.amt " +
                "FROM intern i WHERE i.flag = 0";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> intern = new HashMap<>();
                intern.put("id", rs.getInt("internid"));
                intern.put("name", rs.getString("name"));
                intern.put("email", rs.getString("email"));
                intern.put("dob", rs.getString("dob"));
                intern.put("mobile", rs.getString("mobno"));
                intern.put("aadhar", rs.getString("ano"));
                intern.put("currentAddress", rs.getString("cadd"));
                intern.put("permanentAddress", rs.getString("padd"));
                intern.put("paymentMode", rs.getString("mop"));
                intern.put("txnId", rs.getString("tid"));
                intern.put("amount", rs.getString("amt"));
                interns.add(intern);
            }
        }
        return interns;
    }
}
