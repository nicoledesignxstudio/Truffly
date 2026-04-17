const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const page = await browser.newPage();
  await page.goto('https://connect.stripe.com/setup/e/acct_1TGOZ1BTD2QsfqRH/c5Ar7UCNM8Gk', { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(3000);
  const testPhoneButton = page.getByRole('button', { name: 'Usa numero di telefono di test' });
  if (await testPhoneButton.isVisible()) {
    await testPhoneButton.click();
  }
  await page.locator('input[name="emailAddress"]').fill('seller1@test.com');
  const phone = page.locator('input[type="tel"]');
  if (await phone.isVisible()) {
    await phone.fill('3123456789');
  }
  await page.locator('input[type="submit"]').click();
  await page.waitForTimeout(5000);
  console.log('URL=' + page.url());
  console.log('BODY=' + (await page.locator('body').innerText()).slice(0, 5000));
  await page.screenshot({ path: 'step1.png', fullPage: true });
  await browser.close();
})();
