# End-to-end tests

Browser tests for shiny.i18n, written with [Playwright](https://playwright.dev) and
[`@appsilon/shiny-playwright`](https://github.com/Appsilon/shiny.playwright#readme). They start real Shiny apps
that use the package **built from this checkout** and drive them in Chromium.

This folder is excluded from the package build (`.Rbuildignore`), so `R CMD check` and CRAN never see it.

The harness (installing the package from source, one R process per app, the `shiny` fixture and the Playwright
config) comes from `@appsilon/shiny-playwright`. Its
[README](https://github.com/Appsilon/shiny.playwright/blob/v0.1.0/README.md) documents the fixture, its options
and how to write a test.

## Running

Prerequisites: R with the package's dependencies installed (`shiny` etc.), and Node.js 20 or newer.

```sh
cd tests/e2e
npm ci                               # first time, or after package-lock.json changes
npx playwright install chromium      # first time, or after upgrading @playwright/test
npm test                             # run everything
CI=1 npm test                        # run as CI does, in your Google Chrome
```

To run against another Shiny version, install it into a separate library and put that library on `R_LIBS`, e.g.
`R_LIBS=/path/to/shiny-1.7.5.1-lib npm test`.

When a test fails, its folder in `test-results/` holds a screenshot, a trace, and `app.log` with the app's R
output.

### In CI

`.github/workflows/e2e.yml` calls the reusable workflow of `shiny.playwright`, which runs `npm test` once with the
oldest Shiny version we test (1.7.5.1) and once with the latest. The checks are `e2e / e2e (Shiny latest)` and
`e2e / e2e (Shiny 1.7.5.1)`. If tests fail, download the `e2e-shiny-<version>` artifact: it holds the HTML report
and, per failed test, the trace and `app.log`.

To upgrade `@appsilon/shiny-playwright`, change the tag in both `package.json` (then run `npm install`) and the
`uses:` line of the workflow.

## Layout

```
apps/        fixture Shiny apps (one folder each) and shared translation files in apps/data
specs/       test files (*.spec.ts); examples-smoke.spec.ts starts the demo apps in examples/
```

Prefer small, deterministic fixture apps in `apps/` over the demo apps in `examples/`, which are covered by the
smoke test only.
