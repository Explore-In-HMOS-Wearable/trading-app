/**
 * Core type definitions for the Watch行情 Demo app
 */

export type AlertCondition = 'ABOVE' | 'BELOW';

export type SyncState = 'IDLE' | 'REQUESTED' | 'WAITING_APPROVAL' | 'APPROVED' | 'REJECTED' | 'TIMEOUT';

export type MarketSentiment = 'UP' | 'DOWN' | 'MIXED';

// Interface for subscription callback
export interface SubscriptionCallback<T> {
  call(data: T): void;
}

// Interface for unsubscribe function
export interface UnsubscribeFunction {
  call(): void;
}

// Helper class for creating callbacks
export class CallbackWrapper<T> implements SubscriptionCallback<T> {
  private fn: (data: T) => void;
  
  constructor(fn: (data: T) => void) {
    this.fn = fn;
  }
  
  call(data: T): void {
    this.fn(data);
  }
}

// Helper class for unsubscribe
export class UnsubscribeWrapper implements UnsubscribeFunction {
  private fn: () => void;
  
  constructor(fn: () => void) {
    this.fn = fn;
  }
  
  call(): void {
    this.fn();
  }
}
