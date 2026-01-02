/**
 * StoreProvider - Helper singleton to initialize all stores
 */

import { WatchlistStore } from './WatchlistStore';
import { AlertStore } from './AlertStore';
import { SettingsStore } from './SettingsStore';
import { common } from '@kit.AbilityKit';

export class StoreProvider {
  private static initialized: boolean = false;

  static async initialize(context: common.UIAbilityContext): Promise<void> {
    if (StoreProvider.initialized) {
      return;
    }

    console.info('[StoreProvider] Initializing stores...');

    await Promise.all([
      WatchlistStore.getInstance().load(context),
      AlertStore.getInstance().load(context),
      SettingsStore.getInstance().load(context)
    ]);

    StoreProvider.initialized = true;
    console.info('[StoreProvider] All stores initialized');
  }

  static isInitialized(): boolean {
    return StoreProvider.initialized;
  }
}
