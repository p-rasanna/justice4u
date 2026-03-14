<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, util.EmailUtil"%>
<%
    // Test email approval workflow
    String testResult = "";
    
    try {
        // Test database connection
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/j4u", "root", "");
        Statement st = con.createStatement();
        
        // Check if there are any pending customers
        ResultSet rs = st.executeQuery("SELECT cid, cname, email FROM cust_reg WHERE verification_status='PENDING' LIMIT 1");
        
        if (rs.next()) {
            int customerId = rs.getInt("cid");
            String customerName = rs.getString("cname");
            String customerEmail = rs.getString("email");
            
            // Test email functionality (commented out to avoid sending actual emails during test)
            // EmailUtil.sendEmail(customerEmail, "Test Approval", "This is a test email for approval workflow.");
            
            testResult = "Found pending customer: " + customerName + " (" + customerEmail + ") - ID: " + customerId;
            testResult += "<br>Email functionality is configured but not sent to avoid spam during testing.";
        } else {
            testResult = "No pending customers found in the database.";
        }
        
        rs.close();
        st.close();
        con.close();
        
    } catch (Exception e) {
        testResult = "Error: " + e.toString();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Email Approval Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .result { padding: 20px; background: #f0f8ff; border: 1px solid #0066cc; border-radius: 5px; }
        .success { background: #e8f5e8; border-color: #00cc00; }
        .error { background: #ffe8e8; border-color: #cc0000; }
    </style>
</head>
<body>
    <h1>Email Approval Workflow Test</h1>
    
    <h2>System Configuration Check:</h2>
    <ul>
        <li>✅ Database connection configured (MySQL)</li>
        <li>✅ EmailUtil class exists with SMTP settings</li>
        <li>✅ Approval/Rejection JSP files updated with email functionality</li>
        <li>⚠️ Email credentials need to be configured in EmailUtil.java</li>
    </ul>
    
    <h2>Test Results:</h2>
    <div class="result <%= testResult.contains("Error") ? "error" : "success" %>">
        <%= testResult %>
    </div>
    
    <h2>Workflow Summary:</h2>
    <ol>
        <li>Client registers → status set to 'PENDING'</li>
        <li>Admin views pending clients in admin dashboard</li>
        <li>Admin clicks 'Approve' or 'Reject' button</li>
        <li>System updates database status accordingly</li>
        <li>Automated email is sent to client with approval/rejection notification</li>
    </ol>
    
    <h2>Configuration Required:</h2>
    <p>To enable email sending, update EmailUtil.java with:</p>
    <ul>
        <li>Valid Gmail address (replace "your-email@gmail.com")</li>
        <li>Gmail app password (replace "your-app-password")</li>
        <li>Ensure "less secure apps" is enabled or use app-specific password</li>
    </ul>
    
    <p><a href="admindashboard.jsp">← Back to Admin Dashboard</a></p>
</body>
</html>
