<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil"%>
<%@include file="db_connection.jsp" %>
<%
   try {
       // ── Core account fields (match customer.html exactly) ──────────────────
       String name   = request.getParameter("txtname");
       String email  = request.getParameter("txtemail");
       String phone  = request.getParameter("txtmno");
       String dob    = request.getParameter("txtdob");
       String aadhar = request.getParameter("txtadhar");
       String cadd   = request.getParameter("txtadd");
       String padd   = request.getParameter("txtper");
       String pass   = request.getParameter("txtpass");

       // ── FIX 1: Read confirm password from its own field ────────────────────
       // customer.html uses name="txtpassconfirm" for the confirm field
       String passConfirm = request.getParameter("txtpassconfirm");

       // ── Lawyer assignment preference ───────────────────────────────────────
       String profileType = request.getParameter("assignmentPreference");
       if (profileType == null || profileType.isEmpty()) { profileType = "admin"; }

       // ── Required field validation ──────────────────────────────────────────
       if (name == null || name.trim().isEmpty() ||
           email == null || email.trim().isEmpty() ||
           pass == null || pass.trim().isEmpty()) {
           response.sendRedirect("customer.html?error=Missing required fields");
           return;
       }

       // ── FIX 2: Server-side password match check ────────────────────────────
       if (passConfirm != null && !pass.equals(passConfirm)) {
           response.sendRedirect("customer.html?error=Passwords do not match");
           return;
       }

       // ── Basic email format check ───────────────────────────────────────────
       if (!email.matches("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$")) {
           response.sendRedirect("customer.html?error=Invalid email address");
           return;
       }

       // ── Aadhaar format check (12 digits) ──────────────────────────────────
       if (aadhar != null && !aadhar.isEmpty() && !aadhar.matches("\\d{12}")) {
           response.sendRedirect("customer.html?error=Aadhaar must be 12 digits");
           return;
       }

       Connection con = getDatabaseConnection();

       // ── Duplicate email check ──────────────────────────────────────────────
       PreparedStatement checkPs = con.prepareStatement(
           "SELECT cid FROM cust_reg WHERE email=?"
       );
       checkPs.setString(1, email.trim().toLowerCase());
       ResultSet rs = checkPs.executeQuery();
       if (rs.next()) {
           rs.close(); checkPs.close(); con.close();
           response.sendRedirect("customer.html?error=This email is already registered. Please log in.");
           return;
       }
       rs.close(); checkPs.close();

       // ── FIX 3: verification_status = PENDING (not auto-VERIFIED) ──────────
       // Admin must approve the account before the client can log in.
       // FIX 4: Only one name column — remove duplicate cname/name insert.
       PreparedStatement ps = con.prepareStatement(
           "INSERT INTO cust_reg(cname, email, pass, dob, mobno, ano, padd, cadd, verification_status, profile_type) " +
           "VALUES(?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)"
       );

       ps.setString(1, name.trim());
       ps.setString(2, email.trim().toLowerCase());
       ps.setString(3, PasswordUtil.hashPassword(pass));
       ps.setString(4, dob    != null ? dob.trim()    : "");
       ps.setString(5, phone  != null ? phone.trim()  : "");
       ps.setString(6, aadhar != null ? aadhar.trim() : "");
       ps.setString(7, padd   != null ? padd.trim()   : "");
       ps.setString(8, cadd   != null ? cadd.trim()   : "");
       ps.setString(9, profileType);

       int k = ps.executeUpdate();
       ps.close(); con.close();

       if (k > 0) {
           // Registration successful — account awaits admin approval
           response.sendRedirect("cust_login.html?msg=Registration successful. Your account is pending admin verification.");
       } else {
           response.sendRedirect("customer.html?error=Registration failed. Please try again.");
       }

   } catch (Exception e) {
       e.printStackTrace();
       response.sendRedirect("customer.html?error=System error. Please try again later.");
   }
%>
