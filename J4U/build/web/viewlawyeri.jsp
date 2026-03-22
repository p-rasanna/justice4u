<%-- 
    Document   : viewlawyers
    Created on : 3 Apr, 2025, 8:15:04 PM
    Author     : ZulkiflMugad
--%>


<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%
  String message = request.getParameter("msg");
%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Justice4U · Lawyer Approvals</title>

    <!-- Bootstrap 3 -->
    <link rel="stylesheet"
          href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>

    <!-- Inter font to match client dashboard -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
      :root {
        /* Same palette as client dashboard */
        --j4u-bg: #f5f2ea;
        --j4u-surface: #fdfbf6;
        --j4u-surface-soft: #faf5ea;
        --j4u-border: #ddd1b8;
        --j4u-gold: #c9a76a;
        --j4u-gold-soft: #e3c796;
        --j4u-text-main: #111827;
        --j4u-text-muted: #6b7280;
        --j4u-accent-green: #16a34a;
        --j4u-danger: #b91c1c;
        --j4u-warning: #f59e0b;
      }

      body {
        margin: 0;
        background:
          radial-gradient(circle at top, #f0ebe0 0, #f5f2ea 32%, #e8decc 100%);
        font-family: "Inter", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        color: var(--j4u-text-main);
      }

      .page-shell {
        max-width: 1200px;
        margin: 0 auto;
        padding: 28px 16px 40px;
      }

      /* Header, same feel as client welcome header but simpler */
      .page-header-custom {
        margin-top: 0;
        margin-bottom: 18px;
        padding: 16px 18px 14px;
        background: linear-gradient(145deg, rgba(253, 251, 246, 0.96), rgba(244, 237, 220, 0.96));
        border-radius: 20px;
        border: 1px solid rgba(221, 209, 184, 0.9);
        box-shadow:
          0 18px 36px rgba(15, 23, 42, 0.14),
          0 0 0 1px rgba(148, 133, 96, 0.12);
        display: flex;
        justify-content: space-between;
        align-items: center;
      }

      .page-header-left h2 {
        font-size: 1.6rem;
        font-weight: 600;
        color: var(--j4u-text-main);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
      }

      .page-header-left h2 span.emoji {
        font-size: 1.8rem;
      }

      .page-subtitle {
        color: var(--j4u-text-muted);
        margin-top: 4px;
        font-size: 0.93rem;
      }

      .page-header-right {
        padding: 6px 11px;
        border-radius: 999px;
        border: 1px solid rgba(221, 209, 184, 0.9);
        background: rgba(253, 251, 246, 0.92);
        font-size: 0.8rem;
        color: #7c5f2b;
        display: inline-flex;
        align-items: center;
        gap: 6px;
      }

      .page-header-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: var(--j4u-accent-green);
        box-shadow: 0 0 8px rgba(22,163,74,0.7);
      }

      .alert-info {
        border-radius: 12px;
        border: 1px solid rgba(221, 209, 184, 0.9);
        background: #fef9c3;
        color: #92400e;
        box-shadow: 0 10px 24px rgba(180, 83, 9, 0.18);
        margin-top: 14px;
        margin-bottom: 18px;
      }

      /* Main card, aligned with client cards */
      .j4u-card {
        border-radius: 20px;
        background: var(--j4u-surface);
        border: 1px solid var(--j4u-border);
        box-shadow:
          0 18px 36px rgba(15, 23, 42, 0.12),
          0 0 0 1px rgba(148, 133, 96, 0.09);
        padding: 20px 20px 16px;
        position: relative;
        overflow: hidden;
        transition: none;
      }

      .j4u-card::before {
        content: "";
        position: absolute;
        top: 0;
        left: 20px;
        right: 20px;
        height: 4px;
        border-radius: 0 0 999px 999px;
        background: linear-gradient(90deg, var(--j4u-gold), var(--j4u-gold-soft));
        opacity: 0.9;
      }

      .j4u-card:hover {
        transform: translate3d(0, -3px, 0);
        box-shadow:
          0 24px 50px rgba(15, 23, 42, 0.18),
          0 0 0 1px rgba(148, 133, 96, 0.16);
        border-color: rgba(201, 167, 106, 0.95);
        background: var(--j4u-surface-soft);
      }

      .j4u-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
        padding-bottom: 10px;
        border-bottom: 1px dashed rgba(221, 209, 184, 0.9);
      }

      .j4u-card-title {
        margin: 0;
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--j4u-text-main);
        display: inline-flex;
        align-items: center;
        gap: 6px;
      }

      .j4u-card-title span.emoji {
        font-size: 1.15rem;
      }

      .j4u-card-sub {
        display: block;
        font-size: 0.85rem;
        color: var(--j4u-text-muted);
        margin-top: 2px;
      }

      .j4u-card-tag {
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: #7c5f2b;
        padding: 4px 10px;
        border-radius: 999px;
        background: #fffbeb;
        border: 1px solid rgba(221, 209, 184, 0.9);
      }

      .j4u-table-shell {
        background: var(--j4u-surface);
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
        border: 1px solid rgba(221, 209, 184, 0.9);
      }

      .j4u-table-scroll {
        max-height: 480px;
        overflow: auto;
      }

      .j4u-table-scroll::-webkit-scrollbar {
        width: 7px;
        height: 7px;
      }
      .j4u-table-scroll::-webkit-scrollbar-thumb {
        background: rgba(148, 133, 96, 0.8);
        border-radius: 999px;
      }

      .table {
        margin-bottom: 0;
      }

      .table thead tr {
        background: linear-gradient(135deg, #facc15, var(--j4u-gold));
        color: #111827;
      }

      .table > thead > tr > th {
        border-bottom: 1px solid rgba(180, 83, 9, 0.35);
        font-weight: 500;
        font-size: 0.8rem;
        padding: 9px 10px;
        white-space: nowrap;
      }

      .table tbody tr {
        background: transparent;
        transition: none;
      }

      .table tbody tr:nth-child(even) {
        background: #fdfbf6;
      }

      .table-hover tbody tr:hover {
        background: #fffbeb;
        transform: translateY(-1px);
        box-shadow: 0 8px 18px rgba(148, 118, 62, 0.35);
      }

      .table td {
        font-size: 0.82rem;
        vertical-align: middle !important;
        padding: 8px 10px;
        color: #111827;
      }

      .status-pill {
        display: inline-flex;
        align-items: center;
        padding: 3px 10px;
        border-radius: 999px;
        font-size: 0.74rem;
        font-weight: 600;
        letter-spacing: 0.04em;
      }

      .status-verified {
        background: rgba(21, 128, 61, 0.12);
        color: var(--j4u-accent-green);
        border: 1px solid rgba(21, 128, 61, 0.4);
      }

      .status-pending {
        background: rgba(250, 204, 21, 0.16);
        color: #92400e;
        border: 1px solid rgba(234, 179, 8, 0.6);
      }

      .status-rejected {
        background: rgba(185, 28, 28, 0.14);
        color: var(--j4u-danger);
        border: 1px solid rgba(185, 28, 28, 0.55);
      }

      .btn-approve,
      .btn-reject {
        border-radius: 999px;
        padding: 4px 12px;
        font-size: 0.78rem;
        font-weight: 500;
        border-width: 1px;
        box-shadow:
          0 6px 14px rgba(15, 23, 42, 0.12),
          0 1px 0 rgba(255, 255, 255, 0.8) inset;
        transition: none;
      }

      .btn-approve {
        background: rgba(22, 163, 74, 0.08);
        border-color: rgba(22, 163, 74, 0.65);
        color: #14532d;
      }

      .btn-approve:hover {
        background: rgba(22, 163, 74, 0.15);
        transform: translateY(-1px);
        box-shadow: 0 8px 18px rgba(22, 163, 74, 0.35);
      }

      .btn-reject {
        background: rgba(239, 68, 68, 0.08);
        border-color: rgba(239, 68, 68, 0.7);
        color: #7f1d1d;
      }

      .btn-reject:hover {
        background: rgba(239, 68, 68, 0.16);
        transform: translateY(-1px);
        box-shadow: 0 8px 18px rgba(239, 68, 68, 0.4);
      }

      .text-muted-note {
        color: var(--j4u-text-muted);
        font-size: 0.78rem;
      }

      .footer-actions {
        margin-top: 20px;
        text-align: center;
        display: flex;
        justify-content: center;
        gap: 14px;
        flex-wrap: wrap;
      }

      .btn-shell-main {
        border-radius: 999px;
        padding: 8px 18px;
        font-size: 0.85rem;
        font-weight: 500;
        border-width: 1px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: none;
      }

      .btn-shell-main:hover {
        transform: translateY(-1px);
      }

      .btn-dashboard {
        background: linear-gradient(135deg, #facc15, #eab308);
        border-color: rgba(234, 179, 8, 0.9);
        color: #1f2933 !important;
        box-shadow: 0 12px 26px rgba(202, 138, 4, 0.55);
      }

      .btn-signout {
        background: #b91c1c;
        border-color: #7f1d1d;
        color: #fef2f2 !important;
        box-shadow: 0 12px 26px rgba(239, 68, 68, 0.55);
      }

      @media (max-width: 991px) {
        .page-header-custom {
          flex-direction: column;
          align-items: flex-start;
          gap: 10px;
        }
      }
    </style>
  </head>

  <body>
    <div class="page-shell">

      <div class="page-header-custom">
        <div class="page-header-left">
          <h2>
            <span class="emoji">👨‍⚖️</span>
            Lawyer Approvals
          </h2>
          <p class="page-subtitle">
            Review new lawyer registrations and approve or reject accounts after document verification.
          </p>
        </div>
        <div class="page-header-right">
          <span class="page-header-dot"></span>
          <span>Justice4U · Admin panel</span>
        </div>
      </div>

      <% if(message != null && !message.isEmpty()) { %>
        <div class="alert alert-info">
          <%= message %>
        </div>
      <% } %>

      <div class="j4u-card">
        <div class="j4u-card-header">
          <div>
            <h3 class="j4u-card-title">
              <span class="emoji">📋</span>
              Pending & Verified Lawyers
            </h3>
            <span class="j4u-card-sub">
              Approve only when all submitted documents are marked as verified in the system.
            </span>
          </div>
          <span class="j4u-card-tag">Approval queue</span>
        </div>

        <div class="j4u-table-shell">
          <div class="j4u-table-scroll">
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>Lawyer Id</th>
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
                  <th>Document Status</th>
                  <th>Approve</th>
                  <th>Reject</th>
                </tr>
              </thead>
              <tbody>
<%@include file="db_connection.jsp" %>
              <%
                try {
                  Class.forName("com.mysql.jdbc.Driver");
                  Connection con = getDatabaseConnection();
                  Statement st = con.createStatement();
                  ResultSet rs = st.executeQuery(
                    "SELECT l.*, COALESCE(l.document_verification_status, 'PENDING') as doc_status " +
                    "FROM lawyer_reg l WHERE l.flag = 0"
                  );
                  while(rs.next()) {
                    int aa = rs.getInt(1);
                    String docStatus = rs.getString("doc_status");
                    String statusClass = "status-pending";
                    String statusText = "Pending";

                    if ("VERIFIED".equals(docStatus)) {
                      statusClass = "status-verified";
                      statusText = "Verified";
                    } else if ("REJECTED".equals(docStatus)) {
                      statusClass = "status-rejected";
                      statusText = "Rejected";
                    }
              %>
                <tr>
                  <td><%= aa %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(2)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(3)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(5)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(6)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(7)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(8)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(9)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(10)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(11)) %></td>
                  <td><%= com.j4u.Sanitizer.sanitize(rs.getString(12)) %></td>
                  <td>
                    <span class="status-pill <%= statusClass %>">
                      <%= statusText %>
                    </span>
                  </td>
                  <td>
                    <% if ("VERIFIED".equals(docStatus)) { %>
                      <a href="approvel.jsp?id=<%= aa %>" class="btn btn-xs btn-approve">
                        Approve
                      </a>
                    <% } else { %>
                      <span class="text-muted-note">Verify docs first</span>
                    <% } %>
                  </td>
                  <td>
                    <a href="rejectl.jsp?id=<%= aa %>" class="btn btn-xs btn-reject">
                      Reject
                    </a>
                  </td>
                </tr>
              <%
                  }
                  rs.close();
                  st.close();
                  con.close();
                } catch(Exception e) {
              %>
                <tr>
                  <td colspan="14" class="text-danger">
                    Error: <%= e.getMessage() %>
                  </td>
                </tr>
              <%
                }
              %>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="footer-actions">
        <a href="admindashboard.jsp" class="btn-shell-main btn-dashboard">
          ⬅ Back to Dashboard
        </a>
        <a href="asignout.jsp" class="btn-shell-main btn-signout">
          🚪 Sign Out
        </a>
      </div>

    </div>
  </body>
</html>


