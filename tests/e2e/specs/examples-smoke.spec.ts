import path from 'node:path';
import { test } from '../harness';
import { PKG_ROOT } from '../harness/paths';

// Every Shiny example in examples/ must start and render without errors.
// automatic_translations is left out: it needs Google Cloud credentials.
const EXAMPLES = [
  'basic/app_csv.R',
  'basic/app_json.R',
  'language_dropdown/app.R',
  'live_language_change/browser_app.R',
  'live_language_change/browser_app_modules.R',
  'live_language_change/server_app.R',
];

for (const example of EXAMPLES) {
  test.describe(`examples/${example}`, () => {
    test.use({ app: path.join(PKG_ROOT, 'examples', example) });

    test('starts and renders without errors', async ({ shiny }) => {
      await shiny.goto();
      await shiny.expectNoErrors();
    });
  });
}
