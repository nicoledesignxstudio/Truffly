import { test } from '@playwright/test';
import { chromium } from '@playwright/test';

test('inspect stripe onboarding page', async () => {
  const browser = await chromium.launch({
    executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
    headless: true,
  });
  const page = await browser.newPage();
  await page.goto('https://connect.stripe.com/setup/e/acct_1TGOZ1BTD2QsfqRH/c5Ar7UCNM8Gk', { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(5000);
  console.log('URL=' + page.url());
  console.log('TITLE=' + await page.title());
  const bodyText = await page.locator('body').innerText();
  console.log('BODY=' + bodyText.slice(0, 5000));
  const controls = await page.evaluate(() => Array.from(document.querySelectorAll('input, select, textarea, button')).map((el) => ({ tag: el.tagName, type: el.getAttribute('type'), name: el.getAttribute('name'), id: el.getAttribute('id'), placeholder: el.getAttribute('placeholder'), text: (el.textContent || '').trim().slice(0, 120), aria: el.getAttribute('aria-label') })));
  console.log('CONTROLS=' + JSON.stringify(controls, null, 2));
  await page.screenshot({ path: 'tmp_stripe_onboarding_inspect.png', fullPage: true });
  await browser.close();
});
