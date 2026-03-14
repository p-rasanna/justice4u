# TODO: Implement Multiple Role Login in Same Browser

## Status: Plan Approved - Implementation Started

## Information Gathered
- **Login JSPs**: All login pages (cust_login.jsp, Lawyer_login.jsp, Login.jsp, internlogin.jsp) currently call `session.invalidate()` before setting new session attributes, preventing multiple role logins.
- **SecurityFilter.java**: Determines user role from a single session attribute (aname for admin, cname/cemail for client, lname for lawyer, iname for intern). Invalidates session if no valid role found. Access control checks if the single role matches required permissions.
- **test_all_features.jsp**: Only checks for lawyer or client session (lname or cname), displays features for one role only.
- **Signout JSPs**: All signout pages invalidate the entire session.

## Plan
### 1. Modify Login JSPs (cust_login.jsp, Lawyer_login.jsp, Login.jsp, internlogin.jsp)
- Remove `session.invalidate()` and `session = request.getSession(true);`
- Check if the user is already logged in as the target role; if yes, redirect to dashboard
- If not, set the role attribute without invalidating existing session
- Allow adding multiple roles to the same session

### 2. Modify SecurityFilter.java
- Change role detection logic to collect all roles present in session (admin, client, lawyer, intern)
- Modify access control to allow access if any of the user's roles match the required role for the URI
- Update validation and logging to handle multiple roles

### 3. Update test_all_features.jsp
- Modify to check for all possible roles (admin, client, lawyer, intern)
- Display features for all roles the user is logged in as
- Update navigation and logout links to handle multiple roles

### 4. Update Signout JSPs (asignout.jsp, csignout.jsp, lsignout.jsp, isignout.jsp)
- Keep session.invalidate() to logout all roles at once, as multiple role login implies single logout for all

## Dependent Files to be Edited
- [x] J4U/web/cust_login.jsp
- [x] J4U/web/Lawyer_login.jsp
- [x] J4U/web/Login.jsp
- [x] J4U/web/internlogin.jsp
- [x] J4U/src/java/SecurityFilter.java
- [x] J4U/web/test_all_features.jsp

## Implementation Progress
- [x] Created TODO file and got plan approval
- [x] Modify cust_login.jsp
- [x] Modify Lawyer_login.jsp
- [x] Modify Login.jsp
- [x] Modify internlogin.jsp
- [x] Modify SecurityFilter.java
- [x] Update test_all_features.jsp
- [ ] Test implementation

## Followup Steps
- Test logging in as multiple roles in the same browser
- Verify access to features for all logged-in roles
- Test logout functionality
- Check SecurityFilter logs for multiple role handling
