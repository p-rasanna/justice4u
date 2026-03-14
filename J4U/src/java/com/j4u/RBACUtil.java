package com.j4u;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RBACUtil {

    /**
     * Check if user has permission to access a specific case
     */
    /**
     * Check if user has permission to access a specific case
     */
    public static boolean canAccessCase(String userEmail, String userRole, int caseId) {
        String query = "";
        switch (userRole) {
            case "admin":
                return true;
            case "client":
                query = "SELECT COUNT(*) as count FROM allotlawyer a JOIN cust_reg c ON a.cname = c.cname WHERE c.email=? AND a.alid=?";
                break;
            case "lawyer":
                query = "SELECT COUNT(*) as count FROM allotlawyer WHERE lname=? AND alid=?";
                break;
            case "intern":
                query = "SELECT COUNT(*) as count FROM intern_assignments ia WHERE ia.intern_email=? AND ia.alid=? AND ia.status='ACTIVE'";
                break;
            default:
                return false;
        }

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement pst = con.prepareStatement(query)) {

            pst.setString(1, userEmail);
            pst.setInt(2, caseId);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if user has permission to access a specific document
     */
    public static boolean canAccessDocument(String userEmail, String userRole, int docId) {
        String query = "";
        switch (userRole) {
            case "admin":
                return true;
            case "client":
                query = "SELECT COUNT(*) as count FROM lawyer_documents ld " +
                        "JOIN allotlawyer a ON ld.alid = a.alid " +
                        "JOIN cust_reg c ON a.cname = c.cname " +
                        "WHERE c.email=? AND ld.doc_id=?";
                break;
            case "lawyer":
                query = "SELECT COUNT(*) as count FROM lawyer_documents ld " +
                        "JOIN allotlawyer a ON ld.alid = a.alid " +
                        "WHERE a.lname=? AND ld.doc_id=?";
                break;
            case "intern":
                query = "SELECT COUNT(*) as count FROM lawyer_documents ld " +
                        "JOIN intern_assignments ia ON ld.alid = ia.alid " +
                        "WHERE ia.intern_email=? AND ld.doc_id=? AND ia.status='ACTIVE'";
                break;
            default:
                return false;
        }

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement pst = con.prepareStatement(query)) {

            pst.setString(1, userEmail);
            pst.setInt(2, docId);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid admin
     */
    public static boolean isValidAdmin(String email) {
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement pst = con.prepareStatement("SELECT COUNT(*) as count FROM admin WHERE email=?")) {

            pst.setString(1, email);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid client
     */
    public static boolean isValidClient(String email) {
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement pst = con.prepareStatement("SELECT COUNT(*) as count FROM cust_reg WHERE email=?")) {

            pst.setString(1, email);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid lawyer
     */
    public static boolean isValidLawyer(String email) {
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement pst = con
                        .prepareStatement("SELECT COUNT(*) as count FROM lawyer_reg WHERE email=? AND flag=1")) {

            pst.setString(1, email);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid intern
     */
    public static boolean isValidIntern(String email) {
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement pst = con
                        .prepareStatement("SELECT COUNT(*) as count FROM intern WHERE email=? AND flag=1")) {

            pst.setString(1, email);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if user can send messages in a specific case chat
     */
    public static boolean canSendMessage(String userEmail, String userRole, int caseId) {
        String query = "";
        switch (userRole) {
            case "admin":
                return true;
            case "client":
                query = "SELECT COUNT(*) as count FROM allotlawyer a JOIN cust_reg c ON a.cname = c.cname WHERE c.email=? AND a.alid=?";
                break;
            case "lawyer":
                query = "SELECT COUNT(*) as count FROM allotlawyer WHERE lname=? AND alid=?";
                break;
            case "intern":
                query = "SELECT COUNT(*) as count FROM intern_assignments ia WHERE ia.intern_email=? AND ia.alid=? AND ia.status='ACTIVE'";
                break;
            default:
                return false;
        }

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement pst = con.prepareStatement(query)) {

            pst.setString(1, userEmail);
            pst.setInt(2, caseId);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
