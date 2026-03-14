<%@page contentType="text/html" pageEncoding="UTF-8"
    import="java.sql.*, java.io.*, java.util.*, java.util.regex.*, com.j4u.PasswordUtil, com.j4u.ValidationUtil" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@ include file="db_connection.jsp" %>

<%
    // Check multipart
    boolean isMultipart = ServletFileUpload.isMultipartContent(request);
    if (!isMultipart) {
        response.sendRedirect("Lawyer.html?error=Form must be multipart/form-data");
        return;
    }

    // Parameters to extract
    Map<String, String> formFields = new HashMap<>();
    Map<String, FileItem> fileFields = new HashMap<>();
    List<String> practiceAreasList = new ArrayList<>();

    try {
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletContext servletContext = this.getServletConfig().getServletContext();
        File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");
        factory.setRepository(repository);
        ServletFileUpload upload = new ServletFileUpload(factory);
        List<FileItem> items = upload.parseRequest(request);

        for (FileItem item : items) {
            if (item.isFormField()) {
                String name = item.getFieldName();
                String value = item.getString("UTF-8");
                
                if (name.equals("practiceAreas")) {
                    practiceAreasList.add(value);
                } else {
                    formFields.put(name, value);
                }
            } else {
                if (item.getName() != null && !item.getName().trim().isEmpty()) {
                    fileFields.put(item.getFieldName(), item);
                }
            }
        }
        
        // Join practice areas
        String practiceAreas = String.join(", ", practiceAreasList);

        // Extract and Sanitize
        String fullName = ValidationUtil.sanitize(formFields.get("fullName"));
        String email = ValidationUtil.sanitize(formFields.get("email"));
        String password = formFields.get("password"); // Don't sanitize password
        String phone = ValidationUtil.sanitize(formFields.get("phone"));
        String barNumber = ValidationUtil.sanitize(formFields.get("barNumber"));
        String stateBar = ValidationUtil.sanitize(formFields.get("stateBar"));
        String enrollmentYear = ValidationUtil.sanitize(formFields.get("enrollmentYear"));
        String experienceYears = ValidationUtil.sanitize(formFields.get("experienceYears"));
        String practiceLocation = ValidationUtil.sanitize(formFields.get("practiceLocation"));
        String paymentMode = ValidationUtil.sanitize(formFields.get("paymentMode"));
        String transactionId = ValidationUtil.sanitize(formFields.get("transactionId"));
        String dob = ValidationUtil.sanitize(formFields.get("dob"));
        String amount = ValidationUtil.sanitize(formFields.get("amount"));
        
        // New fields for address (cadd = current address, padd = permanent address)
        String cadd = ValidationUtil.sanitize(formFields.get("cadd"));
        String padd = ValidationUtil.sanitize(formFields.get("padd"));
        String ano = ValidationUtil.sanitize(formFields.get("ano"));

        // Validation Patterns
        String emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        String phonePattern = "^[0-9]{10,15}$";
        String barPattern = "^[A-Z0-9]{5,20}$";
        String yearPattern = "^\\d{4}$";
        String amountPattern = "^\\d+(\\.\\d{1,2})?$";
        String aadharPattern = "^[0-9]{12}$";

        // Validate required fields
        if (!ValidationUtil.validateInput(fullName, null, 100) ||
            !ValidationUtil.validateInput(email, emailPattern, 100) ||
            !ValidationUtil.validateInput(password, null, 255) ||
            !ValidationUtil.validateInput(phone, phonePattern, 15) ||
            !ValidationUtil.validateInput(ano, aadharPattern, 12) ||
            !ValidationUtil.validateInput(cadd, null, 200) ||
            !ValidationUtil.validateInput(padd, null, 200) ||
            !ValidationUtil.validateInput(barNumber, barPattern, 20) ||
            !ValidationUtil.validateInput(stateBar, null, 50) ||
            !ValidationUtil.validateInput(enrollmentYear, yearPattern, 4) ||
            !ValidationUtil.validateInput(experienceYears, "^\\d{1,2}$", 2) ||
            !ValidationUtil.validateInput(practiceLocation, null, 200) ||
            !ValidationUtil.validateInput(paymentMode, null, 20) ||
            !ValidationUtil.validateInput(transactionId, null, 50) ||
            //!ValidationUtil.validateInput(amount, amountPattern, 10) || // Optional check
            !ValidationUtil.validateInput(dob, "^\\d{4}-\\d{2}-\\d{2}$", 10)) {
            
            response.sendRedirect("Lawyer.html?error=Invalid input. Please check all fields.");
            return;
        }

        Connection con = getDatabaseConnection();
        con.setAutoCommit(false); // Start transaction

        try {
            // Check for duplicates
            String checkQuery = "SELECT COUNT(*) FROM lawyer_reg WHERE email=? OR bar_reg_number=?";
            PreparedStatement checkStmt = con.prepareStatement(checkQuery);
            checkStmt.setString(1, email);
            checkStmt.setString(2, barNumber);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                con.rollback();
                response.sendRedirect("Lawyer.html?error=Email or Bar Number already exists.");
                return;
            }
            rs.close();
            checkStmt.close();

            // Insert lawyer
            String insertLawyerQuery = "INSERT INTO lawyer_reg (name, email, pass, phone, bar_council_number, address, specialization, experience_years, flag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)";
            PreparedStatement lawyerStmt = con.prepareStatement(insertLawyerQuery, Statement.RETURN_GENERATED_KEYS);
            lawyerStmt.setString(1, fullName);
            lawyerStmt.setString(2, email);
            lawyerStmt.setString(3, PasswordUtil.hashPassword(password)); // Secure hash
            lawyerStmt.setString(4, phone);
            lawyerStmt.setString(5, barNumber);
            lawyerStmt.setString(6, practiceLocation);
            lawyerStmt.setString(7, practiceAreas);
            lawyerStmt.setString(8, experienceYears);

            int lawyerId = 0;
            if (lawyerStmt.executeUpdate() > 0) {
                ResultSet rsKey = lawyerStmt.getGeneratedKeys();
                if (rsKey.next()) {
                    lawyerId = rsKey.getInt(1);
                }
                rsKey.close();
            }
            lawyerStmt.close();

            if (lawyerId > 0) {
                 // Handle files with Commons FileUpload
                String appPath = request.getServletContext().getRealPath("");
                String uploadBase = appPath + File.separator + "uploads" + File.separator + "lawyer_documents";
                File uploadDirFile = new File(uploadBase);
                if (!uploadDirFile.exists()) uploadDirFile.mkdirs();

                Map<String, String> documentTypes = new HashMap<>();
                documentTypes.put("barCertificate", "BAR_CERTIFICATE");
                documentTypes.put("idProof", "GOV_ID_PROOF");
                documentTypes.put("profilePhoto", "PROFESSIONAL_PHOTO");
                documentTypes.put("selfie", "LIVE_SELFIE");

                for (Map.Entry<String, String> entry : documentTypes.entrySet()) {
                    String fieldName = entry.getKey();
                    if (fileFields.containsKey(fieldName)) {
                        FileItem fileItem = fileFields.get(fieldName);
                        String fileName = FilenameUtils.getName(fileItem.getName());
                        String uniqueName = System.currentTimeMillis() + "_" + fileName;
                        
                        // Save file
                        File storeFile = new File(uploadBase + File.separator + uniqueName);
                        fileItem.write(storeFile);
                        
                        String relativePath = "uploads/lawyer_documents/" + uniqueName;

                        // Insert DB record
                        String insertDocQuery = "INSERT INTO lawyer_documents (lawyer_id, document_type, file_name, file_path, status) VALUES (?, ?, ?, ?, 'PENDING')";
                        PreparedStatement docStmt = con.prepareStatement(insertDocQuery);
                        docStmt.setInt(1, lawyerId);
                        docStmt.setString(2, entry.getValue());
                        docStmt.setString(3, fileName);
                        docStmt.setString(4, relativePath);
                        docStmt.executeUpdate();
                        docStmt.close();
                    }
                }

                con.commit();
                response.sendRedirect("lawyer_registration_success.jsp");

            } else {
                con.rollback();
                response.sendRedirect("Lawyer.html?error=Registration failed. Please try again.");
            }
            
        } catch (Exception ex) {
            con.rollback();
            ex.printStackTrace();
            response.sendRedirect("Lawyer.html?error=Database Error: " + ex.getMessage());
        } finally {
            con.close();
        }

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("Lawyer.html?error=System Error: " + e.getMessage());
    }
%>
