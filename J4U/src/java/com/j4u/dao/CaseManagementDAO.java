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

public class CaseManagementDAO {

    /**
     * Retrieves all unassigned cases for the Admin to allot.
     */
    public List<Map<String, Object>> getUnassignedCases() throws SQLException {
        List<Map<String, Object>> cases = new ArrayList<>();
        String query = "SELECT cid, cname, title, des, curdate, courttype, city, mop, tid, amt, name FROM casetb WHERE flag = 0";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> caseData = new HashMap<>();
                caseData.put("id", rs.getInt("cid"));
                caseData.put("customerName", rs.getString("cname"));
                caseData.put("title", rs.getString("title"));
                caseData.put("description", rs.getString("des"));
                caseData.put("date", rs.getString("curdate"));
                caseData.put("courtType", rs.getString("courttype"));
                caseData.put("city", rs.getString("city"));
                caseData.put("paymentMode", rs.getString("mop"));
                caseData.put("txnId", rs.getString("tid"));
                caseData.put("amount", rs.getString("amt"));
                caseData.put("email", rs.getString("name"));
                cases.add(caseData);
            }
        }
        return cases;
    }
}
