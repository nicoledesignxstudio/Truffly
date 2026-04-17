const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const page = await browser.newPage();
  await page.goto('https://connect.stripe.com/setup/e/acct_1TGOZ1BTD2QsfqRH/c5Ar7UCNM8Gk', { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(7000);
  console.log('URL=' + page.url());
  console.log('BODY=' + (await page.locator('body').innerText()).slice(0, 5000));
  const html = await page.content();
  console.log('HAS_EMAIL=' + html.includes('emailAddress'));
  console.log('HAS_HCAPTCHA=' + html.includes('h-captcha'));
  await page.screenshot({ path: 'inspect_again.png', fullPage: true });
  await browser.close();
})();
