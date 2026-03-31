<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied | Justice4U</title>
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display:ital@0;1&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../shared/app-layout.css">
</head>
<body class="auth-grid">
    <div class="auth-card auth-card-wide text-center">
        <i class="ph-fill ph-prohibit text-faint mb-4" style="font-size: 3rem;"></i>
        <h2 class="font-serif mb-3" style="font-size:2rem;">Access Denied</h2>
        <p class="text-muted small mb-4 mx-auto" style="max-width:320px; line-height:1.6;">Your current authorization scope does not permit entry to this directory. Reach out to an administrator for clearance.</p>
        <a href="../auth/Login.jsp" class="btn btn-dark w-100 p-3">Re-Authenticate</a>
        
    </div>
</body>
</html>
