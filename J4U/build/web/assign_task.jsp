<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.RBACUtil, java.util.*"%>
<%@include file="db_connection.jsp" %>
<%
    String lawyerEmail = (String) session.getAttribute("lname");
    String role = (String) session.getAttribute("role");
    Integer lawyerId = (Integer) session.getAttribute("lid");

    if (lawyerEmail == null || lawyerId == null) {
        response.sendRedirect("Lawyer_login.html?msg=Unauthorized");
        return;
    }

    String internIdStr = request.getParameter("intern_id");
    int internId = 0;
    String internName = "";
    String internEmail = "";

    try {
        if (internIdStr != null) {
            Connection con = getDatabaseConnection();
            internId = Integer.parseInt(internIdStr);
            PreparedStatement ps = con.prepareStatement("SELECT name, email FROM intern WHERE internid=?");
            ps.setInt(1, internId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                internName = rs.getString("name");
                internEmail = rs.getString("email");
            }
            rs.close();
            ps.close();
            con.close();
        } else {
             response.sendRedirect("viewinternl.jsp?msg=Invalid Intern ID");
             return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewinternl.jsp?msg=System Error");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Task Delegation</title>
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
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            
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
            max-width: 600px; width: 100%;
            overflow: hidden;
            opacity: 0; transform: translateY(15px);
            animation: enterUp 0.6s var(--ease-smart) forwards;
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

        .form-control, .form-select {
            padding: 12px 16px; border-radius: 8px; border: 1px solid var(--border-subtle);
            font-size: 0.95rem; font-family: "Inter", sans-serif; color: var(--ink-primary);
            box-shadow: none; transition: all 0.2s; background: #fff;
        }
        .form-control:focus, .form-select:focus { border-color: var(--ink-primary); box-shadow: 0 0 0 3px rgba(18, 18, 18, 0.05); outline:none; }

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
            <p>Direct Case Tasking</p>
        </div>
        
        <div class="card-body-custom">
            <form action="process_assign_intern.jsp" method="post">
                <input type="hidden" name="action" value="assign_task">
                <input type="hidden" name="intern_email" value="<%= internEmail %>">
                <input type="hidden" name="lawyer_id" value="<%= lawyerId %>">
                
                <div class="mb-4">
                    <label class="form-label" for="caseId">Associated Case context</label>
                    <select id="caseId" name="case_id" class="form-select" required>
                        <option value="">-- Select Linked Case --</option>
                        <%
                            try {
                                Connection con = getDatabaseConnection();
                                // Fetch cases assigned to THIS lawyer from allotlawyer
                                PreparedStatement psC = con.prepareStatement(
                                    "SELECT cid as case_id, title FROM allotlawyer WHERE lname = ?"
                                );
                                psC.setString(1, lawyerEmail);
                                ResultSet rsC = psC.executeQuery();
                                while(rsC.next()) {
                        %>
                            <option value="<%= rsC.getInt("case_id") %>">#<%= rsC.getInt("case_id") %> - <%= com.j4u.Sanitizer.sanitize(rsC.getString("title")) %></option>
                        <%
                                }
                                rsC.close(); psC.close(); con.close();
                            } catch(Exception e) { out.println("<option disabled>Error loading cases " + e.getMessage() + "</option>"); }
                        %>
                    </select>
                </div>

                <div class="mb-4">
                    <label class="form-label" for="taskTitle">Task Brief / Title</label>
                    <input type="text" id="taskTitle" name="title" class="form-control" required placeholder="e.g. Research Recent IT Precedents">
                </div>
                
                <div class="mb-4">
                    <label class="form-label" for="taskDate">Target Completion Date</label>
                    <input type="date" id="taskDate" name="due_date" class="form-control" required>
                </div>
                
                <div class="action-flex">
                    <a href="viewinternl.jsp" class="btn-custom btn-secondary-custom"><i class="ph ph-x"></i> Cancel</a>
                    <button type="submit" class="btn-custom btn-primary-custom"><i class="ph ph-clipboard-text"></i> Create Task</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
