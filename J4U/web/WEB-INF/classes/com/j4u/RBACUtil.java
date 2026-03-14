package com.j4u;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.j4u.DatabaseConfig;

public class RBACUtil {

    /**
     * Check if user has permission to access a specific case
     */
    public static boolean canAccessCase(String userEmail, String userRole, int caseId) {
        try {
            // Class.forName("com.mysql.jdbc.Driver");
            Connection con = DatabaseConfig.getConnection();

            String query = "";
            switch (userRole) {
                case "admin":
                    // Admins can access all cases
                    return true;
                case "client":
                    // Clients can only access their own cases
                    query = "SELECT COUNT(*) as count FROM allotlawyer a JOIN cust_reg c ON a.cname = c.cname WHERE c.email=? AND a.alid=?";
                    break;
                case "lawyer":
                    // Lawyers can only access cases assigned to them
                    query = "SELECT COUNT(*) as count FROM allotlawyer WHERE lname=? AND alid=?";
                    break;
                case "intern":
                    // Interns can only access cases they're assigned to
                    query = "SELECT COUNT(*) as count FROM intern_assignments ia WHERE ia.intern_email=? AND ia.alid=? AND ia.status='ACTIVE'";
                    break;
                default:
                    return false;
            }

            if (!"admin".equals(userRole)) {
                PreparedStatement pst = con.prepareStatement(query);
                pst.setString(1, userEmail);
                pst.setInt(2, caseId);
                ResultSet rs = pst.executeQuery();

                boolean hasAccess = false;
                if (rs.next()) {
                    hasAccess = rs.getInt("count") > 0;
                }

                rs.close();
                pst.close();
                con.close();
                return hasAccess;
            }

            con.close();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if user has permission to access a specific document
     */
    public static boolean canAccessDocument(String userEmail, String userRole, int docId) {
        try {
            // Class.forName("com.mysql.jdbc.Driver");
            Connection con = DatabaseConfig.getConnection();

            String query = "";
            switch (userRole) {
                case "admin":
                    // Admins can access all documents
                    return true;
                case "client":
                    // Clients can only access documents from their cases
                    query = "SELECT COUNT(*) as count FROM lawyer_documents ld " +
                            "JOIN allotlawyer a ON ld.alid = a.alid " +
                            "JOIN cust_reg c ON a.cname = c.cname " +
                            "WHERE c.email=? AND ld.doc_id=?";
                    break;
                case "lawyer":
                    // Lawyers can only access documents from their cases
                    query = "SELECT COUNT(*) as count FROM lawyer_documents ld " +
                            "JOIN allotlawyer a ON ld.alid = a.alid " +
                            "WHERE a.lname=? AND ld.doc_id=?";
                    break;
                case "intern":
                    // Interns can only access documents from cases they're assigned to
                    query = "SELECT COUNT(*) as count FROM lawyer_documents ld " +
                            "JOIN intern_assignments ia ON ld.alid = ia.alid " +
                            "WHERE ia.intern_email=? AND ld.doc_id=? AND ia.status='ACTIVE'";
                    break;
                default:
                    return false;
            }

            if (!"admin".equals(userRole)) {
                PreparedStatement pst = con.prepareStatement(query);
                pst.setString(1, userEmail);
                pst.setInt(2, docId);
                ResultSet rs = pst.executeQuery();

                boolean hasAccess = false;
                if (rs.next()) {
                    hasAccess = rs.getInt("count") > 0;
                }

                rs.close();
                pst.close();
                con.close();
                return hasAccess;
            }

            con.close();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid admin
     */
    public static boolean isValidAdmin(String email) {
        try {
            // Class.forName("com.mysql.jdbc.Driver");
            Connection con = DatabaseConfig.getConnection();
            PreparedStatement pst = con.prepareStatement("SELECT COUNT(*) as count FROM admin WHERE email=?");
            pst.setString(1, email);
            ResultSet rs = pst.executeQuery();

            boolean valid = false;
            if (rs.next()) {
                valid = rs.getInt("count") > 0;
            }

            rs.close();
            pst.close();
            con.close();
            return valid;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid client
     */
    public static boolean isValidClient(String email) {
        try {
            // Class.forName("com.mysql.jdbc.Driver");
            Connection con = DatabaseConfig.getConnection();
            PreparedStatement pst = con
                    .prepareStatement("SELECT COUNT(*) as count FROM cust_reg WHERE email=? AND flag=1");
            pst.setString(1, email);
            ResultSet rs = pst.executeQuery();

            boolean valid = false;
            if (rs.next()) {
                valid = rs.getInt("count") > 0;
            }

            rs.close();
            pst.close();
            con.close();
            return valid;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid lawyer
     */
    public static boolean isValidLawyer(String email) {
        try {
            // Class.forName("com.mysql.jdbc.Driver");
            Connection con = DatabaseConfig.getConnection();
            PreparedStatement pst = con
                    .prepareStatement("SELECT COUNT(*) as count FROM lawyer_reg WHERE email=? AND flag=1");
            pst.setString(1, email);
            ResultSet rs = pst.executeQuery();

            boolean valid = false;
            if (rs.next()) {
                valid = rs.getInt("count") > 0;
            }

            rs.close();
            pst.close();
            con.close();
            return valid;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate if user is a valid intern
     */
    public static boolean isValidIntern(String email) {
        try {
            // Class.forName("com.mysql.jdbc.Driver");
            Connection con = DatabaseConfig.getConnection();
            PreparedStatement pst = con
                    .prepareStatement("SELECT COUNT(*) as count FROM intern_reg WHERE email=? AND flag=1");
            pst.setString(1, email);
            ResultSet rs = pst.executeQuery();

            boolean valid = false;
            if (rs.next()) {
                valid = rs.getInt("count") > 0;
            }

            rs.close();
            pst.close();
            con.close();
            return valid;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if user can send messages in a specific case chat
     */
    public static boolean canSendMessage(String userEmail, String userRole, int caseId) {
        try {
            // Class.forName("com.mysql.jdbc.Driver");
            Connection con = DatabaseConfig.getConnection();

            String query = "";
            switch (userRole) {
                case "admin":
                    // Admins can send messages to any case
                    return true;
                case "client":
                    // Clients can only send messages to their own cases
                    query = "SELECT COUNT(*) as count FROM allotlawyer a JOIN cust_reg c ON a.cname = c.cname WHERE c.email=? AND a.alid=?";
                    break;
                case "lawyer":
                    // Lawyers can only send messages to cases assigned to them
                    query = "SELECT COUNT(*) as count FROM allotlawyer WHERE lname=? AND alid=?";
                    break;
                case "intern":
                    // Interns can only send messages to cases they're assigned to, and only to
                    // their supervising lawyer
                    query = "SELECT COUNT(*) as count FROM intern_assignments ia WHERE ia.intern_email=? AND ia.alid=? AND ia.status='ACTIVE'";
                    break;
                default:
                    return false;
            }

            if (!"admin".equals(userRole)) {
                PreparedStatement pst = con.prepareStatement(query);
                pst.setString(1, userEmail);
                pst.setInt(2, caseId);
                ResultSet rs = pst.executeQuery();

                boolean hasAccess = false;
                if (rs.next()) {
                    hasAccess = rs.getInt("count") > 0;
                }

                rs.close();
                pst.close();
                con.close();
                return hasAccess;
            }

            con.close();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
