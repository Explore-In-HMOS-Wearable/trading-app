/**
 * NavigationRouter - Main navigation entry point
 * Based on HarmonyOS Navigation component pattern
 */

import { HomePage } from './HomePage';
import { WatchlistPage } from './WatchlistPage';
import { SymbolDetailPage } from './SymbolDetailPage';
import { AlertsPage } from './AlertsPage';
import { NavigationService } from '../utils/NavigationService';

@Entry
@Component
struct NavigationRouter {
  private navService: NavigationService = NavigationService.getInstance();

  aboutToAppear() {
    this.navService.pageInfos.pushPath({ name: 'HomePage' });
  }

  @Builder
  routeMap(builderName: string, param: object) {
    if (builderName === 'HomePage') {
      HomePage();
    } else if (builderName === 'WatchlistPage') {
      WatchlistPage();
    } else if (builderName === 'SymbolDetailPage') {
      SymbolDetailPage();
    } else if (builderName === 'AlertsPage') {
      AlertsPage();
    }
  }

  build() {
    Navigation(this.navService.pageInfos) {
    }
    .navDestination(this.routeMap)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#121212')
  }
}
