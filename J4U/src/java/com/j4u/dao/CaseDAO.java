package com.j4u.dao;
import com.j4u.DatabaseConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
public class CaseDAO {
  public List<Map<String, Object>> getCasesByClientEmail(String email) throws SQLException {
    List<Map<String, Object>> cases = new ArrayList<>();
    String query = "SELECT c.cid, c.title, c.des, c.curdate, c.courttype, c.city, c.amt, c.mop, " +
        "COALESCE(cc.status, 'OPEN') as real_status " +
        "FROM casetb c " +
        "LEFT JOIN customer_cases cc ON c.cid = cc.case_id " +
        "WHERE c.cname = ? ORDER BY c.cid DESC";
    try (Connection con = DatabaseConfig.getConnection();
        PreparedStatement ps = con.prepareStatement(query)) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Map<String, Object> caseData = new HashMap<>();
          caseData.put("id", rs.getInt("cid"));
          caseData.put("title", rs.getString("title"));
          caseData.put("description", rs.getString("des"));
          caseData.put("date", rs.getString("curdate"));
          caseData.put("courtType", rs.getString("courttype"));
          caseData.put("city", rs.getString("city"));
          caseData.put("amount", rs.getString("amt"));
          caseData.put("paymentMode", rs.getString("mop"));
          caseData.put("status", rs.getString("real_status"));
          cases.add(caseData);
        }
      }
    }
    return cases;
  }
}