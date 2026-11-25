import { expect, test } from '@appsilon/shiny-playwright';

test.use({ app: 'missing_key' });

test('a key without a translation falls back to the key and warns in R', async ({ page, shiny }) => {
  await shiny.goto();
  await expect(page.locator('#missing')).toHaveText('Not in the translation file');
  await expect
    .poll(() => shiny.logs())
    .toContain("'Not in the translation file' translation does not exist.");
  await shiny.expectNoErrors();
});
