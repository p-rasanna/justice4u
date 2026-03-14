<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.io.*,javax.servlet.http.Part" %>
<%@ include file="db_connection.jsp" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%
    // 1. Session Check (Lawyer)
    String lawyerEmail = (String) session.getAttribute("lname");
    if (lawyerEmail == null) {
        response.sendRedirect("Lawyerlogin.html");
        return;
    }

    String msg = "";
    try {
        Part filePart = request.getPart("file"); 
        String caseIdParam = request.getParameter("caseId");
        
        if (filePart == null || caseIdParam == null) {
            throw new Exception("Missing file or case ID");
        }

        int caseId = Integer.parseInt(caseIdParam);
        String fileName = filePart.getSubmittedFileName();

        Connection con = getDatabaseConnection();
        
        // 2. Resolve Lawyer ID
        int lawyerId = 0;
        PreparedStatement psL = con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?");
        psL.setString(1, lawyerEmail);
        ResultSet rsL = psL.executeQuery();
        if (rsL.next()) { lawyerId = rsL.getInt("lid"); }
        rsL.close(); psL.close();

        // 3. Verify Assignment (Lawyer can upload to any case they are assigned to via customer_cases OR allotlawyer)
        // Check customer_cases first (New Schema)
        PreparedStatement psAuth = con.prepareStatement(
            "SELECT case_id FROM customer_cases WHERE assigned_lawyer_id=? AND case_id=? AND status='ASSIGNED'"
        );
        psAuth.setInt(1, lawyerId);
        psAuth.setInt(2, caseId);
        ResultSet rsAuth = psAuth.executeQuery();
        boolean isAssigned = rsAuth.next();
        rsAuth.close(); psAuth.close();
        
        // Fallback check for allotlawyer (Old Schema - just in case)
        if (!isAssigned) {
             PreparedStatement psOld = con.prepareStatement("SELECT alid FROM allotlawyer WHERE lname=? AND alid=?");
             // Note: viewcase.jsp passes 'id' which acts as alid/cid. Assuming cid here.
             // If mismatch, lawyer might be using legacy ID.
             psOld.setString(1, lawyerEmail); // allotlawyer uses lname string
             psOld.setInt(2, caseId);
             ResultSet rsOld = psOld.executeQuery();
             isAssigned = rsOld.next();
             rsOld.close(); psOld.close();
        }

        if (!isAssigned) {
            con.close();
            response.sendRedirect("viewcase.jsp?id=" + caseId + "&msg=Unauthorized Upload Access");
            return;
        }

        // 4. Save File
        String uploadPath = "C:/J4U_Uploads/case_documents/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String secureName = "CASE" + caseId + "_LAWYER_" + System.currentTimeMillis() + "_" + fileName;
        filePart.write(uploadPath + secureName);

        // 5. Insert Record
        PreparedStatement psIns = con.prepareStatement(
            "INSERT INTO case_documents (case_id, uploader_email, uploader_role, file_name, file_path) VALUES (?, ?, 'lawyer', ?, ?)"
        );
        psIns.setInt(1, caseId);
        psIns.setString(2, lawyerEmail);
        psIns.setString(3, fileName); 
        psIns.setString(4, uploadPath + secureName);
        psIns.executeUpdate();
        psIns.close();
        con.close();

        msg = "Document Uploaded Successfully";

    } catch (Exception e) {
        e.printStackTrace();
        msg = "Upload Failed: " + e.getMessage();
    }

    // Redirect back to viewcase.jsp
    // viewcase.jsp uses param 'id'
    response.sendRedirect("viewcase.jsp?id=" + request.getParameter("caseId") + "&msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
%>
