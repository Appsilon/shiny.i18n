import { expect, test } from '../harness';

test.use({ app: 'initial_language_live' });

test('usei18n() keeps the language chosen before the UI was built', async ({ page, shiny }) => {
  await shiny.goto();
  await expect(page.locator('h1')).toHaveText('Witaj Shiny!');
  await expect(page.locator('#i18n_state')).toHaveText('pl');
  await shiny.expectNoErrors();
});
