<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%
    // Get customer details from session attributes
    String customerName = (String) session.getAttribute("customerName");
    String customerEmail = (String) session.getAttribute("customerEmail");
    String customerMobile = (String) session.getAttribute("customerMobile");
    String registrationDate = (String) session.getAttribute("registrationDate");
    
    // If session attributes are not available, try request parameters
    if (customerName == null) customerName = request.getParameter("cname");
    if (customerEmail == null) customerEmail = request.getParameter("email");
    if (customerMobile == null) customerMobile = request.getParameter("mobno");
    if (registrationDate == null) registrationDate = request.getParameter("registrationDate");
    
    // Fallback values if still null
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
  <title>Submission Confirmed – Justice4U</title>

  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@400;500;600&display=swap" rel="stylesheet">

  <style>
    /* ============================
       1. STUDIO DESIGN TOKENS
       ============================ */
    :root {
      --bg-color: #FAFAF9;
      --ink-primary: #0F0F0F;
      --ink-secondary: #525252;
      --ink-tertiary: #A3A3A3;
      
      --gold-main: #C6A75E;
      --success-green: #059669;
      --success-bg: #ECFDF5;
      
      --surface-paper: #FFFFFF;
      --border-line: #E5E5E5;
      
      --ease-snap: cubic-bezier(0.16, 1, 0.3, 1);
      --ease-flow: cubic-bezier(0.33, 1, 0.68, 1);
    }

    * { box-sizing: border-box; outline: none; }

    body {
      margin: 0;
      background-color: var(--bg-color);
      color: var(--ink-primary);
      font-family: 'Inter', sans-serif;
      min-height: 100vh;
      overflow-x: hidden;
      display: flex;
      flex-direction: column;
    }

    .noise-overlay {
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.03'/%3E%3C/svg%3E");
      z-index: -1; pointer-events: none;
    }

    .header {
      padding: 24px 0; text-align: center;
      border-bottom: 1px solid rgba(0,0,0,0.03);
      background: rgba(250, 250, 249, 0.8);
      backdrop-filter: blur(8px);
      position: sticky; top: 0; z-index: 10;
    }
    .logo h1 {
      font-family: 'Playfair Display', serif;
      font-size: 1.4rem; margin: 0; color: var(--ink-primary); letter-spacing: -0.01em;
    }

    .stage {
      flex: 1; display: flex; align-items: center; justify-content: center;
      padding: 40px 20px;
    }

    .receipt-card {
      background: var(--surface-paper);
      border: 1px solid var(--border-line);
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02), 0 10px 15px -3px rgba(0, 0, 0, 0.02);
      border-radius: 12px;
      padding: 0; max-width: 540px; width: 100%;
      position: relative; overflow: hidden;
      opacity: 0; transform: translateY(20px);
      animation: cardEnter 0.8s var(--ease-snap) forwards;
    }

    .loading-line {
      height: 4px; width: 0%;
      background: linear-gradient(90deg, var(--gold-main), #E5D4A5);
      animation: loadLine 1s var(--ease-flow) forwards 0.2s;
    }

    .card-body { padding: 48px 40px; }

    /* ============================
       ANIMATED TICK STYLES
       ============================ */
    .icon-wrapper {
      width: 64px; height: 64px; margin: 0 auto 24px;
      border-radius: 50%;
      background: var(--success-bg);
      display: flex; align-items: center; justify-content: center;
      position: relative;
      opacity: 0; transform: scale(0.5);
      animation: none;
    }

    /* The SVG Checkmark */
    .check-svg {
      width: 32px; height: 32px;
      stroke: var(--success-green);
      stroke-width: 3;
      stroke-linecap: round;
      stroke-linejoin: round;
      fill: none;
      /* Length of checkmark path is approx 24px */
      stroke-dasharray: 40; 
      stroke-dashoffset: 40; /* Start hidden */
      animation: drawCheck 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards 0.8s; /* Start after circle pops */
    }

    @keyframes drawCheck {
      100% { stroke-dashoffset: 0; }
    }

    .status-group { text-align: center; margin-bottom: 40px; }
    h2 {
      font-family: 'Playfair Display', serif; font-size: 1.8rem; margin: 0 0 8px; color: var(--ink-primary);
      opacity: 0; transform: translateY(10px);
      animation: none;
    }
    .status-desc {
      color: var(--ink-secondary); font-size: 0.95rem; margin: 0;
      opacity: 0; transform: translateY(10px);
      animation: none;
    }

    /* The Docket */
    .docket-container {
      background: #FAFAFA;
      border: 1px solid var(--border-line);
      border-radius: 8px; margin-bottom: 40px; overflow: hidden;
      opacity: 0; transform: translateY(15px);
      animation: none;
    }
    .docket-header {
      padding: 12px 20px; background: #F5F5F5;
      border-bottom: 1px solid var(--border-line);
      display: flex; justify-content: space-between; align-items: center;
    }
    .ref-label { font-size: 0.75rem; font-weight: 600; color: var(--ink-tertiary); text-transform: uppercase; letter-spacing: 0.05em; }
    .ref-code { font-family: 'Space Grotesk', monospace; font-size: 0.8rem; color: var(--ink-secondary); }
    .detail-row {
      display: flex; justify-content: space-between; align-items: center;
      padding: 14px 20px; border-bottom: 1px solid var(--border-line);
      transition: none;
    }
    .detail-row:last-child { border-bottom: none; }
    .detail-row:hover { background: #FFFFFF; }
    .label { font-size: 0.85rem; color: var(--ink-secondary); }
    .value { font-family: 'Space Grotesk', monospace; font-size: 0.9rem; font-weight: 500; color: var(--ink-primary); }

    /* Timeline */
    .process-area {
      margin-bottom: 40px; padding-left: 8px;
      opacity: 0; animation: none;
    }
    .step { display: flex; gap: 16px; position: relative; padding-bottom: 32px; }
    .step:last-child { padding-bottom: 0; }
    .step-line {
      position: absolute; left: 11px; top: 24px; bottom: 0; width: 2px;
      background: #F0F0F0; z-index: 1;
    }
    .step-line-fill {
      position: absolute; top: 0; left: 0; width: 100%; height: 0%;
      background: var(--gold-main);
      animation: drawLine 1s ease-out forwards 1.2s;
    }
    .step-icon {
      width: 24px; height: 24px; border-radius: 50%;
      background: #fff; border: 2px solid #E5E5E5;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.75rem; z-index: 2; position: relative;
    }
    .step.completed .step-icon { background: var(--success-green); border-color: var(--success-green); color: #fff; }
    .step.current .step-icon {
      border-color: var(--gold-main); color: var(--gold-main);
      box-shadow: 0 0 0 4px rgba(198, 167, 94, 0.15);
      animation: pulseGold 2s infinite;
    }
    .step.waiting .step-icon { color: transparent; }
    .step-info h4 { margin: 0 0 2px 0; font-size: 0.9rem; font-weight: 600; color: var(--ink-primary); }
    .step-info p { margin: 0; font-size: 0.8rem; color: var(--ink-secondary); }

    /* Admin Toast */
    .admin-toast {
      background: #111; color: #fff;
      padding: 12px 16px; border-radius: 8px;
      font-size: 0.8rem; display: flex; align-items: center; gap: 10px;
      margin-bottom: 32px;
      opacity: 0; transform: translateY(10px);
      animation: none;
    }
    .toast-icon { color: var(--gold-main); }

    .btn-return {
      display: block; width: 100%; padding: 14px;
      text-align: center; border-radius: 8px;
      border: 1px solid var(--border-line);
      background: transparent; color: var(--ink-primary);
      font-weight: 600; font-size: 0.9rem;
      text-decoration: none; transition: none;
      opacity: 0; animation: none;
    }
    .btn-return:hover { background: #F9F9F9; border-color: var(--ink-primary); }

    /* Keyframes */
    @keyframes cardEnter { to { opacity: 1; transform: translateY(0); } }
    @keyframes loadLine { to { width: 100%; } }
    @keyframes popIn { 0% { opacity: 0; transform: scale(0.5); } 80% { transform: scale(1.1); } 100% { opacity: 1; transform: scale(1); } }
    @keyframes fadeUp { to { opacity: 1; transform: translateY(0); } }
    @keyframes drawLine { to { height: 100%; } }
    @keyframes pulseGold { 0% { box-shadow: 0 0 0 0 rgba(198, 167, 94, 0.4); } 70% { box-shadow: 0 0 0 6px rgba(198, 167, 94, 0); } 100% { box-shadow: 0 0 0 0 rgba(198, 167, 94, 0); } }

    @media (max-width: 600px) { .card-body { padding: 32px 24px; } h2 { font-size: 1.5rem; } }
  </style>
  <style>
    /* Override excessive animations for immediate professional presentation */
    .receipt-card, .loading-line, .icon-wrapper, .check-svg, h2, .status-desc, .docket-container, .process-area, .step-line-fill, .step.current .step-icon, .admin-toast, .btn-return {
      animation: none !important;
      opacity: 1 !important;
      transform: none !important;
      stroke-dashoffset: 0 !important;
      width: 100% !important;
    }
    .check-svg { animation: none !important; }
    .loading-line { animation: none !important; width: 100% !important; }
    .step-line-fill { animation: none !important; height: 100% !important; }
  </style>
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

