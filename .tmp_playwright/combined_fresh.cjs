const { chromium } = require('playwright');

(async () => {
  const onboardingUrl = process.argv[2];
  if (!onboardingUrl) throw new Error('missing onboarding url');
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const context = await browser.newContext({ userAgent: 'TrufflyPhase2BridgeValidation/1.0' });
  const page = await context.newPage();
  await page.goto(onboardingUrl, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(7000);
  console.log('URL=' + page.url());
  console.log('BODY=' + (await page.locator('body').innerText()).slice(0, 3000));
  await page.screenshot({ path: 'combined_fresh.png', fullPage: true });
  await browser.close();
})();
