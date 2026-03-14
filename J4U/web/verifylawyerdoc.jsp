<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="db_connection.jsp" %>
<%
    String action = request.getParameter("action");
    String docId = request.getParameter("doc_id");
    String lawyerId = request.getParameter("lawyer_id");

    boolean success = false;
    String message = "";

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = getDatabaseConnection();

        if("approve".equals(action) && docId != null) {
            // Approve single document
            PreparedStatement pst = con.prepareStatement(
                "UPDATE lawyer_documents SET status='VERIFIED', admin_review_date=NOW() WHERE doc_id=?");
            pst.setInt(1, Integer.parseInt(docId));
            int result = pst.executeUpdate();

            if(result > 0) {
                success = true;
                message = "Document approved successfully!";
            } else {
                message = "Failed to approve document.";
            }
            pst.close();

        } else if("reject".equals(action) && docId != null) {
            // Reject single document
            PreparedStatement pst = con.prepareStatement(
                "UPDATE lawyer_documents SET status='REJECTED', admin_review_date=NOW() WHERE doc_id=?");
            pst.setInt(1, Integer.parseInt(docId));
            int result = pst.executeUpdate();

            if(result > 0) {
                success = true;
                message = "Document rejected.";
            } else {
                message = "Failed to reject document.";
            }
            pst.close();

        } else if("approve_all".equals(action) && lawyerId != null) {
            // Approve all documents for a lawyer
            PreparedStatement pst = con.prepareStatement(
                "UPDATE lawyer_documents SET status='VERIFIED', admin_review_date=NOW() WHERE lawyer_id=? AND status='PENDING'");
            pst.setInt(1, Integer.parseInt(lawyerId));
            int result = pst.executeUpdate();

            if(result > 0) {
                // Update lawyer verification status
                PreparedStatement lawyerPst = con.prepareStatement(
                    "UPDATE lawyer_reg SET document_verification_status='VERIFIED' WHERE lid=?");
                lawyerPst.setInt(1, Integer.parseInt(lawyerId));
                lawyerPst.executeUpdate();
                lawyerPst.close();

                success = true;
                message = "All documents approved successfully! Lawyer verification status updated.";
            } else {
                message = "No pending documents found to approve.";
            }
            pst.close();
        }

        // Check if all documents for lawyer are verified
        if(lawyerId != null) {
            PreparedStatement checkPst = con.prepareStatement(
                "SELECT COUNT(*) as pending_count FROM lawyer_documents WHERE lawyer_id=? AND status='PENDING'");
            checkPst.setInt(1, Integer.parseInt(lawyerId));
            ResultSet checkRs = checkPst.executeQuery();

            if(checkRs.next() && checkRs.getInt("pending_count") == 0) {
                // All documents verified, update lawyer status
                PreparedStatement updatePst = con.prepareStatement(
                    "UPDATE lawyer_reg SET document_verification_status='VERIFIED' WHERE lid=?");
                updatePst.setInt(1, Integer.parseInt(lawyerId));
                updatePst.executeUpdate();
                updatePst.close();
            }
            checkRs.close();
            checkPst.close();
        }

        con.close();

    } catch(Exception e) {
        message = "Error: " + e.getMessage();
    }

    // Redirect back with message
    response.sendRedirect("viewlawyerdocuments.jsp?msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
%>
