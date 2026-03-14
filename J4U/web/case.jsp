<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*, com.j4u.RBACUtil, java.util.Calendar" %>
<%@ include file="db_connection.jsp" %>
<%
    String username = (String) session.getAttribute("cname");
    String cemailSession = (String) session.getAttribute("cemail"); 
    if(cemailSession == null && username != null && username.contains("@")) {
        cemailSession = username;
    }
    
    if (username == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · New Case Intake</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --bg-ivory: #FAFAF8;
            --ink-primary: #121212;
            --ink-secondary: #555555;
            --ink-tertiary: #888888;
            
            --gold-main: #C6A75E;
            --gold-dim: #9C824A;
            --success-green: #059669;
            --alert-amber: #D97706;
            --danger-red: #DC2626;
            
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        body {
            margin: 0; background-color: var(--bg-ivory); color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .layout-wrapper { display: flex; min-height: 100vh; }

        /* SIDEBAR NAVIGATION */
        .sidebar {
            width: 260px; background: var(--surface-card); border-right: 1px solid var(--border-subtle);
            padding: 32px 24px; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh;
        }

        .brand { display: flex; align-items: center; gap: 12px; margin-bottom: 48px; text-decoration: none; }
        .brand-icon { font-size: 2rem; color: var(--gold-main); }
        .brand h2 { font-family: 'Playfair Display', serif; margin: 0; color: var(--ink-primary); font-size: 1.5rem; }

        .nav-group { margin-bottom: 32px; }
        .nav-title { font-size: 0.75rem; text-transform: uppercase; color: var(--ink-tertiary); margin-bottom: 12px; font-weight: 600; letter-spacing: 0.05em; }
        .nav-link {
            display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: 8px;
            color: var(--ink-secondary); text-decoration: none; font-weight: 500; transition: all 0.2s; margin-bottom: 4px; border: 1px solid transparent;
        }
        .nav-link:hover, .nav-link.active {
            background: #FAFAFA; color: var(--ink-primary); border-color: var(--border-subtle);
        }
        .nav-link.active { box-shadow: 0 2px 8px rgba(0,0,0,0.02); }
        .nav-link i { font-size: 1.2rem; color: var(--gold-dim); }

        .logout-link {
            display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: 8px;
            color: var(--ink-secondary); text-decoration: none; font-weight: 500; transition: all 0.2s; margin-top: auto;
        }
        .logout-link:hover { background: #FEF2F2; color: var(--danger-red); }
        .logout-link i { font-size: 1.2rem; }

        /* MAIN CONTENT */
        .main-content { flex: 1; padding: 40px 48px; max-width: 1000px; margin: 0 auto; }

        .smart-enter {
            opacity: 0; transform: translateY(15px);
            /* animation removed */
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }
        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* PAGE HEADER */
        .page-header { margin-bottom: 40px; display: flex; justify-content: space-between; align-items: flex-end; }
        .page-header h1 { font-family: 'Playfair Display', serif; font-size: 2.2rem; margin: 0 0 8px 0; color: var(--ink-primary); }
        .page-header p { color: var(--ink-secondary); margin: 0; font-family: 'Inter', sans-serif; font-size: 0.95rem; }
        
        .time-pill {
            display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px; background: #FAFAFA;
            border-radius: 100px; font-size: 0.8rem; font-family: 'Space Grotesk', monospace; color: var(--ink-secondary); border: 1px solid var(--border-subtle);
        }

        /* FORM PANEL */
        .panel {
            background: var(--surface-card); border-radius: 16px; border: 1px solid var(--border-subtle);
            box-shadow: var(--shadow-card); padding: 40px;
        }

        .section-title {
            font-size: 1.1rem; font-weight: 600; color: var(--ink-primary); margin: 32px 0 24px; padding-bottom: 12px; border-bottom: 1px solid var(--border-subtle); display: flex; align-items: center; gap: 8px;
        }
        .section-title:first-child { margin-top: 0; }
        .section-title i { color: var(--gold-main); font-size: 1.4rem; }

        .form-label { font-weight: 500; font-size: 0.85rem; color: var(--ink-secondary); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px; }
        .form-control, .form-select {
            padding: 14px 16px; border-radius: 8px; border: 1px solid var(--border-subtle);
            font-size: 0.95rem; font-family: "Inter", sans-serif; color: var(--ink-primary);
            box-shadow: none; transition: all 0.2s; background: #FAFAFA;
        }
        .form-control:focus, .form-select:focus { border-color: var(--ink-primary); box-shadow: 0 0 0 3px rgba(18, 18, 18, 0.05); background: #fff; outline: none; }
        
        textarea.form-control { resize: vertical; min-height: 120px; }

        /* RECIPIENT BANNER */
        .recipient-banner {
            background: #FAFAFA; border: 1px solid var(--border-subtle); border-radius: 12px; padding: 20px 24px;
            margin-bottom: 32px; display: flex; align-items: center; gap: 20px;
        }
        .recipient-banner.direct { border-color: rgba(198, 167, 94, 0.4); background: #FFFAF0; }
        .banner-icon {
            width: 56px; height: 56px; background: var(--surface-card); border: 1px solid var(--border-subtle); color: var(--ink-primary);
            border-radius: 50%; display: grid; place-items: center; font-size: 1.5rem; font-family: 'Playfair Display', serif;
        }
        .recipient-banner.direct .banner-icon { color: var(--gold-main); border-color: var(--gold-main); background: #fff; }

        .banner-text h4 { margin: 0 0 4px 0; color: var(--ink-primary); font-size: 1.1rem; font-weight: 600; }
        .banner-text p { margin: 0; font-size: 0.9rem; color: var(--ink-secondary); }

        /* BUTTONS */
        .btn-action {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            padding: 14px 28px; border-radius: 8px; font-weight: 500; font-size: 0.95rem;
            transition: all 0.2s; text-decoration: none; border: none; cursor: pointer;
        }
        .btn-primary { background: var(--ink-primary); color: #fff; }
        .btn-primary:hover { background: var(--gold-main); transform: translateY(-2px); box-shadow: 0 8px 16px rgba(198, 167, 94, 0.2); }
        .btn-secondary { background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary); }
        .btn-secondary:hover { border-color: var(--ink-primary); background: #FAFAFA; }

        .checkbox-label { display: flex; align-items: center; gap: 10px; font-size: 0.9rem; color: var(--ink-secondary); cursor: pointer; margin-top: 24px; }
        .checkbox-label input[type="checkbox"] { width: 18px; height: 18px; accent-color: var(--gold-main); cursor: pointer; }

        .error-alert {
            background: #FEF2F2; border: 1px solid #FECACA; color: var(--danger-red);
            padding: 16px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; font-size: 0.9rem;
        }

        @media (max-width: 992px) {
            .sidebar { display: none; }
            .main-content { padding: 24px; }
            .page-header { flex-direction: column; align-items: flex-start; gap: 16px; }
        }
    </style>
</head>
<body>
    <div class="layout-wrapper">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <a href="clientdashboard_manual.jsp" class="brand">
                <i class="ph-fill ph-scales brand-icon"></i>
                <h2>Justice4U</h2>
            </a>

            <div class="nav-group">
                <div class="nav-title">Client Workspace</div>
                <a href="clientdashboard_manual.jsp" class="nav-link"><i class="ph-duotone ph-squares-four"></i> Console</a>
                <a href="#" class="nav-link active"><i class="ph-duotone ph-file-plus"></i> File Case</a>
                <a href="ClientDashboard" class="nav-link"><i class="ph-duotone ph-briefcase"></i> My Portfolio</a>
            </div>
            
            <div class="nav-group">
                <div class="nav-title">Lawyer Network</div>
                <a href="findlawyer.jsp" class="nav-link"><i class="ph-duotone ph-magnifying-glass"></i> Find Counsel</a>
                <a href="viewlawdetails.jsp" class="nav-link"><i class="ph-duotone ph-identification-card"></i> Assigned Lawyer</a>
            </div>

            <a href="csignout.jsp" class="logout-link"><i class="ph-duotone ph-sign-out"></i> Secure Logout</a>
        </aside>

        <!-- MAIN WINDOW -->
        <main class="main-content">
            
            <div class="page-header smart-enter d-1">
                <div>
                    <h1>New Case Intake</h1>
                    <p>Provide details to initiate a secure legal request.</p>
                </div>
                <div class="time-pill">
                    <i class="ph-bold ph-clock"></i> Est. Time: 2-3 minutes
                </div>
            </div>

            <div class="panel smart-enter d-2">
                <form action="ProcessCaseRequestServlet" method="post" enctype="multipart/form-data">
                    
                    <%-- Error Handling --%>
                    <%
                      String errorParam = request.getParameter("error");
                      String errorMessage = (String) session.getAttribute("errorMessage");
                      if ("1".equals(errorParam) && errorMessage != null) {
                        session.removeAttribute("errorMessage");
                    %>
                    <div class="error-alert">
                        <i class="ph-fill ph-warning-circle" style="font-size:1.5rem;"></i>
                        <div><strong>Error:</strong> <%= com.j4u.Sanitizer.sanitize(errorMessage) %></div>
                    </div>
                    <% } %>

                    <%-- Dynamic Lawyer Selection Header --%>
                    <%
                      String selectedLawyerEmail = request.getParameter("lawyer_email");
                      String selectedLawyerName = request.getParameter("lawyer_name");
                      
                      if (selectedLawyerEmail != null && !selectedLawyerEmail.isEmpty()) {
                    %>
                        <div class="recipient-banner direct">
                            <div class="banner-icon"><%= selectedLawyerName.charAt(0) %></div>
                            <div class="banner-text">
                                <h4>Recipient: <%= com.j4u.Sanitizer.sanitize(selectedLawyerName) %></h4>
                                <p>This request will be sent directly to the selected lawyer for confirmation.</p>
                            </div>
                            <input type="hidden" name="selected_lawyer_email" value="<%= com.j4u.Sanitizer.sanitize(selectedLawyerEmail) %>">
                        </div>
                    <% } else { %>
                        <div class="recipient-banner">
                            <div class="banner-icon"><i class="ph-fill ph-globe-hemisphere-west"></i></div>
                            <div class="banner-text">
                                <h4>General Marketplace Request</h4>
                                <p>Case will be listed as OPEN. You can select a lawyer from the directory later.</p>
                            </div>
                        </div>
                    <% } %>

                    <div class="section-title"><i class="ph-fill ph-file-text"></i> Case Essentials</div>

                    <div class="mb-4">
                        <label for="caseTitle" class="form-label">Case Title</label>
                        <input type="text" id="caseTitle" class="form-control" name="title" placeholder="e.g., Property Dispute in Pune" required>
                    </div>

                    <div class="mb-4">
                        <label for="caseDescription" class="form-label">Detailed Description</label>
                        <textarea id="caseDescription" class="form-control" name="description" placeholder="Describe the incident, key dates, and what outcome you are looking for..." required></textarea>
                    </div>

                    <div class="row mb-4">
                        <div class="col-md-6 mb-3 mb-md-0">
                            <label for="caseCategory" class="form-label">Category</label>
                            <select id="caseCategory" class="form-select" name="category" required>
                                <option value="" disabled selected>Select Category</option>
                                <option>Criminal Defense</option>
                                <option>Civil Litigation</option>
                                <option>Family & Divorce</option>
                                <option>Property & Real Estate</option>
                                <option>Corporate Law</option>
                                <option>Cyber Crime</option>
                                <option>Consumer Protection</option>
                                <option>Other</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="caseUrgency" class="form-label">Urgency</label>
                            <select id="caseUrgency" class="form-select" name="urgency" required>
                                <option value="" disabled selected>Select Level</option>
                                <option>Standard (Reply within 48h)</option>
                                <option>High (Reply within 24h)</option>
                                <option>Critical (Immediate Attention)</option>
                            </select>
                        </div>
                    </div>

                    <div class="section-title"><i class="ph-fill ph-map-pin-line"></i> Jurisdiction & Logistics</div>

                    <div class="row mb-4">
                        <div class="col-md-6 mb-3 mb-md-0">
                            <label for="courtType" class="form-label">Target Court</label>
                            <select id="courtType" class="form-select" name="courtType" required>
                                <option value="" disabled selected>Select Court Tier</option>
                                <option>District / Sessions Court</option>
                                <option>High Court</option>
                                <option>Supreme Court</option>
                                <option>Tribunal / Other</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="city" class="form-label">City</label>
                            <input type="text" id="city" class="form-control" name="city" placeholder="e.g. Mumbai" required>
                        </div>
                    </div>

                    <div class="section-title"><i class="ph-fill ph-paperclip"></i> Attachments & Payment</div>

                    <div class="mb-4">
                        <label for="documents" class="form-label">Case Evidence / Documents (PDF, JPG)</label>
                        <input type="file" id="documents" class="form-control" name="documents" accept=".pdf,.jpg,.png" required style="padding-top:10px;">
                    </div>

                    <div class="row mb-4">
                        <div class="col-md-6 mb-3 mb-md-0">
                             <label for="regFee" class="form-label">Registration Fee</label>
                             <input type="text" id="regFee" class="form-control" value="₹ 500.00" readonly style="background:#F1F5F9; color:var(--ink-secondary); font-weight:600; font-family:'Space Grotesk', monospace;">
                        </div>
                        <div class="col-md-6">
                             <label for="paymentMode" class="form-label">Payment Mode</label>
                             <select id="paymentMode" class="form-select" name="paymentMode" required>
                                 <option>UPI (PhonePe / GPay)</option>
                                 <option>Credit / Debit Card</option>
                                 <option>Net Banking</option>
                             </select>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="transactionId" class="form-label">Transaction ID / Reference No.</label>
                        <input type="text" id="transactionId" class="form-control" name="transactionId" placeholder="Enter UPI Ref ID or Transaction No." required pattern="[A-Za-z0-9]{8,20}">
                    </div>
                    
                    <label class="checkbox-label">
                        <input type="checkbox" required>
                        I confirm that the details provided are accurate and authorize Justice4U to process this request.
                    </label>

                    <div style="margin-top: 40px; display: flex; gap: 16px;">
                        <button type="submit" class="btn-action btn-primary">
                            Submit & Initiate Case <i class="ph-bold ph-arrow-right"></i>
                        </button>
                        <a href="clientdashboard_manual.jsp" class="btn-action btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </main>
    </div>
</body>
</html>
