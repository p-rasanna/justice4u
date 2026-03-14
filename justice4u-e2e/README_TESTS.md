# Justice4U Playwright Test Suite 🎭

A comprehensive end-to-end automation suite for verifying the complete functionality of the Justice4U lawyer-client-intern case management platform across all user roles.

## Requirements

- Node.js (v18 or higher)
- Tomcat Server running the `J4U` app locally on `http://localhost:8080/J4U`
- A clean database state is recommended but the tests use randomized emails to avoid duplicate registration errors.
- Ensure the Admin Credentials `admin@gmail.com` / `12345678` are valid in the database.

## Installation

1. Navigate to the test directory:

```
shell
cd justice4u-e2e
```

2. Install the necessary node modules for Playwright:

```
shell
npm install
```

3. Install the Playwright Chromium browser binaries:

```
shell
npx playwright install chromium
```

## Running Tests

### Run the Complete E2E Flow (Recommended)

This runs the full system workflow test covering all 9 steps:

```
shell
npx playwright test tests/complete-flow.spec.ts
```

### Run the Original Basic Flow Tests

```
shell
npx playwright test tests/flow.spec.ts
```

### Run All Tests

```
shell
npm test
```

### Run with the UI Mode (Highly Recommended)

This opens the beautiful Playwright UI where you can watch the test click-by-click, pause, debug, and inspect elements.

```
shell
npm run test:ui
```

### Run in a visible browser (headed)

```
shell
npm run test:headed
```

## Complete Test Coverage

The `complete-flow.spec.ts` test suite covers all 9 required workflows:

### 1. Client Registration, Admin Approval & Login

- Register a new client with all required fields
- Verify form validation
- Admin logs in to approve the newly registered client
- Client logs in with created credentials
- Confirm dashboard loads correctly
- Logout functionality

### 2. Lawyer Registration

- Register a new lawyer with professional details
- Submit required documents (bar certificate, ID proof, etc.)
- Fill payment details (test mode)
- Verify registration success

### 3. Admin Login & Approval

- Login as Admin (admin@gmail.com / 12345678)
- Navigate to lawyer approval section
- Approve the newly registered lawyer
- Verify lawyer status updates

### 4. Client Case Creation

- Client logs in
- Create a new case with title, description, category
- Submit case
- Verify case appears in dashboard

### 5. Admin Case Assignment

- Admin logs in
- Navigate to case allocation
- Assign case to approved lawyer
- Confirm assignment status updated

### 6. Lawyer Case Management

- Lawyer logs in
- View assigned cases
- Update case progress (change status to "In Progress")
- Access case details

### 7. Chat System Testing

- Client sends message to lawyer
- Verify lawyer receives message
- Lawyer replies to client
- Confirm client receives reply
- Full chat functionality verification

### 8. Intern Selection & Task Assignment

- Lawyer assigns task to intern
- Intern logs in
- Verify task visibility
- Task management verification

### 9. Final Case Completion

- Lawyer marks case as Completed
- Client verifies completion status
- Ensure final status updates correctly

### 10. Security & Access Control

- Test unauthorized access to protected pages
- Verify proper redirects to login
- Ensure no 500 errors on protected routes

## Test Features

1. **Dynamic Generation**: Creates randomized Client, Lawyer, and Intern per run to prevent DB collisions.
2. **Data Isolation**: Each test run uses unique email addresses.
3. **Console Error Traps**: Validates UI stability via the `checkConsoleErrors` helper.
4. **Screenshot on Failure**: Automatically captures screenshots when tests fail.
5. **Video Recording**: Retains video recordings on failure for debugging.
6. **HTML Report**: Automatically generates visual HTML reports.
7. **Network Stability**: Includes retry logic and network idle waits.

## Helper Functions

The `helpers.ts` module provides:

- `checkConsoleErrors()` - Monitor for JavaScript errors
- `checkResponseStatus()` - Verify pages don't return 500 errors
- `logout()` - Multi-method logout handling
- `fillForm()` - Generic form filling
- `waitForElement()` - Custom element waiting
- `takeScreenshot()` - Capture screenshots
- `fillTextarea()` - Chat message input
- `clickButton()` - Button interaction
- `selectDropdown()` - Dropdown selection
- `verifySuccess()` - Success message verification
- `uploadFile()` - File upload handling
- `waitForRedirect()` - URL pattern verification
- `verifyText()` - Text content verification
- `scrollAndClick()` - Scroll and click handling
- `fillPassword()` - Password field handling
- `acceptTerms()` - Checkbox handling
- `generateUniqueData()` - Test data generation
- `waitForNetworkIdle()` - Network stability

## To Check Results

If a test fails or finishes, use:

```
shell
npm run test:report
```

## Test Reports

Test results are saved in:

- `test-results/` - Individual test run results with screenshots and videos
- `playwright-report/` - HTML report with full visualization

## Notes

- Tests are configured to run sequentially (`fullyParallel: false`) to maintain proper database state flow
- Each test creates unique data to prevent conflicts
- The base URL is configured as `http://localhost:8080/J4U`
- Tests support both headless and headed execution
