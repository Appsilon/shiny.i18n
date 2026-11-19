import { expect, Page } from '@playwright/test';
import { ShinyAppProcess } from './shiny-app';

type ShinyState = {
  connected: boolean;
  disconnected: boolean;
  busy: boolean;
  idleCount: number;
  initializedAt: number | null;
};

/**
 * The server only reports busy/idle when an observer or output actually runs. If no busy
 * signal arrives within this window after the session starts, the app had no initial
 * server work (e.g. a static UI) and is treated as idle.
 */
const NO_WORK_WINDOW_MS = 500;

// Runs before any page script. Shiny announces busy/idle with jQuery events, which
// native listeners never see, so subscribe through jQuery once the DOM is parsed.
// This DOMContentLoaded listener is registered before jQuery's own ready handler,
// so it is in place before Shiny initialises.
function trackShinyState() {
  const state: ShinyState = { connected: false, disconnected: false, busy: false, idleCount: 0, initializedAt: null };
  (window as unknown as { __e2eShiny: ShinyState }).__e2eShiny = state;
  document.addEventListener('DOMContentLoaded', () => {
    const $ = (window as unknown as { jQuery?: (el: Document) => { on: (e: string, f: () => void) => void } }).jQuery;
    if (!$) return;
    $(document).on('shiny:sessioninitialized', () => (state.initializedAt = performance.now()));
    $(document).on('shiny:connected', () => (state.connected = true));
    $(document).on('shiny:disconnected', () => {
      state.connected = false;
      state.disconnected = true;
    });
    $(document).on('shiny:busy', () => (state.busy = true));
    $(document).on('shiny:idle', () => {
      state.busy = false;
      state.idleCount += 1;
    });
  });
}

/** Test-facing handle for one Shiny app and the page that shows it. */
export class Shiny {
  private readonly browserErrors: string[] = [];

  constructor(
    readonly page: Page,
    readonly app: ShinyAppProcess,
    private readonly logStart: number,
  ) {
    page.on('console', (msg) => {
      if (msg.type() === 'error') this.browserErrors.push(`console: ${msg.text()}`);
    });
    page.on('pageerror', (error) => this.browserErrors.push(`pageerror: ${error.message}`));
  }

  /** Open the app and wait until Shiny is connected and has finished its first round of work. */
  async goto(pathname = '/'): Promise<void> {
    await this.page.addInitScript(trackShinyState);
    await this.page.goto(new URL(pathname, this.app.url).toString());
    await this.waitForIdle();
  }

  /**
   * Wait until Shiny is connected and not busy. Use it after page load; after a user
   * action prefer web-first assertions (`await expect(locator).toHaveText(...)`),
   * which retry until the UI settles.
   */
  async waitForIdle(): Promise<void> {
    const outcome = await this.page.waitForFunction(
      (noWorkWindowMs) => {
        const s = (window as unknown as { __e2eShiny?: ShinyState }).__e2eShiny;
        if (s?.disconnected) return 'disconnected';
        if (!s || !s.connected || s.busy) return false;
        if (s.idleCount > 0) return 'idle';
        const quiet = s.initializedAt !== null && performance.now() - s.initializedAt > noWorkWindowMs;
        return quiet ? 'idle' : false;
      },
      NO_WORK_WINDOW_MS,
      { polling: 50 },
    );
    if ((await outcome.jsonValue()) === 'disconnected') {
      throw new Error(`The Shiny session disconnected (the app likely errored). R output:\n${this.logs()}`);
    }
  }

  /** Current value of a Shiny input, as the server sees it. */
  async inputValue(inputId: string): Promise<unknown> {
    return this.page.evaluate((id) => {
      const values = (window as unknown as { Shiny: { shinyapp: { $inputValues: Record<string, unknown> } } })
        .Shiny.shinyapp.$inputValues;
      // Inputs with a custom type are stored as "<id>:<type>".
      const key = Object.keys(values).find((k) => k === id || k.startsWith(`${id}:`));
      return key === undefined ? undefined : values[key];
    }, inputId);
  }

  /** Pick `value` in a selectInput the way a user would; handles selectize and native <select>. */
  async selectOption(inputId: string, value: string): Promise<void> {
    const selectize = this.page.locator(`[id="${inputId}"] + .selectize-control`);
    if ((await selectize.count()) > 0) {
      await selectize.locator('.selectize-input').click();
      await selectize.locator(`.selectize-dropdown .option[data-value="${value}"]`).click();
    } else {
      await this.page.locator(`select[id="${inputId}"]`).selectOption(value);
    }
  }

  /** R output of the app captured since this test started. */
  logs(): string {
    return this.app.logs(this.logStart);
  }

  /** Assert the app is healthy: still connected, no output errors, no browser errors. */
  async expectNoErrors(): Promise<void> {
    await expect(this.page.locator('#shiny-disconnected-overlay')).toHaveCount(0);
    await expect(
      this.page.locator('.shiny-output-error:not(.shiny-output-error-silent):not(.shiny-output-error-validation)'),
    ).toHaveCount(0);
    expect(this.browserErrors, 'browser console errors').toEqual([]);
  }
}
