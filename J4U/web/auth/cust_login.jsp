<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Justice4U | Client Authentication</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root { --navy: #0B192C; --gold: #D4AF37; --bg: #F8F9FA; --border: #EAEAEA; }
    body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 1.5rem; flex-direction: column; }
    .font-law { font-family: 'Playfair Display', serif; }
    .login-card { width: 100%; max-width: 420px; background: white; padding: 2.5rem; border: 1px solid var(--border); border-top: 4px solid var(--gold); border-radius: 8px; box-shadow: 0 10px 30px rgba(11,25,44,0.05); text-align: center; }
    .form-control { height: 50px; padding: 0 1rem; border-radius: 4px; border: 1px solid var(--border); background: var(--bg); font-size: 0.95rem; transition: 0.3s; }
    .form-control:focus { background: white; border-color: var(--gold); box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.15); }
    .btn-submit { background: var(--navy); color: white; height: 50px; font-weight: 600; border-radius: 4px; border: none; transition: 0.3s; width: 100%; }
    .btn-submit:hover { background: var(--gold); color: var(--navy); }
    .btn-submit:disabled { opacity: 0.7; cursor: not-allowed; }
  </style>
</head>
<body>
  <div class="login-card">
    <div class="mb-2">
      <i class="bi bi-layers-half fs-1" style="color: var(--gold);"></i>
    </div>
    <h2 class="font-law fw-bold mb-1" style="color: var(--navy);">Justice4U</h2>
    <p class="text-muted small mb-4 text-uppercase fw-bold" style="letter-spacing: 1px;">Claimant Portal</p>
    <div id="alertBox" class="alert alert-info border-0 small mb-4 py-2 d-none">
      <i class="bi bi-info-circle me-2"></i> <span id="alertMessage"></span>
    </div>
    <form id="loginForm" action="${pageContext.request.contextPath}/LoginServlet" method="post">
      <input type="hidden" name="role" value="client">
      <div class="text-start mb-3">
        <label class="form-label small fw-bold text-muted text-uppercase mb-1">Account Email</label>
        <input type="email" id="email" name="email" class="form-control" placeholder="client@example.com" required>
      </div>
      <div class="text-start mb-4">
        <div class="d-flex justify-content-between align-items-center mb-1">
          <label class="form-label small fw-bold text-muted text-uppercase mb-0">Security Code</label>
          <a href="#" class="small text-decoration-none fw-medium" style="color: var(--gold);">Recover?</a>
        </div>
        <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
      </div>
      <button type="submit" class="btn-submit mb-4" id="submitBtn">Secure Login</button>
    </form>
    <div class="mb-4">
      <p class="text-muted small mb-1">New to the platform?</p>
      <a href="../client/customer_form.jsp" class="fw-bold text-decoration-none small" style="color: var(--navy);">Register Secure Profile</a>
    </div>
    <a href="../landing/role_select.html" class="text-muted text-decoration-none small">
      <i class="bi bi-arrow-left me-1"></i> Return to Selection
    </a>
  </div>
  <div class="text-center mt-4">
    <p class="text-muted small">&copy; 2026 Justice4U. All rights reserved.</p>
  </div>
  <script>
    const urlParams = new URLSearchParams(window.location.search);
    const msg = urlParams.get('msg');
    if (msg) {
      document.getElementById('alertBox').classList.remove('d-none');
      document.getElementById('alertMessage').innerText = msg;
    }
    document.getElementById('loginForm').addEventListener('submit', function() {
      const btn = document.getElementById('submitBtn');
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Authenticating...';
    });
  </script>
</body>
</html>