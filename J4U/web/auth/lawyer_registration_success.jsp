<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Submission Confirmed | Justice4U</title>
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  
</head>
<body>
  <div class="ambience"></div>
  <div class="receipt-card">
    <div class="success-visual">
      <div class="circle-bg"></div>
      <svg class="checkmark" viewBox="0 0 24 24">
        <path d="M20 6L9 17l-5-5"></path>
      </svg>
    </div>
    <h1>Dossier Received</h1>
    <p class="subtitle">
      Your application for accreditation has been securely logged. Our administration council will review your credentials shortly.
    </p>
    <div class="timeline">
      <div class="step active">
        <div class="dot"><i class="ph-bold ph-check"></i></div>
        <span class="label">Submitted</span>
      </div>
      <div class="step next">
        <div class="dot"><i class="ph-bold ph-hourglass"></i></div>
        <span class="label">Review</span>
      </div>
      <div class="step">
        <div class="dot"><i class="ph-bold ph-gavel"></i></div>
        <span class="label">Active</span>
      </div>
    </div>
    <div class="info-box">
      <div class="ib-row">
        <span class="ib-label">Ref ID</span>
        <span class="ib-val">#REG-<%= System.currentTimeMillis() % 10000 %></span>
      </div>
      <div class="ib-row">
        <span class="ib-label">Date</span>
        <span class="ib-val"><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()) %></span>
      </div>
      <div class="ib-row">
        <span class="ib-label">Notification</span>
        <span class="ib-val">Sent to Email</span>
      </div>
    </div>
    <a href="Home.html" class="btn-home">
      Return to Homepage <i class="ph-bold ph-house"></i>
    </a>
  </div>
</body>
</html>
