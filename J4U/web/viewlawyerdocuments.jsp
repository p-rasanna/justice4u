<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%
    String message = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U – Document Verification</title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        /* ============================
           1. 10/10 INTELLIGENCE THEME
           ============================ */
        :root {
            --bg-ivory: #FAFAF8;
            --ink-primary: #121212;
            --ink-secondary: #555555;
            --ink-tertiary: #888888;
            
            /* Authority Colors */
            --gold-main: #C6A75E;
            --gold-dim: #9C824A;
            --alert-amber: #D97706;
            --success-green: #059669;
            --danger-red: #DC2626;
            
            /* Surfaces */
            --surface-card: #FFFFFF;
            --surface-hover: #FDFDFD;
            --border-subtle: #E6E6E6;
            --border-focus: #121212;
            
            /* 10/10 Physics */
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --shadow-hover: 0 15px 40px -10px rgba(198, 167, 94, 0.15);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background-color: var(--bg-ivory);
            color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        /* ============================
           2. LAYOUT & STRUCTURE
           ============================ */
        .dashboard-shell {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 32px;
        }

        /* Entrance Stagger */
        .smart-enter {
            opacity: 0; transform: translateY(15px);
            /* animation removed */
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }
        .d-3 { animation-delay: 0.3s; }

        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* ============================
           3. INTELLIGENT HEADER
           ============================ */
        .admin-header {
            display: flex; justify-content: space-between; align-items: flex-end;
            margin-bottom: 48px; border-bottom: 1px solid var(--border-subtle); padding-bottom: 24px;
        }

        .header-content h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.2rem; margin: 0; color: var(--ink-primary);
        }
        
        .header-meta {
            display: flex; gap: 24px; align-items: center; margin-top: 8px;
            font-family: 'Space Grotesk', monospace; font-size: 0.8rem; color: var(--ink-secondary);
        }
        .meta-item { display: flex; align-items: center; gap: 6px; }
        .secure-lock { color: var(--success-green); }

        .admin-profile {
            display: flex; align-items: center; gap: 12px;
            padding: 8px 16px; background: #fff; border: 1px solid var(--border-subtle);
            border-radius: 100px; box-shadow: var(--shadow-card);
        }
        .profile-role { 
            font-family: 'Inter', sans-serif;
            font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600; color: var(--gold-main); 
        }
        .profile-dot { width: 8px; height: 8px; background: var(--success-green); border-radius: 50%; box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.1); }

        /* ============================
           4. DATA MANAGEMENT PANEL
           ============================ */
        .lawyer-card {
            background: var(--surface-card);
            border: 1px solid var(--border-subtle);
            border-radius: 16px; overflow: hidden;
            box-shadow: var(--shadow-card);
            display: flex; flex-direction: column;
            margin-bottom: 32px;
        }

        .lawyer-header {
            padding: 24px; border-bottom: 1px solid var(--border-subtle);
            display: flex; justify-content: space-between; align-items: center;
            background: #FAFAFA;
        }

        .lawyer-info h3 { 
            font-family: 'Inter', sans-serif; 
            font-size: 1.1rem; margin: 0 0 4px 0; font-weight: 600; color: var(--ink-primary); 
            display: flex; align-items: center; gap: 8px;
        }

        .lawyer-info p {
            margin: 0; font-size: 0.85rem; color: var(--ink-secondary);
        }

        .status-badge {
            font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
            padding: 4px 10px; border-radius: 100px;
        }

        .status-pending { background: rgba(217, 119, 6, 0.1); color: var(--alert-amber); }
        .status-verified { background: rgba(5, 150, 105, 0.1); color: var(--success-green); }
        .status-rejected { background: rgba(220, 38, 38, 0.1); color: var(--danger-red); }

        /* ============================
           5. DOCUMENT GRID
           ============================ */
        .documents-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            padding: 24px;
        }

        .document-card {
            background: #FAFAFA;
            border: 1px solid var(--border-subtle);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            transition: all 0.2s var(--ease-smart);
        }

        .document-card:hover { border-color: var(--gold-main); transform: translateY(-2px); box-shadow: var(--shadow-card); }

        .document-icon {
            width: 48px; height: 48px;
            margin: 0 auto 16px;
            background: #F5F5F0; color: var(--gold-main);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
            transition: all 0.2s;
        }

        .document-card:hover .document-icon { background: var(--gold-main); color: #fff; }

        .document-name {
            font-size: 0.9rem; font-weight: 600; color: var(--ink-primary); margin-bottom: 8px;
        }

        .document-status {
            font-size: 0.75rem; padding: 4px 8px; border-radius: 100px; display: inline-block; margin-bottom: 16px;
        }

        .document-actions {
            display: flex; gap: 8px; justify-content: center; flex-wrap: wrap;
        }

        /* Action Buttons */
        .btn-view, .btn-approve, .btn-reject {
            display: inline-flex; align-items: center; justify-content: center; gap: 4px;
            padding: 6px 12px; border-radius: 6px;
            font-size: 0.75rem; font-weight: 600; text-decoration: none;
            transition: all 0.2s; background: #fff; border: 1px solid var(--border-subtle);
            cursor: pointer;
        }

        .btn-view { color: var(--ink-primary); }
        .btn-view:hover { background: #f5f5f5; border-color: var(--ink-secondary); transform: translateY(-1px); }

        .btn-approve { color: var(--success-green); border-color: rgba(5, 150, 105, 0.3); }
        .btn-approve:hover { background: var(--success-green); color: #fff; border-color: var(--success-green); transform: translateY(-1px); }

        .btn-reject { color: var(--danger-red); border-color: rgba(220, 38, 38, 0.3); }
        .btn-reject:hover { background: var(--danger-red); color: #fff; border-color: var(--danger-red); transform: translateY(-1px); }

        .bulk-actions {
            text-align: center; padding: 20px 24px;
            border-top: 1px solid var(--border-subtle);
            background: #FAFAFA;
        }

        /* ============================
           6. ALERTS & NAVIGATION
           ============================ */
        .alert-info {
            background: #FFFBEB; border: 1px solid #FEF3C7; border-left: 4px solid var(--alert-amber);
            color: #92400E; padding: 16px; border-radius: 8px; margin-bottom: 24px; font-weight: 500; font-size: 0.9rem;
        }

        .alert-danger {
            background: #FEF2F2; border: 1px solid #FEE2E2; border-left: 4px solid var(--danger-red);
            color: #991B1B; padding: 16px; border-radius: 8px; margin-bottom: 24px; font-weight: 500; font-size: 0.9rem;
        }

        .footer-nav {
            display: flex; justify-content: flex-end; gap: 16px; margin-top: 24px;
        }
        
        .btn-nav {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: 0.85rem;
            text-decoration: none; transition: all 0.2s;
        }
        
        .btn-back { background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary); }
        .btn-back:hover { border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-1px); }

    </style>
</head>
<body>
    <div class="dashboard-shell">

        <header class="admin-header smart-enter d-1">
            <div class="header-content">
                <h1>Document Verification</h1>
                <div class="header-meta">
                    <span class="meta-item"><i class="ph ph-lock-key secure-lock"></i> Secure Session Active</span>
                    <span class="meta-item"><i class="ph ph-file-text"></i> Audit Trailing</span>
                </div>
            </div>
            <div class="admin-profile">
                <span class="profile-dot"></span>
                <span class="profile-role">System Admin</span>
            </div>
        </header>

        <% if(message != null && !message.isEmpty()) { %>
            <div class="<%= message.contains("Error") || message.contains("Failed") ? "alert-danger" : "alert-info" %> smart-enter d-1">
                <i class="ph <%= message.contains("Error") ? "ph-warning-circle" : "ph-info" %>"></i> <%= message %>
            </div>
        <% } %>

        <%
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection con = getDatabaseConnection();

                // Get lawyers with pending documents
                String query = "SELECT DISTINCT l.lid, l.name, l.email, " +
                              "COALESCE(l.document_verification_status, 'PENDING') as doc_status " +
                              "FROM lawyer_reg l " +
                              "INNER JOIN lawyer_documents d ON l.lid = d.lawyer_id " +
                              "WHERE d.status = 'PENDING' " +
                              "ORDER BY l.lid";

                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery(query);

                boolean hasLawyers = false;

                while(rs.next()) {
                    hasLawyers = true;
                    int lawyerId = rs.getInt("lid");
                    String lawyerName = rs.getString("name");
                    String lawyerEmail = rs.getString("email");
                    String overallStatus = rs.getString("doc_status");
        %>

        <div class="lawyer-card">
            <div class="lawyer-header">
                <div class="lawyer-info">
                    <h3><%= lawyerName %></h3>
                    <p><%= lawyerEmail %></p>
                </div>
                <div class="status-badge status-<%= overallStatus.toLowerCase() %>">
                    <%= overallStatus %>
                </div>
            </div>

            <div class="documents-grid">
                <%
                    // Get documents for this lawyer
                    PreparedStatement docPst = con.prepareStatement(
                        "SELECT doc_id, document_type, file_name, status FROM lawyer_documents WHERE lawyer_id = ? ORDER BY document_type");
                    docPst.setInt(1, lawyerId);
                    ResultSet docRs = docPst.executeQuery();

                    while(docRs.next()) {
                        int docId = docRs.getInt("doc_id");
                        String docType = docRs.getString("document_type");
                        String fileName = docRs.getString("file_name");
                        String docStatus = docRs.getString("status");

                        String displayName = "";
                        String icon = "";

                        switch(docType) {
                            case "BAR_CERTIFICATE":
                                displayName = "Bar Council Certificate";
                                icon = "<i class='ph ph-scales'></i>";
                                break;
                            case "GOV_ID_PROOF":
                                displayName = "Government ID Proof";
                                icon = "<i class='ph ph-identification-card'></i>";
                                break;
                            case "PROFESSIONAL_PHOTO":
                                displayName = "Professional Photograph";
                                icon = "<i class='ph ph-camera'></i>";
                                break;
                            case "LIVE_SELFIE":
                                displayName = "Live Selfie";
                                icon = "<i class='ph ph-device-mobile-camera'></i>";
                                break;
                            default:
                                displayName = docType;
                                icon = "<i class='ph ph-file-text'></i>";
                        }
                %>

                <div class="document-card">
                    <div class="document-icon"><%= icon %></div>
                    <div class="document-name"><%= displayName %></div>
                    <div class="document-status status-<%= docStatus.toLowerCase() %>">
                        <%= docStatus %>
                    </div>

                    <div class="document-actions">
                        <a href="#" class="btn-view" onclick="viewDocument('<%= fileName %>')"><i class="ph ph-eye"></i> View</a>
                        <% if("PENDING".equals(docStatus)) { %>
                            <button class="btn-approve" onclick="verifyDocument(<%= docId %>, 'approve')"><i class="ph ph-check"></i> Approve</button>
                            <button class="btn-reject" onclick="verifyDocument(<%= docId %>, 'reject')"><i class="ph ph-x"></i> Reject</button>
                        <% } %>
                    </div>
                </div>

                <%
                    }
                    docRs.close();
                    docPst.close();
                %>
            </div>

            <div class="bulk-actions">
                <p class="mb-3" style="color: var(--ink-secondary); font-size: 0.9rem;"><strong>Bulk Actions:</strong> Approve all pending documents for this lawyer</p>
                <button class="btn-approve" style="padding: 10px 20px; font-size: 0.85rem;" onclick="approveAllDocuments(<%= lawyerId %>)">
                    <i class="ph ph-checks"></i> Approve All Documents
                </button>
            </div>
        </div>

        <%
                }

                if(!hasLawyers) {
        %>
        <div class="lawyer-card smart-enter d-2">
            <div style="text-align: center; padding: 40px;">
                <i class="ph ph-check-circle" style="font-size: 3rem; color: var(--success-green); margin-bottom: 16px;"></i>
                <h3 style="color: var(--ink-primary); font-family: 'Playfair Display', serif;">No Pending Documents</h3>
                <p style="color: var(--ink-secondary); font-size: 0.9rem;">All lawyer documents have been reviewed.</p>
            </div>
        </div>
        <%
                }

                rs.close();
                st.close();
                con.close();

            } catch(Exception e) {
        %>
        <%
            }
        %>
        
        <!-- Document Viewer Modal -->
        <div class="modal fade" id="documentViewerModal" tabindex="-1" aria-labelledby="documentViewerModalLabel" aria-hidden="true" style="z-index: 1055;">
            <div class="modal-dialog modal-xl modal-dialog-centered">
                <div class="modal-content" style="border-radius: 16px; border: 1px solid var(--border-subtle); box-shadow: var(--shadow-hover);">
                    <div class="modal-header" style="background: #FAFAFA; border-bottom: 1px solid var(--border-subtle); border-radius: 16px 16px 0 0; padding: 16px 24px;">
                        <h5 class="modal-title" id="documentViewerModalLabel" style="font-family: 'Inter', sans-serif; font-size: 1.1rem; font-weight: 600; color: var(--ink-primary); display: flex; align-items: center; gap: 8px;">
                            <i class="ph ph-file-text" style="color: var(--gold-main); font-size: 1.4rem;"></i>
                            Document Viewer
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center p-4" id="documentViewerContainer" style="background: var(--bg-ivory); min-height: 50vh; display: flex; align-items: center; justify-content: center; overflow: auto;">
                        <!-- Content will be injected here via JS -->
                    </div>
                    <div class="modal-footer" style="background: #FAFAFA; border-top: 1px solid var(--border-subtle); border-radius: 0 0 16px 16px; padding: 12px 24px;">
                        <button type="button" class="btn btn-secondary" style="font-size: 0.85rem; font-weight: 500; border-radius: 8px; border: 1px solid var(--border-subtle); background: #fff; color: var(--ink-primary);" data-bs-dismiss="modal">Close Viewer</button>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="footer-nav smart-enter d-3">
            <a href="admindashboard.jsp" class="btn-nav btn-back">
                <i class="ph ph-arrow-left"></i> Back to Dashboard
            </a>
        </div>
    </div>

    <script>
        function viewDocument(fileName) {
            const fileUrl = 'uploads/lawyer_documents/' + fileName;
            const ext = fileName.split('.').pop().toLowerCase();
            const viewerContainer = document.getElementById('documentViewerContainer');
            
            // Show image tag if it is an image, otherwise fallback to iframe (for PDF and other files)
            if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext)) {
                viewerContainer.innerHTML = `<img src="${fileUrl}" style="max-width: 100%; height: auto; border-radius: 8px; box-shadow: var(--shadow-card);" alt="Document">`;
            } else {
                viewerContainer.innerHTML = `<iframe src="${fileUrl}" style="width: 100%; height: 75vh; border: 1px solid var(--border-subtle); border-radius: 8px; box-shadow: var(--shadow-card);"></iframe>`;
            }
            
            const docModal = new bootstrap.Modal(document.getElementById('documentViewerModal'));
            docModal.show();
        }

        function verifyDocument(docId, action) {
            if(confirm('Are you sure you want to ' + action + ' this document?')) {
                window.location.href = 'verifylawyerdoc.jsp?action=' + action + '&doc_id=' + docId;
            }
        }

        function approveAllDocuments(lawyerId) {
            if(confirm('Are you sure you want to approve ALL pending documents for this lawyer?')) {
                window.location.href = 'verifylawyerdoc.jsp?action=approve_all&lawyer_id=' + lawyerId;
            }
        }
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
