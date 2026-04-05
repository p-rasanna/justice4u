package com.j4u.servlet;

import com.j4u.DatabaseConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/AssignLawyerServlet")
public class AssignLawyerServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AssignLawyerServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Authorization Check
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("auth/Login.html");
            return;
        }

        // 2. Input Validation
        String caseIdStr = request.getParameter("case_id");
        String lawyerIdStr = request.getParameter("lawyer_id");

        if (caseIdStr == null || lawyerIdStr == null || caseIdStr.isEmpty() || lawyerIdStr.isEmpty()) {
            response.sendRedirect("ViewCases?error=Missing parameters");
            return;
        }

        int caseId;
        int lawyerId;
        try {
            caseId = Integer.parseInt(caseIdStr);
            lawyerId = Integer.parseInt(lawyerIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("ViewCases?error=Invalid parameters format");
            return;
        }

        // 3. TRANSACTION MANAGEMENT: Guarantee both outputs succeed, or neither do.
        try (Connection con = DatabaseConfig.getConnection()) {

            // Disable Auto-Commit to begin transaction
            con.setAutoCommit(false);

            String updateCaseStatus = "UPDATE customer_cases SET status='PENDING_LAWYER_CONFIRMATION', assigned_lawyer_id=? WHERE case_id=?";
            String insertAssignment = "INSERT INTO case_assignments (case_id, lawyer_id) VALUES (?, ?)";
            String updateLegacyFlag = "UPDATE casetb SET flag=1 WHERE cid=?";
            String syncAllotLawyer = "INSERT INTO allotlawyer (cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, lname) "
                    +
                    "SELECT cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, " +
                    "(SELECT email FROM lawyer_reg WHERE lid=?) FROM casetb WHERE cid=?";

            try (
                    PreparedStatement psCase = con.prepareStatement(updateCaseStatus);
                    PreparedStatement psLawyer = con.prepareStatement(insertAssignment);
                    PreparedStatement psLegacy = con.prepareStatement(updateLegacyFlag);
                    PreparedStatement psSync = con.prepareStatement(syncAllotLawyer)) {
                // Step 1: Update Case Status and Lawyer ID
                psCase.setInt(1, lawyerId);
                psCase.setInt(2, caseId);
                int caseRows = psCase.executeUpdate();

                if (caseRows == 0) {
                    throw new SQLException("Case ID " + caseId + " not found to assign.");
                }

                // Step 3: Update Legacy Flag in casetb (was missing executeUpdate — now fixed)
                psLegacy.setInt(1, caseId);
                psLegacy.executeUpdate();
                // Step 4: Sync to AllotLawyer
                psSync.setInt(1, lawyerId);
                psSync.setInt(2, caseId);
                psSync.executeUpdate();

                // Commit Transaction if both successfully executed without exception
                con.commit();
                LOGGER.info("Successfully completed transaction to assign Lawyer " + lawyerId + " to Case " + caseId);

                response.sendRedirect("ViewCases?success=Lawyer Assigned Successfully");

            } catch (SQLException e) {
                // ROLLBACK Transaction on any failure to maintain database integrity
                con.rollback();
                LOGGER.log(Level.SEVERE,
                        "Transaction failed. Database Rolled Back. Lawyer: " + lawyerId + " Case: " + caseId, e);
                throw new ServletException(
                        "Failed to assign lawyer due to database conflict. Operation aborted securely.", e);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database connection failure during transaction setup.", e);
            throw new ServletException("Unable to process assignment at this time.", e);
        }
    }
}
