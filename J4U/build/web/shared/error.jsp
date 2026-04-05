<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>System Error | Justice4U</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <style>
    :root { --gold: #B4975A; --bg: #F9FAFB; --text: #111827; }
    body { font-family: 'Inter', sans-serif; background: var(--bg); min-height: 100vh; display: flex; align-items: center; justify-content: center; margin: 0; padding: 1.5rem; }
    .error-card { max-width: 440px; width: 100%; background: white; border: 1px solid rgba(0,0,0,0.08); border-radius: 12px; padding: 3rem 2.5rem; text-align: center; }
    .font-serif { font-family: 'DM Serif Display', serif; }
    .btn-dark { background: var(--text); color: white; border: none; border-radius: 8px; padding: 0.75rem; font-weight: 500; transition: 0.2s; width: 100%; display: block; text-decoration: none; }
    .btn-dark:hover { opacity: 0.9; color: white; }
    .error-details { background: #f8f8f8; border: 1px solid #eee; border-radius: 8px; padding: 1rem; margin: 1rem 0; text-align: left; max-height: 200px; overflow: auto; }
    .error-details p { margin: 0.25rem 0; font-size: 0.8rem; color: #666; }
    .error-details pre { font-size: 0.7rem; color: #c00; white-space: pre-wrap; margin: 0.5rem 0 0 0; }
  </style>
</head>
<body>
  <div class="error-card">
    <i class="bi bi-exclamation-triangle" style="font-size: 3rem; color: var(--gold); opacity: 0.6;"></i>
    <h2 class="font-serif mb-3 mt-3" style="font-size: 1.75rem; color: var(--text);">System Exception</h2>
    <p style="color: #6B7280; font-size: 0.9rem; line-height: 1.6; max-width: 320px; margin: 0 auto 1.5rem;">A procedural fault occurred during operation. The trace has been logged for administrative review.</p>
    <%
      Throwable ex = (Throwable) request.getAttribute("javax.servlet.error.exception");
      Integer errorCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
      String errorURI = (String) request.getAttribute("javax.servlet.error.request_uri");
    %>
    <% if(ex != null || errorCode != null) { %>
    <div class="error-details">
      <% if(errorURI != null) { %><p><strong>URI:</strong> <%= errorURI %></p><% } %>
      <% if(errorCode != null) { %><p><strong>Code:</strong> <%= errorCode %></p><% } %>
      <% if(ex != null) { %>
        <p><strong>Error:</strong> <%= ex.getClass().getSimpleName() %>: <%= ex.getMessage() != null ? ex.getMessage().substring(0, Math.min(ex.getMessage().length(), 200)) : "Unknown" %></p>
      <% } %>
    </div>
    <% } %>
    <a href="${pageContext.request.contextPath}/landing/Home.html" class="btn-dark">Return to Hub</a>
  </div>
</body>
</html>