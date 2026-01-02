/**
 * Asset model - represents a market symbol with real-time price data
 */

export class Asset {
  symbol: string = '';
  name: string = '';
  price: number = 0;
  changePct: number = 0;
  lastUpdated: number = 0;
  history: number[] = [];

  constructor(
    symbol: string,
    name: string,
    price: number,
    changePct: number = 0
  ) {
    this.symbol = symbol;
    this.name = name;
    this.price = price;
    this.changePct = changePct;
    this.lastUpdated = Date.now();
    this.history = [price];
  }

  updatePrice(newPrice: number): void {
    const oldPrice = this.price;
    this.price = newPrice;
    this.changePct = ((newPrice - oldPrice) / oldPrice) * 100;
    this.lastUpdated = Date.now();
    
    this.history.push(newPrice);
    if (this.history.length > 60) {
      this.history.shift();
    }
  }

  getHigh(): number {
    if (this.history.length === 0) {return this.price;}
    return Math.max(...this.history);
  }

  getLow(): number {
    if (this.history.length === 0) {return this.price;}
    return Math.min(...this.history);
  }

  clone(): Asset {
    const cloned = new Asset(this.symbol, this.name, this.price, this.changePct);
    cloned.lastUpdated = this.lastUpdated;
    cloned.history = [...this.history];
    return cloned;
  }
}
