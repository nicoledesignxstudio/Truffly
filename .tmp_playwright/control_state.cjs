const { chromium } = require('playwright');

(async () => {
  const onboardingUrl = process.argv[2];
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const context = await browser.newContext({ userAgent: 'TrufflyPhase2BridgeValidation/1.0' });
  const page = await context.newPage();
  await page.goto(onboardingUrl, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(5000);
  const controls = await page.evaluate(() => Array.from(document.querySelectorAll('input, select, textarea, button')).map((el) => ({ tag: el.tagName, type: el.getAttribute('type'), name: el.getAttribute('name'), id: el.getAttribute('id'), disabled: el.hasAttribute('disabled'), text: (el.textContent || '').trim().slice(0, 120), aria: el.getAttribute('aria-label') })));
  console.log(JSON.stringify(controls, null, 2));
  await browser.close();
})();
