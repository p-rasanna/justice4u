package com.j4u.servlet;

import com.j4u.PasswordUtil;
import com.j4u.dao.InternRegistrationDAO;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
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
import javax.servlet.http.Part;

@WebServlet("/ProcessInternServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ProcessInternServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ProcessInternServlet.class.getName());
    private final InternRegistrationDAO dao = new InternRegistrationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // 1. Extract Parameters from Multipart Request
            String fullName = "", email = "", password = "", phone = "", collegeName = "", degreeProgram = "",
                    yearSemester = "", studentId = "", areasOfInterest = "", skills = "", preferredCity = "",
                    availabilityDuration = "", internship_mode = "", securityQuestion = "", securityAnswer = "";

            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getSubmittedFileName() == null) { // Form field
                    String name = part.getName();
                    try (InputStream is = part.getInputStream(); Scanner s = new Scanner(is, "UTF-8")) {
                        if (s.hasNext()) {
                            String value = s.useDelimiter("\\A").next();
                            switch (name) {
                                case "fullName":
                                    fullName = value;
                                    break;
                                case "email":
                                    email = value;
                                    break;
                                case "password":
                                    password = value;
                                    break;
                                case "phone":
                                    phone = value;
                                    break;
                                case "collegeName":
                                    collegeName = value;
                                    break;
                                case "degreeProgram":
                                    degreeProgram = value;
                                    break;
                                case "yearSemester":
                                    yearSemester = value;
                                    break;
                                case "studentId":
                                    studentId = value;
                                    break;
                                case "areasOfInterest":
                                    areasOfInterest += value + ",";
                                    break;
                                case "skills":
                                    skills += value + ",";
                                    break;
                                case "internMode":
                                    internship_mode = value;
                                    break;
                                case "preferredCity":
                                    preferredCity = value;
                                    break;
                                case "availabilityDuration":
                                    availabilityDuration = value;
                                    break;
                                case "securityQuestion":
                                    securityQuestion = value;
                                    break;
                                case "securityAnswer":
                                    securityAnswer = value;
                                    break;
                            }
                        }
                    }
                }
            }

            // Cleanup trailing commas from checkboxes
            if (!areasOfInterest.isEmpty() && areasOfInterest.endsWith(",")) {
                areasOfInterest = areasOfInterest.substring(0, areasOfInterest.length() - 1);
            }
            if (!skills.isEmpty() && skills.endsWith(",")) {
                skills = skills.substring(0, skills.length() - 1);
            }

            // Defaults
            String dob = "2000-01-01";
            String aadhar = (studentId != null && !studentId.isEmpty()) ? studentId : "N/A";
            String currentAddress = (preferredCity != null && !preferredCity.isEmpty()) ? preferredCity
                    : "Not provided";
            String permanentAddress = currentAddress;
            String modeOfPayment = "N/A";
            String transactionId = "N/A";
            String amount = "0";

            // 2. Business Logic Checks
            if (dao.isEmailRegistered(email)) {
                response.sendRedirect(request.getContextPath() + "/auth/internlogin.html?msg=Email already registered");
                return;
            }

            String hashedPassword = PasswordUtil.hashPassword(password);

            // 3. Database Insertion (Intern table)
            boolean registered = dao.registerIntern(fullName, email, hashedPassword, dob, phone, aadhar,
                    currentAddress, permanentAddress, modeOfPayment,
                    transactionId, amount, securityQuestion, securityAnswer);

            if (registered) {
                // 4. File Uploads handling
                String appPath = request.getServletContext().getRealPath("");
                String uploadBase = appPath + File.separator + "uploads";
                String uploadPath = uploadBase + File.separator + "intern_documents";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists())
                    uploadDir.mkdirs();

                String frontPath = "", backPath = "", bonafidePath = "";

                for (Part part : parts) {
                    String fileName = part.getSubmittedFileName();
                    if (fileName != null && !fileName.isEmpty()) {
                        String partName = part.getName();
                        String extension = "";
                        int i = fileName.lastIndexOf('.');
                        if (i > 0) {
                            extension = fileName.substring(i);
                        }
                        String uniqueName = email.replaceAll("[^a-zA-Z0-9]", "") + "_" + partName + "_"
                                + System.currentTimeMillis() + extension;
                        String fullPath = uploadPath + File.separator + uniqueName;

                        part.write(fullPath);

                        String dbPath = "uploads/intern_documents/" + uniqueName; // Portable path

                        if ("collegeIdFront".equals(partName))
                            frontPath = dbPath;
                        else if ("collegeIdBack".equals(partName))
                            backPath = dbPath;
                        else if ("bonafide".equals(partName))
                            bonafidePath = dbPath;
                    }
                }

                // 5. Database Insertion (Profile table)
                dao.saveInternProfile(email, collegeName, degreeProgram, yearSemester, studentId,
                        areasOfInterest, skills, preferredCity, availabilityDuration,
                        internship_mode, frontPath, backPath, bonafidePath);

                response.sendRedirect(request.getContextPath() + "/auth/internlogin.html?msg=Registration details submitted. Awaiting Admin Approval.");
            } else {
                response.sendRedirect(request.getContextPath() + "/intern/intern.jsp?error=Registration failed at main step.");
            }

        } catch (Exception e) {
            String logPath = request.getServletContext().getRealPath("/") + "registration_error.log";
            try (java.io.PrintWriter pw = new java.io.PrintWriter(new java.io.FileWriter(logPath, true))) {
                pw.println("--- Error at " + new java.util.Date() + " ---");
                e.printStackTrace(pw);
                pw.println("------------------------------------");
            } catch (IOException io) {
                LOGGER.log(Level.SEVERE, "Could not write to custom log", io);
            }
            LOGGER.log(Level.SEVERE, "Error processing intern registration", e);
            response.sendRedirect(request.getContextPath() + "/intern/intern.jsp?error=Server Error processing registration.");
        }
    }
}
