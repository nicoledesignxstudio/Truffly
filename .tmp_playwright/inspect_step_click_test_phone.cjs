const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const page = await browser.newPage();
  await page.goto('https://connect.stripe.com/setup/e/acct_1TGOZ1BTD2QsfqRH/c5Ar7UCNM8Gk', { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(3000);
  const testPhoneButton = page.getByRole('button', { name: 'Usa numero di telefono di test' });
  console.log('testPhoneVisible=' + await testPhoneButton.isVisible());
  await testPhoneButton.click();
  await page.waitForTimeout(5000);
  console.log('URL=' + page.url());
  console.log('BODY=' + (await page.locator('body').innerText()).slice(0, 5000));
  const controls = await page.evaluate(() => Array.from(document.querySelectorAll('input, select, textarea, button')).map((el) => ({ tag: el.tagName, type: el.getAttribute('type'), name: el.getAttribute('name'), id: el.getAttribute('id'), placeholder: el.getAttribute('placeholder'), text: (el.textContent || '').trim().slice(0, 120), aria: el.getAttribute('aria-label') })));
  console.log('CONTROLS=' + JSON.stringify(controls, null, 2));
  await browser.close();
})();
