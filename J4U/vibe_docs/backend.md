# Justice4U: Backend Design & Notes

This document provides technical details for the Java Servlets, JSP scriplets, and database schema governing the backend.

## Security & Session Management

- **Primary Mechanism**: The backend relies heavily on `HttpSession`. Access control is managed either via `J4USecurityFilter` (intercepting URLs) or direct session checks at the top of JSPs.
- **Valid Session Keys**:
  - Admin: `session.getAttribute("user") != null && "admin".equals(session.getAttribute("role"))`
  - Lawyer: `session.getAttribute("role").equalsIgnoreCase("lawyer")`
- **Password Philosophy**: For diploma-level simplicity, passwords are sent and logged in plain text (as coordinated in `PasswordUtil.java` overrides).

## Core Servlets

1. **`LoginServlet.java`**: Centralized authentication. Reads `role` from the request to determine which database table to check. Establishes the session schema (`user`, `role`).
2. **`RegisterServlet.java`**: Handles multi-role registration. Contains branching logic `if (role.equals("client")) ... else if (role.equals("lawyer"))`.
3. **`DocumentUploadServlet.java`**: Uses `FileUploadUtil` to handle `multipart/form-data` for saving PDF/JPG files to the local `uploads/` directory.

## JSP Scriplet Pattern

Most data fetching is handled directly in the JSP file rather than a strict MVC pattern.
Example pattern found in dashboard files:

```jsp
<%@include file="db_connection.jsp" %>
<%
    Connection con = getDatabaseConnection();
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery("SELECT * FROM table");
    while(rs.next()) {
        // Output HTML injected with <%= rs.getString("col") %>
    }
    rs.close(); st.close(); con.close();
%>
```

## Database Schema Highlights (`master_schema.sql`)

- **`lawyer_reg`**: `lid` (PK), `name`, `email`, `password`, `flag` (approval state), `document_verification_status`. Note: Name column is `name`, not `lname`.
- **`cust_reg`**: `cid` (PK), `cname`, `email`, `verification_status`.
- **`lawyer_documents`**: `doc_id` (PK), `lawyer_id` (FK), `document_type`, `file_name`, `status`.
- **`customer_cases`**: `case_id` (PK), `client_id` (FK), `lawyer_id` (FK), `description`, `status`.
