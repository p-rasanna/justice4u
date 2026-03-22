<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, java.util.*" %>
<%@ include file="db_connection.jsp" %>
<%
    String username = (String) session.getAttribute("cname");
    String cemailSession = (String) session.getAttribute("cemail"); 
    if(cemailSession == null && username != null && username.contains("@")) {
        cemailSession = username;
    }
    if (cemailSession == null) {
        response.sendRedirect("cust_login.html?msg=Session expired");
        return;
    }

    String lawyerEmail = request.getParameter("lawyer_email");
    if (lawyerEmail == null || lawyerEmail.isEmpty()) {
        response.sendRedirect("findlawyer.jsp?error=No lawyer selected");
        return;
    }

    Connection con = null;
    PreparedStatement st = null;
    ResultSet rs = null;
    
    int custId = -1;
    int lawyerId = -1;
    String lawyerName = "";
    List<Map<String, String>> openCases = new ArrayList<>();

    try {
        con = getDatabaseConnection();
        // Get customer ID
        st = con.prepareStatement("SELECT cid FROM cust_reg WHERE email=?");
        st.setString(1, cemailSession);
        rs = st.executeQuery();
        if (rs.next()) custId = rs.getInt("cid");
        rs.close(); st.close();

        // Get lawyer ID and name
        st = con.prepareStatement("SELECT lid, name, fname, lname FROM lawyer_reg WHERE email=?");
        st.setString(1, lawyerEmail);
        rs = st.executeQuery();
        if (rs.next()) {
            lawyerId = rs.getInt("lid");
            lawyerName = rs.getString("name");
            if (lawyerName == null || lawyerName.trim().isEmpty()) {
                lawyerName = rs.getString("fname") + " " + rs.getString("lname");
            }
        }
        rs.close(); st.close();

        if (lawyerId == -1) {
             response.sendRedirect("findlawyer.jsp?error=Invalid lawyer selected");
             return;
        }

        // Handle POST submission
        String action = request.getParameter("action");
        if ("link_case".equals(action)) {
             String caseIdStr = request.getParameter("selected_case_id");
             if(caseIdStr != null && !caseIdStr.isEmpty()) {
                 int caseId = Integer.parseInt(caseIdStr);
                 
                 // Update customer_cases
                 PreparedStatement upd1 = con.prepareStatement("UPDATE customer_cases SET assigned_lawyer_id=?, status='REQUESTED' WHERE case_id=? AND customer_id=?");
                 upd1.setInt(1, lawyerId);
                 upd1.setInt(2, caseId);
                 upd1.setInt(3, custId);
                 upd1.executeUpdate();
                 upd1.close();

                 // Update legacy casetb
                 try {
                    PreparedStatement upd2 = con.prepareStatement("UPDATE casetb SET flag=1, lid=? WHERE cid=?"); 
                    upd2.setInt(1, lawyerId);
                    upd2.setInt(2, caseId);
                    upd2.executeUpdate();
                    upd2.close();
                 } catch(Exception e) { /* ignore */ }
                 
                 response.sendRedirect("ClientDashboard?msg=Counsel Requested Successfully");
                 return;
             }
        }

        // Fetch OPEN cases for dropdown
        st = con.prepareStatement("SELECT case_id, title FROM customer_cases WHERE customer_id=? AND status='OPEN' ORDER BY case_id DESC");
        st.setInt(1, custId);
        rs = st.executeQuery();
        while (rs.next()) {
             Map<String, String> cMap = new HashMap<>();
             cMap.put("id", String.valueOf(rs.getInt("case_id")));
             cMap.put("title", rs.getString("title"));
             openCases.add(cMap);
        }
        rs.close(); st.close();

        // If NO open cases, redirect strictly to create case page
        if (openCases.isEmpty()) {
             response.sendRedirect("case.jsp?lawyer_email=" + java.net.URLEncoder.encode(lawyerEmail, "UTF-8") + "&lawyer_name=" + java.net.URLEncoder.encode(lawyerName, "UTF-8"));
             return;
        }

    } catch (Exception e) {
        response.sendRedirect("findlawyer.jsp?error=" + e.getMessage());
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e){}
        if (st != null) try { st.close(); } catch(Exception e){}
        if (con != null) try { con.close(); } catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <title>Justice4U | Request Counsel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Switzer:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --bg: #FDFBF7; 
            --surface: #FFFFFF;
            --border: rgba(28, 25, 23, 0.08);
            --text-main: #1C1917; 
            --text-muted: #57534E;
            --accent-gold: #D4AF37; 
            --accent-gold-dark: #B48E2D;
            --radius-md: 12px;
            --shadow-md: 0 8px 24px rgba(28, 25, 23, 0.06);
            --transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        body {
            margin: 0; background-color: var(--bg); color: var(--text-main);
            font-family: 'Switzer', sans-serif; display: grid; place-items: center; min-height: 100vh;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .auth-card {
            background: var(--surface); padding: 48px; border-radius: var(--radius-md);
            box-shadow: var(--shadow-md); border: 1px solid var(--border); width: 100%; max-width: 500px;
            text-align: center;
        }

        .auth-logo { color: var(--accent-gold); font-size: 3rem; margin-bottom: 24px; }
        
        .auth-card h1 {
            font-family: 'Instrument Serif', serif; font-size: 2.5rem; margin: 0 0 12px; color: var(--text-main); font-style: italic; line-height: 1.1;
        }

        .auth-card p { color: var(--text-muted); font-size: 1rem; margin: 0 0 32px; line-height: 1.5; }

        .form-group { text-align: left; margin-bottom: 24px; }
        .form-label { display: block; font-size: 0.9rem; font-weight: 500; color: var(--text-muted); margin-bottom: 8px; }
        .form-select {
            width: 100%; padding: 14px 16px; border: 1px solid var(--border); border-radius: var(--radius-md);
            font-family: 'Switzer', sans-serif; font-size: 1rem; color: var(--text-main); background: #FAFAFA;
            outline: none; transition: var(--transition); appearance: none;
        }
        .form-select:focus { border-color: var(--accent-gold); background: #fff; box-shadow: 0 0 0 4px rgba(212, 175, 55, 0.1); }

        .btn-submit {
            width: 100%; background: var(--text-main); color: #fff; border: none; padding: 16px;
            border-radius: var(--radius-md); font-family: 'Switzer', sans-serif; font-size: 1.05rem; font-weight: 500;
            cursor: pointer; transition: var(--transition); display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .btn-submit:hover { background: var(--accent-gold-dark); transform: translateY(-2px); }

        .btn-cancel {
            width: 100%; background: transparent; color: var(--text-muted); border: 1px solid var(--border); padding: 16px; display: inline-block;
            border-radius: var(--radius-md); font-family: 'Switzer', sans-serif; font-size: 1.05rem; font-weight: 500; text-decoration: none;
            cursor: pointer; transition: var(--transition); margin-top: 16px;
        }
        .btn-cancel:hover { background: #FAFAFA; border-color: var(--text-main); color: var(--text-main); }

    </style>
</head>
<body>
    <div class="auth-card">
        <i class="ph-fill ph-scales auth-logo"></i>
        <h1>Request Counsel</h1>
        <p>You are requesting <strong>Adv. <%= com.j4u.Sanitizer.sanitize(lawyerName) %></strong> to represent you. Please select the case you wish to assign them to.</p>

        <form action="requestlawyer.jsp" method="POST">
            <input type="hidden" name="action" value="link_case">
            <input type="hidden" name="lawyer_email" value="<%= com.j4u.Sanitizer.sanitize(lawyerEmail) %>">
            
            <div class="form-group">
                <label class="form-label" for="selected_case_id">Select Open Case</label>
                <div style="position:relative;">
                    <select class="form-select" id="selected_case_id" name="selected_case_id" required>
                        <option value="" disabled selected>— Choose Case —</option>
                        <% for(Map<String, String> c : openCases) { %>
                            <option value="<%= c.get("id") %>">Case #<%= c.get("id") %>: <%= com.j4u.Sanitizer.sanitize(c.get("title")) %></option>
                        <% } %>
                    </select>
                    <i class="ph-bold ph-caret-down" style="position:absolute; right:16px; top:50%; transform:translateY(-50%); pointer-events:none; color:var(--text-muted);"></i>
                </div>
            </div>

            <button type="submit" class="btn-submit">
                Link Case & Request Lawyer <i class="ph-bold ph-arrow-right"></i>
            </button>
            <a href="findlawyer.jsp" class="btn-cancel">Cancel</a>
        </form>
    </div>
</body>
</html>
