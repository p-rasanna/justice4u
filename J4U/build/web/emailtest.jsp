<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, util.EmailUtil"%>
<%
    String testResult = "";
    String testType = request.getParameter("testType");
    String customerId = request.getParameter("customerId");
    
    if (testType != null && customerId != null) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/j4u", "root", "");
            Statement st = con.createStatement();
            
            // Get customer details
            ResultSet rs = st.executeQuery("SELECT cname, email, verification_status FROM cust_reg WHERE cid=" + customerId);
            
            if (rs.next()) {
                String customerName = rs.getString("cname");
                String customerEmail = rs.getString("email");
                String currentStatus = rs.getString("verification_status");
                
                if ("approve".equals(testType)) {
                    // Update status to VERIFIED
                    st.executeUpdate("UPDATE cust_reg SET verification_status='VERIFIED' WHERE cid=" + customerId);
                    
                    // Send approval email
                    EmailUtil.sendEmail(customerEmail, "Account Approved - Justice4U", 
                        "Dear " + customerName + ",\n\n" +
                        "Congratulations! Your account has been approved and is now active.\n\n" +
                        "You can now login to your account and access our services.\n\n" +
                        "Login URL: http://localhost:8080/J4U/cust_login.html\n\n" +
                        "Best regards,\n" +
                        "Justice4U Team");
                    
                    testResult = "✅ APPROVAL EMAIL SENT to " + customerEmail + " for " + customerName;
                    
                } else if ("reject".equals(testType)) {
                    // Update status to REJECTED
                    st.executeUpdate("UPDATE cust_reg SET verification_status='REJECTED' WHERE cid=" + customerId);
                    
                    // Send rejection email
                    EmailUtil.sendEmail(customerEmail, "Account Registration Status - Justice4U", 
                        "Dear " + customerName + ",\n\n" +
                        "We regret to inform you that your registration has been rejected after review.\n\n" +
                        "If you believe this is an error or need clarification, please contact our support team.\n\n" +
                        "Email: support@justice4u.com\n\n" +
                        "Best regards,\n" +
                        "Justice4U Team");
                    
                    testResult = "❌ REJECTION EMAIL SENT to " + customerEmail + " for " + customerName;
                }
            } else {
                testResult = "❌ Customer not found with ID: " + customerId;
            }
            
            rs.close();
            st.close();
            con.close();
            
        } catch (Exception e) {
            testResult = "❌ Error: " + e.toString();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Approval Test - Justice4U</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f2ea; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .result { padding: 20px; margin: 20px 0; border-radius: 8px; font-weight: bold; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; font-weight: bold; }
        .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; margin: 2px; text-decoration: none; display: inline-block; }
        .btn-approve { background: #28a745; color: white; }
        .btn-reject { background: #dc3545; color: white; }
        .btn-test { background: #007bff; color: white; }
        .status-pending { color: #856404; font-weight: bold; }
        .status-approved { color: #155724; font-weight: bold; }
        .status-rejected { color: #721c24; font-weight: bold; }
        .config-box { background: #e9ecef; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📧 Email Approval/Rejection Test</h1>
        
        <div class="config-box">
            <h3>⚙️ Email Configuration Status</h3>
            <p><strong>EmailUtil.java Status:</strong> ✅ Configured with Gmail SMTP</p>
            <p><strong>Current Settings:</strong></p>
            <ul>
                <li>SMTP Server: smtp.gmail.com:587</li>
                <li>Authentication: Enabled</li>
                <li>TLS: Enabled</li>
                <li>⚠️ <strong>Note:</strong> Update EmailUtil.java with your Gmail credentials</li>
            </ul>
        </div>

        <% if (testResult != null && !testResult.isEmpty()) { %>
            <div class="result <%= testResult.contains("❌") ? "error" : testResult.contains("⚠️") ? "warning" : "success" %>">
                <%= testResult %>
            </div>
        <% } %>

        <h2>👥 Customer Registration List</h2>
        <p>Click "Test Approve" or "Test Reject" to send emails to customers:</p>
        
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Mobile</th>
                    <th>Status</th>
                    <th>Test Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/j4u", "root", "");
                    Statement st = con.createStatement();
                    ResultSet rs = st.executeQuery("SELECT cid, cname, email, mobno, verification_status FROM cust_reg ORDER BY cid DESC");
                    
                    boolean hasCustomers = false;
                    while(rs.next()) {
                        hasCustomers = true;
                        int id = rs.getInt("cid");
                        String name = rs.getString("cname");
                        String email = rs.getString("email");
                        String mobile = rs.getString("mobno");
                        String status = rs.getString("verification_status");
                        
                        String statusClass = "status-pending";
                        if ("VERIFIED".equals(status)) statusClass = "status-approved";
                        else if ("REJECTED".equals(status)) statusClass = "status-rejected";
            %>
                <tr>
                    <td><%= id %></td>
                    <td><%= name %></td>
                    <td><%= email %></td>
                    <td><%= mobile %></td>
                    <td><span class="<%= statusClass %>"><%= status %></span></td>
                    <td>
                        <% if ("PENDING".equals(status)) { %>
                            <a href="?testType=approve&customerId=<%= id %>" class="btn btn-approve" onclick="return confirm('Send approval email to <%= name %>?')">✅ Test Approve</a>
                            <a href="?testType=reject&customerId=<%= id %>" class="btn btn-reject" onclick="return confirm('Send rejection email to <%= name %>?')">❌ Test Reject</a>
                        <% } else { %>
                            <span style="color: #666;">Already processed</span>
                        <% } %>
                    </td>
                </tr>
            <%
                    }
                    
                    rs.close();
                    st.close();
                    con.close();
                    
                    if (!hasCustomers) {
            %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px;">
                        No customers found in database. Please register a client first.
                    </td>
                </tr>
            <%
                    }
                } catch (Exception e) {
            %>
                <tr>
                    <td colspan="6" style="color: red; text-align: center;">
                        Error loading customers: <%= e.toString() %>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>

        <div style="margin-top: 30px;">
            <h3>📋 Test Instructions:</h3>
            <ol>
                <li>Make sure EmailUtil.java is configured with your Gmail credentials</li>
                <li>Find a customer with "PENDING" status above</li>
                <li>Click "Test Approve" to send approval email</li>
                <li>Click "Test Reject" to send rejection email</li>
                <li>Check the customer's email inbox for the test email</li>
            </ol>
        </div>

        <div style="margin-top: 20px;">
            <a href="admindashboard.jsp" class="btn btn-test">← Back to Admin Dashboard</a>
            <a href="viewcustomers.jsp" class="btn btn-test">View Customers</a>
        </div>
    </div>
</body>
</html>
