<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%
    // 1. Session & Role Check
    String lawyerEmail = (String) session.getAttribute("lname");
    Integer lawyerId = (Integer) session.getAttribute("lid");

    if (lawyerEmail == null || lawyerId == null) {
        response.sendRedirect("Lawyer_login.html?msg=Please login to view documents");
        return;
    }

    // 2. Extract Case ID
    String caseIdParam = request.getParameter("caseId");
    if (caseIdParam == null || caseIdParam.isEmpty()) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Invalid case reference");
        return;
    }

    int caseId = Integer.parseInt(caseIdParam);
    String caseTitle = "";
    String clientName = "";

    try {
        Connection con = getDatabaseConnection();
        
        // 3. Authorization Check
        // Ensure this lawyer is assigned to the case
        PreparedStatement psAuth = con.prepareStatement(
            "SELECT al.title, al.name FROM allotlawyer al WHERE al.alid = ? AND al.lname = ?"
        );
        psAuth.setInt(1, caseId);
        psAuth.setString(2, lawyerEmail);
        ResultSet rsAuth = psAuth.executeQuery();
        
        if (rsAuth.next()) {
            caseTitle = rsAuth.getString("title");
            clientName = rsAuth.getString("name");
        } else {
            con.close();
            response.sendRedirect("Lawyerdashboard.jsp?msg=Unauthorized access to case documents");
            return;
        }
        rsAuth.close();
        psAuth.close();
        con.close();
    } catch (Exception e) {
        response.sendRedirect("Lawyerdashboard.jsp?msg=Database error: " + e.getMessage());
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Case Repository</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --bg-ivory: #FAFAF8;
            --ink-primary: #121212;
            --ink-secondary: #555555;
            --gold-main: #C6A75E;
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
        }
        body {
            background-color: var(--bg-ivory);
            color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            padding: 40px 20px;
        }
        .doc-container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .header-panel {
            background: var(--surface-card);
            padding: 24px;
            border-radius: 16px;
            border: 1px solid var(--border-subtle);
            margin-bottom: 32px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.02);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .doc-card {
            background: var(--surface-card);
            border: 1px solid var(--border-subtle);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 16px;
            transition: all 0.2s;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .doc-card:hover {
            border-color: var(--gold-main);
            transform: translateY(-2px);
            box-shadow: 0 10px 30px -10px rgba(198, 167, 94, 0.1);
        }
        .role-tag {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 100px;
        }
        .role-intern { background: #E0F2FE; color: #0369A1; }
        .role-lawyer { background: #F0FDF4; color: #166534; }
        .role-client { background: #FEF3C7; color: #92400E; }
        .btn-download {
            background: var(--gold-main);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            font-size: 0.85rem;
        }
        .btn-download:hover {
            background: #B0924B;
            color: white;
        }
    </style>
</head>
<body>
    <div class="doc-container">
        <div class="header-panel">
            <div>
                <h6 class="text-uppercase text-muted mb-1" style="font-size: 0.7rem; letter-spacing: 0.1em;">Case Folder #<%= caseId %></h6>
                <h2 style="font-family: 'Playfair Display', serif; margin: 0;"><%= com.j4u.Sanitizer.sanitize(caseTitle) %></h2>
                <p class="mb-0 text-muted" style="font-size: 0.85rem;">Client: <%= com.j4u.Sanitizer.sanitize(clientName) %></p>
            </div>
            <div class="d-flex gap-2">
                <a href="viewcase.jsp?id=<%= caseId %>" class="btn btn-outline-secondary btn-sm">Back to Case</a>
            </div>
        </div>

        <h5 class="mb-4 d-flex align-items-center gap-2">
            <i class="ph-bold ph-files" style="color:var(--gold-main);"></i> All Documents
        </h5>

        <%
            try {
                Connection con = getDatabaseConnection();
                PreparedStatement ps = con.prepareStatement(
                    "SELECT file_name, file_path, uploader_role, uploaded_at, uploader_email FROM case_documents WHERE case_id=? ORDER BY uploaded_at DESC"
                );
                ps.setInt(1, caseId);
                ResultSet rs = ps.executeQuery();

                boolean found = false;
                while (rs.next()) {
                    found = true;
                    String fileName = rs.getString("file_name");
                    String filePath = rs.getString("file_path");
                    String role = rs.getString("uploader_role");
                    String date = rs.getString("uploaded_at");
                    String uploader = rs.getString("uploader_email");
        %>
            <div class="doc-card">
                <div class="d-flex align-items-center gap-3">
                    <div style="width: 40px; height: 40px; background: #f5f5f5; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; color: var(--gold-main);">
                        <i class="ph ph-file"></i>
                    </div>
                    <div>
                        <div style="font-weight: 600; font-size: 0.95rem;"><%= com.j4u.Sanitizer.sanitize(fileName) %></div>
                        <div style="font-size: 0.75rem; color: var(--ink-secondary);">
                            <span class="role-tag role-<%= role.toLowerCase() %>"><%= role %></span> 
                            &bull; <%= date %> &bull; <%= uploader %>
                        </div>
                    </div>
                </div>
                <!-- Logic for download: In a real system, we'd serve via a stream servlet. 
                     For this prototype, we'll link to a relative path assuming web accessibility or provide a placeholder. -->
                <a href="download_case_doc.jsp?file=<%= java.net.URLEncoder.encode(fileName, "UTF-8") %>" class="btn-download">
                    <i class="ph ph-download-simple"></i> Download
                </a>
            </div>
        <%
                }
                if (!found) {
        %>
            <div class="text-center py-5 text-muted bg-white border rounded-3">
                <i class="ph ph-folder-open mb-2" style="font-size: 3rem;"></i>
                <p>No documents found in this case repository yet.</p>
            </div>
        <%
                }
                rs.close(); ps.close(); con.close();
            } catch (Exception e) {
        %>
            <div class="alert alert-danger">Error fetching documents: <%= e.getMessage() %></div>
        <%
            }
        %>
    </div>
</body>
</html>
