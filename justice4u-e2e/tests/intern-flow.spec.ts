import { test, expect } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

test.describe('Intern Registration and Approval Flow', () => {
  const uniqueId = Date.now().toString().slice(-6);
  const internEmail = `intern_verify_${uniqueId}@test.com`;
  const defaultPass = 'Password@123';
  const internName = `Verify Intern ${uniqueId}`;

  test('Complete Intern Flow: Register -> Approve -> Login', async ({ page }) => {
    // Forward browser console logs
    page.on('console', msg => console.log(`BROWSER: [${msg.type()}] ${msg.text()}`));

    console.log('--- Phase 1: Intern Registration ---');
    await page.goto('http://localhost:8080/J4U/intern.jsp');
    
    // Fill Identity
    await page.fill('#fullName', internName);
    await page.fill('#email', internEmail);
    await page.fill('#phone', '9876543210');
    await page.selectOption('#securityQuestion', 'What city were you born in?');
    await page.fill('#securityAnswer', 'Detroit');
    await page.fill('#password', defaultPass);
    await page.fill('#confirmPassword', defaultPass);

    // Fill Academic
    await page.fill('#collegeName', 'Global Law University');
    await page.selectOption('#degreeProgram', 'LLB5');
    await page.fill('#yearSemester', '4th Year');
    await page.fill('#studentId', `ID-${uniqueId}`);

    // Create dummy files for upload
    const dummyIdFront = path.join(process.cwd(), 'id_front.png');
    const dummyIdBack = path.join(process.cwd(), 'id_back.png');
    const dummyBonafide = path.join(process.cwd(), 'bonafide.pdf');
    fs.writeFileSync(dummyIdFront, 'dummy image content');
    fs.writeFileSync(dummyIdBack, 'dummy image content');
    fs.writeFileSync(dummyBonafide, 'dummy pdf content');

    await page.setInputFiles('#collegeIdFront', dummyIdFront);
    await page.setInputFiles('#collegeIdBack', dummyIdBack);
    await page.setInputFiles('#bonafide', dummyBonafide);

    // Fill Professional Focus
    await page.check('input[name="areasOfInterest"][value="Criminal"]');
    await page.check('input[name="skills"][value="LegalResearch"]');
    await page.fill('#preferredCity', 'New York');
    await page.check('input[name="internMode"][value="Remote"]');
    await page.selectOption('#availabilityDuration', '3months');

    // Ethics
    await page.check('input[name="confRestricted"]');
    await page.check('input[name="confCode"]');

    // Submit
    await page.click('button[type="submit"]');

    // Verify registration success modal
    await page.waitForURL(/internlogin\.html/);
    console.log('✓ Redirected to login. Waiting for success modal...');
    
    // Wait for the modal to be active and visible
    await page.waitForSelector('#successModal.active', { state: 'visible', timeout: 8000 });
    const modal = page.locator('#successModal');
    
    await expect(modal).toContainText(/Application Received|Request/i);
    await expect(modal).toContainText(/wait for administrative approval/i);
    console.log('✓ Registration success modal verified.');

    // Close modal
    await modal.locator('button.modal-btn').click();
    await page.waitForSelector('#successModal', { state: 'hidden' });

    console.log('--- Phase 2: Admin Approval ---');
    // Login as Admin
    await page.goto('http://localhost:8080/J4U/Login.html');
    await page.fill('input[name="email"]', 'admin@gmail.com');
    await page.fill('input[name="password"]', '12345678');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL(/AdminDashboard/);
    
    // Navigate to Intern Approval
    await page.goto('http://localhost:8080/J4U/ViewInterns');
    await expect(page).toHaveURL(/ViewInterns|viewinterns\.jsp/i);

    // Find our intern and approve
    const internRow = page.locator('tr').filter({ hasText: internEmail });
    await expect(internRow).toBeVisible();
    
    // Click approve
    await internRow.locator('.btn-approve').click();
    
    // Wait for success message or redirect back
    // Wait for success message or redirect back
    await expect(page.locator('body')).toContainText(/Approved|Verified|Success/i);
    console.log('✓ Intern approved and verified by Admin.');
    console.log('✓ Intern approved and verified by Admin.');

    console.log('--- Phase 3: Intern Login ---');
    // Login as Intern
    await page.goto('http://localhost:8080/J4U/internlogin.html');
    await page.fill('input[name="email"]', internEmail);
    await page.fill('input[name="password"]', defaultPass);
    await page.click('button[type="submit"]');

    // Verify dashboard access
    await page.waitForURL(/interndashboard/);
    await expect(page).toHaveURL(/interndashboard\.jsp/);
    await expect(page.locator('h1')).toContainText(/Associate Workspace/i);
    console.log('✓ Intern reached dashboard initial view.');

    console.log('--- Phase 4: Lawyer Assigning Case & Task ---');
    // Login as Lawyer (dhoni)
    await page.goto('http://localhost:8080/J4U/Lawyer_login.html');
    await page.fill('#txtname', 'dhoni@gmail.com');
    await page.fill('#txtpass', '12345678');
    await page.click('#btnSubmit');
    await page.waitForSelector('.header-content h1', { timeout: 20000 });

    // Go to Intern Directory
    await page.goto('http://localhost:8080/J4U/viewinternl.jsp');
    const internRowAssign = page.locator('tr').filter({ hasText: internEmail });
    await internRowAssign.locator('.btn-action:has-text("Assign Case")').click();
    
    // Select Case #3 (Violation of Signal)
    await page.selectOption('#activeCaseSelect', '3');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/viewinternl\.jsp/);
    console.log('✓ Case #3 assigned to intern.');

    // Delegate Task
    const internRowTask = page.locator('tr').filter({ hasText: internEmail });
    await internRowTask.locator('.btn-action:has-text("Delegate Task")').click();
    await page.fill('#taskTitle', 'Research Signal Violation Penalties');
    await page.fill('#dueDate', '2025-12-31');
    await page.selectOption('#caseSelect', '3');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/viewinternl\.jsp/);
    console.log('✓ Task delegated to intern.');

    console.log('--- Phase 5: Intern Dashboard Verification ---');
    // Back to Intern Dashboard
    await page.goto('http://localhost:8080/J4U/internlogin.html');
    await page.fill('input[name="email"]', internEmail);
    await page.fill('input[name="password"]', defaultPass);
    await page.click('button[type="submit"]');

    await page.waitForURL(/interndashboard/);
    // 1. Verify Metric
    await expect(page.locator('.metric-card:has-text("Assigned Cases") h3')).toHaveText('1');
    await expect(page.locator('.metric-card:has-text("Pending Tasks") h3')).toHaveText('1');

    // 2. Verify List Item
    await expect(page.locator('.table-custom:has-text("Active Assignments")')).toContainText('Violation of Signal');
    await expect(page.locator('.table-custom:has-text("Pending Directives")')).toContainText('Research Signal Violation Penalties');

    console.log('✓ Intern dashboard synchronization verified successfully.');

    // Cleanup dummy files
    fs.unlinkSync(dummyIdFront);
    fs.unlinkSync(dummyIdBack);
    fs.unlinkSync(dummyBonafide);
  });
});
