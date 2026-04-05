<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%
  String customerName = (String) session.getAttribute("customerName");
  String customerEmail = (String) session.getAttribute("customerEmail");
  String customerMobile = (String) session.getAttribute("customerMobile");
  String registrationDate = (String) session.getAttribute("registrationDate");
  if (customerName == null) customerName = request.getParameter("cname");
  if (customerEmail == null) customerEmail = request.getParameter("email");
  if (customerMobile == null) customerMobile = request.getParameter("mobno");
  if (registrationDate == null) registrationDate = request.getParameter("registrationDate");
  if (customerName == null) customerName = "Not available";
  if (customerEmail == null) customerEmail = "Not available";
  if (customerMobile == null) customerMobile = "Not available";
  if (registrationDate == null) registrationDate = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Submission Confirmed â€“ Justice4U</title>
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
</head>
<body>
  <div class="noise-overlay"></div>
  <div class="header">
  <div class="logo"><h1>Justice4U</h1></div>
  </div>
  <div class="stage">
  <main class="receipt-card">
    <div class="loading-line"></div>
    <div class="card-body">
    <div class="icon-wrapper">
      <svg class="check-svg" viewBox="0 0 24 24">
      <polyline points="20 6 9 17 4 12"></polyline>
      </svg>
    </div>
    <div class="status-group">
      <h2>Registration Filed</h2>
      <p class="status-desc">Your application has been securely transmitted.</p>
    </div>
    <div class="docket-container">
      <div class="docket-header">
      <span class="ref-label">Reference ID</span>
      <span class="ref-code"><%= registrationDate.replaceAll("[-: ]", "").substring(0, 12) %></span>
      </div>
      <div class="detail-row">
      <span class="label">Applicant</span>
      <span class="value"><%= customerName %></span>
      </div>
      <div class="detail-row">
      <span class="label">Primary Contact</span>
      <span class="value"><%= customerEmail %></span>
      </div>
      <div class="detail-row">
      <span class="label">Filed On</span>
      <span class="value"><%= registrationDate %></span>
      </div>
    </div>
    <div class="process-area">
      <div class="step completed">
      <div class="step-line"><div class="step-line-fill"></div></div>
      <div class="step-icon"><i class="ph ph-check"></i></div>
      <div class="step-info">
        <h4>Submission Received</h4>
        <p>Data encrypted and stored.</p>
      </div>
      </div>
      <div class="step current">
      <div class="step-line"></div>
      <div class="step-icon"><i class="ph ph-shield-check"></i></div>
      <div class="step-info">
        <h4>Verification Pending</h4>
        <p>Admin review in progress (Est. 24hrs).</p>
      </div>
      </div>
      <div class="step waiting">
      <div class="step-icon"></div>
      <div class="step-info">
        <h4>Account Active</h4>
        <p>Access granted via email.</p>
      </div>
      </div>
    </div>
    <div class="admin-toast">
      <i class="ph ph-paper-plane-tilt toast-icon"></i>
      <span>System Notification sent to Administrator.</span>
    </div>
    <a href="Home.html" class="btn-return">Return to Homepage</a>
    </div>
  </main>
  </div>
</body>
</html>