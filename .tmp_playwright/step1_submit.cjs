const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const context = await browser.newContext({ userAgent: 'TrufflyPhase2BridgeValidation/1.0' });
  const page = await context.newPage();
  await page.goto('https://connect.stripe.com/setup/e/acct_1TGOgTBCqhPqDnDK/Zlp1cYQMHwr0', { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForSelector('#emailAddress', { timeout: 30000 });
  await page.locator('#emailAddress').fill('seller1@test.com');
  await page.locator('input[type="tel"]').fill('3123456789');
  await page.locator('input[type="submit"]').click();
  await page.waitForTimeout(6000);
  console.log('URL=' + page.url());
  console.log('BODY=' + (await page.locator('body').innerText()).slice(0, 5000));
  await page.screenshot({ path: 'after_step1.png', fullPage: true });
  await browser.close();
})();
