package com.j4u.dao;

import com.j4u.DatabaseConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class InternRegistrationDAO {

    /**
     * Checks if the email is already registered in the intern table.
     */
    public boolean isEmailRegistered(String email) throws SQLException {
        String query = "SELECT internid FROM intern WHERE email = ?";
        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Registers a new intern account securely.
     */
    public boolean registerIntern(String fullName, String email, String hashedPassword, String dob,
            String phone, String aadhar, String currentAddress, String permanentAddress,
            String modeOfPayment, String transactionId, String amount,
            String securityQuestion, String securityAnswer) throws SQLException {

        String insertInternSql = "INSERT INTO intern (name, email, pass, dob, mobno, ano, cadd, padd, mop, tid, amt, flag, security_question, security_answer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(insertInternSql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, hashedPassword);
            ps.setString(4, dob);
            ps.setString(5, phone);
            ps.setString(6, aadhar);
            ps.setString(7, currentAddress);
            ps.setString(8, permanentAddress);
            ps.setString(9, modeOfPayment);
            ps.setString(10, transactionId);
            ps.setString(11, amount);
            ps.setString(12, securityQuestion);
            ps.setString(13, securityAnswer);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Saves the intern's academic profile details securely.
     */
    public boolean saveInternProfile(String email, String collegeName, String degreeProgram, String yearSemester,
            String studentId, String areasOfInterest, String skills, String preferredCity,
            String availabilityDuration, String internshipMode, String frontPath,
            String backPath, String bonafidePath) throws SQLException {

        String insertProfileSql = "INSERT INTO intern_profiles (intern_email, college_name, degree_program, current_year, student_id_number, areas_of_interest, skills, preferred_city, availability_duration, internship_mode, id_card_front_path, id_card_back_path, bonafide_cert_path, verification_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'UNVERIFIED')";

        try (Connection con = DatabaseConfig.getConnection();
                PreparedStatement ps = con.prepareStatement(insertProfileSql)) {

            ps.setString(1, email);
            ps.setString(2, collegeName);
            ps.setString(3, degreeProgram);
            ps.setString(4, yearSemester);
            ps.setString(5, studentId);
            ps.setString(6, areasOfInterest);
            ps.setString(7, skills);
            ps.setString(8, preferredCity);
            ps.setString(9, availabilityDuration);
            ps.setString(10, internshipMode);
            ps.setString(11, frontPath);
            ps.setString(12, backPath);
            ps.setString(13, bonafidePath);

            return ps.executeUpdate() > 0;
        }
    }
}
