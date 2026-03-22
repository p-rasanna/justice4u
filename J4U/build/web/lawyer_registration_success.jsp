<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Submission Confirmed | Justice4U</title>

  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500&display=swap" rel="stylesheet">

  <style>
    :root {
      --bg-color: #FAFAF9;
      --text-main: #111111;
      --text-muted: #555555;
      
      --gold-main: #C6A75E;
      --secure-green: #059669;
      
      --surface-card: #FFFFFF;
      --border-line: #E5E5E5;
      
      --ease-spring: cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      background-color: var(--bg-color);
      color: var(--text-main);
      font-family: 'Inter', sans-serif;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      perspective: 1000px;
    }

    /* BACKGROUND AMBIANCE */
    .ambience {
      position: fixed; inset: 0; z-index: -1;
      background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.03'/%3E%3C/svg%3E");
    }

    /* MAIN CARD */
    .receipt-card {
      background: var(--surface-card);
      border: 1px solid var(--border-line);
      border-radius: 24px;
      padding: 48px;
      width: 100%; max-width: 500px;
      text-align: center;
      box-shadow: 0 20px 40px -10px rgba(0,0,0,0.05);
      position: relative;
      opacity: 0;
      transform: translateY(20px) rotateX(10deg);
      animation: cardEntrance 0.8s var(--ease-spring) 0.5s forwards;
    }

    @keyframes cardEntrance {
      to { opacity: 1; transform: translateY(0) rotateX(0); }
    }

    /* 3D CHECKMARK ANIMATION */
    .success-visual {
      width: 80px; height: 80px; margin: 0 auto 32px;
      position: relative;
    }
    
    .circle-bg {
      position: absolute; inset: 0; border-radius: 50%;
      background: #ECFDF5; transform: scale(0);
      animation: expandCircle 0.5s var(--ease-spring) forwards;
    }
    
    .checkmark {
      width: 40px; height: 40px;
      fill: none; stroke: var(--secure-green); stroke-width: 3; stroke-linecap: round; stroke-linejoin: round;
      stroke-dasharray: 100; stroke-dashoffset: 100;
      position: absolute; top: 20px; left: 20px;
      animation: drawCheck 0.6s ease-out 0.4s forwards;
    }

    @keyframes expandCircle { to { transform: scale(1); } }
    @keyframes drawCheck { to { stroke-dashoffset: 0; } }

    /* TEXT CONTENT */
    h1 {
      font-family: 'Playfair Display', serif; font-size: 2rem; 
      color: var(--text-main); margin-bottom: 12px;
    }
    
    .subtitle { color: var(--text-muted); font-size: 0.95rem; line-height: 1.5; margin-bottom: 32px; }

    /* STATUS TIMELINE */
    .timeline {
      display: flex; justify-content: space-between; position: relative;
      margin: 0 auto 40px; width: 80%;
    }
    .timeline::before {
      content:''; position: absolute; top: 12px; left: 0; right: 0; height: 2px;
      background: var(--border-line); z-index: 0;
    }
    
    .step { position: relative; z-index: 1; display: flex; flex-direction: column; align-items: center; gap: 8px; }
    
    .dot {
      width: 24px; height: 24px; border-radius: 50%; background: #FFF;
      border: 2px solid var(--border-line); display: flex; align-items: center; justify-content: center;
      font-size: 0.7rem; color: var(--text-muted); transition: 0.3s;
    }
    
    .step.active .dot { border-color: var(--secure-green); background: var(--secure-green); color: #FFF; }
    .step.next .dot { border-color: var(--gold-main); background: #FFF; color: var(--gold-main); }
    
    .label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); }
    .step.active .label { color: var(--secure-green); }

    /* INFO BOX */
    .info-box {
      background: #FAFAFA; border: 1px solid var(--border-line); border-radius: 12px;
      padding: 16px; margin-bottom: 32px; text-align: left;
    }
    .ib-row { display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 8px; }
    .ib-row:last-child { margin-bottom: 0; }
    .ib-label { color: var(--text-muted); }
    .ib-val { font-family: 'Space Grotesk'; font-weight: 600; color: var(--text-main); }

    /* ACTION */
    .btn-home {
      display: inline-flex; align-items: center; gap: 8px;
      text-decoration: none; color: var(--text-main); font-weight: 600; font-size: 0.9rem;
      padding: 12px 24px; border: 1px solid var(--border-line); border-radius: 50px;
      transition: none;
    }
    .btn-home:hover { background: #111; color: #FFF; border-color: #111; transform: translateY(-2px); }

  </style>
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

