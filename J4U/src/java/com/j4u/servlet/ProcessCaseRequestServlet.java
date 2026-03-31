package com.j4u.servlet;

import com.j4u.dao.CaseRequestDAO;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Scanner;
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

@WebServlet("/ProcessCaseRequestServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ProcessCaseRequestServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ProcessCaseRequestServlet.class.getName());
    private final CaseRequestDAO dao = new CaseRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        // Accept either 'cname' (email stored by login) or 'cemail'
        String sessionEmail = null;
        if (session != null) {
            Object cname = session.getAttribute("cname");
            Object cemail = session.getAttribute("cemail");
            if (cemail != null)
                sessionEmail = cemail.toString();
            else if (cname != null)
                sessionEmail = cname.toString();
        }
        if (sessionEmail == null) {
            response.sendRedirect("auth/cust_login.html?error=session_expired");
            return;
        }

        try {
            String title = "", description = "", category = "", urgency = "", courtType = "";
            String city = "", language = "", consultMode = "", paymentMode = "", transactionId = "";
            String selectedLawyerEmail = "";
            String amount = "500";

            String uploadedFilePath = "";

            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getSubmittedFileName() == null) {
                    String name = part.getName();
                    try (InputStream is = part.getInputStream(); Scanner s = new Scanner(is, "UTF-8")) {
                        if (s.hasNext()) {
                            String value = s.useDelimiter("\\A").next();
                            switch (name) {
                                case "title":
                                    title = value;
                                    break;
                                case "description":
                                    description = value;
                                    break;
                                case "category":
                                    category = value;
                                    break;
                                case "urgency":
                                    urgency = value;
                                    break;
                                case "courtType":
                                    courtType = value;
                                    break;
                                case "city":
                                    city = value;
                                    break;
                                case "language":
                                    language = value;
                                    break;
                                case "consultMode":
                                    consultMode = value;
                                    break;
                                case "paymentMode":
                                    paymentMode = value;
                                    break;
                                case "transactionId":
                                    transactionId = value;
                                    break;
                                case "selected_lawyer_email":
                                    selectedLawyerEmail = value;
                                    break;
                            }
                        }
                    }
                } else {
                    String fileName = part.getSubmittedFileName();
                    if (fileName != null && !fileName.trim().isEmpty()) {
                        String appPath = request.getServletContext().getRealPath("");
                        String uploadDir = appPath + File.separator + "uploads" + File.separator + "case_documents";
                        File uploadDirFile = new File(uploadDir);
                        if (!uploadDirFile.exists()) {
                            uploadDirFile.mkdirs();
                        }

                        String uniqueFileName = System.currentTimeMillis() + "_"
                                + fileName.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
                        uploadedFilePath = "uploads/case_documents/" + uniqueFileName;
                        String storeFilePath = uploadDir + File.separator + uniqueFileName;

                        part.write(storeFilePath);
                    }
                }
            }

            if (transactionId == null || transactionId.trim().length() < 8) {
                response.sendRedirect(
                        "client/case.jsp?error=1&msg=Invalid+Transaction+ID.+Please+enter+a+valid+payment+reference.");
                return;
            }

            Object[] custData = dao.getCustomerByEmail(sessionEmail);
            if (custData == null) {
                response.sendRedirect("auth/cust_login.html?error=session_expired");
                return;
            }

            int customerId = (Integer) custData[0];
            String customerName = (String) custData[1];

            String curDate = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

            StringBuilder fullDesc = new StringBuilder();
            fullDesc.append(description).append("\n\n[Details]\nCategory: ").append(category)
                    .append("\nUrgency: ").append(urgency).append("\nLanguage: ").append(language)
                    .append("\nConsultation: ").append(consultMode);

            if (!uploadedFilePath.isEmpty()) {
                fullDesc.append("\n\n[Attachment Saved]: ").append(uploadedFilePath);
            }

            int caseId = dao.createCase(sessionEmail, customerName, title, fullDesc.toString(), curDate,
                    courtType, city, paymentMode, transactionId, amount);

            if (caseId > 0) {
                int assignedLawyerId = dao.getLawyerIdByEmail(selectedLawyerEmail);
                String assignmentStatus = (assignedLawyerId > 0) ? "REQUESTED" : "OPEN";

                int caseTypeId = 9;
                if (category != null) {
                    String catLower = category.toLowerCase();
                    if (catLower.contains("civil"))
                        caseTypeId = 1;
                    else if (catLower.contains("criminal"))
                        caseTypeId = 2;
                    else if (catLower.contains("family") || catLower.contains("divorce"))
                        caseTypeId = 3;
                    else if (catLower.contains("corporate"))
                        caseTypeId = 4;
                    else if (catLower.contains("property") || catLower.contains("estate"))
                        caseTypeId = 5;
                    else if (catLower.contains("tax"))
                        caseTypeId = 6;
                    else if (catLower.contains("labor"))
                        caseTypeId = 7;
                    else if (catLower.contains("intellectual"))
                        caseTypeId = 8;
                }

                dao.linkCaseToCustomer(caseId, customerId, assignedLawyerId, assignmentStatus,
                        title, caseTypeId, fullDesc.toString());

                if (assignedLawyerId > 0) {
                    dao.syncToAllotLawyer(caseId, selectedLawyerEmail);
                }

                String pt = (String) session.getAttribute("profileType");
                boolean isAdmin = pt != null && (pt.equalsIgnoreCase("admin") || pt.equalsIgnoreCase("admin_assigned") || pt.equalsIgnoreCase("assigned") || pt.equalsIgnoreCase("auto"));
                response.sendRedirect("client/" + (isAdmin ? "customerdashboard.jsp" : "clientdashboard_manual.jsp") + "?msg=Case Created Successfully!");
            } else {
                response.sendRedirect("client/case.jsp?error=1&msg=Database Insertion Failed");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing case request", e);
            response.sendRedirect("client/case.jsp?error=1&msg=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
