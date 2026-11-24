import { expect, test } from '@appsilon/shiny-playwright';

test.use({ app: 'initial_language' });

test('UI built after set_translation_language() is in that language', async ({ page, shiny }) => {
  await shiny.goto();
  await expect(page.locator('h1')).toHaveText('Witaj Shiny!');
  await shiny.expectNoErrors();
});
