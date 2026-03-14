<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%
    String internEmail = request.getParameter("intern_email");
    String internName = request.getParameter("intern_name");
    String lawyerEmail = (String) session.getAttribute("lname");
    
    if (lawyerEmail == null) {
        response.sendRedirect("Lawyer_login.html");
        return;
    }
    
    if (internEmail == null) {
        response.sendRedirect("viewinternl.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Case Delegation</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
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
            
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        body { 
            margin: 0; 
            font-family: "Inter", sans-serif; 
            background: var(--bg-ivory); 
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
            padding: 40px 20px;
        }

        .delegation-card {
            background: var(--surface-card);
            border-radius: 16px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.04);
            max-width: 600px;
            width: 100%;
            overflow: hidden;
            opacity: 0; transform: translateY(15px);
            /* animation removed */
        }

        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        .card-head {
            padding: 32px 32px 24px; text-align: center; border-bottom: 1px solid var(--border-subtle);
            background: #FAFAFA;
        }
        
        .card-head h3 {
            font-family: 'Playfair Display', serif; font-size: 1.8rem;
            color: var(--ink-primary); margin: 0 0 8px 0;
        }
        .card-head p { margin: 0; color: var(--ink-secondary); font-size: 0.95rem; }

        .avatar {
            width: 64px; height: 64px; background: rgba(198, 167, 94, 0.1);
            color: var(--gold-main); border-radius: 50%; border: 1px solid rgba(198, 167, 94, 0.3);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem; font-family: 'Playfair Display', serif; margin: 0 auto 16px;
        }

        .card-body-custom { padding: 32px; }

        .form-label {
            font-weight: 600; font-size: 0.85rem; color: var(--ink-secondary);
            text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;
        }

        .form-select {
            padding: 12px 16px; border-radius: 8px; border: 1px solid var(--border-subtle);
            font-size: 0.95rem; font-family: "Inter", sans-serif; color: var(--ink-primary);
            box-shadow: none; transition: all 0.2s;
        }
        .form-select:focus { border-color: var(--ink-primary); box-shadow: 0 0 0 3px rgba(18, 18, 18, 0.05); }

        .action-flex {
            display: flex; justify-content: space-between; gap: 16px; margin-top: 32px;
            padding-top: 24px; border-top: 1px solid var(--border-subtle);
        }

        .btn-custom {
            padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size: 0.9rem;
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            transition: all 0.2s; text-decoration: none; border: none; cursor: pointer; flex: 1;
        }

        .btn-secondary-custom {
            background: #fff; border: 1px solid var(--border-subtle); color: var(--ink-primary);
        }
        .btn-secondary-custom:hover { border-color: var(--ink-secondary); transform: translateY(-2px); }

        .btn-primary-custom {
            background: var(--ink-primary); color: #fff;
        }
        .btn-primary-custom:hover { background: var(--gold-main); transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="delegation-card">
        <div class="card-head">
            <div class="avatar"><%= internName != null && !internName.isEmpty() ? internName.charAt(0) : 'I' %></div>
            <h3><%= internName %></h3>
            <p>Case Delegation Interface</p>
        </div>
        
        <div class="card-body-custom">
            <form action="process_assign_intern.jsp" method="post">
                <input type="hidden" name="action" value="assign_case">
                <input type="hidden" name="intern_email" value="<%= internEmail %>">
                
                <%
                    int lawyerId = 0;
                    try {
                        Connection con = getDatabaseConnection();
                        // Get Lawyer ID
                        PreparedStatement psL = con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?");
                        psL.setString(1, lawyerEmail);
                        ResultSet rsL = psL.executeQuery();
                        if (rsL.next()) {
                            lawyerId = rsL.getInt("lid");
                        }
                        rsL.close();
                        psL.close();
                %>
                <input type="hidden" name="lawyer_id" value="<%= lawyerId %>">
                
                <div class="mb-4">
                    <label class="form-label" for="activeCaseSelect">Select Active Case (Read-Only Access)</label>
                    <select id="activeCaseSelect" name="case_id" class="form-select" required>
                        <option value="">-- Choose Case --</option>
                        <%
                            // Fetch Active Cases assigned to this lawyer from allotlawyer
                            // In this system, allotlawyer seems to be the mapping.
                            PreparedStatement psC = con.prepareStatement(
                                "SELECT a.cid as case_id, a.title, cr.name as client_name " +
                                "FROM allotlawyer a " +
                                "JOIN cust_reg cr ON a.cname = cr.email " +
                                "WHERE a.lname = ? " +
                                "ORDER BY a.cid DESC"
                            );
                            psC.setString(1, lawyerEmail);
                            ResultSet rsC = psC.executeQuery();
                            boolean hasCases = false;
                            while(rsC.next()) {
                                hasCases = true;
                        %>
                        <option value="<%= rsC.getInt("case_id") %>">
                            #<%= rsC.getInt("case_id") %> - <%= com.j4u.Sanitizer.sanitize(rsC.getString("title")) %> (<%= com.j4u.Sanitizer.sanitize(rsC.getString("client_name")) %>)
                        </option>
                        <%
                            }
                            if(!hasCases) out.println("<option disabled>No active cases available to assign.</option>");
                            rsC.close();
                            psC.close();
                            con.close();
                        } catch(Exception e) {
                            out.println("<option disabled>Error loading cases " + e.getMessage() + "</option>");
                        }
                        %>
                    </select>
                </div>
                
                <div class="action-flex">
                    <a href="viewinternl.jsp" class="btn-custom btn-secondary-custom"><i class="ph ph-x"></i> Cancel</a>
                    <button type="submit" class="btn-custom btn-primary-custom"><i class="ph ph-briefcase"></i> Authorize Access</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
