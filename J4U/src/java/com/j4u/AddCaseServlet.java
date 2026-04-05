package com.j4u;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
@WebServlet(name = "AddCaseServlet", urlPatterns = { "/AddCaseServlet" })
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10, // 10MB
    maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class AddCaseServlet extends HttpServlet {
  private static final Logger LOGGER = Logger.getLogger(AddCaseServlet.class.getName());
  private static final String UPLOAD_SUBDIR = "uploads" + File.separator + "case_docs";
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession(false);
    String sessionEmail = null;
    if (session != null) {
      Object cemail = session.getAttribute("cemail");
      Object cname = session.getAttribute("cname");
      if (cemail != null)
        sessionEmail = cemail.toString();
      else if (cname != null)
        sessionEmail = cname.toString();
    }
    if (sessionEmail == null) {
      response.sendRedirect(request.getContextPath() + "/auth/cust_login.jsp?msg=Session expired");
      return;
    }
    String title = request.getParameter("title");
    String description = request.getParameter("description");
    String paymentMode = request.getParameter("paymentMode");
    if (paymentMode == null) paymentMode = request.getParameter("mop");
    String transactionId = request.getParameter("transactionId");
    if (transactionId == null) transactionId = request.getParameter("tid");
    if (!areRequiredFieldsPresent(title, description)) {
      response.sendRedirect(request.getContextPath() + "/client/case.jsp?error=Missing+required+fields");
      return;
    }
    try {
      processCaseSubmission(request, session, title, description, paymentMode, transactionId);
      session.setAttribute("submittedCaseTitle", title);
      response.sendRedirect(request.getContextPath() + "/client/clientdashboard.jsp?msg=Case+filed+successfully");
    } catch (Exception e) {
      LOGGER.log(Level.SEVERE, "Error processing case submission", e);
      response.sendRedirect(request.getContextPath() + "/client/case.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    }
  }
  private boolean areRequiredFieldsPresent(String... fields) {
    for (String field : fields) {
      if (field == null || field.trim().isEmpty()) {
        return false;
      }
    }
    return true;
  }
  private void processCaseSubmission(HttpServletRequest request, HttpSession session, String title,
      String description, String paymentMode, String transactionId)
      throws SQLException, IOException, ServletException, ClassNotFoundException {
    String customerEmail = (String) session.getAttribute("cemail");
    if (customerEmail == null) customerEmail = (String) session.getAttribute("cname");
    String category = request.getParameter("category");
    String urgency = request.getParameter("urgency");
    String courtType = request.getParameter("courtType");
    String city = request.getParameter("city");
    String language = request.getParameter("language");
    String consultMode = request.getParameter("consultMode");
    String profileType = (String) session.getAttribute("profileType");
    if (profileType == null) profileType = "admin";
    String assignmentType = "manual".equalsIgnoreCase(profileType) ? "MANUAL" : "ADMIN";
    String initialCaseStatus = "MANUAL".equals(assignmentType) ? "SEARCHING" : "PENDING";
    try (Connection con = DatabaseConfig.getConnection()) {
      String customerName = getCustomerName(con, customerEmail);
      String fullDescription = buildFullDescription(description, category, urgency, language, consultMode);
      String selectedLawyerEmail = request.getParameter("selected_lawyer_email");
      saveToLegacyTable(con, customerName, title, fullDescription, courtType, city, paymentMode, transactionId,
          customerEmail, assignmentType, initialCaseStatus);
      int caseId = getGeneratedCaseId(con, customerEmail);
      if (caseId > 0) {
        linkToCustomerCases(con, caseId, (Integer) session.getAttribute("cid"), title, fullDescription);
        handleFileUpload(request, caseId);
        if ("MANUAL".equals(assignmentType) && selectedLawyerEmail != null && !selectedLawyerEmail.trim().isEmpty()) {
          createLawyerRequest(con, caseId, customerEmail, selectedLawyerEmail.trim());
          try (PreparedStatement ps = con.prepareStatement("UPDATE casetb SET case_status='REQUESTED' WHERE cid=?")) {
            ps.setInt(1, caseId); ps.executeUpdate();
          }
        }
      }
    }
  }
  private String getCustomerName(Connection con, String email) throws SQLException {
    try (PreparedStatement ps = con.prepareStatement("SELECT cname FROM cust_reg WHERE email=?")) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return rs.getString("cname");
        }
      }
    }
    return "Unknown";
  }
  private String buildFullDescription(String description, String category, String urgency, String language,
      String consultMode) {
    return description +
        " | Category: " + category +
        " | Urgency: " + urgency +
        " | Language: " + language +
        " | Consult Mode: " + consultMode;
  }
  @SuppressWarnings("java:S107") // Suppress parameter count warning for legacy support
  private void saveToLegacyTable(Connection con, String name, String title, String description,
      String courtType, String city, String mop, String tid, String cname,
      String assignmentType, String caseStatus) throws SQLException {
    String sql = "INSERT INTO casetb (name, title, des, curdate, courttype, city, mop, tid, amt, cname, flag, assignment_type, case_status) VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, 500, ?, 0, ?, ?)";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setString(1, name);
      ps.setString(2, title);
      ps.setString(3, description);
      ps.setString(4, courtType);
      ps.setString(5, city);
      ps.setString(6, mop != null ? mop : "N/A");
      ps.setString(7, tid != null ? tid : "N/A");
      ps.setString(8, cname);
      ps.setString(9, assignmentType != null ? assignmentType : "ADMIN");
      ps.setString(10, caseStatus != null ? caseStatus : "PENDING");
      ps.executeUpdate();
    }
  }
  private void createLawyerRequest(Connection con, int caseId, String clientEmail, String lawyerEmail) throws SQLException {
    try (PreparedStatement ps = con.prepareStatement(
        "UPDATE lawyer_requests SET status='CANCELLED' WHERE case_id=? AND status='PENDING'")) {
      ps.setInt(1, caseId); ps.executeUpdate();
    }
    String sql = "INSERT INTO lawyer_requests (case_id, client_email, lawyer_email, status) VALUES (?, ?, ?, 'PENDING')";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setInt(1, caseId);
      ps.setString(2, clientEmail);
      ps.setString(3, lawyerEmail);
      ps.executeUpdate();
    }
  }
  private int getGeneratedCaseId(Connection con, String cname) throws SQLException {
    try (PreparedStatement ps = con.prepareStatement("SELECT MAX(cid) FROM casetb WHERE cname=?")) {
      ps.setString(1, cname);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return rs.getInt(1);
        }
      }
    }
    return 0;
  }
  private void linkToCustomerCases(Connection con, int caseId, int customerId, String title, String description) throws SQLException {
    String sql = "INSERT INTO customer_cases (case_id, customer_id, case_type_id, title, description, status) VALUES (?, ?, 9, ?, ?, 'OPEN')";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setInt(1, caseId);
      ps.setInt(2, customerId);
      ps.setString(3, title);
      ps.setString(4, description);
      ps.executeUpdate();
    }
  }
  private void handleFileUpload(HttpServletRequest request, int caseId) throws IOException, ServletException {
    Part filePart = request.getPart("documents");
    if (filePart != null && filePart.getSize() > 0) {
      String uploadDirPath = request.getServletContext().getRealPath("/") + UPLOAD_SUBDIR;
      File uploadDir = new File(uploadDirPath);
      if (!uploadDir.exists()) {
        uploadDir.mkdirs();
      }
      String fileName = "Case_" + caseId + "_" + UUID.randomUUID().toString().substring(0, 8) + ".pdf";
      filePart.write(uploadDirPath + File.separator + fileName);
    }
  }
}