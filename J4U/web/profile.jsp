<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<%
  String username = (String) session.getAttribute("cname");
  if (username == null) {
    response.sendRedirect("cust_login.html");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Justice4U | My Profile</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <style>
    :root {
      --bg-body: #F3F4F6;
      --bg-surface: #FFFFFF;
      --text-primary: #1F2937;
      --text-secondary: #6B7280;
      --brand-gold: #C6A75E;
      --border-light: #E5E7EB;
      --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
      --radius: 12px;
    }
    body { font-family: 'Inter', sans-serif; background: var(--bg-body); color: var(--text-primary); }
    .container { max-width: 800px; margin: 0 auto; padding: 20px; }
    .profile-card { background: var(--bg-surface); border-radius: var(--radius); padding: 32px; margin-bottom: 24px; box-shadow: var(--shadow-card); }
    .avatar { width: 80px; height: 80px; background: var(--brand-gold); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2rem; font-weight: 600; color: white; margin: 0 auto 20px; }
    .form-group { margin-bottom: 20px; }
    .btn-save { background: var(--brand-gold); color: white; border: none; padding: 12px 24px; border-radius: 8px; font-weight: 600; }
    .btn-save:hover { background: #B0924B; }
  </style>
</head>
<body>
  <div class="container">
    <div class="profile-card">
      <div class="text-center">
        <div class="avatar"><%= username != null ? username.charAt(0).toUpperCase() : "C" %></div>
        <h2>My Profile</h2>
        <p class="text-muted">Manage your account information</p>
      </div>

      <%
        try {
          Class.forName("com.mysql.jdbc.Driver");
          Connection con = getDatabaseConnection();

          PreparedStatement ps = con.prepareStatement("SELECT * FROM cust_reg WHERE email = ?");
          ps.setString(1, username);
          ResultSet rs = ps.executeQuery();

          if (rs.next()) {
      %>
      <form method="post" action="update_profile.jsp">
        <div class="row">
          <div class="col-md-6">
            <div class="form-group">
              <label>Full Name</label>
              <input type="text" class="form-control" name="cname" value="<%= com.j4u.Sanitizer.sanitize(rs.getString("cname")) %>" required>
            </div>
          </div>
          <div class="col-md-6">
            <div class="form-group">
              <label>Email</label>
              <input type="email" class="form-control" name="email" value="<%= com.j4u.Sanitizer.sanitize(rs.getString("email")) %>" readonly>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="col-md-6">
            <div class="form-group">
              <label>Mobile Number</label>
              <input type="text" class="form-control" name="mobno" value="<%= com.j4u.Sanitizer.sanitize(rs.getString("mobno")) %>" required>
            </div>
          </div>
          <div class="col-md-6">
            <div class="form-group">
              <label>Date of Birth</label>
              <input type="date" class="form-control" name="dob" value="<%= com.j4u.Sanitizer.sanitize(rs.getString("dob")) %>" required>
            </div>
          </div>
        </div>

        <div class="form-group">
          <label>Current Address</label>
          <textarea class="form-control" name="cadd" rows="3" required><%= com.j4u.Sanitizer.sanitize(rs.getString("cadd")) %></textarea>
        </div>

        <div class="form-group">
          <label>Permanent Address</label>
          <textarea class="form-control" name="padd" rows="3" required><%= com.j4u.Sanitizer.sanitize(rs.getString("padd")) %></textarea>
        </div>

        <div class="text-center">
          <button type="submit" class="btn-save">Save Changes</button>
        </div>
      </form>
      <%
          }

          rs.close();
          ps.close();
          con.close();
        } catch (Exception e) {
      %>
      <div class="alert alert-danger">
        Error loading profile: <%= e.getMessage() %>
      </div>
      <%
        }
      %>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
