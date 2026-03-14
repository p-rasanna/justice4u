import { test, expect } from '@playwright/test';

test('Lawyer-Intern Collaboration Flow', async ({ page }) => {
    // 1. Lawyer Login
    await page.goto('http://localhost:8080/J4U/Lawyer_login.html');
    await page.waitForSelector('#txtname');
    await page.fill('#txtname', 'dhoni@gmail.com');
    await page.waitForSelector('#txtpass');
    await page.fill('#txtpass', '123456');
    
    // The login page has a 1.5s delay in handleLogin script
    console.log("Submitting login form...");
    await page.click('#btnSubmit');
    
    // Wait for the dashboard heading using role for better resilience
    await page.getByRole('heading', { name: /dhoni@gmail.com/i }).waitFor({ timeout: 25000 });
    console.log("Dashboard reached:", page.url());
    
    await expect(page.getByRole('heading', { name: /dhoni@gmail.com/i })).toBeVisible();
    
    // Check if Associate Workspace exists
    const associateWorkspace = page.locator('.panel:has-text("Associate Workspace")');
    await expect(associateWorkspace).toBeVisible();

    // 3. Navigate to Intern Directory
    await page.click('a[href="viewinternl.jsp"]');
    await expect(page).toHaveURL(/viewinternl.jsp/);
    await expect(page.locator('h1')).toContainText('Intern Directory');

    // 4. Assign Case to Intern (if not already assigned)
    const internRow = page.locator('tr').filter({ hasText: 'virat@gmail.com' });
    await expect(internRow).toBeVisible();
    
    // Click "Deploy to Case" (the first action button)
    await internRow.locator('.btn-action').first().click();
    await expect(page).toHaveURL(/assign_intern_case.jsp/);
    
    // Select a case and assign
    await page.selectOption('select[name="case_id"]', { index: 1 });
    await page.click('button[type="submit"]');
    
    // Should redirect back with success
    await expect(page).toHaveURL(/viewinternl.jsp\?msg=/);
    
    // 5. Delegate Task
    // Now it should be marked as "MY TEAM"
    await expect(internRow).toContainText('MY TEAM');
    await internRow.locator('.btn-action:has-text("Delegate Task")').click();
    await expect(page).toHaveURL(/assign_task.jsp/);
    
    // Fill Task Details
    // Select case again
    await page.selectOption('select[name="case_id"]', { index: 1 });
    await page.fill('input[name="title"]', 'Automated Verification Task ' + Date.now());
    await page.fill('input[name="due_date"]', '2026-12-31');
    await page.click('button[type="submit"]');
    
    // Should redirect back
    await expect(page).toHaveURL(/viewinternl.jsp\?msg=/);

    // 6. Final Dashboard Verification
    await page.goto('http://localhost:8080/J4U/LawyerDashboardServlet'); 
    await expect(page.locator('.panel-body:has-text("Active Team")')).toContainText('virat kohli'); 
});
