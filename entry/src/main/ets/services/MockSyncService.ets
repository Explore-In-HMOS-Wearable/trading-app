/**
 * MockSyncService - Simulates cross-device sync flow
 */

import { SyncState } from '../model/Types';
import { getRandomValue } from '../utils/RandomService';

export interface SyncSession {
  state: SyncState;
  remoteSymbols: string[];
  message: string;
}

export class MockSyncService {
  private static instance: MockSyncService;

  private constructor() {}

  static getInstance(): MockSyncService {
    if (!MockSyncService.instance) {
      MockSyncService.instance = new MockSyncService();
    }
    return MockSyncService.instance;
  }

  async requestSync(): Promise<SyncSession> {
    const session: SyncSession = {
      state: 'REQUESTED',
      remoteSymbols: [],
      message: 'Requesting sync with phone...'
    };

    await this.delay(1000);

    session.state = 'WAITING_APPROVAL';
    session.message = 'Waiting for phone approval...';

    const approvalDelay = 2000 + getRandomValue() * 2000;
    await this.delay(approvalDelay);

    const outcome = getRandomValue();
    
    if (outcome < 0.8) {
      session.state = 'APPROVED';
      session.remoteSymbols = this.getMockRemoteWatchlist();
      session.message = `Sync successful! Received ${session.remoteSymbols.length} symbols.`;
    } else if (outcome < 0.9) {
      session.state = 'REJECTED';
      session.message = 'Sync rejected on phone.';
    } else {
      session.state = 'TIMEOUT';
      session.message = 'Sync request timed out.';
    }

    return session;
  }

  private getMockRemoteWatchlist(): string[] {
    const allSymbols = ['AAPL', 'TSLA', 'GOOGL', 'MSFT', 'NVDA', 'META', 'BTC', 'ETH', 'GOLD'];
    const count = 3 + Math.floor(getRandomValue() * 5);
    const shuffled = [...allSymbols].sort(() => getRandomValue() - 0.5);
    return shuffled.slice(0, count);
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
