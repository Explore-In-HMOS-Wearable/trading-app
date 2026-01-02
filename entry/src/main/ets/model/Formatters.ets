/**
 * Formatters - utility functions for displaying prices and percentages
 */
import { getRandomValue } from '../utils/RandomService';

export class Formatters {
  static formatPrice(price: number, decimals: number = 2): string {
    return price.toFixed(decimals);
  }

  static formatPriceWithSymbol(price: number, decimals: number = 2): string {
    return `$${Formatters.formatPrice(price, decimals)}`;
  }

  static formatChange(changePct: number): string {
    const sign = changePct >= 0 ? '+' : '';
    return `${sign}${changePct.toFixed(2)}%`;
  }

  static formatChangeColor(changePct: number): string {
    if (changePct > 0) {return '#00C853';}
    if (changePct < 0) {return '#FF3D00';}
    return '#757575';
  }

  static formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  }

  static formatRelativeTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    const seconds = Math.floor(diff / 1000);

    if (seconds < 10) {return 'Just now';}
    if (seconds < 60) {return `${seconds}s ago`;}

    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) {return `${minutes}m ago`;}

    const hours = Math.floor(minutes / 60);
    return `${hours}h ago`;
  }

  static generateId(): string {
    return `${Date.now()}-${getRandomValue().toString(36).substr(2, 9)}`;
  }
}
