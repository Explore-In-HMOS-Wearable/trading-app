/**
 * AlertStore - Manages price alerts with persistence
 */

import preferences from '@ohos.data.preferences';
import { PriceAlert, PriceAlertJSON } from '../model/PriceAlert';
import { AlertCondition } from '../model/Types';
import { common } from '@kit.AbilityKit';

const PREFERENCES_NAME = 'watch_quotes_prefs';
const KEY_ALERTS = 'price_alerts';

// Interface for trigger history
export interface AlertTriggerHistory {
  alert: PriceAlert;
  timestamp: number;
}

export class AlertStore {
  private static instance: AlertStore;
  private alerts: Map<string, PriceAlert> = new Map();
  private prefsStore?: preferences.Preferences;
  private isLoaded: boolean = false;

  private constructor() {}

  static getInstance(): AlertStore {
    if (!AlertStore.instance) {
      AlertStore.instance = new AlertStore();
    }
    return AlertStore.instance;
  }

  async load(context: common.UIAbilityContext): Promise<void> {
    if (this.isLoaded) {return;}

    try {
      this.prefsStore = await preferences.getPreferences(context, PREFERENCES_NAME);
      const stored = await this.prefsStore.get(KEY_ALERTS, '[]');
      const parsed = JSON.parse(stored as string) as PriceAlertJSON[];

      this.alerts.clear();
      parsed.forEach((json: PriceAlertJSON) => {
        const alert = PriceAlert.fromJSON(json);
        this.alerts.set(alert.id, alert);
      });

      this.isLoaded = true;
      console.info('[AlertStore] Loaded alerts:', this.alerts.size);
    } catch (error) {
      console.error('[AlertStore] Load error:', error);
      this.alerts.clear();
      this.isLoaded = true;
    }
  }

  private async save(): Promise<void> {
    if (!this.prefsStore) {return;}

    try {
      const data = Array.from(this.alerts.values()).map(alert => alert.toJSON());
      const json = JSON.stringify(data);
      await this.prefsStore.put(KEY_ALERTS, json);
      await this.prefsStore.flush();
      console.info('[AlertStore] Saved alerts');
    } catch (error) {
      console.error('[AlertStore] Save error:', error);
    }
  }

  getAlerts(): PriceAlert[] {
    return Array.from(this.alerts.values());
  }

  getAlert(id: string): PriceAlert | undefined {
    return this.alerts.get(id);
  }

  getAlertsForSymbol(symbol: string): PriceAlert[] {
    return this.getAlerts().filter(alert => alert.symbol === symbol);
  }

  async upsert(alert: PriceAlert): Promise<void> {
    this.alerts.set(alert.id, alert);
    await this.save();
  }

  async remove(id: string): Promise<void> {
    if (!this.alerts.has(id)) {return;}
    this.alerts.delete(id);
    await this.save();
  }

  async toggleEnabled(id: string): Promise<void> {
    const alert = this.alerts.get(id);
    if (!alert) {return;}

    alert.enabled = !alert.enabled;
    await this.save();
  }

  async recordTrigger(id: string, timestamp: number): Promise<void> {
    const alert = this.alerts.get(id);
    if (!alert) {return;}
    
    alert.recordTrigger(timestamp);
    await this.save();
  }

  getRecentTriggers(limit: number = 5): AlertTriggerHistory[] {
    const triggered = this.getAlerts()
      .filter(alert => alert.lastTriggeredAt !== undefined)
      .map(alert => {
        const history: AlertTriggerHistory = {
          alert: alert,
          timestamp: alert.lastTriggeredAt as number
        };
        return history;
      })
      .sort((a, b) => b.timestamp - a.timestamp);

    return triggered.slice(0, limit);
  }
}
