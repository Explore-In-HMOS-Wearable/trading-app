/**
 * AlertEngine - Monitors price alerts and triggers notifications
 */

import { Asset } from '../model/Asset';
import { PriceAlert } from '../model/PriceAlert';
import { QuoteService } from './QuoteService';
import { AlertStore } from '../store/AlertStore';

export interface AlertTriggerEvent {
  alert: PriceAlert;
  currentPrice: number;
  timestamp: number;
}

export class AlertEngine {
  private static instance: AlertEngine;
  private quoteService: QuoteService;
  private alertStore: AlertStore;
  private unsubscribe?: () => void;
  private triggerCallbacks: Set<(event: AlertTriggerEvent) => void> = new Set();

  private constructor() {
    this.quoteService = QuoteService.getInstance();
    this.alertStore = AlertStore.getInstance();
  }

  static getInstance(): AlertEngine {
    if (!AlertEngine.instance) {
      AlertEngine.instance = new AlertEngine();
    }
    return AlertEngine.instance;
  }

  start(): void {
    if (this.unsubscribe) {
      return;
    }

    this.unsubscribe = this.quoteService.subscribe((assets: Asset[]) => {
      this.checkAlerts(assets);
    });
  }

  stop(): void {
    if (this.unsubscribe) {
      this.unsubscribe();
      this.unsubscribe = undefined;
    }
  }

  onTrigger(callback: (event: AlertTriggerEvent) => void): () => void {
    this.triggerCallbacks.add(callback);
    return () => {
      this.triggerCallbacks.delete(callback);
    };
  }

  private checkAlerts(assets: Asset[]): void {
    const alerts = this.alertStore.getAlerts();
    const now = Date.now();
    const assetMap = new Map<string, Asset>();

    assets.forEach(asset => {
      assetMap.set(asset.symbol, asset);
    });

    alerts.forEach(alert => {
      const asset = assetMap.get(alert.symbol);
      if (!asset) {
        return;
      }

      if (alert.canTrigger(asset.price, now)) {
        this.triggerAlert(alert, asset.price, now);
      }
    });
  }

  private triggerAlert(alert: PriceAlert, currentPrice: number, timestamp: number): void {
    this.alertStore.recordTrigger(alert.id, timestamp);

    const event: AlertTriggerEvent = {
      alert: alert,
      currentPrice: currentPrice,
      timestamp: timestamp
    };

    this.triggerCallbacks.forEach(callback => {
      callback(event);
    });

    this.triggerHaptic();
  }

  private triggerHaptic(): void {
    // TODO: Implement haptic feedback using HarmonyOS vibrator API
    console.info('[AlertEngine] Haptic feedback triggered (stub)');
  }
}
