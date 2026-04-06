<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Justice4U | Associate Portal</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root { --navy: #0B192C; --gold: #D4AF37; --bg: #F8F9FA; --border: #EAEAEA; }
    body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 1.5rem; flex-direction: column; }
    .font-law { font-family: 'Playfair Display', serif; }
    .auth-card { width: 100%; max-width: 420px; background: white; padding: 2.5rem; border: 1px solid var(--border); border-top: 4px solid var(--gold); border-radius: 8px; box-shadow: 0 10px 30px rgba(11,25,44,0.05); }
    .form-floating > .form-control { border: 1px solid var(--border); border-radius: 4px; transition: 0.3s; }
    .form-floating > .form-control:focus { border-color: var(--gold); box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.15); }
    .form-floating > label { color: #6c757d; font-size: 0.95rem; }
    .pass-toggle { position: absolute; right: 15px; top: 50%; transform: translateY(-50%); cursor: pointer; color: var(--navy); z-index: 10; font-size: 1.1rem; }
    .btn-submit { background: var(--navy); color: white; height: 50px; font-weight: 600; border-radius: 4px; border: none; transition: 0.3s; width: 100%; }
    .btn-submit:hover { background: var(--gold); color: var(--navy); }
    .btn-submit:disabled { opacity: 0.7; cursor: not-allowed; }
  </style>
</head>
<body>
  <div class="auth-card">
    <div class="text-center mb-4">
      <div class="mb-2">
        <i class="bi bi-mortarboard fs-1" style="color: var(--gold);"></i>
      </div>
      <h2 class="font-law fw-bold mb-1" style="color: var(--navy);">Justice4U</h2>
      <p class="text-muted small mb-0 text-uppercase fw-bold" style="letter-spacing: 1px;">Associate Portal</p>
    </div>
    <div id="errorBanner" class="alert alert-danger d-none small mb-4 py-2 shadow-sm text-center border-0">
      <i class="bi bi-exclamation-circle-fill me-2"></i> <span id="errorText"></span>
    </div>
    <form id="loginForm" action="${pageContext.request.contextPath}/LoginServlet" method="post">
      <input type="hidden" name="role" value="intern">
      <div class="form-floating mb-3">
        <input type="email" id="email" name="email" class="form-control" placeholder="name@example.com" required>
        <label for="email"><i class="bi bi-envelope-fill me-2" style="color: var(--gold);"></i>Account Email</label>
      </div>
      <div class="form-floating mb-4 position-relative">
        <input type="password" id="password" name="password" class="form-control" placeholder="Password" required>
        <label for="password"><i class="bi bi-lock-fill me-2" style="color: var(--gold);"></i>Security Password</label>
        <i class="bi bi-eye pass-toggle" id="passToggle"></i>
      </div>
      <button type="submit" class="btn-submit mb-4" id="submitBtn">
        Authenticate Profile <i class="bi bi-arrow-right ms-2"></i>
      </button>
    </form>
    <div class="text-center small mb-3">
      <p class="text-muted mb-1">Not registered as an associate?</p>
      <a href="../intern/intern.jsp" class="fw-bold text-decoration-none" style="color: var(--navy);">Request Program Access</a>
    </div>
    <div class="text-center pt-3 border-top mt-2">
      <a href="../landing/role_select.html" class="text-muted text-decoration-none small">
        <i class="bi bi-arrow-left me-1"></i> Return to Portal Selection
      </a>
    </div>
  </div>
  <div class="text-center mt-4">
    <p class="text-muted small">&copy; 2026 Justice4U. All rights reserved.</p>
  </div>
  <script>
    document.getElementById('passToggle').addEventListener('click', function() {
      const passInput = document.getElementById('password');
      if (passInput.type === 'password') {
        passInput.type = 'text';
        this.classList.replace('bi-eye', 'bi-eye-slash');
      } else {
        passInput.type = 'password';
        this.classList.replace('bi-eye-slash', 'bi-eye');
      }
    });
    document.getElementById('loginForm').addEventListener('submit', function() {
      const btn = document.getElementById('submitBtn');
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Verifying...';
    });
    const params = new URLSearchParams(window.location.search);
    if (params.get('error')) {
      document.getElementById('errorText').textContent = decodeURIComponent(params.get('error'));
      document.getElementById('errorBanner').classList.remove('d-none');
    }
    if (params.get('msg')) {
      document.getElementById('errorText').textContent = decodeURIComponent(params.get('msg'));
      document.getElementById('errorBanner').classList.remove('d-none');
      document.getElementById('errorBanner').classList.replace('alert-danger', 'alert-info');
    }
  </script>
</body>
</html>