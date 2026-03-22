<%@page import="java.sql.*" %>
  <%@include file="db_connection.jsp" %>
<%
    // Admin Session Validation Guard
    if (session.getAttribute("aname") == null) {
        response.sendRedirect("Login.html?msg=Unauthorized access");
        return;
    }
%>
    <!DOCTYPE html>
    <html lang="en">

    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Case Review & Lawyer Allocation | Justice4U</title>

      <!-- Bootstrap 3 for compatibility with your existing pages -->
      <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">

      <style>
        :root {
          --j4u-bg: #f5f2ea;
          --j4u-surface: #fdfbf6;
          --j4u-border: #ddd1b8;
          --j4u-gold: #c9a76a;
          --j4u-gold-soft: #e3c796;
          --j4u-text-main: #111827;
          --j4u-text-muted: #6b7280;
          --j4u-accent-blue: #2563eb;
          --j4u-accent-green: #16a34a;
        }

        html,
        body {
          height: 100%;
        }

        body {
          margin: 0;
          min-height: 100vh;
          background:
            radial-gradient(circle at top, #f0ebe0 0, #f5f2ea 32%, #e8decc 100%);
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
          color: var(--j4u-text-main);
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 24px 12px;
        }

        .shell {
          width: 100%;
          max-width: 980px;
        }

        .page-header-bar {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 14px;
        }

        .page-title {
          font-size: 1.4rem;
          font-weight: 600;
          margin: 0;
        }

        .page-subtitle {
          margin: 2px 0 0;
          font-size: 0.88rem;
          color: var(--j4u-text-muted);
        }

        .badge-flow {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          padding: 4px 10px;
          border-radius: 999px;
          border: 1px solid rgba(148, 133, 96, 0.7);
          background: rgba(253, 251, 246, 0.9);
          font-size: 0.75rem;
          color: #7c5f2b;
        }

        .badge-dot {
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background: var(--j4u-accent-blue);
          box-shadow: 0 0 8px rgba(37, 99, 235, 0.7);
        }

        .card-main {
          background: var(--j4u-surface);
          border-radius: 20px;
          border: 1px solid var(--j4u-border);
          box-shadow:
            0 18px 38px rgba(15, 23, 42, 0.16),
            0 0 0 1px rgba(148, 133, 96, 0.16);
          padding: 18px 20px 20px;
          position: relative;
          overflow: hidden;
        }

        .card-main::before {
          content: "";
          position: absolute;
          top: 0;
          left: 18px;
          right: 18px;
          height: 4px;
          border-radius: 0 0 999px 999px;
          background: linear-gradient(90deg, var(--j4u-gold), var(--j4u-gold-soft));
          opacity: 0.95;
        }

        .section-label {
          font-size: 0.8rem;
          text-transform: uppercase;
          letter-spacing: 0.1em;
          color: var(--j4u-text-muted);
          margin: 8px 0 4px;
        }

        .divider-soft {
          border-top: 1px dashed #e5e7eb;
          margin-bottom: 10px;
        }

        .field-label {
          font-size: 0.8rem;
          text-transform: uppercase;
          letter-spacing: 0.09em;
          color: var(--j4u-text-muted);
          margin-bottom: 4px;
        }

        .form-control {
          border-radius: 10px;
          border: 1px solid #d4cab3;
          padding: 8px 11px;
          font-size: 0.92rem;
          box-shadow: none;
          transition: border-color 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
          background: #fefdf9;
        }

        .form-control:focus {
          border-color: var(--j4u-gold);
          box-shadow: 0 0 0 2px rgba(201, 167, 106, 0.30);
          background: #ffffff;
        }

        .form-control[readonly] {
          background: #f9f5eb;
          cursor: default;
        }

        .pill-meta {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          padding: 3px 8px;
          border-radius: 999px;
          background: #fef9c3;
          color: #854d0e;
          font-size: 0.75rem;
        }

        .btn-primary-main {
          width: 100%;
          border-radius: 999px;
          border: none;
          padding: 11px 14px;
          font-size: 0.95rem;
          font-weight: 600;
          letter-spacing: 0.02em;
          background: linear-gradient(135deg, #2563eb, #1d4ed8);
          color: #f9fafb;
          box-shadow: 0 10px 22px rgba(37, 99, 235, 0.35);
          transition: none;
        }

        .btn-primary-main:hover {
          transform: translateY(-1px);
          filter: brightness(1.03);
          box-shadow: 0 14px 26px rgba(37, 99, 235, 0.45);
        }

        .btn-ghost {
          width: 100%;
          margin-top: 6px;
          border-radius: 999px;
          border: 1px solid rgba(148, 133, 96, 0.7);
          padding: 9px 14px;
          font-size: 0.9rem;
          color: #7c5f2b;
          background: rgba(253, 251, 246, 0.9);
          text-decoration: none;
          text-align: center;
          transition: none;
          display: inline-block;
        }

        .btn-ghost:hover {
          background: var(--j4u-gold);
          color: #111827;
          transform: translateY(-1px);
          box-shadow: 0 8px 18px rgba(148, 118, 62, 0.3);
          text-decoration: none;
        }

        .helper-text {
          font-size: 0.78rem;
          color: var(--j4u-text-muted);
          margin-top: 3px;
        }

        .layout-row {
          display: flex;
          flex-wrap: wrap;
          gap: 18px;
        }

        .layout-col {
          flex: 1 1 260px;
          min-width: 0;
        }

        @media (max-width: 768px) {
          .card-main {
            padding: 16px 14px 18px;
          }

          .page-header-bar {
            flex-direction: column;
            align-items: flex-start;
            gap: 4px;
          }
        }
      </style>

      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
      <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
    </head>

    <body>

<% 
    String caseIdParam = request.getParameter("id");
    if (caseIdParam == null || caseIdParam.trim().isEmpty()) {
        response.sendRedirect("viewcases.jsp?msg=Please+select+a+case+first");
        return;
    }
    int caseIdVal = 0;
    try { caseIdVal = Integer.parseInt(caseIdParam.trim()); }
    catch(NumberFormatException nfe) {
        response.sendRedirect("viewcases.jsp?msg=Invalid+case+ID");
        return;
    }
    java.sql.ResultSet rs = null;
    try { 
        Connection con = getDatabaseConnection(); 
        java.sql.Statement st = con.createStatement(); 
        rs = st.executeQuery("SELECT * FROM casetb WHERE cid=" + caseIdVal);
        if (!rs.next()) {
            response.sendRedirect("viewcases.jsp?msg=Case+not+found");
            return;
        }
    } catch(Exception ee) {
        out.println("DB Error: " + ee.getMessage());
        return;
    }
%>

<div class=" shell">
          <div class="page-header-bar">
            <div>
              <h1 class="page-title">Case review & lawyer allocation</h1>
              <p class="page-subtitle">Confirm client details, review payment, and assign this matter to a Justice4U
                lawyer.</p>
            </div>
            <div class="badge-flow">
              <span class="badge-dot"></span>
              Client → Case → <strong>Assign lawyer</strong> → Lawyer dashboard
            </div>
          </div>

          <div class="card-main">
            <form id="caseForm" action="allotlawyerdone.jsp" method="post">
              <div class="layout-row">
                <!-- Left column: Case summary -->
                <div class="layout-col">
                  <div class="section-label">Case summary</div>
                  <div class="divider-soft"></div>

                  <div class="form-group">
                    <div class="field-label">Case / Customer ID</div>
                    <input type="text" class="form-control" name="customerid" value="<%=rs.getInt(1)%>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Client name</div>
                    <input type="text" class="form-control" name="customername" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(2)) %>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Case title</div>
                    <input type="text" class="form-control" name="title" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(3)) %>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Case description</div>
                    <textarea class="form-control" rows="3" name="currentdate" readonly><%= com.j4u.Sanitizer.sanitize(rs.getString(4)) %></textarea>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Filed date</div>
                    <input type="text" class="form-control" name="description" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(5)) %>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Court type</div>
                    <input type="text" class="form-control" name="courtType" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(6)) %>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">City</div>
                    <input type="text" class="form-control" name="city" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(7)) %>" readonly>
                  </div>
                </div>

                <!-- Right column: Payment & routing -->
                <div class="layout-col">
                  <div class="section-label">Payment & routing</div>
                  <div class="divider-soft"></div>

                  <div class="form-group">
                    <div class="field-label">Mode of payment</div>
                    <input type="text" class="form-control" name="mop" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(8)) %>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Transaction ID</div>
                    <input type="text" class="form-control" name="transactionid" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(9)) %>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Amount (₹)</div>
                    <input type="number" class="form-control" name="amt" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(10)) %>" min="0" step="1"
                      readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Client email</div>
                    <input type="email" class="form-control" name="cname" value="<%= com.j4u.Sanitizer.sanitize(rs.getString(11)) %>" readonly>
                  </div>

                  <div class="form-group">
                    <div class="field-label">Assign lawyer (email)</div>
                    <select name="lname" class="form-control" required>
                      <option value="">Select a verified lawyer</option>
                      <% try { Connection con2=getDatabaseConnection(); Statement st2=con2.createStatement(); ResultSet
                        rsLaw=st2.executeQuery("select email from lawyer_reg where flag=1"); while (rsLaw.next()) { %>
                        <option value="<%= com.j4u.Sanitizer.sanitize(rsLaw.getString(1)) %>">
                          <%= com.j4u.Sanitizer.sanitize(rsLaw.getString(1)) %>
                        </option>
                        <% } rsLaw.close(); st2.close(); con2.close(); } catch(Exception e2) { out.println(e2); } %>
                    </select>
                    <div class="helper-text">
                      Only verified and active lawyers are listed. Once submitted, the case appears in the selected
                      lawyer’s dashboard.
                    </div>
                  </div>

                  <div class="form-group">
                    <span class="pill-meta">
                      <span class="glyphicon glyphicon-lock" aria-hidden="true"></span>
                      Client data is shared only with the allocated lawyer.
                    </span>
                  </div>
                </div>
              </div>

              <div class="divider-soft" style="margin-top:14px;"></div>

              <div class="row">
                <div class="col-sm-6">
                  <button type="submit" class="btn-primary-main">
                    Confirm allocation & send to lawyer
                  </button>
                </div>
                <div class="col-sm-6">
                  <a href="admindashboard.jsp" class="btn-ghost">
                    Back to dashboard
                  </a>
                </div>
              </div>
            </form>
          </div>
          </div>

    </body>

    </html>

