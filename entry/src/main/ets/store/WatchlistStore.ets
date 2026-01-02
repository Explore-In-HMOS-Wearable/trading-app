/**
 * WatchlistStore - Manages user's watchlist with persistence
 */

import preferences from '@ohos.data.preferences';
import { UIContext } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

const PREFERENCES_NAME = 'watch_quotes_prefs';
const KEY_WATCHLIST = 'watchlist_symbols';

export class WatchlistStore {
  private static instance: WatchlistStore;
  private symbols: Set<string> = new Set();
  private prefsStore?: preferences.Preferences;
  private isLoaded: boolean = false;

  private constructor() {
  }

  static getInstance(): WatchlistStore {
    if (!WatchlistStore.instance) {
      WatchlistStore.instance = new WatchlistStore();
    }
    return WatchlistStore.instance;
  }

  async load(context: common.UIAbilityContext): Promise<void> {
    if (this.isLoaded) {
      return;
    }

    try {

      this.prefsStore = await preferences.getPreferences(context, PREFERENCES_NAME);

      const stored = await this.prefsStore.get(KEY_WATCHLIST, '[]');
      const parsed = JSON.parse(stored as string) as string[];

      this.symbols = new Set(parsed);
      this.isLoaded = true;
      console.info('[WatchlistStore] Loaded watchlist:', Array.from(this.symbols));
    } catch (error) {
      console.error('[WatchlistStore] Load error:', error);
      this.symbols = new Set();
      this.isLoaded = true;
    }
  }

  private async save(): Promise<void> {
    if (!this.prefsStore) {
      return;
    }

    try {
      const data = JSON.stringify(Array.from(this.symbols));
      await this.prefsStore.put(KEY_WATCHLIST, data);
      await this.prefsStore.flush();
      console.info('[WatchlistStore] Saved watchlist');
    } catch (error) {
      console.error('[WatchlistStore] Save error:', error);
    }
  }

  getSymbols(): string[] {
    return Array.from(this.symbols);
  }

  has(symbol: string): boolean {
    return this.symbols.has(symbol);
  }

  async add(symbol: string): Promise<void> {
    if (this.symbols.has(symbol)) {
      return;
    }
    this.symbols.add(symbol);
    await this.save();
  }

  async remove(symbol: string): Promise<void> {
    if (!this.symbols.has(symbol)) {
      return;
    }
    this.symbols.delete(symbol);
    await this.save();
  }

  async addMultiple(newSymbols: string[]): Promise<void> {
    let changed = false;
    newSymbols.forEach(symbol => {
      if (!this.symbols.has(symbol)) {
        this.symbols.add(symbol);
        changed = true;
      }
    });

    if (changed) {
      await this.save();
    }
  }

  async clear(): Promise<void> {
    this.symbols.clear();
    await this.save();
  }

  getCount(): number {
    return this.symbols.size;
  }
}
