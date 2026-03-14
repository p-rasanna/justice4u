<%--
    Document   : viewcases
    Created on : 3 Apr, 2025, 8:15:04 PM
    Author     : Justice4U System
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
<%
    // View-layer fallback authentication guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html");
        return;
    }
%>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>Justice4U – My Cases</title>

  <link rel="stylesheet"
        href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css"><!-- bootstrap 3 -->[file:1]
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>[web:337]
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>[file:1]

  <style>
    :root {
      --j4u-bg: #f5f2ea;
      --j4u-surface: #fdfbf6;
      --j4u-border: #ddd1b8;
      --j4u-gold: #c9a76a;
      --j4u-gold-soft: #e3c796;
      --j4u-text-main: #111827;
      --j4u-text-muted: #6b7280;
      --j4u-accent-blue: #2563eb;
    }

    body {
      margin: 0;
      padding: 24px 0 32px;
      font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
      background:
        radial-gradient(circle at top, #f0ebe0 0, #f5f2ea 32%, #e8decc 100%);
      color: var(--j4u-text-main);
    }

    .page-shell {
      max-width: 1100px;
      margin: 0 auto;
      padding: 0 16px;
    }

    .page-shell::before {
      content: "";
      position: fixed;
      inset: 0;
      margin: auto;
      max-width: 900px;
      height: 240px;
      background:
        radial-gradient(circle at 0 0, rgba(191, 219, 254, 0.45), transparent 65%),
        radial-gradient(circle at 100% 0, rgba(233, 213, 166, 0.6), transparent 65%);
      opacity: 0.8;
      filter: blur(18px);
      z-index: -1;
      pointer-events: none;
    }

    .welcome-header {
      margin-bottom: 18px;
      padding: 18px 20px 16px;
      background: linear-gradient(145deg, rgba(253, 251, 246, 0.98), rgba(244, 237, 220, 0.98));
      border-radius: 18px;
      border: 1px solid rgba(221, 209, 184, 0.9);
      box-shadow:
        0 18px 40px rgba(15, 23, 42, 0.14),
        0 0 0 1px rgba(148, 133, 96, 0.1);
      position: relative;
      overflow: hidden;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 10px;
    }

    .welcome-header h2 {
      margin: 0 0 4px;
      font-size: 1.6rem;
      font-weight: 600;
    }

    .welcome-header p {
      margin: 0;
      font-size: 0.95rem;
      color: var(--j4u-text-muted);
    }

    .welcome-pill {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      margin-top: 8px;
      padding: 4px 12px;
      border-radius: 999px;
      border: 1px solid rgba(37, 99, 235, 0.75);
      background: #eff6ff;
      color: #1d4ed8;
      font-size: 0.78rem;
      font-weight: 500;
    }

    .welcome-pill-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: var(--j4u-accent-blue);
      box-shadow: 0 0 10px rgba(37, 99, 235, 0.9);
    }

    .welcome-avatar {
      width: 52px;
      height: 52px;
      border-radius: 50%;
      background:
        radial-gradient(circle at 25% 0%, #ffffff, rgba(240, 230, 210, 0.7)),
        linear-gradient(135deg, var(--j4u-gold), var(--j4u-gold-soft));
      display: flex;
      align-items: center;
      justify-content: center;
      color: #1f2933;
      font-size: 1.5rem;
      font-weight: 700;
      box-shadow:
        0 10px 22px rgba(15, 23, 42, 0.3),
        0 0 0 2px rgba(253, 251, 246, 0.9);
    }

    .card-shell {
      background: var(--j4u-surface);
      border-radius: 18px;
      border: 1px solid var(--j4u-border);
      box-shadow:
        0 18px 36px rgba(15, 23, 42, 0.12),
        0 0 0 1px rgba(148, 133, 96, 0.09);
      padding: 16px 18px 14px;
      position: relative;
      overflow: hidden;
    }

    .card-shell::before {
      content: "";
      position: absolute;
      top: 0;
      left: 18px;
      right: 18px;
      height: 4px;
      border-radius: 0 0 999px 999px;
      background: linear-gradient(90deg, var(--j4u-gold), var(--j4u-gold-soft));
      opacity: 0.95;
    }

    .table {
      width: 100%;
      margin-bottom: 10px;
      background: transparent;
    }

    .table thead th {
      background: #f9fafb;
      color: var(--j4u-text-muted);
      border-bottom: 1px solid #e5e7eb;
      font-weight: 600;
      padding: 10px 8px;
      font-size: 0.85rem;
      text-transform: uppercase;
    }

    .table tbody tr {
      transition:
        background 0.18s ease,
        box-shadow 0.18s ease,
        transform 0.16s ease;
    }

    .table tbody tr:hover {
      background: #fefce8;
      box-shadow: 0 6px 16px rgba(148, 118, 62, 0.25);
      transform: translateY(-1px);
    }

    .table tbody td {
      vertical-align: middle !important;
      padding: 9px 8px;
      font-size: 0.9rem;
      border-top: 1px solid #e5e7eb;
    }

    .tag-court {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 999px;
      font-size: 0.75rem;
      background: #eff6ff;
      color: #1d4ed8;
    }

    .tag-city {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 999px;
      font-size: 0.75rem;
      background: #ecfdf3;
      color: #166534;
    }

    .btn-allot {
      padding: 5px 12px;
      border-radius: 999px;
      border: 1px solid var(--j4u-gold);
      background: #fdfbf6;
      color: #7c5f2b;
      font-size: 0.85rem;
      font-weight: 500;
      text-decoration: none !important;
      display: inline-block;
      transition:
        background 0.18s ease,
        color 0.18s ease,
        box-shadow 0.18s ease,
        transform 0.14s ease;
    }

    .btn-allot:hover {
      background: var(--j4u-gold);
      color: #111827;
      box-shadow: 0 8px 18px rgba(148, 118, 62, 0.3);
      transform: translateY(-1px);
    }

    .footer-actions {
      margin-top: 12px;
      text-align: center;
    }

    .footer-actions .btn {
      border-radius: 999px;
      padding: 8px 20px;
      font-size: 0.9rem;
      font-weight: 500;
    }

    .btn-dashboard {
      background: linear-gradient(135deg, var(--j4u-gold), var(--j4u-gold-soft));
      border-color: var(--j4u-gold);
      color: #111827;
    }

    .btn-dashboard:hover {
      background: var(--j4u-gold-soft);
    }

    .btn-signout {
      background: #dc2626;
      border-color: #b91c1c;
    }

    .btn-signout:hover {
      background: #b91c1c;
    }

    @media (max-width: 992px) {
      .table thead th:nth-child(4),
      .table thead th:nth-child(5) {
        display: none;
      }
      .table tbody td:nth-child(4),
      .table tbody td:nth-child(5) {
        display: none;
      }
    }

    @media (max-width: 640px) {
      .welcome-header {
        flex-direction: column;
        align-items: flex-start;
      }
    }
  </style>
</head>
<body>
  <div class="page-shell">
    <div class="welcome-header">
      <div>
        <h2>Pending Cases for Allotment</h2>
        <p>Review new cases and allot them to suitable lawyers in Justice4U.</p>
        <div class="welcome-pill">
          <span class="welcome-pill-dot"></span>
          Admin panel • Unassigned cases
        </div>
      </div>
      <div class="welcome-avatar">
        A
      </div>
    </div>

    <div class="card-shell">
      <table class="table table-hover">
        <thead>
          <tr>
            <th>Case Id</th>
            <th>Customer Name</th>
            <th>Title</th>
            <th>Description</th>
            <th>Date</th>
            <th>Court</th>
            <th>City</th>
            <th>Payment Mode</th>
            <th>Transaction Id</th>
            <th>Amount</th>
            <th>Customer Email</th>
            <th>Allot Lawyer</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${not empty unassignedCases}">
              <c:forEach var="caseItem" items="${unassignedCases}">
                <tr>
                  <td><c:out value="${caseItem.id}" /></td>
                  <td><c:out value="${caseItem.customerName}" /></td>
                  <td><c:out value="${caseItem.title}" /></td>
                  <td><c:out value="${caseItem.description}" /></td>
                  <td><c:out value="${caseItem.date}" /></td>
                  <td><span class="tag-court"><c:out value="${caseItem.courtType}" /></span></td>
                  <td><span class="tag-city"><c:out value="${caseItem.city}" /></span></td>
                  <td><c:out value="${caseItem.paymentMode}" /></td>
                  <td><c:out value="${caseItem.txnId}" /></td>
                  <td><c:out value="${caseItem.amount}" /></td>
                  <td><c:out value="${caseItem.email}" /></td>
                  <td>
                    <a href="allotlawyer.jsp?id=${caseItem.id}" class="btn-allot">
                      Allot Lawyer →
                    </a>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="12" style="text-align:center; padding: 20px; font-weight: 500;">
                  No pending cases found for allotment.
                </td>
              </tr>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

      <div class="footer-actions">
        <a href="admindashboard.jsp" class="btn btn-dashboard">
          ← Back to Dashboard
        </a>
        <a href="asignout.jsp" class="btn btn-signout">
          Sign Out
        </a>
      </div>
    </div>
  </div>
</body>
</html>
