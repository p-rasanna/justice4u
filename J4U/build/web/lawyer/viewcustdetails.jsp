<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="../shared/db_connection.jsp" %>
<%
  // ==========================================
  // BACKEND LOGIC (STRICTLY PRESERVED)
  // ==========================================
  String lnameSession = (String) session.getAttribute("lname");
  if (lnameSession == null) {
    session.invalidate();
    response.sendRedirect("../auth/Lawyer_login_form.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Justice4U · Client Roster</title>
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  
</head>
<body>
  <div class="dashboard-shell">
    <header class="admin-header">
        <div class="header-content">
            <h1>Assigned Portfolio</h1>
            <div class="header-meta">
                <span class="meta-item"><i class="ph ph-lock-key secure-lock"></i> Secure Counsel Session</span>
                <span class="meta-item"><i class="ph ph-users-three"></i> Client Roster</span>
            </div>
        </div>
        <div class="admin-profile">
            <span class="profile-dot"></span>
            <span class="profile-role">Verified Counsel</span>
        </div>
    </header>
    <div class="panel">
        <div class="panel-head">
            <div class="panel-head-left">
                <h3><i class="ph ph-address-book panel-icon"></i> Client Intelligence Roster</h3>
                <span class="tag-info">Live Database</span>
            </div>
            <div class="search-bar">
                <i class="ph-bold ph-magnifying-glass" style="color:var(--ink-tertiary)"></i>
                <input type="text" id="clientSearch" class="search-input" placeholder="Search client name, court, or case..." onkeyup="filterTable()">
            </div>
        </div>
        <div class="table-responsive">
            <table class="table" id="clientTable">
              <thead>
                <tr>
                  <th>Case Ref</th>
                  <th>Client Profile</th>
                  <th>Matter Details</th>
                  <th>Jurisdiction</th>
                  <th>Financials</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <%
                  try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = getDatabaseConnection();
                    // 1. Get Lawyer ID
                    PreparedStatement psLid = con.prepareStatement("SELECT lid FROM lawyer_reg WHERE email=?");
                    psLid.setString(1, lnameSession);
                    ResultSet rsLid = psLid.executeQuery();
                    int lawyerId = 0;
                    if (rsLid.next()) {
                        lawyerId = rsLid.getInt(1);
                    }
                    rsLid.close(); psLid.close();
                    // 2. Query allotlawyer and casetb
                    PreparedStatement ps = con.prepareStatement(
                      "SELECT a.cid as case_id, a.title, a.des as description, a.curdate as created_date, " +
                      "a.courttype as preferred_court_location, a.mop as payment_model, a.amt as total_fee, " +
                      "a.name as cname, a.cname as email, cr.cid as client_id " +
                      "FROM allotlawyer a " +
                      "JOIN casetb c ON a.cid = c.cid " +
                      "JOIN cust_reg cr ON a.cname = cr.email " +
                      "WHERE a.lname = ? AND c.flag >= 1"
                    );
                    ps.setString(1, lnameSession);
                    ResultSet rs = ps.executeQuery();
                    boolean hasData = false;
                    while(rs.next()) {
                      hasData = true;
                      int caseId = rs.getInt("case_id");
                      String title = rs.getString("title");
                      if(title == null) title = "Case #" + caseId;
                      String desc = rs.getString("description");
                      if(desc == null) desc = "N/A";
                      Date date = rs.getDate("created_date");
                      String court = rs.getString("preferred_court_location");
                      if(court == null) court = "Online Jurisdiction";
                      String payMode = rs.getString("payment_model");
                      if(payMode == null) payMode = "Standard";
                      double amount = rs.getDouble("total_fee");
                      String clientName = rs.getString("cname");
                      String email = rs.getString("email");
                      int clientId = rs.getInt("client_id");
                %>
                <tr>
                  <td>
                    <div class="col-id">#C-<%= caseId %></div>
                    <div class="col-sub">Assigned</div>
                  </td>
                  <td>
                    <div class="col-main"><%= clientName %></div>
                    <div class="col-sub"><%= email %></div>
                  </td>
                  <td class="wrap-cell">
                    <div class="col-main"><%= title %></div>
                    <div class="col-sub" style="margin-bottom:4px;"><%= desc %></div>
                    <div class="col-sub" style="color:var(--gold-main); font-weight:600;"><i class="ph-bold ph-calendar"></i> <%= date %></div>
                  </td>
                  <td>
                    <span class="tag tag-court"><%= court %></span>
                  </td>
                  <td>
                    <div class="col-main">$<%= String.format("%.2f", amount) %></div>
                    <div style="margin-top:4px;"><span class="tag tag-pay"><%= payMode %></span></div>
                  </td>
                  <td>
                    <div class="action-flex">
                        <a href="viewcusdet.jsp?client_id=<%= clientId %>" class="btn-action">
                            <i class="ph ph-folder-open"></i> Dossier
                        </a>
                    </div>
                  </td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr>
                  <td colspan="6">
                    <div class="empty-state">
                      <i class="ph-duotone ph-folder-dashed" style="font-size:3rem; margin-bottom:12px; color:var(--ink-tertiary);"></i><br>
                      <span>No Clients Assigned Yet. When administrators assign cases to you, they will appear here.</span>
                    </div>
                  </td>
                </tr>
                <%
                    }
                    rs.close(); ps.close(); con.close();
                  } catch(Exception e) {
                %>
                <tr><td colspan="6" style="color:red; padding:20px; text-align:center;">System Error: <%= e.getMessage() %></td></tr>
                <% } %>
              </tbody>
            </table>
        </div>
    </div>
    <div class="footer-nav">
        <a href="Lawyerdashboard.jsp" class="btn-nav btn-back">
            <i class="ph ph-arrow-left"></i> Counsel Workspace
        </a>
        <a href="../shared/signout.jsp?role=lawyer" class="btn-nav btn-danger">
            <i class="ph ph-sign-out"></i> Sign Out
        </a>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function filterTable() { const input = document.getElementById("clientSearch"); const filter = input.value.toUpperCase(); const table = document.getElementById("clientTable"); const tr = table.getElementsByTagName("tr"); for (let i = 1; i < tr.length; i++) { let textContent = tr[i].textContent || tr[i].innerText; if (textContent.toUpperCase().indexOf(filter) > -1) { tr[i].style.display = ""; } else { tr[i].style.display = "none"; } } }
  </script>
</body>
</html>
