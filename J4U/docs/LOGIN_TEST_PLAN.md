# Client Login Test Plan

## Overview
This test plan covers the login functionality for clients in the Justice4U system. The login process validates credentials, checks verification status, determines profile type, and redirects to appropriate dashboards.

## Test Environment Prerequisites
- MySQL database with `j4u` schema
- Apache Tomcat server running on port 8080
- Test data in `cust_reg` and `client_profiles` tables
- Email verification system (optional for login testing)

## Test Data Setup

### Valid Test Users
```sql
-- Manual profile user (VERIFIED)
INSERT INTO cust_reg (cname, email, pass, dob, mobno, ano, cadd, padd, pan_number, case_category, case_description, preferred_location, urgency_level, verification_status, profile_type)
VALUES ('John Doe', 'john@test.com', 'password123', '1990-01-01', '9876543210', '123456789012', 'Test Address', 'Test Address', 'ABCDE1234F', 'Civil', 'Test case', 'Mumbai', 'NORMAL', 'VERIFIED', 'manual');

-- Get the customer ID and insert into client_profiles
INSERT INTO client_profiles (customer_id, profile_type, is_active) VALUES (LAST_INSERT_ID(), 'manual', 1);

-- Admin profile user (VERIFIED)
INSERT INTO cust_reg (cname, email, pass, dob, mobno, ano, cadd, padd, pan_number, case_category, case_description, preferred_location, urgency_level, verification_status, profile_type)
VALUES ('Jane Admin', 'jane@test.com', 'adminpass123', '1985-05-15', '9123456789', '987654321098', 'Admin Address', 'Admin Address', 'FGHIJ5678K', 'Criminal', 'Admin test case', 'Delhi', 'HIGH', 'VERIFIED', 'admin');

INSERT INTO client_profiles (customer_id, profile_type, is_active) VALUES (LAST_INSERT_ID(), 'admin', 1);

-- Pending verification user
INSERT INTO cust_reg (cname, email, pass, dob, mobno, ano, cadd, padd, pan_number, case_category, case_description, preferred_location, urgency_level, verification_status, profile_type)
VALUES ('Pending User', 'pending@test.com', 'pending123', '1995-08-20', '8765432109', '456789012345', 'Pending Address', 'Pending Address', 'KLMNO9012P', 'Family', 'Pending case', 'Chennai', 'LOW', 'PENDING', 'manual');

INSERT INTO client_profiles (customer_id, profile_type, is_active) VALUES (LAST_INSERT_ID(), 'manual', 1);
```

## Test Cases

### TC-LOGIN-001: Valid Login - Manual Profile
**Objective:** Verify successful login for verified user with manual profile
**Preconditions:** User exists with VERIFIED status and manual profile
**Test Steps:**
1. Navigate to login page (cust_login.html)
2. Enter valid email: john@test.com
3. Enter valid password: password123
4. Click Login button
**Expected Results:**
- Redirect to clientdashboard_manual.jsp
- Session attributes set: cid, cname, cemail
- No error messages displayed

### TC-LOGIN-002: Valid Login - Admin Profile
**Objective:** Verify successful login for verified user with admin profile
**Preconditions:** User exists with VERIFIED status and admin profile
**Test Steps:**
1. Navigate to login page
2. Enter valid email: jane@test.com
3. Enter valid password: adminpass123
4. Click Login button
**Expected Results:**
- Redirect to clientdashboard_admin.jsp
- Session attributes set correctly
- Profile type correctly identified as admin

### TC-LOGIN-003: Invalid Email
**Objective:** Verify error handling for non-existent email
**Preconditions:** None
**Test Steps:**
1. Navigate to login page
2. Enter invalid email: nonexistent@test.com
3. Enter any password: testpass
4. Click Login button
**Expected Results:**
- Redirect to cust_login.html with msg=Invalid credentials
- No session created
- Error message displayed to user

### TC-LOGIN-004: Invalid Password
**Objective:** Verify error handling for wrong password
**Preconditions:** Valid user exists
**Test Steps:**
1. Navigate to login page
2. Enter valid email: john@test.com
3. Enter invalid password: wrongpass
4. Click Login button
**Expected Results:**
- Redirect to cust_login.html with msg=Invalid credentials
- No session created

### TC-LOGIN-005: Unverified Account
**Objective:** Verify login blocked for pending verification
**Preconditions:** User exists with PENDING status
**Test Steps:**
1. Navigate to login page
2. Enter valid email: pending@test.com
3. Enter valid password: pending123
4. Click Login button
**Expected Results:**
- Redirect to cust_login.html with msg=Account not approved
- No session created

### TC-LOGIN-006: SQL Injection Prevention
**Objective:** Verify prepared statements prevent SQL injection
**Preconditions:** None
**Test Steps:**
1. Navigate to login page
2. Enter email: ' OR '1'='1
3. Enter password: ' OR '1'='1
4. Click Login button
**Expected Results:**
- No unauthorized access
- Treated as invalid credentials
- No database errors

### TC-LOGIN-007: Empty Email Field
**Objective:** Verify validation for empty email
**Preconditions:** None
**Test Steps:**
1. Navigate to login page
2. Leave email field empty
3. Enter password: testpass
4. Click Login button
**Expected Results:**
- Form validation prevents submission or server handles gracefully
- Appropriate error message

