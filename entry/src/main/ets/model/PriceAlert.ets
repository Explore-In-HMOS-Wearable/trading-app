/**
 * PriceAlert model - represents a price condition alert
 */

import { AlertCondition } from './Types';

// Interface for JSON serialization
export interface PriceAlertJSON {
  id: string;
  symbol: string;
  condition: string;
  target: number;
  enabled: boolean;
  triggeredCount: number;
  lastTriggeredAt?: number;
  lastCooldownAt: number;
}

export class PriceAlert {
  id: string = '';
  symbol: string = '';
  condition: AlertCondition = 'ABOVE';
  target: number = 0;
  enabled: boolean = true;
  triggeredCount: number = 0;
  lastTriggeredAt?: number = undefined;
  lastCooldownAt: number = 0;

  constructor(
    id: string,
    symbol: string,
    condition: AlertCondition,
    target: number,
    enabled: boolean = true
  ) {
    this.id = id;
    this.symbol = symbol;
    this.condition = condition;
    this.target = target;
    this.enabled = enabled;
    this.triggeredCount = 0;
    this.lastCooldownAt = 0;
  }

  canTrigger(currentPrice: number, now: number, cooldownMs: number = 30000): boolean {
    if (!this.enabled) {return false;}
    if (now - this.lastCooldownAt < cooldownMs) {return false;}

    const shouldTrigger =
      (this.condition === 'ABOVE' && currentPrice >= this.target) ||
      (this.condition === 'BELOW' && currentPrice <= this.target);

    return shouldTrigger;
  }

  recordTrigger(now: number): void {
    this.triggeredCount++;
    this.lastTriggeredAt = now;
    this.lastCooldownAt = now;
  }

  toJSON(): PriceAlertJSON {
    return {
      id: this.id,
      symbol: this.symbol,
      condition: this.condition,
      target: this.target,
      enabled: this.enabled,
      triggeredCount: this.triggeredCount,
      lastTriggeredAt: this.lastTriggeredAt,
      lastCooldownAt: this.lastCooldownAt
    };
  }

  static fromJSON(json: PriceAlertJSON): PriceAlert {
    const alert = new PriceAlert(
      json.id,
      json.symbol,
      json.condition as AlertCondition,
      json.target,
      json.enabled
    );
    alert.triggeredCount = json.triggeredCount || 0;
    alert.lastTriggeredAt = json.lastTriggeredAt;
    alert.lastCooldownAt = json.lastCooldownAt || 0;
    return alert;
  }
}
