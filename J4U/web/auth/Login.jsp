<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Justice4U | Secure Authentication</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminlte.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/shared/justice4u-tokens.css">
  <style>
    body {
      background: var(--bg);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1.5rem;
    }
    .login-container {
      width: 100%;
      max-width: 420px;
    }
    .login-card {
      background: white;
      padding: 2.5rem;
      border: 1px solid var(--border);
      border-radius: 16px;
      text-align: center;
    }
    .brand-logo {
      font-size: 2rem;
      margin-bottom: 0.5rem;
    }
    .form-control {
      height: 52px;
      padding: 0 1rem;
      border-radius: 8px;
      border: 1px solid var(--border);
      background: var(--bg);
      font-size: 0.95rem;
      transition: all 0.2s ease;
    }
    .form-control:focus {
      background: white;
      border-color: var(--gold);
      box-shadow: 0 0 0 4px rgba(180, 151, 90, 0.1);
    }
    .btn-submit {
      height: 52px;
      font-weight: 600;
      letter-spacing: 0.02em;
    }
  </style>
</head>
<body>
  <div class="login-container">
    <div class="login-card">
      <div class="brand-logo text-serif">
        Justice<span class="text-gold">4U</span>
      </div>
      <p class="text-muted small mb-5 ls-1 text-uppercase fw-bold">Executive Authentication</p>
      <% if(request.getParameter("msg") != null) { %>
        <div class="alert alert-danger border-0 small mb-4 py-2">
          <i class="bi bi-exclamation-circle me-2"></i> <%= request.getParameter("msg") %>
        </div>
      <% } %>
      <form action="${pageContext.request.contextPath}/LoginServlet" method="post" id="loginForm">
        <input type="hidden" name="role" value="admin">
        <div class="text-start mb-4">
          <label for="email" class="form-label small fw-bold text-muted text-uppercase mb-2">Account Identity</label>
          <input type="text" id="email" name="email" class="form-control" placeholder="Enter your email or username" required>
        </div>
        <div class="text-start mb-5">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <label for="password" class="form-label small fw-bold text-muted text-uppercase mb-0">Security Protocol</label>
            <a href="#" class="small text-gold text-decoration-none fw-medium">Recovery?</a>
          </div>
          <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
        </div>
        <button type="submit" class="btn btn-gold btn-submit w-100 mb-4" id="submitBtn">
          Authenticate Access
        </button>
      </form>
      <a href="../landing/role_select.html" class="text-muted text-decoration-none small opacity-75 hover-opacity-100">
        <i class="bi bi-arrow-left me-1"></i> Return to Portal Selection
      </a>
    </div>
    <div class="text-center mt-4">
      <p class="text-muted small">Global Compliance Standard &copy; 2026 Justice4U</p>
    </div>
  </div>
  <script>
    document.getElementById('loginForm').addEventListener('submit', function() {
      const btn = document.getElementById('submitBtn');
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Verifying...';
    });
  </script>
</body>
</html>