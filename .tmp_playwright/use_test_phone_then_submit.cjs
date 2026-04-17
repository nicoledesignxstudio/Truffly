const { chromium } = require('playwright');

(async () => {
  const onboardingUrl = process.argv[2];
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const context = await browser.newContext({ userAgent: 'TrufflyPhase2BridgeValidation/1.0' });
  const page = await context.newPage();
  await page.goto(onboardingUrl, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(5000);
  await page.getByRole('button', { name: 'Usa numero di telefono di test' }).click();
  await page.waitForTimeout(2000);
  await page.getByRole('button', { name: 'Invia' }).click();
  await page.waitForTimeout(7000);
  console.log('URL=' + page.url());
  console.log('BODY=' + (await page.locator('body').innerText()).slice(0, 5000));
  const controls = await page.evaluate(() => Array.from(document.querySelectorAll('input, select, textarea, button, a[role="button"]')).map((el) => ({ tag: el.tagName, type: el.getAttribute('type'), name: el.getAttribute('name'), id: el.getAttribute('id'), disabled: el.hasAttribute('disabled'), text: (el.textContent || '').trim().slice(0, 120), aria: el.getAttribute('aria-label') })));
  console.log('CONTROLS=' + JSON.stringify(controls, null, 2));
  await page.screenshot({ path: 'after_click_test_phone.png', fullPage: true });
  await browser.close();
})();
