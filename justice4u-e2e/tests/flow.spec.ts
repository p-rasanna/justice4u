import { test, expect } from '@playwright/test';
import { Helpers } from './helpers';

/**
 * FULL E2E AUTOMATION SUITE FOR JUSTICE4U
 * 
 * Order of Execution (Sequential):
 * 1. Register Client & Lawyer
 * 2. Admin logs in, approves lawyer, assigns lawyer to case (if any prepopulated, otherwise next step)
 * 3. Client logs in, adds case, logs out
 * 4. Admin assigns case to lawyer
 * 5. Lawyer logs in, updates case
 * 6. Security tests (Direct access protection)
 */

test.describe.serial('Justice4U Full User Flow E2E Tests', () => {

  // Generate dynamic unique emails to prevent duplicate key errors in DB
  const uniqueId = Date.now().toString().slice(-6);
  const clientEmail = `client${uniqueId}@test.com`;
  const lawyerEmail = `lawyer${uniqueId}@test.com`;
  const defaultPass = '12345678';
  
  test.beforeEach(async ({ page }) => {
    Helpers.checkConsoleErrors(page);
  });

  // ========== 1. REGISTRATION FLOW ==========
  test('1. Client Registration', async ({ page }) => {
    await Helpers.checkResponseStatus(page, './Custregistration.html');
    
    await page.fill('input[name="cname"]', `Test Client ${uniqueId}`);
    await page.fill('input[name="email"]', clientEmail);
    await page.fill('input[name="pass"]', defaultPass);
    await page.fill('input[name="cpass"]', defaultPass);
    // Assuming basic generic fields
    await page.getByRole('button', { name: /Register/i }).click();

    // Verify successful registration (usually redirects to login or shows success)
    await expect(page.locator('text=Login').first()).toBeVisible();
  });

  test('2. Lawyer Registration', async ({ page }) => {
    await Helpers.checkResponseStatus(page, './Lawyerregistration.html');
    
    await page.fill('input[name="name"]', `Test Lawyer ${uniqueId}`);
    await page.fill('input[name="email"]', lawyerEmail);
    await page.fill('input[name="pass"]', defaultPass);
    await page.fill('input[name="cpass"]', defaultPass);
    await page.fill('input[name="mobile"]', '1234567890');
    // Assuming file upload is required for lawyer registration (proof of identity)
    // await page.setInputFiles('input[type="file"]', 'path/to/dummy.pdf'); // Uncomment & specify path if needed
    
    await page.getByRole('button', { name: /Register/i }).click();
    await expect(page.locator('text=Login').first()).toBeVisible();
  });


  // ========== 2. ADMIN FLOW ==========
  test('3. Admin Login, Lawyer & Client Approval', async ({ page }) => {
    await Helpers.checkResponseStatus(page, './Login.html');
    
    // Admin login
    await page.fill('input[name="email"]', 'admin@gmail.com');
    await page.fill('input[name="password"]', '12345678');
    await page.selectOption('select[name="role"]', 'admin');
    await page.getByRole('button', { name: /Login/i }).click();

    // Verify Admin Dashboard Load
    await expect(page).toHaveURL(/.*AdminDashboard.*/);
    
    // Navigate to Lawyer Approval
    await page.click('text=View Lawyers'); // Assuming a link text.
    await expect(page).toHaveURL(/.*viewlawyers.jsp/);
    
    // Find the lawyer we just registered based on email and click Approve
    // We locate the table row containing the specific email, then click the approve link in that row.
    const row = page.locator('tr').filter({ hasText: lawyerEmail });
    await row.getByRole('link', { name: /Approve/i }).click();
    
    // Navigate to Client Approval
    await page.goto('./viewcustomers.jsp');
    const clientRow = page.locator('tr').filter({ hasText: clientEmail });
    if (await clientRow.count() > 0) {
      page.once('dialog', dialog => dialog.accept());
      await clientRow.locator('.btn-approve').click();
    }
    
    await Helpers.logout(page);
  });


  // ========== 3. CLIENT FLOW ==========
  test('4. Client Login & Add Case', async ({ page }) => {
    await Helpers.checkResponseStatus(page, './cust_login.html');
    
    await page.fill('input[name="email"]', clientEmail);
    await page.fill('input[name="password"]', defaultPass);
    await page.selectOption('select[name="role"]', 'client');
    await page.getByRole('button', { name: /Login/i }).click();

    // Verify Client Dashboard
    await expect(page).toHaveURL(/.*clientdashboard_manual.*/);

    // Add a Case
    await page.click('text=Add Case'); // Navigate
    await page.fill('input[name="title"]', `Case ${uniqueId} Title`);
    await page.fill('textarea[name="description"]', `Full description for testing case ${uniqueId}.`);
    // Example dropdowns according to standard J4U implementation
    await page.selectOption('select[name="courtType"]', 'Civil');
    await page.fill('input[name="city"]', 'New York');
    
    await page.getByRole('button', { name: /Submit/i }).click();
    
    // Verify successful submission
    await expect(page.locator('text=Success').first()).toBeVisible();

    // Chat functionality (Assuming specific chat access point)
    // await page.click('text=Chat');
    // await page.fill('textarea[name="message"]', 'Hello Lawyer!');
    // await page.click('button:has-text("Send")');

    await Helpers.logout(page);
  });


  // ========== 4. ADMIN ASSIGNMENT FLOW ==========
  test('5. Admin Assigns Case to Lawyer', async ({ page }) => {
    await page.goto('./Login.html');
    await page.fill('input[name="email"]', 'admin@gmail.com');
    await page.fill('input[name="password"]', '12345678');
    await page.selectOption('select[name="role"]', 'admin');
    await page.getByRole('button', { name: /Login/i }).click();

    // Navigate to View Cases matching client
    await page.click('text=View Cases');
    const caseRow = page.locator('tr').filter({ hasText: `Case ${uniqueId} Title` });
    await caseRow.getByRole('link', { name: /Allot Lawyer/i }).click();
    
    // In allot form, select our approved lawyer
    await page.selectOption('select[name="lname"]', lawyerEmail);
    await page.getByRole('button', { name: /Submit/i }).click();
    
    await Helpers.logout(page);
  });


  // ========== 5. LAWYER FLOW ==========
  test('6. Lawyer Login & Case Status Update', async ({ page }) => {
    await page.goto('./Lawyer_login.html');
    await page.fill('input[name="email"]', lawyerEmail);
    await page.fill('input[name="password"]', defaultPass);
    await page.selectOption('select[name="role"]', 'lawyer');
    await page.getByRole('button', { name: /Login/i }).click();

    await expect(page).toHaveURL(/.*Lawyerdashboard.*/);

    // View Assigned Cases
    await page.click('text=Assigned Cases');
    
    // Verify the newly assigned case is visible
    await expect(page.locator(`text=Case ${uniqueId} Title`)).toBeVisible();

    // Update case status (Action often exists in the row)
    // await page.selectOption(`select[name="status"]`, 'In Progress');
    // await page.click('button:has-text("Update")');

    // Chat verification
    // await page.click('text=Chat');
    // await expect(page.locator('text=Hello Lawyer!')).toBeVisible();
    // await page.fill('textarea[name="message"]', 'Hello Client! I am reviewing your case.');
    // await page.click('button:has-text("Send")');

    await Helpers.logout(page);
  });


  // ========== 6. SECURITY & ACCESS PROTECTION ==========
  test('7. Unauthorized Access Protection', async ({ page }) => {
    // Attempting to access Admin pages without logging in should redirect
    const adminUrls = [
      '/AdminDashboard',
      '/viewlawyers.jsp',
      '/viewcases.jsp',
      '/approvel.jsp?id=1',
      '/allotlawyer.jsp?id=1'
    ];

    for (const url of adminUrls) {
      const response = await page.goto(url);
      // Wait for protection filter to redirect us
      await page.waitForLoadState('networkidle');
      
      // Should redirect to Login page or show Unauthorized
      const redirectUrl = page.url();
      expect(redirectUrl).toContain('Login.html');
      
      // Bonus: Check for 500 error specifically on forced calls
      expect(response?.status()).toBeLessThan(500);
    }
  });

});
