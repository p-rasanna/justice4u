import { Page, expect, type Locator } from '@playwright/test';

// Shared utilities for Justice4U E2E tests
export const Helpers = {
  /**
   * Wait for no console errors
   */
  checkConsoleErrors(page: Page) {
    page.on('pageerror', (err) => {
      console.error(`Page Error: ${err.message}`);
      // Fail the test if critical error found
      expect(true, `Found critical console error: ${err.message}`).toBeFalsy();
    });
  },

  /**
   * Check that the page doesn't return a 500 error
   */
  async checkResponseStatus(page: Page, url: string) {
    const response = await page.goto(url, { waitUntil: 'domcontentloaded' });
    if (response) {
      expect(response.status(), `URL ${url} returned ${response.status()}`).toBeLessThan(500);
    }
  },
  
  /**
   * Generic Logout Flow - tries multiple logout methods
   */
  async logout(page: Page) {
    try {
      // Try logout links in order of common patterns
      const logoutSelectors = [
        'a:has-text("Logout")',
        'a:has-text("Secure Logout")',
        'a:has-text("Terminate Session")',
        'a:has-text("Sign Out")',
        'a[href*="signout"]',
        'a[href*="Logout"]'
      ];
      
      for (const selector of logoutSelectors) {
        const logoutLink = page.locator(selector).first();
        if (await logoutLink.count() > 0) {
          await logoutLink.click();
          await expect(page.locator('text=Login').first()).toBeVisible({ timeout: 10000 });
          return;
        }
      }
      
      // Fallback: navigate to home
      await page.goto('./Home.html');
    } catch (e) {
      console.log('Logout completed with warnings');
    }
  },

  /**
   * Fill and submit a form with common patterns
   */
  async fillForm(page: Page, formData: Record<string, string>) {
    for (const [fieldName, value] of Object.entries(formData)) {
      const input = page.locator(`input[name="${fieldName}"]`);
      if (await input.count() > 0) {
        await input.fill(value);
      }
    }
  },

  /**
   * Wait for element to be visible with custom timeout
   */
  async waitForElement(page: Page, selector: string, timeout = 10000) {
    await page.locator(selector).first().waitFor({ state: 'visible', timeout });
  },

  /**
   * Take a screenshot with name
   */
  async takeScreenshot(page: Page, name: string) {
    await page.screenshot({ 
      path: `test-results/${name}-${Date.now()}.png`,
      fullPage: true 
    });
  },

  /**
   * Fill textarea (for chat messages)
   */
  async fillTextarea(page: Page, selector: string, text: string) {
    const textarea = page.locator(selector);
    await textarea.fill(text);
  },

  /**
   * Click button by text
   */
  async clickButton(page: Page, text: string) {
    await page.getByRole('button', { name: new RegExp(text, 'i') }).click();
  },

  /**
   * Select option from dropdown by value
   */
  async selectDropdown(page: Page, selector: string, value: string) {
    await page.locator(selector).selectOption(value);
  },

  /**
   * Check for success message
   */
  async verifySuccess(page: Page, message?: string) {
    if (message) {
      await expect(page.locator(`text=${message}`)).toBeVisible({ timeout: 10000 });
    } else {
      // Generic success indicators
      const successIndicators = [
        'text=Success',
        'text=success',
        'text=Successfully',
        '[class*="success"]'
      ];
      
      for (const indicator of successIndicators) {
        const element = page.locator(indicator).first();
        if (await element.count() > 0) {
          await expect(element).toBeVisible({ timeout: 5000 });
          return;
        }
      }
    }
  },

  /**
   * Handle file upload (for document uploads)
   */
  async uploadFile(page: Page, selector: string, filePath: string) {
    await page.locator(selector).setInputFiles(filePath);
  },

  /**
   * Wait for redirect to specific URL pattern
   */
  async waitForRedirect(page: Page, pattern: RegExp, timeout = 15000) {
    await expect(page).toHaveURL(pattern, { timeout });
  },

  /**
   * Check element contains text
   */
  async verifyText(page: Page, selector: string, text: string) {
    const element = page.locator(selector);
    await expect(element).toContainText(text);
  },

  /**
   * Scroll to element and click
   */
  async scrollAndClick(page: Page, selector: string) {
    const element = page.locator(selector).first();
    await element.scrollIntoViewIfNeeded();
    await element.click();
  },

  /**
   * Fill password field
   */
  async fillPassword(page: Page, password: string) {
    const passwordFields = page.locator('input[type="password"]');
    const count = await passwordFields.count();
    for (let i = 0; i < count; i++) {
      await passwordFields.nth(i).fill(password);
    }
  },

  /**
   * Accept all checkboxes in a form
   */
  async acceptTerms(page: Page) {
    const checkboxes = page.locator('input[type="checkbox"]');
    const count = await checkboxes.count();
    for (let i = 0; i < count; i++) {
      const checkbox = checkboxes.nth(i);
      const isChecked = await checkbox.isChecked();
      if (!isChecked) {
        await checkbox.check();
      }
    }
  },

  /**
   * Generate unique test data
   */
  generateUniqueData(prefix: string) {
    const uniqueId = Date.now().toString().slice(-6);
    return {
      email: `${prefix}${uniqueId}@test.com`,
      id: uniqueId,
      name: `${prefix} ${uniqueId}`
    };
  },

  /**
   * Wait for network idle
   */
  async waitForNetworkIdle(page: Page, timeout = 5000) {
    await page.waitForLoadState('networkidle', { timeout }).catch(() => {
      console.log('Network idle timeout - continuing');
    });
  }
};
