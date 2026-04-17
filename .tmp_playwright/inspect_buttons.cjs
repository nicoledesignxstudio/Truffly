const { chromium } = require('playwright');

(async () => {
  const onboardingUrl = process.argv[2];
  const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true });
  const context = await browser.newContext({ userAgent: 'TrufflyPhase2BridgeValidation/1.0' });
  const page = await context.newPage();
  await page.goto(onboardingUrl, { waitUntil: 'domcontentloaded', timeout: 120000 });
  await page.waitForTimeout(5000);
  const result = await page.evaluate(() => {
    const nodes = Array.from(document.querySelectorAll('*'));
    return nodes.map((el) => ({
      tag: el.tagName,
      role: el.getAttribute('role'),
      text: (el.textContent || '').trim(),
      aria: el.getAttribute('aria-label'),
      classes: el.getAttribute('class'),
    })).filter((item) => /Invia|Usa numero di telefono di test/.test(item.text) || /Invia|Usa numero di telefono di test/.test(item.aria || ''));
  });
  console.log(JSON.stringify(result, null, 2));
  await browser.close();
})();
