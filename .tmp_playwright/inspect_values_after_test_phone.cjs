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
  const values = await page.evaluate(() => ({
    tel: document.querySelector('input[type="tel"]')?.value,
    hidden: document.querySelector('input[name="phone_number"]')?.value,
    email: document.querySelector('#emailAddress')?.value,
  }));
  console.log(JSON.stringify(values, null, 2));
  await browser.close();
})();
