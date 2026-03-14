<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    // View-layer fallback authentication guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U – Approve Interns</title>

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
        .panel {
            background: var(--surface-card);
            border: 1px solid var(--border-subtle);
            border-radius: 16px; overflow: hidden;
            box-shadow: var(--shadow-card);
            display: flex; flex-direction: column;
            margin-bottom: 32px;
        }

        .panel-head {
            padding: 24px; border-bottom: 1px solid var(--border-subtle);
            display: flex; justify-content: space-between; align-items: center;
            background: #FAFAFA;
        }
        .panel-head h3 { 
            font-family: 'Inter', sans-serif; 
            font-size: 1.1rem; margin: 0; font-weight: 600; color: var(--ink-primary); 
            display: flex; align-items: center; gap: 8px;
        }
        .panel-icon { color: var(--gold-main); font-size: 1.4rem; }

        .tag-info {
            font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
            color: var(--ink-secondary); background: #f5f5f5; padding: 4px 10px; border-radius: 100px;
        }

        /* ============================
           5. INTELLIGENT TABLE
           ============================ */
        .table-responsive {
            max-height: 600px; overflow: auto;
        }
        
        .table {
            margin-bottom: 0;
            width: 100%; border-collapse: collapse;
        }
        
        .table thead th {
            background: #FAFAFA;
            color: var(--ink-secondary);
            font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-subtle);
            position: sticky; top: 0; z-index: 10;
        }

        .table tbody tr {
            transition: background 0.2s;
            border-bottom: 1px solid #f5f5f5;
        }
        
        .table tbody tr:hover { background: #FCFCFA; }

        .table tbody td {
            padding: 16px 20px;
            font-size: 0.85rem; color: var(--ink-primary);
            vertical-align: middle;
        }

        /* Status Pills */
        .status-pill {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 4px 10px; border-radius: 100px;
            font-size: 0.75rem; font-weight: 600; letter-spacing: 0.02em;
        }
        .status-pending { background: rgba(217, 119, 6, 0.1); color: var(--alert-amber); }

        /* Actions */
        .action-flex { display: flex; gap: 8px; align-items: center; }
        
        .btn-action {
            display: inline-flex; align-items: center; justify-content: center; gap: 4px;
            padding: 6px 14px; border-radius: 6px;
            font-size: 0.8rem; font-weight: 600; text-decoration: none;
            transition: all 0.2s; background: #fff; border: 1px solid var(--border-subtle);
        }
        
        .btn-approve { color: var(--success-green); border-color: rgba(5, 150, 105, 0.3); }
        .btn-approve:hover { background: var(--success-green); color: #fff; transform: translateY(-1px); border-color: var(--success-green); }

        .btn-reject { color: var(--danger-red); border-color: rgba(220, 38, 38, 0.3); }
        .btn-reject:hover { background: var(--danger-red); color: #fff; transform: translateY(-1px); border-color: var(--danger-red); }

        /* ============================
           6. NAVIGATION FOOTER
           ============================ */
        .footer-nav {
            display: flex; justify-content: flex-end; gap: 16px; margin-top: 24px;
        }
        
        .btn-nav {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: 0.85rem;
            text-decoration: none; transition: all 0.2s;
        }
        
        .btn-back {
            background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary);
        }
        .btn-back:hover { border-color: var(--gold-main); color: var(--gold-main); }
        
        .btn-danger { background: var(--danger-red); color: #fff; border: none; }
        .btn-danger:hover { opacity: 0.9; }

        /* Alerts */
        .alert-info {
            background: #FFFBEB; border: 1px solid #FEF3C7; border-left: 4px solid var(--alert-amber);
            color: #92400E; padding: 16px; border-radius: 8px; margin-bottom: 24px; font-weight: 500; font-size: 0.9rem;
        }

    </style>
</head>

<body>
    <div class="dashboard-shell">

        <header class="admin-header smart-enter d-1">
            <div class="header-content">
                <h1>Pending Intern Approvals</h1>
                <div class="header-meta">
                    <span class="meta-item"><i class="ph ph-lock-key secure-lock"></i> Secure Session Active</span>
                    <span class="meta-item"><i class="ph ph-graduation-cap"></i> Personnel Management</span>
                </div>
            </div>
            <div class="admin-profile">
                <span class="profile-dot"></span>
                <span class="profile-role">System Admin</span>
            </div>
        </header>

        <c:if test="${not empty param.msg}">
            <div class="alert alert-info smart-enter d-1">
                <i class="ph ph-info"></i> <c:out value="${param.msg}" />
            </div>
        </c:if>

        <div class="panel smart-enter d-2">
            <div class="panel-head">
                <h3><i class="ph ph-users panel-icon"></i> Incoming Intern Applications</h3>
                <span class="tag-info">Approval Queue</span>
            </div>

            <div class="table-responsive">
                <table class="table">
              <thead>
                <tr>
                  <th>Intern Id</th>
                  <th>Name</th>
                  <th>Email</th>
                  <th>DOB</th>
                  <th>Mobile</th>
                  <th>Aadhar</th>
                  <th>Current Address</th>
                  <th>Permanent Address</th>
                  <th>Payment Mode</th>
                  <th>Txn ID</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th>Approve</th>
                  <th>Reject</th>
                </tr>
              </thead>
              <tbody>
              <c:choose>
                <c:when test="${not empty pendingInterns}">
                  <c:forEach var="intern" items="${pendingInterns}">
                    <tr>
                      <td><c:out value="${intern.id}" /></td>
                      <td><c:out value="${intern.name}" /></td>
                      <td><c:out value="${intern.email}" /></td>
                      <td><c:out value="${intern.dob}" /></td>
                      <td><c:out value="${intern.mobile}" /></td>
                      <td><c:out value="${intern.aadhar}" /></td>
                      <td><c:out value="${intern.currentAddress}" /></td>
                      <td><c:out value="${intern.permanentAddress}" /></td>
                      <td><c:out value="${intern.paymentMode}" /></td>
                      <td><c:out value="${intern.txnId}" /></td>
                      <td><c:out value="${intern.amount}" /></td>
                      <td>
                        <span class="status-pill status-pending">
                          <i class='ph ph-clock'></i> Pending
                        </span>
                      </td>
                      <td>
                        <div class="action-flex">
                          <a href="approvei.jsp?id=${intern.id}" class="btn-action btn-approve">
                            <i class="ph ph-check"></i> Approve
                          </a>
                        </div>
                      </td>
                      <td>
                        <div class="action-flex">
                          <a href="rejecti.jsp?id=${intern.id}" class="btn-action btn-reject" onclick="return confirm('Reject intern application?')">
                            <i class="ph ph-x"></i> Reject
                          </a>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="14" class="text-center" style="padding: 24px; color: var(--ink-secondary);">No pending intern applications queue empty.</td>
                  </tr>
                </c:otherwise>
              </c:choose>
              </tbody>
            </table>
          </div>
      </div>

      <div class="footer-nav smart-enter d-3">
        <a href="admindashboard.jsp" class="btn-nav btn-back">
          <i class="ph ph-arrow-left"></i> Back to Dashboard
        </a>
        <a href="asignout.jsp" class="btn-nav btn-danger">
          <i class="ph ph-sign-out"></i> Sign Out
        </a>
      </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
