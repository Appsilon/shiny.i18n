import { expect, test } from '../harness';

test.use({ app: 'live_change_module' });

test('update_lang() called inside a module changes the whole session', async ({ page, shiny }) => {
  await shiny.goto();
  await shiny.selectOption('lang-selected_language', 'it');

  await expect(page.locator('h1')).toHaveText('Ciao Shiny!');
  await expect(page.locator('#lang-server_text')).toHaveText('Tradotto sul server');
  await expect(page.locator('#i18n_state')).toHaveText('it');
  await shiny.expectNoErrors();
});
