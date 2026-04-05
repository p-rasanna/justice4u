package com.j4u;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
@WebServlet("/RegisterServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10, // 10MB
    maxRequestSize = 1024 * 1024 * 50) // 50MB
public class RegisterServlet extends HttpServlet {
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String phone = request.getParameter("phone");
    String dob = request.getParameter("dob"); // Added
    String barNumber = request.getParameter("barNumber");
    String stateBar = request.getParameter("stateBar");
    String practiceLocation = request.getParameter("practiceLocation");
    String experienceYears = request.getParameter("experienceYears");
    String cadd = request.getParameter("cadd");
    String padd = request.getParameter("padd");
    String ano = request.getParameter("ano");
    String securityQuestion = request.getParameter("securityQuestion");
    String securityAnswer = request.getParameter("securityAnswer");
    String paymentMode = request.getParameter("paymentMode");
    String transactionId = request.getParameter("transactionId");
    String amount = request.getParameter("amount");
    String[] practiceAreasArr = request.getParameterValues("practiceAreas");
    String practiceAreas = (practiceAreasArr != null) ? String.join(", ", practiceAreasArr) : "";
    String emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    String phonePattern = "^[0-9]{10,15}$";
    String barPattern = "^[a-zA-Z0-9/\\-]{5,30}$"; // More permissive for lawyer reg
    String aadharPattern = "^[0-9]{12}$";
    String dobPattern = "^\\d{4}-\\d{2}-\\d{2}$";
    if (!ValidationUtil.validateInput(fullName, null, 100) ||
      !ValidationUtil.validateInput(email, emailPattern, 100) ||
      !ValidationUtil.validateInput(password, null, 255) ||
      !ValidationUtil.validateInput(phone, phonePattern, 15) ||
      !ValidationUtil.validateInput(ano, aadharPattern, 12) ||
      !ValidationUtil.validateInput(cadd, null, 200) ||
      !ValidationUtil.validateInput(padd, null, 200) ||
      !ValidationUtil.validateInput(barNumber, barPattern, 30) ||
      !ValidationUtil.validateInput(dob, dobPattern, 10)) {
      response.sendRedirect("landing/Lawyer.html?error=Invalid input. Please check all fields.");
      return;
    }
    Connection con = null;
    try {
      con = DatabaseConfig.getConnection();
      con.setAutoCommit(false);
      String checkQuery = "SELECT COUNT(*) FROM lawyer_reg WHERE email = ? OR bar_council_number = ?";
      try (PreparedStatement checkStmt = con.prepareStatement(checkQuery)) {
        checkStmt.setString(1, email);
        checkStmt.setString(2, barNumber);
        try (ResultSet rs = checkStmt.executeQuery()) {
          if (rs.next() && rs.getInt(1) > 0) {
            response.sendRedirect("landing/Lawyer.html?error=Email or Bar Number already registered");
            return;
          }
        }
      }
      String insertSql = "INSERT INTO lawyer_reg (name, email, pass, phone, bar_council_number, address, specialization, experience_years, dob, mop, tid, amt, practicing_courts, ano, cadd, padd, flag, security_question, security_answer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)";
      int lawyerId = 0;
      try (PreparedStatement pst = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
        pst.setString(1, fullName);
        pst.setString(2, email);
        pst.setString(3, PasswordUtil.hashPassword(password));
        pst.setString(4, phone);
        pst.setString(5, barNumber);
        pst.setString(6, practiceLocation);
        pst.setString(7, practiceAreas);
        pst.setString(8, experienceYears);
        pst.setString(9, dob);
        pst.setString(10, paymentMode);
        pst.setString(11, transactionId);
        pst.setString(12, amount);
        pst.setString(13, stateBar); // Mapping stateBar to practicing_courts
        pst.setString(14, ano);
        pst.setString(15, cadd);
        pst.setString(16, padd);
        pst.setString(17, securityQuestion);
        pst.setString(18, securityAnswer);
        int rows = pst.executeUpdate();
        if (rows > 0) {
          try (ResultSet rs = pst.getGeneratedKeys()) {
            if (rs.next())
              lawyerId = rs.getInt(1);
          }
        }
      }
      if (lawyerId > 0) {
        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "uploads"
            + File.separator + "lawyer_documents";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists())
          uploadDir.mkdirs();
        saveDocument(request.getPart("barCertificate"), lawyerId, "BAR_CERTIFICATE", uploadPath, con);
        saveDocument(request.getPart("idProof"), lawyerId, "GOV_ID_PROOF", uploadPath, con);
        saveDocument(request.getPart("profilePhoto"), lawyerId, "PROFESSIONAL_PHOTO", uploadPath, con);
        saveDocument(request.getPart("selfie"), lawyerId, "LIVE_SELFIE", uploadPath, con);
        con.commit();
        response.sendRedirect("landing/Lawyer.html?success=true");
      } else {
        con.rollback();
        response.sendRedirect("landing/Lawyer.html?error=Registration failed");
      }
    } catch (Exception e) {
      if (con != null)
        try {
          con.rollback();
        } catch (Exception ex) {
        }
      e.printStackTrace();
      response.sendRedirect("landing/Lawyer.html?error=Server error: " + e.getMessage());
    } finally {
      if (con != null)
        try {
          con.setAutoCommit(true);
          con.close();
        } catch (Exception e) {
        }
    }
  }
  private void saveDocument(Part part, int lawyerId, String docType, String uploadPath, Connection con)
      throws IOException {
    if (part != null && part.getSize() > 0) {
      String fileName = getFileName(part);
      String uniqueName = UUID.randomUUID().toString() + "_" + fileName;
      String fullPath = uploadPath + File.separator + uniqueName;
      part.write(fullPath);
      String relativePath = "uploads/lawyer_documents/" + uniqueName;
      try (PreparedStatement pst = con.prepareStatement(
          "INSERT INTO lawyer_documents (lawyer_id, document_type, file_name, file_path, status) VALUES (?, ?, ?, ?, 'PENDING')")) {
        pst.setInt(1, lawyerId);
        pst.setString(2, docType);
        pst.setString(3, fileName);
        pst.setString(4, relativePath);
        pst.executeUpdate();
      } catch (Exception e) {
        e.printStackTrace(); // Log but don't fail entire reg? Or fail? Best to fail for consistency.
        throw new IOException("DB Error saving doc", e);
      }
    }
  }
  private String getFileName(Part part) {
    String contentDisp = part.getHeader("content-disposition");
    for (String content : contentDisp.split(";")) {
      if (content.trim().startsWith("filename")) {
        return content.substring(content.indexOf("=") + 2, content.length() - 1);
      }
    }
    return "unknown";
  }
}