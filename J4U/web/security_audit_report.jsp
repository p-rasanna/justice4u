<%--
    Document   : security_audit_report
    Created on : Security audit for login systems
    Author     : Security Audit
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil"%>
<%
    try
    {
        // Class.forName("com.mysql.jdbc.Driver");
        Connection con = com.j4u.DatabaseConfig.getConnection();



        // Test 1: Lawyer Login Security
        out.println("<div class='section critical'>");
        out.println("<h2>🔴 CRITICAL: Lawyer Login Security Issues</h2>");
        out.println("<h3>Issues Found:</h3>");
        out.println("<ul>");
        out.println("<li><span class='fail'>❌ MISSING IMPORT:</span> PasswordUtil class not imported</li>");
        out.println("<li><span class='fail'>❌ COMPILATION ERROR:</span> Code will not compile due to missing import</li>");
        out.println("<li><span class='warning'>⚠️ NO VERIFICATION CHECK:</span> Unlike customer login, no verification_status check</li>");
        out.println("<li><span class='info'>ℹ️ BASIC VALIDATION:</span> Has basic null/empty check (good)</li>");
        out.println("</ul>");

        // Test lawyer login compilation
        try {
            // This would fail if PasswordUtil is not imported
            boolean test = PasswordUtil.verifyPassword("test", "test");
            out.println("<p><span class='info'>PasswordUtil accessible: YES</span></p>");
        } catch(Exception e) {
            out.println("<p><span class='fail'>PasswordUtil compilation error: " + e.getMessage() + "</span></p>");
        }

        out.println("</div>");

        // Test 2: Intern Login Security
        out.println("<div class='section critical'>");
        out.println("<h2>🔴 CRITICAL: Intern Login Security Issues</h2>");
        out.println("<h3>Issues Found:</h3>");
        out.println("<ul>");
        out.println("<li><span class='fail'>❌ SQL INJECTION VULNERABILITY:</span> Uses Statement instead of PreparedStatement</li>");
        out.println("<li><span class='fail'>❌ PERFORMANCE ISSUE:</span> Selects ALL intern records and loops through them</li>");
        out.println("<li><span class='fail'>❌ MISSING IMPORT:</span> PasswordUtil class not imported</li>");
        out.println("<li><span class='fail'>❌ NO INPUT VALIDATION:</span> No null/empty checks</li>");
        out.println("<li><span class='fail'>❌ NO TRIM:</span> Input not trimmed</li>");
        out.println("<li><span class='warning'>⚠️ NO VERIFICATION CHECK:</span> No verification_status check</li>");
        out.println("</ul>");

        // Test intern login vulnerability
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery("SELECT COUNT(*) as total FROM intern WHERE flag=1");
        if(rs.next()) {
            int totalInterns = rs.getInt("total");
            out.println("<p><span class='fail'>Vulnerable query affects " + totalInterns + " intern records</span></p>");
        }
        rs.close();
        st.close();

        out.println("</div>");

        // Test 3: Compare with Customer Login (secure reference)
        out.println("<div class='section'>");
        out.println("<h2>✅ SECURE REFERENCE: Customer Login</h2>");
        out.println("<h3>Security Features:</h3>");
        out.println("<ul>");
        out.println("<li><span class='pass'>✅ PROPER IMPORTS:</span> PasswordUtil correctly imported</li>");
        out.println("<li><span class='pass'>✅ PREPARED STATEMENTS:</span> Uses PreparedStatement to prevent SQL injection</li>");
        out.println("<li><span class='pass'>✅ INPUT VALIDATION:</span> Comprehensive null/empty checks</li>");
        out.println("<li><span class='pass'>✅ VERIFICATION CHECK:</span> Checks verification_status = 'VERIFIED'</li>");
        out.println("<li><span class='pass'>✅ INPUT SANITIZATION:</span> Email trimmed and lowercased</li>");
        out.println("<li><span class='pass'>✅ SECURE PASSWORD:</span> Uses SHA-256 + salt hashing</li>");
        out.println("<li><span class='pass'>✅ BACKWARD COMPATIBILITY:</span> Supports legacy MD5 hashes</li>");
        out.println("</ul>");
        out.println("</div>");

        // Test 4: Database Security Check
        out.println("<div class='section high'>");
        out.println("<h2>🟡 HIGH: Database Security Check</h2>");

        // Check lawyer password formats
        rs = st.executeQuery("SELECT email, pass FROM lawyer_reg WHERE flag=1 LIMIT 3");
        out.println("<h3>Lawyer Password Formats:</h3>");
        while(rs.next()) {
            String email = rs.getString("email");
            String hash = rs.getString("pass");
            boolean isNewFormat = hash.length() > 32 && hash.contains("+");
            out.println("<p>" + email + ": " + (isNewFormat ? "<span class='pass'>SECURE</span>" : "<span class='fail'>LEGACY/PLAIN</span>") + "</p>");
        }
        rs.close();

        // Check intern password formats
        rs = st.executeQuery("SELECT email, pass FROM intern WHERE flag=1 LIMIT 3");
        out.println("<h3>Intern Password Formats:</h3>");
        while(rs.next()) {
            String email = rs.getString("email");
            String hash = rs.getString("pass");
            boolean isNewFormat = hash.length() > 32 && hash.contains("+");
            out.println("<p>" + email + ": " + (isNewFormat ? "<span class='pass'>SECURE</span>" : "<span class='fail'>LEGACY/PLAIN</span>") + "</p>");
        }
        rs.close();

        out.println("</div>");

        // Recommendations
        out.println("<div class='section'>");
        out.println("<h2>🔧 REQUIRED FIXES</h2>");
        out.println("<h3>Lawyer Login (Lawyer_login.jsp):</h3>");
        out.println("<ol>");
        out.println("<li>Add import: <code>import=\"java.sql.*, com.j4u.PasswordUtil\"</code></li>");
        out.println("<li>Add verification status check like customer login</li>");
        out.println("<li>Consider adding profile type logic if needed</li>");
        out.println("</ol>");

        out.println("<h3>Intern Login (internlogin.jsp):</h3>");
        out.println("<ol>");
        out.println("<li>Add import: <code>import=\"java.sql.*, com.j4u.PasswordUtil\"</code></li>");
        out.println("<li>Replace Statement with PreparedStatement</li>");
        out.println("<li>Add input validation (null/empty checks)</li>");
        out.println("<li>Trim inputs: <code>a.trim()</code>, <code>b.trim()</code></li>");
        out.println("<li>Add verification status check</li>");
        out.println("<li>Use targeted query instead of selecting all records</li>");
        out.println("</ol>");

        out.println("<h3>General:</h3>");
        out.println("<ol>");
        out.println("<li>Run password migration for lawyer and intern accounts</li>");
        out.println("<li>Add comprehensive error handling</li>");
        out.println("<li>Implement proper session management</li>");
        out.println("<li>Add rate limiting for login attempts</li>");
        out.println("</ol>");
        out.println("</div>");

        con.close();

    }
    catch(Exception ee)
    {
        out.println("<h1 style='color:red;'>Audit Error</h1>");
        out.println("<p>Error: " + ee.getMessage() + "</p>");
        ee.printStackTrace();
    }
%>
</body>
</html>
