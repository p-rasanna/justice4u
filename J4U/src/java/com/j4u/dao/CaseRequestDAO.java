package com.j4u.dao;

import com.j4u.DatabaseConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class CaseRequestDAO {

    /**
     * Gets customer ID and Name by email.
     * Returns an array where [0] is Integer (ID) and [1] is String (Name), or null
     * if not found.
     */
    public Object[] getCustomerByEmail(String email) throws SQLException {
        // Fixed: column is 'cname' in cust_reg, not 'name'
        String query = "SELECT cid, cname FROM cust_reg WHERE email = ?";
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String customerName = rs.getString("cname");
                    // Null-safe fallback: use email prefix if name is null/blank
                    if (customerName == null || customerName.trim().isEmpty()) {
                        customerName = email.contains("@") ? email.substring(0, email.indexOf('@')) : email;
                    }
                    return new Object[] { rs.getInt("cid"), customerName };
                }
            }
        }
        return null;
    }

    /**
     * Gets lawyer ID by email.
     */
    public int getLawyerIdByEmail(String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return 0;
        }
        String query = "SELECT lid FROM lawyer_reg WHERE email = ?";
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("lid");
                }
            }
        }
        return 0;
    }

    /**
     * Creates a new case in casetb.
     */
    public int createCase(String email, String customerName, String title, String fullDescription,
            String curDate, String courtType, String city, String paymentMode,
            String transactionId, String amount) throws SQLException {

        String insertCaseSql = "INSERT INTO casetb (cname, name, title, des, curdate, courttype, city, mop, tid, amt, flag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)";

        try (Connection con = DatabaseConfig.getConnection()) {
            try (PreparedStatement psCase = con.prepareStatement(insertCaseSql, Statement.RETURN_GENERATED_KEYS)) {
                psCase.setString(1, email);
                psCase.setString(2, customerName);
                psCase.setString(3, title);
                psCase.setString(4, fullDescription);
                psCase.setString(5, curDate);
                psCase.setString(6, courtType);
                psCase.setString(7, city);
                psCase.setString(8, paymentMode);
                psCase.setString(9, transactionId);
                psCase.setString(10, amount);

                int rowAffected = psCase.executeUpdate();
                if (rowAffected > 0) {
                    try (ResultSet rsKeys = psCase.getGeneratedKeys()) {
                        if (rsKeys.next()) {
                            return rsKeys.getInt(1);
                        }
                    }
                }
            } catch (SQLException e) {
                String errMsg = e.getMessage().toLowerCase();
                if (errMsg.contains("unknown column") && errMsg.contains("cname")) {
                    // Auto-fix schema drift if column cname does not exist
                    try (Statement stFix = con.createStatement()) {
                        stFix.executeUpdate(
                                "ALTER TABLE casetb ADD COLUMN cname VARCHAR(200) NOT NULL DEFAULT 'unknown' AFTER cid");
                    } catch (Exception ex) {
                        // ignore drift fix error
                    }
                    // Retry insertion
                    try (PreparedStatement psRetry = con.prepareStatement(insertCaseSql,
                            Statement.RETURN_GENERATED_KEYS)) {
                        psRetry.setString(1, email);
                        psRetry.setString(2, customerName);
                        psRetry.setString(3, title);
                        psRetry.setString(4, fullDescription);
                        psRetry.setString(5, curDate);
                        psRetry.setString(6, courtType);
                        psRetry.setString(7, city);
                        psRetry.setString(8, paymentMode);
                        psRetry.setString(9, transactionId);
                        psRetry.setString(10, amount);

                        if (psRetry.executeUpdate() > 0) {
                            try (ResultSet rsKeys = psRetry.getGeneratedKeys()) {
                                if (rsKeys.next()) {
                                    return rsKeys.getInt(1);
                                }
                            }
                        }
                    }
                } else {
                    throw e;
                }
            }
        }
        return 0;
    }

    /**
     * Links case to the customer_cases tracking table.
     */
    public boolean linkCaseToCustomer(int caseId, int customerId, int assignedLawyerId, String status,
            String title, int caseTypeId, String description) throws SQLException {

        String insertCustCaseSql;
        if (assignedLawyerId > 0) {
            insertCustCaseSql = "INSERT INTO customer_cases (case_id, customer_id, assigned_lawyer_id, status, title, case_type_id, description) VALUES (?, ?, ?, ?, ?, ?, ?)";
        } else {
            insertCustCaseSql = "INSERT INTO customer_cases (case_id, customer_id, status, title, case_type_id, description) VALUES (?, ?, ?, ?, ?, ?)";
        }

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement psCC = con.prepareStatement(insertCustCaseSql)) {

            psCC.setInt(1, caseId);
            psCC.setInt(2, customerId);

            int paramIndex = 3;
            if (assignedLawyerId > 0) {
                psCC.setInt(paramIndex++, assignedLawyerId);
            }

            psCC.setString(paramIndex++, status);
            psCC.setString(paramIndex++, title);
            psCC.setInt(paramIndex++, caseTypeId);
            psCC.setString(paramIndex++, description);

            return psCC.executeUpdate() > 0;
        }
    }

    /**
     * Bridges to the legacy allotlawyer table to ensure timeline/hearings work.
     */
    public boolean syncToAllotLawyer(int caseId, String lawyerEmail) throws SQLException {
        if (lawyerEmail == null || lawyerEmail.trim().isEmpty())
            return false;

        String checkSql = "SELECT 1 FROM allotlawyer WHERE cid = ?";
        String insertSql = "INSERT INTO allotlawyer (cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, lname) "
                +
                "SELECT cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, ? FROM casetb WHERE cid = ?";
        String updateSql = "UPDATE allotlawyer SET lname = ? WHERE cid = ?";

        try (Connection con = DatabaseConfig.getConnection()) {
            // Check if already exists
            try (PreparedStatement psCheck = con.prepareStatement(checkSql)) {
                psCheck.setInt(1, caseId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        // Update existing
                        try (PreparedStatement psUpdate = con.prepareStatement(updateSql)) {
                            psUpdate.setString(1, lawyerEmail);
                            psUpdate.setInt(2, caseId);
                            return psUpdate.executeUpdate() > 0;
                        }
                    } else {
                        // Insert new bridge record
                        try (PreparedStatement psInsert = con.prepareStatement(insertSql)) {
                            psInsert.setString(1, lawyerEmail);
                            psInsert.setInt(2, caseId);
                            return psInsert.executeUpdate() > 0;
                        }
                    }
                }
            }
        }
    }
}
