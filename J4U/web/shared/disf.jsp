<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
</head>
<body>
    <div class="dashboard-shell">
        <header class="admin-header">
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
        <div class="panel">
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
