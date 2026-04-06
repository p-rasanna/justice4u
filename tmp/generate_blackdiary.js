const fs = require('fs');

const html = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Justice4U - Black Diary</title>
<style>
  body { font-family: 'Times New Roman', serif; font-size: 12pt; margin: 50px; line-height: 1.8; }
  h1 { font-size: 22pt; color: #0B192C; text-align: center; border-bottom: 3px double #c8a000; padding-bottom: 10px; margin-bottom: 4px; }
  h2 { font-size: 14pt; color: #0B192C; border-bottom: 2px solid #c8a000; padding-bottom: 5px; margin-top: 40px; }
  .module-title { font-size: 13pt; font-weight: bold; color: #0B192C; margin-top: 30px; background: #f5f0e0; padding: 6px 12px; border-left: 5px solid #c8a000; }
  .label { font-weight: bold; color: #333; margin-top: 14px; display: block; font-size: 11pt; }
  .desc { font-size: 11pt; color: #333; margin: 4px 0 10px 0; font-style: italic; }
  pre {
    font-family: 'Courier New', monospace;
    font-size: 9pt;
    background: #f8f8f8;
    border-left: 4px solid #c8a000;
    padding: 12px 16px;
    white-space: pre-wrap;
    word-wrap: break-word;
    margin: 6px 0 10px 0;
    line-height: 1.6;
  }
  .output { font-size: 11pt; background: #eef4ee; border-left: 4px solid #4a7c4a; padding: 8px 14px; margin: 4px 0 16px 0; }
  .divider { border: none; border-top: 1px dashed #bbb; margin: 30px 0; }
  .cover-sub { text-align: center; color: #666; font-size: 11pt; margin-bottom: 40px; }
  table { width: 100%; border-collapse: collapse; font-size: 10.5pt; }
  td, th { border: 1px solid #ccc; padding: 7px 10px; }
  th { background: #0B192C; color: white; font-weight: bold; }
  tr:nth-child(even) { background: #f9f9f9; }
</style>
</head>
<body>

<h1>Justice4U</h1>
<p class="cover-sub">
  Online Legal Consultation Platform<br>
  Diploma Project — Black Diary<br>
  Technology: Java JSP / Servlet / MySQL<br>
  Architecture: MVC (Model-View-Controller with DAO Pattern)
</p>

<!-- ======================== INDEX ======================== -->
<h2>Index</h2>
<table>
  <tr><th>#</th><th>Module / Topic</th><th>Page No.</th></tr>
  <tr><td>1</td><td>Project Overview & System Flow</td><td></td></tr>
  <tr><td>2</td><td>Database Connection (DatabaseConfig)</td><td></td></tr>
  <tr><td>3</td><td>Security — Password Hashing & Validation</td><td></td></tr>
  <tr><td>4</td><td>Login &amp; Authentication System</td><td></td></tr>
  <tr><td>5</td><td>Client Registration</td><td></td></tr>
  <tr><td>6</td><td>Lawyer Registration</td><td></td></tr>
  <tr><td>7</td><td>Intern Registration</td><td></td></tr>
  <tr><td>8</td><td>Admin Dashboard</td><td></td></tr>
  <tr><td>9</td><td>Case Request System (Client)</td><td></td></tr>
  <tr><td>10</td><td>Lawyer Assignment (Admin)</td><td></td></tr>
  <tr><td>11</td><td>Intern Assignment System</td><td></td></tr>
  <tr><td>12</td><td>Lawyer Dashboard</td><td></td></tr>
  <tr><td>13</td><td>Case Discussion &amp; Messaging System</td><td></td></tr>
  <tr><td>14</td><td>File Upload System</td><td></td></tr>
  <tr><td>15</td><td>Role-Based Access Control (RBAC)</td><td></td></tr>
  <tr><td>16</td><td>Database Schema (Key Tables)</td><td></td></tr>
</table>

<hr class="divider">

<!-- ======================== 1. PROJECT OVERVIEW ======================== -->
<h2>1. Project Overview &amp; System Flow</h2>
<span class="label">📌 Description:</span>
<p class="desc">
  Justice4U is an online legal consultation web platform built using Java JSP/Servlet and MySQL. It enables clients to register, file cases, and get connected with verified lawyers. Four roles operate — Admin, Client, Lawyer, and Intern — each with a dedicated dashboard and controlled access.
</p>
<span class="label">📌 System Flow:</span>
<pre>
Client Registers
  → Admin Approves Client
    → Client Files a Case
      → Admin Assigns Lawyer (Admin-flow) OR Client Selects Lawyer (Manual-flow)
        → Lawyer Accepts Case
          → Admin Assigns Intern to Lawyer
            → Intern Submits Work
              → Lawyer Reviews
                → Case Discussion via Messaging System
</pre>
<span class="label">📌 Technology Stack:</span>
<table>
  <tr><th>Layer</th><th>Technology</th></tr>
  <tr><td>Frontend</td><td>JSP, HTML5, Bootstrap 5</td></tr>
  <tr><td>Backend</td><td>Java Servlet, DAO Pattern</td></tr>
  <tr><td>Database</td><td>MySQL (via JDBC)</td></tr>
  <tr><td>Server</td><td>Apache Tomcat (XAMPP)</td></tr>
  <tr><td>Security</td><td>SHA-256 Hashing, Session-based RBAC</td></tr>
</table>

<hr class="divider">

<!-- ======================== 2. DATABASE CONNECTION ======================== -->
<div class="module-title">🔹 Module 2: Database Connection</div>
<span class="label">📌 Description:</span>
<p class="desc">A centralized utility class that provides JDBC connections to the MySQL database. All DAOs and Servlets call DatabaseConfig.getConnection() to avoid repeating connection code.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// DatabaseConfig.java
public class DatabaseConfig {
  private static final String URL =
    "jdbc:mysql://localhost:3306/j4u?useSSL=false&serverTimezone=UTC";

  static {
    try { Class.forName("com.mysql.cj.jdbc.Driver"); }
    catch (ClassNotFoundException e) { throw new RuntimeException(e); }
  }

  public static Connection getConnection() throws SQLException {
    return DriverManager.getConnection(URL, "root", "");
  }
}
</pre>
<span class="label">📌 Output:</span>
<div class="output">No direct UI. Connection is used internally by all DAO classes. Error is shown on login page if DB is unreachable.</div>

<hr class="divider">

<!-- ======================== 3. SECURITY ======================== -->
<div class="module-title">🔹 Module 3: Security — Password Hashing &amp; Input Validation</div>
<span class="label">📌 Description:</span>
<p class="desc">Passwords are never stored in plain text. SHA-256 algorithm hashes all passwords before storing in the database. A shared ValidationUtil checks all inputs for null, length, and regex pattern before processing.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// PasswordUtil.java — SHA-256 Hashing
public static String hashPassword(String password) {
  MessageDigest md = MessageDigest.getInstance("SHA-256");
  byte[] hashed = md.digest(
    password.getBytes(StandardCharsets.UTF_8));
  return Base64.getEncoder().encodeToString(hashed);
}

public static boolean verifyPassword(String input, String stored) {
  return hashPassword(input).equals(stored);
}
</pre>
<pre>
// ValidationUtil.java — Input Validation
public static boolean validateInput(
    String value, String pattern, int maxLength) {
  if (value == null || value.trim().isEmpty()) return false;
  if (value.length() > maxLength) return false;
  return pattern == null || Pattern.matches(pattern, value);
}

// Usage in RegisterServlet:
String emailPattern = "^[a-zA-Z0-9._%+-]+@[^@]+\\.[a-zA-Z]{2,}$";
if (!ValidationUtil.validateInput(email, emailPattern, 100)) {
  response.sendRedirect("Lawyer.html?error=Invalid+Email");
  return;
}
</pre>
<span class="label">📌 Output:</span>
<div class="output">Validation errors shown as URL query parameters on the registration/login form. E.g., "?error=Invalid+Email" displayed as an alert banner.</div>

<hr class="divider">

<!-- ======================== 4. LOGIN ======================== -->
<div class="module-title">🔹 Module 4: Login &amp; Authentication System</div>
<span class="label">📌 Description:</span>
<p class="desc">A single LoginServlet handles all four roles (Admin, Client, Lawyer, Intern). Based on the role parameter, it queries the correct table, verifies the hashed password, checks approval status (flag), and creates a session.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// LoginServlet.java
protected void doPost(HttpServletRequest req, HttpServletResponse res) {
  String email = req.getParameter("email");
  String password = req.getParameter("password");
  String role = req.getParameter("role");

  String query = "";
  String redirect = "";
  if ("lawyer".equals(role)) {
    query = "SELECT lid, name, pass, flag FROM lawyer_reg WHERE email=?";
    redirect = "LawyerDashboardServlet";
  } else if ("client".equals(role)) {
    query = "SELECT cid, cname, pass, verification_status FROM cust_reg WHERE email=?";
    redirect = "client/clientdashboard.jsp";
  } else if ("intern".equals(role)) {
    query = "SELECT internid, name, pass, flag FROM intern WHERE email=?";
    redirect = "InternDashboardServlet";
  } else if ("admin".equals(role)) {
    query = "SELECT * FROM admin WHERE email=?";
    redirect = "AdminDashboard";
  }

  try (Connection con = DatabaseConfig.getConnection();
       PreparedStatement ps = con.prepareStatement(query)) {
    ps.setString(1, email);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      if (PasswordUtil.verifyPassword(password, rs.getString("pass"))) {
        // Check approval status for lawyer/intern
        if ("lawyer".equals(role) || "intern".equals(role)) {
          if (rs.getInt("flag") == 0) {
            res.sendRedirect(loginPage + "?error=Account+Pending+Approval");
            return;
          }
        }
        // Create Session
        HttpSession session = req.getSession(true);
        session.setAttribute("user", email);
        session.setAttribute("role", role);
        res.sendRedirect(redirect);
      } else {
        res.sendRedirect(loginPage + "?error=Invalid+Credentials");
      }
    } else {
      res.sendRedirect(loginPage + "?error=User+Not+Found");
    }
  }
}
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Login form with email, password, and role dropdown. Error messages displayed for wrong credentials or pending approval status.</div>

<hr class="divider">

<!-- ======================== 5. CLIENT REGISTRATION ======================== -->
<div class="module-title">🔹 Module 5: Client Registration</div>
<span class="label">📌 Description:</span>
<p class="desc">Clients register with personal details and choose their lawyer assignment preference — either Admin-assigned or Manual selection. Credentials are validated, password is hashed, and account is stored with verification_status = 'PENDING' awaiting admin approval.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// customer.jsp — Processes client registration form
&lt;%
  String name   = request.getParameter("txtname");
  String email  = request.getParameter("txtemail");
  String pass   = request.getParameter("txtpass");
  String mobile = request.getParameter("txtmno");
  String aadhar = request.getParameter("txtadhar");
  String pref   = request.getParameter("assignmentPreference");

  String hashed = PasswordUtil.hashPassword(pass);

  String sql = "INSERT INTO cust_reg (cname, email, pass, mobno, ano, "
             + "cadd, verification_status, profile_type) "
             + "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', ?)";

  try (Connection con = DatabaseConfig.getConnection();
       PreparedStatement ps = con.prepareStatement(sql)) {
    ps.setString(1, name);
    ps.setString(2, email);
    ps.setString(3, hashed);
    ps.setString(4, mobile);
    ps.setString(5, aadhar);
    ps.setString(6, request.getParameter("txtadd"));
    ps.setString(7, pref != null ? pref : "admin");
    ps.executeUpdate();
    response.sendRedirect("auth/cust_login.jsp?msg=Registration+Submitted");
  }
%&gt;
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Client registration form with fields for name, email, mobile, Aadhaar, address, and assignment preference radio buttons.</div>

<hr class="divider">

<!-- ======================== 6. LAWYER REGISTRATION ======================== -->
<div class="module-title">🔹 Module 6: Lawyer Registration</div>
<span class="label">📌 Description:</span>
<p class="desc">Lawyers apply with Bar Council number, specialization areas, and upload supporting documents (certificate, ID, photo). The RegisterServlet validates all inputs, inserts the lawyer record with flag=0 (pending), and saves document paths to the lawyer_documents table.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// RegisterServlet.java
// 1. Validate inputs
if (!ValidationUtil.validateInput(email, emailPattern, 100) ||
    !ValidationUtil.validateInput(ano, "^[0-9]{12}$", 12)) {
  res.sendRedirect("Lawyer.html?error=Invalid+Input");
  return;
}

// 2. Check for duplicate
try (PreparedStatement chk = con.prepareStatement(
    "SELECT COUNT(*) FROM lawyer_reg WHERE email=? OR bar_council_number=?")) {
  chk.setString(1, email); chk.setString(2, barNumber);
  ResultSet rs = chk.executeQuery();
  if (rs.next() && rs.getInt(1) > 0) {
    res.sendRedirect("Lawyer.html?error=Already+Registered");
    return;
  }
}

// 3. Insert with flag=0 (pending admin approval)
String sql = "INSERT INTO lawyer_reg (name, email, pass, phone, "
           + "bar_council_number, specialization, ano, flag) "
           + "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";
ps.setString(3, PasswordUtil.hashPassword(password));
int rows = ps.executeUpdate();

// 4. Save uploaded document
private void saveDocument(Part part, int lawyerId,
    String docType, String uploadPath, Connection con) {
  String unique = UUID.randomUUID() + "_" + part.getName();
  part.write(uploadPath + "/" + unique);
  PreparedStatement ps = con.prepareStatement(
    "INSERT INTO lawyer_documents "
  + "(lawyer_id, document_type, file_path, status) "
  + "VALUES (?, ?, ?, 'PENDING')");
  ps.setInt(1, lawyerId);
  ps.setString(2, docType);
  ps.setString(3, "uploads/lawyer_documents/" + unique);
  ps.executeUpdate();
}
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Lawyer registration form with Bar Number, areas of practice checkboxes, and document upload fields. Success redirect to login page.</div>

<hr class="divider">

<!-- ======================== 7. INTERN REGISTRATION ======================== -->
<div class="module-title">🔹 Module 7: Intern Registration</div>
<span class="label">📌 Description:</span>
<p class="desc">Interns register with academic details — college name, degree, student ID, and areas of interest. The ProcessInternServlet reads multipart form data, creates an intern record (flag=0), and stores academic profile and document paths separately in intern_profiles.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// InternRegistrationDAO.java
// 1. Check for duplicate email
public boolean isEmailRegistered(String email) throws SQLException {
  try (Connection con = DatabaseConfig.getConnection();
       PreparedStatement ps = con.prepareStatement(
         "SELECT internid FROM intern WHERE email=?")) {
    ps.setString(1, email);
    try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
  }
}

// 2. Insert intern record
public boolean registerIntern(String name, String email,
    String hashedPass, String phone, ...) throws SQLException {
  String sql = "INSERT INTO intern (name, email, pass, mobno, flag, "
             + "security_question, security_answer) "
             + "VALUES (?, ?, ?, ?, 0, ?, ?)";
  // ... setString() calls
  return ps.executeUpdate() > 0;
}

// 3. Save academic profile with document paths
public boolean saveInternProfile(String email, String college,
    String degree, String skills, String areas, String frontPath, ...) {
  String sql = "INSERT INTO intern_profiles "
             + "(intern_email, college_name, degree_program, "
             + "areas_of_interest, skills, id_card_front_path, "
             + "bonafide_cert_path, verification_status) "
             + "VALUES (?, ?, ?, ?, ?, ?, ?, 'UNVERIFIED')";
  // ... setString() calls
  return ps.executeUpdate() > 0;
}
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Intern registration form with college details, skills, areas of interest, and file upload fields for College ID and Bonafide Certificate.</div>

<hr class="divider">

<!-- ======================== 8. ADMIN DASHBOARD ======================== -->
<div class="module-title">🔹 Module 8: Admin Dashboard</div>
<span class="label">📌 Description:</span>
<p class="desc">The Admin Dashboard aggregates system-wide statistics — pending clients, lawyers, interns, and open cases — using multiple queries on page load. It also displays a pending authorization table and an unassigned case queue with direct action links.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// admindashboard.jsp — Statistics fetch
&lt;%
  if (session.getAttribute("aname") == null) {
    response.sendRedirect("../auth/Login.jsp"); return;
  }
  int pClient=0, pLawyer=0, pIntern=0, openCases=0;
  try (Connection con = DatabaseConfig.getConnection()) {
    ResultSet rs;
    rs = con.prepareStatement(
      "SELECT COUNT(*) FROM cust_reg WHERE verification_status='PENDING'")
      .executeQuery();
    if (rs.next()) pClient = rs.getInt(1);

    rs = con.prepareStatement(
      "SELECT COUNT(*) FROM lawyer_reg WHERE flag=0")
      .executeQuery();
    if (rs.next()) pLawyer = rs.getInt(1);

    rs = con.prepareStatement(
      "SELECT COUNT(*) FROM intern WHERE flag=0")
      .executeQuery();
    if (rs.next()) pIntern = rs.getInt(1);
  }
%&gt;

&lt;!-- Unassigned Cases Queue --&gt;
&lt;%
  PreparedStatement ps = con.prepareStatement(
    "SELECT c.cid, c.title, c.cname FROM casetb c " +
    "LEFT JOIN allotlawyer al ON al.cid=c.cid " +
    "WHERE c.flag=0 AND al.alid IS NULL LIMIT 8");
  ResultSet rs = ps.executeQuery();
  while (rs.next()) {
    int cid     = rs.getInt("cid");
    String title = rs.getString("title");
%&gt;
  &lt;a href="allotlawyer.jsp?id=&lt;%=cid%&gt;"&gt;Assign Lawyer&lt;/a&gt;
&lt;% } %&gt;
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Admin Dashboard showing 4 metric cards (Pending Clients, Pending Lawyers, Pending Interns, Open Cases), Pending Authorization table, and Unassigned Case Queue with Assign buttons.</div>

<hr class="divider">

<!-- ======================== 9. CASE REQUEST ======================== -->
<div class="module-title">🔹 Module 9: Case Request System (Client)</div>
<span class="label">📌 Description:</span>
<p class="desc">Clients file a legal case through the AddCaseServlet. Based on the client's profile type (admin or manual), the case is either routed to admin for assignment or directly assigned to a lawyer chosen by the client. The case is stored in both casetb and customer_cases tables.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// AddCaseServlet.java
String profileType  = (String) session.getAttribute("profileType");
String assignType   = "manual".equalsIgnoreCase(profileType) ? "MANUAL" : "ADMIN";
String caseStatus   = "MANUAL".equals(assignType) ? "SEARCHING" : "PENDING";

// Insert into casetb
String sql = "INSERT INTO casetb "
           + "(name, title, des, curdate, courttype, city, mop, tid, "
           + "amt, cname, flag, assignment_type, case_status) "
           + "VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, 500, ?, 0, ?, ?)";
ps.setString(9, assignType);
ps.setString(10, caseStatus);
ps.executeUpdate();

// If MANUAL: create a lawyer request
String lawyerEmail = request.getParameter("selected_lawyer_email");
if ("MANUAL".equals(assignType) && lawyerEmail != null) {
  PreparedStatement lr = con.prepareStatement(
    "INSERT INTO lawyer_requests "
  + "(case_id, client_email, lawyer_email, status) "
  + "VALUES (?, ?, ?, 'PENDING')");
  lr.setInt(1, caseId);
  lr.setString(2, sessionEmail);
  lr.setString(3, lawyerEmail);
  lr.executeUpdate();
}

// Link to customer_cases
PreparedStatement cc = con.prepareStatement(
  "INSERT INTO customer_cases "
+ "(case_id, customer_id, title, description, status) "
+ "VALUES (?, ?, ?, ?, 'OPEN')");
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Case filing form with title, description, court type, city, and lawyer selection (for manual flow). Redirect to client dashboard with success message.</div>

<hr class="divider">

<!-- ======================== 10. LAWYER ASSIGNMENT ======================== -->
<div class="module-title">🔹 Module 10: Lawyer Assignment (Admin)</div>
<span class="label">📌 Description:</span>
<p class="desc">Admin selects an unassigned case and assigns an approved lawyer from a dropdown. The allotlawyerdone.jsp inserts a record into the allotlawyer table linking the case with the chosen lawyer's email, and updates the casetb flag to 1 (assigned).</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// allotlawyer.jsp — Lawyer dropdown (only approved lawyers)
&lt;select name="lname" required&gt;
  &lt;% ResultSet rl = con.createStatement().executeQuery(
       "SELECT email, name FROM lawyer_reg WHERE flag=1");
     while (rl.next()) { %&gt;
    &lt;option value="&lt;%=rl.getString("email")%&gt;"&gt;
      &lt;%=rl.getString("name")%&gt;
    &lt;/option&gt;
  &lt;% } %&gt;
&lt;/select&gt;

// allotlawyerdone.jsp — Process assignment
&lt;%
  String cid   = request.getParameter("customerid");
  String lname = request.getParameter("lname");  // lawyer email
  String cname = request.getParameter("cname");  // client email

  // 1. Insert into allotlawyer table
  PreparedStatement ps = con.prepareStatement(
    "INSERT INTO allotlawyer (cid, name, title, des, curdate, "
  + "courttype, city, mop, tid, amt, cname, lname) "
  + "SELECT cid, name, title, des, curdate, "
  + "courttype, city, mop, tid, amt, cname, ? "
  + "FROM casetb WHERE cid=?");
  ps.setString(1, lname);
  ps.setInt(2, Integer.parseInt(cid));
  ps.executeUpdate();

  // 2. Update case flag to 1 (assigned)
  PreparedStatement upd = con.prepareStatement(
    "UPDATE casetb SET flag=1 WHERE cid=?");
  upd.setInt(1, Integer.parseInt(cid));
  upd.executeUpdate();
%&gt;
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Lawyer assignment form showing case details (read-only) and a dropdown list of approved lawyers. Confirmation redirects to Admin Dashboard.</div>

<hr class="divider">

<!-- ======================== 11. INTERN ASSIGNMENT ======================== -->
<div class="module-title">🔹 Module 11: Intern Assignment System</div>
<span class="label">📌 Description:</span>
<p class="desc">Admin links an approved intern to an active lawyer. The intern dropdown shows only interns without existing active assignments. Assignment is stored in intern_lawyer_assignments with status PENDING, which the lawyer must accept or reject.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// assign_intern_to_lawyer.jsp — Intern dropdown
PreparedStatement ps = con.prepareStatement(
  "SELECT i.email, i.name FROM intern i WHERE i.flag=1 " +
  "AND i.email NOT IN ( " +
  "  SELECT intern_email FROM intern_lawyer_assignments " +
  "  WHERE status IN ('PENDING','ACCEPTED') " +
  ") ORDER BY i.name");
ResultSet rs = ps.executeQuery();
while (rs.next()) { /* render &lt;option&gt; */ }

// process_assign_intern_lawyer.jsp — Insert assignment
&lt;%
  String internEmail  = request.getParameter("intern_email");
  String lawyerEmail  = request.getParameter("lawyer_email");

  PreparedStatement ps = con.prepareStatement(
    "INSERT INTO intern_lawyer_assignments "
  + "(intern_email, lawyer_email, status, assigned_date) "
  + "VALUES (?, ?, 'PENDING', NOW())");
  ps.setString(1, internEmail);
  ps.setString(2, lawyerEmail);
  int rows = ps.executeUpdate();

  if (rows > 0) {
    response.sendRedirect("assign_intern_to_lawyer.jsp?msg=Assignment+Created");
  }
%&gt;
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Intern Assignment page with two dropdowns (Select Intern, Select Lawyer) and a Current Assignments table showing intern name, assigned lawyer, and status badge (PENDING / ACCEPTED / REJECTED).</div>

<hr class="divider">

<!-- ======================== 12. LAWYER DASHBOARD ======================== -->
<div class="module-title">🔹 Module 12: Lawyer Dashboard</div>
<span class="label">📌 Description:</span>
<p class="desc">The LawyerDashboardServlet fetches assigned clients, pending case requests, assigned interns, and pending intern work submissions via LawyerDashboardDAO. Data is passed as request attributes to the JSP view.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// LawyerDashboardServlet.java
protected void doGet(HttpServletRequest req, HttpServletResponse res) {
  String lawyerEmail = (String) session.getAttribute("lname");
  int lawyerId = dao.getLawyerIdByEmail(lawyerEmail);

  List&lt;Map&lt;String,Object&gt;&gt; clients = dao.getAssignedClients(lawyerId, 5);
  List&lt;Map&lt;String,Object&gt;&gt; interns = dao.getAssignedInterns(lawyerId);

  req.setAttribute("assignedClients", clients);
  req.setAttribute("assignedInterns", interns);
  req.setAttribute("activeMattersCount", clients.size());

  req.getRequestDispatcher("/lawyer/Lawyerdashboard.jsp")
     .forward(req, res);
}

// LawyerDashboardDAO.java — Get assigned clients
public List&lt;Map&lt;String,Object&gt;&gt; getAssignedClients(
    int lawyerId, int limit) throws SQLException {
  String email = getEmailById(lawyerId);
  String sql = "SELECT a.cid, a.title, a.name " +
               "FROM allotlawyer a JOIN casetb c ON a.cid=c.cid " +
               "WHERE a.lname=? AND c.flag &gt;= 1 " +
               "ORDER BY a.cid DESC LIMIT ?";
  // ... execute, build List&lt;Map&gt;, return list
}
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Lawyer Dashboard with Active Matters count, Assigned Clients table, Assigned Interns section, and Pending Intern Work submissions panel.</div>

<hr class="divider">

<!-- ======================== 13. MESSAGING SYSTEM ======================== -->
<div class="module-title">🔹 Module 13: Case Discussion &amp; Messaging System</div>
<span class="label">📌 Description:</span>
<p class="desc">All parties on a case (Client, Lawyer, Intern, Admin) can exchange messages and file attachments through a shared case discussion page. The SendMessageServlet identifies the sender's role from the session and stores messages in the case_messages table.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// SendMessageServlet.java
// 1. Identify sender from session role
String senderEmail = null, senderRole = null;
if (session.getAttribute("cname") != null) {
  senderEmail = (String) session.getAttribute("cname");
  senderRole = "client";
} else if (session.getAttribute("lname") != null) {
  senderEmail = (String) session.getAttribute("lname");
  senderRole = "lawyer";
} else if (session.getAttribute("iname") != null) {
  senderRole = "intern";
} else if (session.getAttribute("aname") != null) {
  senderRole = "admin";
}

// 2. Handle file attachment
Part filePart = request.getPart("attachment");
if (filePart != null && filePart.getSize() > 0) {
  String dir = getServletContext().getRealPath("")
             + "/uploads/case_" + caseId;
  new File(dir).mkdirs();
  String unique = System.currentTimeMillis() + "_" + fileName;
  filePart.write(dir + "/" + unique);
  filePath = "uploads/case_" + caseId + "/" + unique;
}

// 3. Insert message to DB
PreparedStatement ps = con.prepareStatement(
  "INSERT INTO case_messages "
+ "(case_id, sender_email, sender_role, message_text, "
+ "file_name, file_path, created_at) "
+ "VALUES (?, ?, ?, ?, ?, ?, NOW())");
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: Case Discussion page showing chat-style messages from Client, Lawyer, and Admin with sender role labels and file attachment download links.</div>

<hr class="divider">

<!-- ======================== 14. FILE UPLOAD ======================== -->
<div class="module-title">🔹 Module 14: File Upload System</div>
<span class="label">📌 Description:</span>
<p class="desc">FileUploadUtil is a shared utility for validating and storing uploaded files. It checks allowed extensions, enforces file size limits, scans for malicious content, and generates UUID-based unique file names to prevent overwriting.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// FileUploadUtil.java
private static final List&lt;String&gt; ALLOWED_EXT = Arrays.asList(
  "pdf", "doc", "docx", "jpg", "jpeg", "png"
);
private static final long MAX_SIZE = 10L * 1024 * 1024; // 10MB

public static ValidationResult validateFile(Part filePart) {
  String ext = getFileExtension(getFileName(filePart));
  if (!ALLOWED_EXT.contains(ext.toLowerCase()))
    return new ValidationResult(false, "File type not allowed");
  if (filePart.getSize() > MAX_SIZE)
    return new ValidationResult(false, "File too large (max 10MB)");
  if (containsMaliciousContent(filePart))
    return new ValidationResult(false, "Malicious content detected");
  return new ValidationResult(true, "Valid");
}

// Generate a unique filename using UUID
private static String generateSecureFileName(String extension) {
  return UUID.randomUUID().toString().replace("-", "") + "." + extension;
}

// Scan first 1KB for dangerous patterns
private static boolean containsMaliciousContent(Part part) {
  byte[] buffer = new byte[1024];
  part.getInputStream().read(buffer);
  String content = new String(buffer);
  String[] badPatterns = {"&lt;script", "&lt;%", "javascript:", "onload="};
  for (String p : badPatterns)
    if (content.toLowerCase().contains(p)) return true;
  return false;
}
</pre>
<span class="label">📌 Output:</span>
<div class="output">Screenshot: File upload field on registration forms and case discussion page. Error alert shown for unsupported file types or oversized files.</div>

<hr class="divider">

<!-- ======================== 15. RBAC ======================== -->
<div class="module-title">🔹 Module 15: Role-Based Access Control (RBAC)</div>
<span class="label">📌 Description:</span>
<p class="desc">Every protected page checks a role-specific session attribute at the top. If the attribute is missing (session expired or unauthorized access), the user is immediately redirected to the appropriate login page. This prevents URL tampering between roles.</p>
<span class="label">📌 Code Snippet:</span>
<pre>
// Admin page protection
&lt;%
  String adminEmail = (String) session.getAttribute("aname");
  if (adminEmail == null) {
    response.sendRedirect("../auth/Login.jsp"); return;
  }
%&gt;

// Lawyer page protection
&lt;%
  String lawyerEmail = (String) session.getAttribute("lname");
  if (lawyerEmail == null) {
    response.sendRedirect("../auth/Lawyer_login_form.jsp"); return;
  }
%&gt;

// Client page protection
&lt;%
  String clientEmail = (String) session.getAttribute("cname");
  if (clientEmail == null) {
    response.sendRedirect("../auth/cust_login.jsp"); return;
  }
%&gt;

// Intern page protection
&lt;%
  String internEmail = (String) session.getAttribute("iname");
  if (internEmail == null) {
    response.sendRedirect("../auth/internlogin.html"); return;
  }
%&gt;
</pre>
<span class="label">📌 Output:</span>
<div class="output">No direct screenshot. Unauthorized access to any protected page (e.g., /admin/admindashboard.jsp by a client) redirects automatically to the correct login page.</div>

<hr class="divider">

<!-- ======================== 16. DATABASE SCHEMA ======================== -->
<h2>16. Database Schema (Key Tables)</h2>
<table>
  <tr><th>Table</th><th>Purpose</th><th>Key Columns</th></tr>
  <tr><td>cust_reg</td><td>Client accounts</td><td>cid, cname, email, pass, verification_status, profile_type</td></tr>
  <tr><td>lawyer_reg</td><td>Lawyer accounts</td><td>lid, name, email, pass, bar_council_number, flag (0=pending,1=approved)</td></tr>
  <tr><td>intern</td><td>Intern accounts</td><td>internid, name, email, pass, flag</td></tr>
  <tr><td>intern_profiles</td><td>Intern academic details</td><td>intern_email, college_name, skills, id_card_front_path</td></tr>
  <tr><td>casetb</td><td>All filed cases</td><td>cid, cname (client email), title, flag, assignment_type, case_status</td></tr>
  <tr><td>allotlawyer</td><td>Lawyer-case assignments</td><td>alid, cid, lname (lawyer email), cname (client email)</td></tr>
  <tr><td>customer_cases</td><td>Extended case info</td><td>case_id, customer_id, assigned_lawyer_id, status</td></tr>
  <tr><td>case_messages</td><td>Discussion messages</td><td>case_id, sender_email, sender_role, message_text, file_path</td></tr>
  <tr><td>lawyer_documents</td><td>Lawyer verification docs</td><td>lawyer_id, document_type, file_path, status</td></tr>
  <tr><td>intern_lawyer_assignments</td><td>Intern-to-Lawyer links</td><td>intern_email, lawyer_email, status</td></tr>
  <tr><td>lawyer_requests</td><td>Manual lawyer requests</td><td>case_id, client_email, lawyer_email, status</td></tr>
</table>

</body>
</html>`;

fs.writeFileSync('c:/xampp/htdocs/J4U/Justice4U_BlackDiary.doc', html, 'utf8');
console.log('Done! Saved as Justice4U_BlackDiary.doc');
