<%--
    Document   : lawyer_testing
    Created on : Debug page for lawyer login testing
    Author     : AI Assistant
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.PasswordUtil"%>
<%
    // Test login for a specific lawyer
    String testEmail = request.getParameter("email");
    String testPassword = request.getParameter("password");

    if (testEmail != null && testPassword != null) {
        try
        {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/j4u","root","");

            out.println("<h1>Testing Lawyer Login for: " + testEmail + "</h1>");

            // Get lawyer data - check for approved lawyers (flag=1)
            String query = "SELECT email, pass, flag, name, document_verification_status FROM lawyer_reg WHERE email=?";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, testEmail.trim());

            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("pass");
                int flag = rs.getInt("flag");
                String lawyerName = rs.getString("name");
                String documentStatus = rs.getString("document_verification_status");

                out.println("<h2>Lawyer Found</h2>");
                out.println("<p><strong>Name:</strong> " + lawyerName + "</p>");
                out.println("<p><strong>Email:</strong> " + testEmail + "</p>");
                out.println("<p><strong>Approval Status (flag):</strong> " + flag + "</p>");
                out.println("<p><strong>Document Verification:</strong> " + documentStatus + "</p>");
                out.println("<p><strong>Password Hash Length:</strong> " + storedHash.length() + "</p>");
                out.println("<p><strong>Password Hash Preview:</strong> " + storedHash.substring(0, Math.min(20, storedHash.length())) + "...</p>");

                // Step 1: Check if lawyer is approved (flag=1)
                boolean isApproved = (flag == 1);
                out.println("<p><strong>Step 1 - Approval Check:</strong> <span style='color:" + (isApproved ? "green" : "red") + "; font-weight:bold;'>" + (isApproved ? "✓ APPROVED" : "✗ NOT APPROVED") + "</span></p>");

                if (!isApproved) {
                    out.println("<h2 style='color:red;'>✗ LAWYER NOT APPROVED</h2>");
                    out.println("<p>The lawyer account is not approved (flag != 1). Admin approval is required.</p>");
                } else {
                    // Step 2: Check document verification
                    boolean docsVerified = "VERIFIED".equals(documentStatus);
                    out.println("<p><strong>Step 2 - Document Verification:</strong> <span style='color:" + (docsVerified ? "green" : "red") + "; font-weight:bold;'>" + (docsVerified ? "✓ VERIFIED" : "✗ NOT VERIFIED") + "</span></p>");

                    if (!docsVerified) {
                        out.println("<h2 style='color:red;'>✗ DOCUMENTS NOT VERIFIED</h2>");
                        out.println("<p>The lawyer's documents are not verified. Document verification is required.</p>");
                    } else {
                        // Step 3: Test password verification
                        boolean passwordValid = PasswordUtil.verifyPassword(testPassword, storedHash);
                        out.println("<p><strong>Step 3 - Password Verification:</strong> <span style='color:" + (passwordValid ? "green" : "red") + "; font-weight:bold;'>" + (passwordValid ? "✓ VALID" : "✗ INVALID") + "</span></p>");

                        if (passwordValid) {
                            out.println("<h2 style='color:green;'>✓ LOGIN SHOULD WORK</h2>");
                            out.println("<p>All checks passed. The lawyer should be able to log in successfully.</p>");
                            out.println("<p>Expected redirect: Lawyerdashboard.jsp</p>");
                        } else {
                            out.println("<h2 style='color:red;'>✗ PASSWORD VERIFICATION FAILED</h2>");
                            out.println("<p>The password you entered doesn't match the stored hash.</p>");
                            out.println("<p>Possible issues:</p>");
                            out.println("<ul>");
                            out.println("<li>Wrong password entered</li>");
                            out.println("<li>Password hash corruption in database</li>");
                            out.println("<li>PasswordUtil.verifyPassword() method issue</li>");
                            out.println("</ul>");
                        }
                    }
                }

            } else {
                out.println("<h2 style='color:red;'>✗ LAWYER NOT FOUND</h2>");
                out.println("<p>No lawyer found with email: " + testEmail + "</p>");
                out.println("<p>Possible issues:</p>");
                out.println("<ul>");
                out.println("<li>Email address is incorrect</li>");
                out.println("<li>Lawyer hasn't registered yet</li>");
                out.println("<li>Database connection issue</li>");
                out.println("</ul>");
            }

            rs.close();
            pst.close();
            con.close();

        }
        catch(Exception ee)
        {
            out.println("<h1 style='color:red;'>Database Error</h1>");
            out.println("<p>Error: " + ee.getMessage() + "</p>");
            out.println("<p>Stack trace:</p>");
            out.println("<pre>");
            ee.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
        }
    } else {
%>
        <html>
        <head>
            <title>Lawyer Login Testing</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .test-form { background: #f5f5f5; padding: 20px; border-radius: 5px; }
                input[type="email"], input[type="password"] { padding: 8px; margin: 5px 0; width: 300px; }
                button { padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 3px; cursor: pointer; }
                button:hover { background: #0056b3; }
                .info { background: #e7f3ff; padding: 15px; border-left: 4px solid #007bff; margin: 20px 0; }
            </style>
        </head>
        <body>
            <h1>Lawyer Login Testing Page</h1>

            <div class="info">
                <h3>About This Page</h3>
                <p>This page helps debug lawyer login issues by testing each step of the login process:</p>
                <ol>
                    <li><strong>Approval Check:</strong> Verifies if lawyer is approved (flag=1)</li>
                    <li><strong>Document Verification:</strong> Checks if documents are verified</li>
                    <li><strong>Password Verification:</strong> Tests password against stored hash</li>
                </ol>
                <p>Use the test data from <code>lawyer_test_data.sql</code> to test:</p>
                <ul>
                    <li><strong>lawyer@test.com</strong> / lawyer123 (approved, verified)</li>
                    <li><strong>advocate@test.com</strong> / advocate123 (approved, verified)</li>
                    <li><strong>pending@lawyer.com</strong> / pending123 (not approved)</li>
                </ul>
            </div>

            <div class="test-form">
                <h2>Test Lawyer Login</h2>
                <form method="post">
                    <p>Enter the exact email and password you're trying to use for lawyer login:</p>
                    <p><input type="email" name="email" placeholder="Lawyer Email" required></p>
                    <p><input type="password" name="password" placeholder="Password" required></p>
                    <p><button type="submit">Test Login</button></p>
                </form>
            </div>
        </body>
        </html>
<%
    }
%>
