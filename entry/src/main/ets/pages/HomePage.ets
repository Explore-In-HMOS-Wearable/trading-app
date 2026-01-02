/**
 * HomePage - Market overview with Navigation component structure
 */

import { Asset } from '../model/Asset';
import { QuoteService } from '../services/QuoteService';
import { WatchlistStore } from '../store/WatchlistStore';
import { Formatters } from '../model/Formatters';
import { MarketSentiment } from '../model/Types';
import { QuoteRow } from '../components/QuoteRow';
import { SectionHeader } from '../components/SectionHeader';
import { SyncStatusSheet } from '../components/SyncStatusSheet';
import { NavigationService } from '../utils/NavigationService';
import { StoreProvider } from '../store/StoreProvider';
import { AlertEngine } from '../services/AlertEngine';
import { common } from '@kit.AbilityKit';

// Interface for navigation params
interface NavParams {
  symbol?: string;
}

@Builder
export function HomePageBuilder(name: string, param: Object) {
  HomePage()
}

@Component
export struct HomePage {
  pageInfos: NavPathStack = new NavPathStack();
  private navService: NavigationService = NavigationService.getInstance();
  @State assets: Asset[] = [];
  @State watchlistAssets: Asset[] = [];
  @State topMovers: Asset[] = [];
  @State marketSentiment: MarketSentiment = 'MIXED';
  @State lastUpdateTime: string = '';
  @State isStale: boolean = false;
  @State showSyncSheet: boolean = false;
  private quoteService: QuoteService = QuoteService.getInstance();
  private watchlistStore: WatchlistStore = WatchlistStore.getInstance();
  private alertEngine: AlertEngine = AlertEngine.getInstance();
  private unsubscribe?: () => void;

  async aboutToAppear() {
    await StoreProvider.initialize(this.getUIContext().getHostContext() as common.UIAbilityContext);
    this.quoteService.start();
    this.alertEngine.start();

    this.unsubscribe = this.quoteService.subscribe((assets: Asset[]) => {
      this.assets = assets;
      this.updateMarketData();
    });
  }

  aboutToDisappear() {
    if (this.unsubscribe) {
      this.unsubscribe();
    }
  }

  private updateMarketData() {
    const upCount = this.assets.filter(a => a.changePct > 0).length;
    const downCount = this.assets.filter(a => a.changePct < 0).length;

    if (upCount > downCount * 1.5) {
      this.marketSentiment = 'UP';
    } else if (downCount > upCount * 1.5) {
      this.marketSentiment = 'DOWN';
    } else {
      this.marketSentiment = 'MIXED';
    }

    this.topMovers = [...this.assets]
      .sort((a, b) => Math.abs(b.changePct) - Math.abs(a.changePct))
      .slice(0, 5);

    const watchlistSymbols = this.watchlistStore.getSymbols().slice(0, 3);
    this.watchlistAssets = watchlistSymbols
      .map(symbol => this.assets.find(a => a.symbol === symbol))
      .filter(asset => asset !== undefined) as Asset[];

    if (this.assets.length > 0) {
      const latestUpdate = Math.max(...this.assets.map(a => a.lastUpdated));
      this.lastUpdateTime = Formatters.formatTime(latestUpdate);
      this.isStale = Date.now() - latestUpdate > 10000;
    }
  }

  private getSentimentIcon(): string {
    switch (this.marketSentiment) {
      case 'UP':
        return '📈';
      case 'DOWN':
        return '📉';
      default:
        return '➡️';
    }
  }

  private getSentimentText(): string {
    switch (this.marketSentiment) {
      case 'UP':
        return 'Market Up';
      case 'DOWN':
        return 'Market Down';
      default:
        return 'Mixed Market';
    }
  }

  private getSentimentColor(): string {
    switch (this.marketSentiment) {
      case 'UP':
        return '#00C853';
      case 'DOWN':
        return '#FF3D00';
      default:
        return '#FFA726';
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column({ space: 16 }) {
            Text('Trading App')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .padding({ top: 16, left: 12 })
              .width('100%')

            Column({ space: 8 }) {
              Row() {
                Text(this.getSentimentIcon())
                  .fontSize(32)

                Column({ space: 2 }) {
                  Text(this.getSentimentText())
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getSentimentColor())

                  Row({ space: 4 }) {
                    Text(this.lastUpdateTime)
                      .fontSize(11)
                      .fontColor('#B0B0B0')

                    if (this.isStale) {
                      Text('⚠ Stale')
                        .fontSize(10)
                        .fontColor('#FF9800')
                    }
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 })
              }
              .width('100%')
            }
            .width('90%')
            .padding(7)
            .backgroundColor('#1E1E1E')
            .borderRadius(12)
            .alignSelf(ItemAlign.Center)
            .height('50fp')

            Column({ space: 8 }) {
              SectionHeader({ title: 'Top Movers' })

              ForEach(this.topMovers, (asset: Asset) => {
                QuoteRow({
                  asset: asset,
                  onTap: () => {
                    const params: NavParams = { symbol: asset.symbol };
                    this.pageInfos.pushPath({ name: 'SymbolDetailPage', param: params });
                  }
                })
              }, (item: string, index: number) => item)
            }
            .width('85%')

            if (this.watchlistAssets.length > 0) {
              Column({ space: 8 }) {
                SectionHeader({
                  title: 'My Watchlist',
                  rightText: 'View All →',
                  onRightTap: () => {
                    this.pageInfos.pushPath({ name: 'WatchlistPage' });
                  }
                })

                ForEach(this.watchlistAssets, (asset: Asset) => {
                  QuoteRow({
                    asset: asset,
                    onTap: () => {
                      const params: NavParams = { symbol: asset.symbol };
                      this.pageInfos.pushPath({ name: 'SymbolDetailPage', param: params });
                    }
                  })
                }, (item: string, index: number) => item)
              }
              .width('100%')
            }

            Column({ space: 8 }) {
              SectionHeader({ title: 'Quick Actions' })

              this.quickActionButton('📋 Watchlist', () => {
                this.pageInfos.pushPath({ name: 'WatchlistPage' });
              }, true)

              this.quickActionButton('🔔 Alerts', () => {
                this.pageInfos.pushPath({ name: 'AlertsPage' });
              }, true)

              this.quickActionButton('🔄 Sync', () => {
                this.showSyncSheet = true;
              }, true)
            }
            .width('100%')
            .padding({ bottom: 20 })
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Auto)
        .backgroundColor('#121212')

        SyncStatusSheet({
          visible: $showSyncSheet,
          onCompleted: () => {
            this.updateMarketData();
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }

  @Builder
  quickActionButton(label: string, action: () => void, fullWidth: boolean = false) {
    Button(label)
      .width(fullWidth ? '90%' : '45%')
      .height(37)
      .fontSize(13)
      .backgroundColor('#2A2A2A')
      .fontColor('#FFFFFF')
      .borderRadius(8)
      .onClick(action)

  }
}
