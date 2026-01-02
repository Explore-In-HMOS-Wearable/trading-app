/**
 * SettingsStore - Manages app settings
 */

import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

const PREFERENCES_NAME = 'watch_quotes_prefs';
const KEY_REFRESH_INTERVAL = 'refresh_interval';
const KEY_HAPTIC_ENABLED = 'haptic_enabled';

export class SettingsStore {
  private static instance: SettingsStore;
  private refreshInterval: number = 2000;
  private hapticEnabled: boolean = true;
  private prefsStore?: preferences.Preferences;
  private isLoaded: boolean = false;

  private constructor() {}

  static getInstance(): SettingsStore {
    if (!SettingsStore.instance) {
      SettingsStore.instance = new SettingsStore();
    }
    return SettingsStore.instance;
  }

  async load(context: common.UIAbilityContext): Promise<void> {
    if (this.isLoaded) {return;}

    try {
      this.prefsStore = await preferences.getPreferences(context, PREFERENCES_NAME);
      this.refreshInterval = await this.prefsStore.get(KEY_REFRESH_INTERVAL, 2000) as number;
      this.hapticEnabled = await this.prefsStore.get(KEY_HAPTIC_ENABLED, true) as boolean;
      
      this.isLoaded = true;
      console.info('[SettingsStore] Loaded settings');
    } catch (error) {
      console.error('[SettingsStore] Load error:', error);
      this.isLoaded = true;
    }
  }

  getRefreshInterval(): number {
    return this.refreshInterval;
  }

  isHapticEnabled(): boolean {
    return this.hapticEnabled;
  }

  async setRefreshInterval(interval: number): Promise<void> {
    this.refreshInterval = interval;
    if (this.prefsStore) {
      await this.prefsStore.put(KEY_REFRESH_INTERVAL, interval);
      await this.prefsStore.flush();
    }
  }

  async setHapticEnabled(enabled: boolean): Promise<void> {
    this.hapticEnabled = enabled;
    if (this.prefsStore) {
      await this.prefsStore.put(KEY_HAPTIC_ENABLED, enabled);
      await this.prefsStore.flush();
    }
  }
}
