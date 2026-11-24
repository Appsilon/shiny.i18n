import { expect, test } from '@appsilon/shiny-playwright';

test.use({ app: 'live_change' });

test.beforeEach(async ({ shiny }) => {
  await shiny.goto();
});

test('renders in the key language on load', async ({ page, shiny }) => {
  await expect(page.locator('h1')).toHaveText('Hello Shiny!');
  await expect(page.locator('#server_text')).toHaveText('Translated on the server');
  // The server receives the language from the shiny-i18n.js input binding.
  await expect(page.locator('#i18n_state')).toHaveText('en');
  await shiny.expectNoErrors();
});

test('picking a language translates browser-side and server-side text', async ({ page, shiny }) => {
  await shiny.selectOption('selected_language', 'pl');

  // Static UI, translated in the browser by the shiny-i18n.js input binding.
  await expect(page.locator('h1')).toHaveText('Witaj Shiny!');
  await expect(page.locator('#description')).toHaveText('To jest opis.');
  await expect(page.locator('#selected_language-label')).toHaveText('Zmień język');
  // Render function, re-run on the server for the session's new language.
  await expect(page.locator('#server_text')).toHaveText('Przetłumaczone na serwerze');
  // The binding reports the language back to the server.
  await expect(page.locator('#i18n_state')).toHaveText('pl');
  await shiny.expectNoErrors();
});

test('switching back to the key language restores the original text', async ({ page, shiny }) => {
  await shiny.selectOption('selected_language', 'it');
  await expect(page.locator('h1')).toHaveText('Ciao Shiny!');

  await shiny.selectOption('selected_language', 'en');
  await expect(page.locator('h1')).toHaveText('Hello Shiny!');
  await expect(page.locator('#server_text')).toHaveText('Translated on the server');
  await shiny.expectNoErrors();
});