### TC-LOGIN-008: Empty Password Field
**Objective:** Verify validation for empty password
**Preconditions:** None
**Test Steps:**
1. Navigate to login page
2. Enter email: john@test.com
3. Leave password field empty
4. Click Login button
**Expected Results:**
- Form validation prevents submission or server handles gracefully

### TC-LOGIN-009: Case Sensitivity - Email
**Objective:** Verify email is case-insensitive
**Preconditions:** Valid user exists
**Test Steps:**
1. Navigate to login page
2. Enter email in different case: JOHN@TEST.COM
3. Enter valid password: password123
4. Click Login button
**Expected Results:**
- Successful login (email should be case-insensitive)

### TC-LOGIN-010: Case Sensitivity - Password
**Objective:** Verify password is case-sensitive
**Preconditions:** Valid user exists
**Test Steps:**
1. Navigate to login page
2. Enter valid email: john@test.com
3. Enter password in wrong case: PASSWORD123
4. Click Login button
**Expected Results:**
- Login fails (password should be case-sensitive)

### TC-LOGIN-011: Special Characters in Email
**Objective:** Verify handling of special characters in email
**Preconditions:** User with special chars in email exists
**Test Steps:**
1. Create user with email: test+label@example.com
2. Attempt login with that email
**Expected Results:**
- Login works if email format is valid

### TC-LOGIN-012: Session Management
**Objective:** Verify session attributes are set correctly
**Preconditions:** Successful login
**Test Steps:**
1. Login successfully
2. Check session attributes in subsequent pages
**Expected Results:**
- cid: correct customer ID
- cname: correct customer name
- cemail: correct email

### TC-LOGIN-013: Concurrent Sessions
**Objective:** Verify multiple login sessions
**Preconditions:** Valid user
**Test Steps:**
1. Login from one browser
2. Login from another browser with same credentials
**Expected Results:**
- Both sessions work independently

### TC-LOGIN-014: Database Connection Failure
**Objective:** Verify graceful handling of DB connection issues
**Preconditions:** Temporarily stop MySQL service
**Test Steps:**
1. Attempt login during DB outage
**Expected Results:**
- Appropriate error message
- No application crash

## Security Test Cases

### TC-SEC-001: Brute Force Protection
**Objective:** Verify protection against brute force attacks
**Preconditions:** None
**Test Steps:**
1. Attempt multiple failed logins rapidly
**Expected Results:**
- Account lockout or rate limiting implemented

### TC-SEC-002: Session Hijacking Prevention
**Objective:** Verify session security
**Preconditions:** Valid session exists
**Test Steps:**
1. Attempt to use session ID from another user
**Expected Results:**
- Access denied

## Performance Test Cases

### TC-PERF-001: Response Time
**Objective:** Verify acceptable login response time
**Preconditions:** Valid user
**Test Steps:**
1. Login and measure response time
**Expected Results:**
- Response time < 2 seconds

### TC-PERF-002: Concurrent Users
**Objective:** Verify system handles multiple simultaneous logins
**Preconditions:** Multiple test users
**Test Steps:**
1. 10 users attempt login simultaneously
**Expected Results:**
- All logins successful

## Manual Testing Checklist

### Pre-Testing Setup
- [ ] Start Apache Tomcat server
- [ ] Start MySQL service
- [ ] Deploy J4U application
- [ ] Run test data SQL scripts
- [ ] Verify database connections

### Execution Checklist
- [ ] Execute each test case manually
- [ ] Record actual vs expected results
- [ ] Capture screenshots for failures
- [ ] Log any defects found
- [ ] Verify session persistence across pages

### Post-Testing
- [ ] Clean up test data
- [ ] Generate test execution report
- [ ] Document any issues found

## Test Automation

### Recommended Automation Framework
- Selenium WebDriver for UI testing
- JUnit/TestNG for backend unit tests
- JMeter for performance testing

### Automated Test Scripts
```java
// Example Selenium test
@Test
public void testValidLoginManualProfile() {
    driver.get("http://localhost:8080/J4U/cust_login.html");
    driver.findElement(By.name("txtname")).sendKeys("john@test.com");
    driver.findElement(By.name("txtpass")).sendKeys("password123");
    driver.findElement(By.cssSelector("input[type='submit']")).click();

    // Verify redirect
    Assert.assertTrue(driver.getCurrentUrl().contains("clientdashboard_manual.jsp"));
}
```

## Defect Reporting

### Defect Template
- **Defect ID:** AUTO-GENERATED
- **Title:** Brief description
- **Severity:** Critical/High/Medium/Low
- **Test Case:** TC-LOGIN-XXX
- **Steps to Reproduce:**
- **Expected Result:**
- **Actual Result:**
- **Environment:**
- **Attachments:** Screenshots/logs

## Test Metrics

### Coverage Metrics
- Test Cases Executed: X/Y
- Pass Rate: X%
- Defects Found: X
- Critical Defects: X

### Quality Gates
- All critical test cases must pass
- No high-severity defects open
- Performance benchmarks met
- Security tests pass

## Risks and Mitigations

### Risk: Database unavailability
**Mitigation:** Have backup test environment

### Risk: Session management issues
**Mitigation:** Test with different browsers and incognito mode

### Risk: Email dependency
**Mitigation:** Mock email service for testing

## Conclusion

This test plan provides comprehensive coverage of the client login functionality. Execute tests in the specified order, starting with positive test cases, then negative and edge cases. Document all findings and ensure proper defect tracking.
