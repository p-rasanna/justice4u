<%@page import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%!
    String safeEncode(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
    }
%>
<%
  String lnameSession = (String) session.getAttribute("lname");
  if (lnameSession == null) {
      session.invalidate();
      response.sendRedirect("Lawyer_login.html");
      return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U · Consultation Hub</title>

    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        /* ============================
           1. 10/10 INTELLIGENCE THEME
           ============================ */
        :root {
            --bg-ivory: #FAFAF8;
            --ink-primary: #121212;
            --ink-secondary: #555555;
            --ink-tertiary: #888888;
            
            --gold-main: #C6A75E;
            --gold-dim: #9C824A;
            --success-green: #059669;
            --danger-red: #DC2626;
            
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            --border-focus: #121212;
            
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background-color: var(--bg-ivory);
            color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .dashboard-shell {
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 32px;
        }

        .smart-enter {
            opacity: 0; transform: translateY(15px);
            /* animation removed */
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }
        .d-3 { animation-delay: 0.3s; }

        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* HEADER */
        .admin-header {
            display: flex; justify-content: space-between; align-items: flex-end;
            margin-bottom: 40px; border-bottom: 1px solid var(--border-subtle); padding-bottom: 24px;
        }

        .header-content h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.2rem; margin: 0; color: var(--ink-primary);
        }
        
        .header-meta {
            display: flex; gap: 24px; align-items: center; margin-top: 8px;
            font-family: 'Space Grotesk', monospace; font-size: 0.8rem; color: var(--ink-secondary);
        }

        .admin-profile {
            display: flex; align-items: center; gap: 12px;
            padding: 8px 16px; background: #fff; border: 1px solid var(--border-subtle);
            border-radius: 100px; box-shadow: var(--shadow-card);
        }
        .profile-role { 
            font-family: 'Inter', sans-serif;
            font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600; color: var(--gold-main); 
        }

        /* FORM PANEL */
        .panel {
            background: var(--surface-card);
            border: 1px solid var(--border-subtle);
            border-radius: 16px; overflow: hidden;
            box-shadow: var(--shadow-card);
            padding: 40px;
        }

        .form-section-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.4rem; color: var(--ink-primary); margin-bottom: 24px;
            display: flex; align-items: center; gap: 10px;
        }
        .form-section-title i { color: var(--gold-main); }

        .form-group { margin-bottom: 24px; }
        .form-group label {
            display: block; font-weight: 600; font-size: 0.85rem; color: var(--ink-secondary);
            margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.05em;
        }
        
        .form-control {
            width: 100%; padding: 12px 16px; border-radius: 8px;
            border: 1px solid var(--border-subtle); background: #FAFAFA;
            font-family: 'Inter', sans-serif; font-size: 0.95rem; color: var(--ink-primary);
            transition: all 0.2s;
        }
        .form-control:focus {
            background: #FFF; border-color: var(--border-focus);
            box-shadow: 0 0 0 4px rgba(18, 18, 18, 0.05); outline: none;
        }
        textarea.form-control { resize: vertical; min-height: 120px; }

        .error {
            color: var(--danger-red); font-size: 0.8rem; font-weight: 500;
            display: block; margin-top: 6px;
        }

        /* BUTTONS */
        .btn-flex {
            display: flex; gap: 16px; margin-top: 32px; padding-top: 24px;
            border-top: 1px solid var(--border-subtle); justify-content: flex-end;
        }
        
        .btn-custom {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size: 0.9rem;
            text-decoration: none; border: none; cursor: pointer; transition: all 0.2s;
        }
        .btn-primary-intel {
            background: var(--ink-primary); color: #fff;
        }
        .btn-primary-intel:hover {
            background: var(--gold-main); transform: translateY(-2px);
        }
        .btn-secondary {
            background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary);
        }
        .btn-secondary:hover {
            border-color: var(--ink-secondary); transform: translateY(-2px);
        }

        @media (max-width: 768px) {
            .dashboard-shell { padding: 20px; }
            .panel { padding: 24px; }
            .btn-flex { flex-direction: column; }
            .btn-custom { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body>
    <div class="dashboard-shell">

        <header class="admin-header smart-enter d-1">
            <div class="header-content">
                <h1>Consultation Hub</h1>
                <div class="header-meta">
                    <span class="meta-item"><i class="ph ph-lock-key" style="color:var(--success-green);"></i> Secure Message Thread</span>
                    <span class="meta-item"><i class="ph ph-paper-plane-tilt"></i> Dispatching as <%= lnameSession %></span>
                </div>
            </div>
            <div class="admin-profile">
                <span class="profile-role">Verified Counsel</span>
            </div>
        </header>

        <div class="panel smart-enter d-2">
            <h2 class="form-section-title"><i class="ph-fill ph-chat-circle-text"></i> Open New Discussion</h2>
            
            <form action="lddone.jsp" onsubmit="return validateForm()">
                <div class="row">
                    <div class="col-md-6 form-group">
                        <label for="txtname">Discussion Title</label>
                        <input type="text" name="title" id="txtname" class="form-control" placeholder="E.g., Document Review Update" required>
                        <span id="nameError" class="error"></span>
                    </div>
                    <div class="col-md-6 form-group">
                        <label for="txtemail">Current Date</label>
                        <!-- Auto-filling to today for better UX -->
                        <input type="date" name="cdate" id="txtemail" class="form-control" value="<%= new java.sql.Date(System.currentTimeMillis()).toString() %>" required>
                        <span id="emailError" class="error"></span>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="txtcpass">Target Client</label>
                        <select name="cname" id="txtcpass" class="form-control" required>
                            <option value="">-- Select an Assigned Client --</option>
                            <%
                            try {
                                Connection con = getDatabaseConnection();
                                PreparedStatement pst = con.prepareStatement("SELECT DISTINCT(cname) FROM allotlawyer WHERE lname=?");
                                pst.setString(1, lnameSession);
                                ResultSet rs = pst.executeQuery();
                                while(rs.next()) {
                                    out.println("<option value=\""+safeEncode(rs.getString(1))+"\">"+safeEncode(rs.getString(1))+"</option>");
                                }
                                rs.close(); pst.close(); con.close();
                            } catch(Exception e) {
                                out.println("<option disabled>Error loading clients</option>");
                            }
                            %>
                        </select>
                        <span id="cpassError" class="error"></span>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12 form-group">
                        <label for="descr">Message / Advice</label>
                        <textarea name="descr" id="descr" class="form-control" placeholder="Write your legal advice or discussion notes here..." required></textarea>
                        <span id="passError" class="error"></span>
                    </div>
                </div>

                <!-- Hidden, but keeping the name 'lemail' parameter as requested by lddone.jsp -->
                <input type="hidden" name="lemail" value="<%= lnameSession %>">

                <div class="btn-flex">
                    <a href="Lawyerdashboard.jsp" class="btn-custom btn-secondary"><i class="ph ph-x"></i> Cancel</a>
                    <button type="submit" class="btn-custom btn-primary-intel"><i class="ph ph-paper-plane-right"></i> Send Message</button>
                </div>
            </form>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function validateForm() {
            let isValid = true;
            let title = document.getElementById("txtname").value.trim();
            let client = document.getElementById("txtcpass").value.trim();
            let desc = document.getElementById("descr").value.trim();

            if (title === "") {
                document.getElementById("nameError").innerText = "Title is required.";
                isValid = false;
            } else {
                document.getElementById("nameError").innerText = "";
            }

            if (client === "") {
                document.getElementById("cpassError").innerText = "Please select a client.";
                isValid = false;
            } else {
                document.getElementById("cpassError").innerText = "";
            }

            if (desc === "") {
                document.getElementById("passError").innerText = "Message cannot be empty.";
                isValid = false;
            } else {
                document.getElementById("passError").innerText = "";
            }

            return isValid;
        }
    </script>
</body>
</html>
