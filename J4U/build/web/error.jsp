<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Error - Justice4U</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #FAFAF8; font-family: 'Inter', sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .error-card { background: #FFFFFF; padding: 40px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); text-align: center; max-width: 500px; border: 1px solid #E6E6E6; }
        .error-icon { font-size: 4rem; color: #DC2626; margin-bottom: 20px; }
        h1 { font-family: 'Playfair Display', serif; color: #121212; margin-bottom: 10px; }
        p { color: #555555; margin-bottom: 24px; font-size: 0.95rem; }
        .btn-home { background-color: #121212; color: #FFFFFF; padding: 10px 24px; border-radius: 6px; text-decoration: none; font-weight: 500; transition: background 0.2s; }
        .btn-home:hover { background-color: #C6A75E; color: #FFFFFF; }
    </style>
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
</head>
<body>
    <div class="error-card">
        <i class="ph-fill ph-warning-circle error-icon"></i>
        <h1>System Error</h1>
        <p>Our secure system encountered an unexpected error while processing your request. Please try again or return securely to the homepage.</p>
        <div style="background: #f8f9fa; padding: 15px; margin-bottom: 20px; text-align: left; overflow: auto; max-height: 200px; font-size: 0.8rem; border: 1px solid #ccc;">
            <strong>Error Details:</strong><br/>
            <%
                String urlError = request.getParameter("error");
                if (exception != null) {
                    out.println(exception.getMessage());
                    exception.printStackTrace(new java.io.PrintWriter(out));
                } else if (urlError != null) {
                    out.println(com.j4u.Sanitizer.sanitize(urlError));
                } else {
                    out.println("No exception details available.");
                }
            %>
        </div>
        <a href="Home.html" class="btn-home">Return to Safety</a>
    </div>
</body>
</html>
