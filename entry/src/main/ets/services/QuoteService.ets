/**
 * QuoteService - Mock quote engine with simulated real-time updates
 */

import { Asset } from '../model/Asset';
import { getRandomValue } from '../utils/RandomService';

// Interface for mock asset data
interface MockAssetData {
  symbol: string;
  name: string;
  price: number;
}

export class QuoteService {
  private static instance: QuoteService;
  private assets: Map<string, Asset> = new Map();
  private subscribers: Set<(assets: Asset[]) => void> = new Set();
  private timerId: number = -1;
  private isRunning: boolean = false;

  private constructor() {
    this.initializeMockAssets();
  }

  static getInstance(): QuoteService {
    if (!QuoteService.instance) {
      QuoteService.instance = new QuoteService();
    }
    return QuoteService.instance;
  }

  private initializeMockAssets(): void {
    const mockData: MockAssetData[] = [
      { symbol: 'AAPL', name: 'Yapple Inc.', price: 178.50 },
      { symbol: 'TSLA', name: 'Pesla Inc.', price: 242.80 },
      { symbol: 'GOOGL', name: 'Kalphabet Inc.', price: 140.25 },
      { symbol: 'MSFT', name: 'Dicrosoft Corp.', price: 378.90 },
      { symbol: 'AMZN', name: 'Zamazon.com Inc.', price: 155.30 },
      { symbol: 'NVDA', name: 'NHVIDIA Corp.', price: 495.20 },
      { symbol: 'META', name: 'Metar Platforms', price: 352.75 },
      { symbol: 'BTC', name: 'Bitlicoin', price: 43250.00 },
      { symbol: 'ETH', name: 'Zethereum', price: 2280.50 },
      { symbol: 'EURUSD', name: 'EUR/USD', price: 1.0875 },
      { symbol: 'GBPUSD', name: 'GBP/USD', price: 1.2650 },
      { symbol: 'USDJPY', name: 'USD/JPY', price: 148.25 },
      { symbol: 'GOLD', name: 'Gold Spot', price: 2045.80 },
      { symbol: 'OIL', name: 'Crude Oil', price: 77.30 },
      { symbol: 'SPX', name: 'S&P 500', price: 4780.25 }
    ];

    mockData.forEach((item: MockAssetData) => {
      const asset = new Asset(item.symbol, item.name, item.price, 0);
      this.assets.set(item.symbol, asset);
    });
  }

  start(): void {
    if (this.isRunning) {
      return;
    }
    this.isRunning = true;
    this.tick();
  }

  stop(): void {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
  }

  private tick(): void {
    this.updatePrices();
    this.notifySubscribers();

    if (this.isRunning) {
      this.timerId = setTimeout(() => {
        this.tick();
      }, 2000);
    }
  }

  private updatePrices(): void {
    this.assets.forEach((asset) => {
      const volatility = this.getVolatility(asset.symbol);
      const change = (getRandomValue() - 0.5) * 2 * volatility;
      const newPrice = asset.price * (1 + change / 100);
      asset.updatePrice(newPrice);
    });
  }

  private getVolatility(symbol: string): number {
    if (symbol.startsWith('BTC') || symbol.startsWith('ETH')) {
      return 0.5;
    }
    if (symbol.includes('USD')) {
      return 0.1;
    }
    if (symbol === 'GOLD' || symbol === 'OIL') {
      return 0.3;
    }
    return 0.25;
  }

  subscribe(callback: (assets: Asset[]) => void): () => void {
    this.subscribers.add(callback);
    callback(this.getAssets());

    return () => {
      this.subscribers.delete(callback);
    };
  }

  private notifySubscribers(): void {
    const assets = this.getAssets();
    this.subscribers.forEach(callback => {
      callback(assets);
    });
  }

  getAssets(): Asset[] {
    return Array.from(this.assets.values()).map(asset => asset.clone());
  }

  getAsset(symbol: string): Asset | undefined {
    const asset = this.assets.get(symbol);
    return asset ? asset.clone() : undefined;
  }

  searchAssets(query: string): Asset[] {
    const lowerQuery = query.toLowerCase();
    return this.getAssets().filter(asset =>
    asset.symbol.toLowerCase().includes(lowerQuery) ||
    asset.name.toLowerCase().includes(lowerQuery)
    );
  }
}
