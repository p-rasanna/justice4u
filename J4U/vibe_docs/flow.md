# Justice4U: Data & User Flows

This document outlines the core data movement and user journeys within the application.

## 1. Authentication Flow

- **User Action**: User enters credentials on `Login.html` or `Lawyer_login.html`.
- **Backend**: Request is sent to `LoginServlet`.
- **DB Interaction**: Servlet queries `cust_reg`, `lawyer_reg`, `intern`, or static admin logic to verify the email/password.
- **Session Layer**: If successful, `LoginServlet` creates an `HttpSession` and sets attributes (`user`, `role`, `uid`/`lid`/`iid`).
- **Routing**: `LoginServlet` redirects the user to their respective dashboard (`clientdashboard.html`, `Lawyerdashboard.html`, `interndashboard.html`, `admindashboard.jsp`).

## 2. Lawyer Registration & Onboarding Flow

- **User Action**: Lawyer fills out `Lawyer_reg.html`.
- **Backend**: `RegisterServlet` receives the POST request.
- **DB Interaction**: `RegisterServlet` inserts the raw data into `lawyer_reg` with `flag=0` (pending) and `document_verification_status='PENDING'`.
- **Upload Phase**: Lawyer is redirected to `upload_documents.jsp` via `DocumentUploadServlet`. Documents are saved to `/uploads/lawyer_documents/` and records are added to `lawyer_documents` table.
- **Admin Review**: Admin opens `viewlawyerdocuments.jsp`, views the physical files, and clicks "Approve" (calls `verifylawyerdoc.jsp?action=approve`).
- **DB Update**: `verifylawyerdoc.jsp` updates `status='VERIFIED'` in `lawyer_documents`. Once all are verified, `lawyer_reg.document_verification_status` becomes `VERIFIED`. Admin then approves the lawyer in `viewlawyers.jsp`, setting `flag=1`.

## 3. Case Posting & Allocation Flow

- **User Action**: Verified Client submits a case via `customer_post_cases.jsp`.
- **DB Interaction**: Inserted into `customer_cases` with `status='PENDING_LAWYER_CONFIRMATION'`.
- **Lawyer Acceptance**: Lawyer sees case on dashboard, clicks "Accept Case" (`accept_case.jsp`).
- **DB Update**: `customer_cases.status` updates to `IN_PROGRESS`, `lawyer_id` is assigned.

## 4. General Data Display (Admin/Dashboard)

- **Frontend Action**: Admin loads `admindashboard.jsp`.
- **JSP Scriplet**: `<% Connection con = getDatabaseConnection(); Statement st = con.createStatement(); ResultSet rs = st.executeQuery("..."); %>`
- **Render**: Data is fetched directly from MySQL and mapped into HTML grid cells (`<%= rs.getString("column") %>`).
