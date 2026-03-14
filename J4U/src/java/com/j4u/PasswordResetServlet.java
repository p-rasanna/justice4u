package com.j4u;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/PasswordResetServlet")
public class PasswordResetServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String role = request.getParameter("role");
        String email = request.getParameter("email");
        String securityQuestion = request.getParameter("securityQuestion");
        String securityAnswer = request.getParameter("securityAnswer");
        String newPassword = request.getParameter("newPassword");

        if (role == null || email == null || securityQuestion == null || securityAnswer == null
                || newPassword == null) {
            response.sendRedirect("forgot_password.html?error=All fields are required.");
            return;
        }

        String tableName = "";
        if ("client".equals(role)) {
            tableName = "cust_reg";
        } else if ("lawyer".equals(role)) {
            tableName = "lawyer_reg";
        } else if ("intern".equals(role)) {
            tableName = "intern";
        } else {
            response.sendRedirect("forgot_password.html?error=Invalid role specification.");
            return;
        }

        Connection con = null;
        try {
            con = DatabaseConfig.getConnection();

            // 1. Verify credentials and answer
            String checkQuery = "SELECT * FROM " + tableName
                    + " WHERE email = ? AND security_question = ? AND security_answer = ?";
            boolean isValid = false;
            try (PreparedStatement checkStmt = con.prepareStatement(checkQuery)) {
                checkStmt.setString(1, email);
                checkStmt.setString(2, securityQuestion);
                checkStmt.setString(3, securityAnswer);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        isValid = true;
                    }
                }
            }

            if (!isValid) {
                // Return generic error so we don't leak whether an email exists
                response.sendRedirect("forgot_password.html?error=Invalid email or incorrect security answer.");
                return;
            }

            // 2. Hash new password and update
            String hashedPass = PasswordUtil.hashPassword(newPassword);
            String updateQuery = "UPDATE " + tableName + " SET pass = ? WHERE email = ?";

            try (PreparedStatement updateStmt = con.prepareStatement(updateQuery)) {
                updateStmt.setString(1, hashedPass);
                updateStmt.setString(2, email);

                int rowsAffected = updateStmt.executeUpdate();
                if (rowsAffected > 0) {
                    response.sendRedirect(
                            "forgot_password.html?msg=Password reset successful! You may now return to the login page.");
                } else {
                    response.sendRedirect(
                            "forgot_password.html?error=An error occurred while resetting your password. Please try again.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("forgot_password.html?error=Server error: " + e.getMessage());
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
}
