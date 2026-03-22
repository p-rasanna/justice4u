<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Justice4U | Case Submitted Successfully</title>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">

<style>
:root {
  --j4u-bg: #f5f2ea;
  --j4u-surface: #fdfbf6;
  --j4u-border: #ddd1b8;
  --j4u-gold: #c9a76a;
  --j4u-gold-soft: #e3c796;
  --j4u-text-main: #111827;
  --j4u-text-muted: #6b7280;
}

/* Page */
body {
  margin: 0;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px 12px;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
  background:
    radial-gradient(circle at top, #f0ebe0 0, #f5f2ea 32%, #e8decc 100%);
  color: var(--j4u-text-main);
}

/* Card container */
.success-card {
  width: 100%;
  max-width: 500px;
  background: var(--j4u-surface);
  border-radius: 18px;
  border: 1px solid var(--j4u-border);
  box-shadow:
    0 20px 40px rgba(15, 23, 42, 0.18),
    0 0 0 1px rgba(148, 133, 96, 0.10);
  padding: 32px 24px;
  text-align: center;
  position: relative;
  overflow: hidden;
}

.success-card::before {
  content: "";
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 4px;
  border-radius: 0 0 999px 999px;
  background: linear-gradient(90deg, var(--j4u-gold), var(--j4u-gold-soft));
  opacity: 0.95;
}

/* Success icon */
.success-icon {
  font-size: 4rem;
  color: var(--j4u-gold);
  margin-bottom: 16px;
}

/* Header */
.success-header {
  margin-bottom: 16px;
}

.success-title {
  margin: 0 0 8px;
  font-size: 1.75rem;
  font-weight: 600;
  color: var(--j4u-text-main);
}

.success-sub {
  margin: 0;
  font-size: 1rem;
  color: var(--j4u-text-muted);
}

/* Content */
.success-content {
  margin-bottom: 24px;
}

.success-message {
  font-size: 0.95rem;
  color: var(--j4u-text-muted);
  line-height: 1.5;
}

/* Buttons */
.actions-row {
  margin-top: 24px;
}

.btn-primary-j4u,
.btn-secondary-j4u {
  border-radius: 999px;
  padding: 12px 20px;
  font-size: 0.95rem;
  font-weight: 500;
  border: none;
  outline: none;
  transition: none;
  text-decoration: none;
  display: inline-block;
  width: 100%;
  margin-bottom: 8px;
}

.btn-primary-j4u {
  background: linear-gradient(135deg, var(--j4u-gold), var(--j4u-gold-soft));
  color: #111827;
  box-shadow:
    0 12px 26px rgba(148, 118, 62, 0.35),
    0 0 0 1px rgba(148, 118, 62, 0.35);
}

.btn-primary-j4u:hover {
  transform: translateY(-1px);
  box-shadow:
    0 16px 30px rgba(148, 118, 62, 0.4),
    0 0 0 1px rgba(148, 118, 62, 0.5);
}

.btn-secondary-j4u {
  background: #fdfbf6;
  color: #7c5f2b;
  border: 1px solid var(--j4u-gold);
}

.btn-secondary-j4u:hover {
  background: var(--j4u-gold);
  color: #111827;
}

/* Layout tweaks */
@media (max-width: 767px) {
  .success-card {
    padding: 24px 16px;
  }
}
</style>
</head>

<body>

<div class="success-card">
  <div class="success-icon">✅</div>

  <div class="success-header">
    <h2 class="success-title">Case Submitted Successfully!</h2>
    <p class="success-sub">Your case has been received and is being processed.</p>
  </div>

  <div class="success-content">
    <div class="case-details" style="background: #f9fafb; padding: 16px; border-radius: 8px; margin-bottom: 16px; border: 1px solid #e5e7eb;">
      <h4 style="margin: 0 0 8px; color: var(--j4u-text-main); font-size: 1.1rem;">Case Submission Details</h4>
      <%
        // Get case details from session if available
        String submittedTitle = (String) session.getAttribute("submittedCaseTitle");
        String submittedCategory = (String) session.getAttribute("submittedCaseCategory");
        String submittedCourt = (String) session.getAttribute("submittedCaseCourt");
        String submittedCity = (String) session.getAttribute("submittedCaseCity");

        if (submittedTitle != null) {
      %>
        <p style="margin: 4px 0; font-size: 0.9rem;"><strong>Title:</strong> <%= submittedTitle %></p>
        <p style="margin: 4px 0; font-size: 0.9rem;"><strong>Category:</strong> <%= submittedCategory %></p>
        <p style="margin: 4px 0; font-size: 0.9rem;"><strong>Court:</strong> <%= submittedCourt %></p>
        <p style="margin: 4px 0; font-size: 0.9rem;"><strong>City:</strong> <%= submittedCity %></p>
      <%
          // Clear session attributes
          session.removeAttribute("submittedCaseTitle");
          session.removeAttribute("submittedCaseCategory");
          session.removeAttribute("submittedCaseCourt");
          session.removeAttribute("submittedCaseCity");
        }
      %>
    </div>
    <p class="success-message">
      Thank you for choosing Justice4U. Your case details have been securely stored in our system.
      Our admin team will review your submission and assign a qualified lawyer shortly.
      You will receive updates via email once a lawyer is assigned to your case.
    </p>
  </div>

  <div class="actions-row">
    <%
      // Get profile type from session to redirect to appropriate dashboard
      String profileType = (String) session.getAttribute("profileType");
      String dashboardUrl = "clientdashboard_manual.jsp"; // default

      if ("admin".equals(profileType)) {
        dashboardUrl = "clientdashboard_admin.jsp";
      }
    %>
    <a href="<%= dashboardUrl %>" class="btn-primary-j4u">
      Back to Dashboard
    </a>
  </div>
</div>

</body>
</html>

