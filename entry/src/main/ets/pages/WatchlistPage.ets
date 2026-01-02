/**
 * WatchlistPage - Manage watchlist with Navigation component
 */

import { Asset } from '../model/Asset';
import { QuoteService } from '../services/QuoteService';
import { WatchlistStore } from '../store/WatchlistStore';
import { QuoteRow } from '../components/QuoteRow';
import { SectionHeader } from '../components/SectionHeader';
import { AddSymbolSheet } from '../components/AddSymbolSheet';
import { SyncStatusSheet } from '../components/SyncStatusSheet';

// Interface for navigation params
interface NavParams {
  symbol?: string;
}

@Builder
export function WatchlistPageBuilder(name: string, param: Object) {
  WatchlistPage()
}

@Component
export struct WatchlistPage {
  pageInfos: NavPathStack = new NavPathStack();
  @State watchlistAssets: Asset[] = [];
  @State showAddSheet: boolean = false;
  @State showSyncSheet: boolean = false;
  private quoteService: QuoteService = QuoteService.getInstance();
  private watchlistStore: WatchlistStore = WatchlistStore.getInstance();
  private unsubscribe?: () => void;

  aboutToAppear() {
    this.quoteService.start();
    this.unsubscribe = this.quoteService.subscribe((assets: Asset[]) => {
      this.updateWatchlist(assets);
    });
  }

  aboutToDisappear() {
    if (this.unsubscribe) {
      this.unsubscribe();
    }
  }

  private updateWatchlist(assets: Asset[]) {
    const symbols = this.watchlistStore.getSymbols();
    this.watchlistAssets = symbols
      .map(symbol => assets.find(a => a.symbol === symbol))
      .filter(asset => asset !== undefined) as Asset[];
  }

  private async handleRemove(symbol: string) {
    await this.watchlistStore.remove(symbol);
    const assets = this.quoteService.getAssets();
    this.updateWatchlist(assets);
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Row() {
            Text('← ')
              .fontSize(24)
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.pageInfos.pop();
              })

            Text('My Watchlist')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .layoutWeight(1)
            // .margin({ left: 1 })

            Text('🔄')
              .fontSize(20)
              .onClick(() => {
                this.showSyncSheet = true;
              })

          }
          .width('70%')
          .padding(12)

          if (this.watchlistAssets.length > 0) {
            Scroll() {
              Column({ space: 12 }) {
                SectionHeader({
                  title: `${this.watchlistAssets.length} Symbols`,
                  rightText: '+ Add',
                  onRightTap: () => {
                    this.showAddSheet = true;
                  }
                })

                ForEach(this.watchlistAssets, (asset: Asset) => {
                  Row() {
                    QuoteRow({
                      asset: asset,
                      onTap: () => {
                        const params: NavParams = { symbol: asset.symbol };
                        this.pageInfos.pushPath({ name: 'SymbolDetailPage', param: params });
                      }
                    })
                      .layoutWeight(1)

                    Button('X')
                      .width(26)
                      .height(26)
                      .fontSize(16)
                      .backgroundColor('#FF3D00')
                      .fontColor(Color.White)
                      .borderRadius(8)
                      .margin({ left: 8 })
                      .onClick(() => {
                        this.handleRemove(asset.symbol);
                      })
                      .opacity(0.55)
                      .padding(0)

                  }
                  .width('100%')
                }, (item: string, index: number) => item)
              }
              .width('80%')
              .padding({ top: 8, bottom: 20 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          } else {
            Column() {
              Column({ space: 9 }) {

                Blank()
                  .width('100%')
                  .height('1fp')

                Text('📊')
                  .fontSize(48)

                Text('No symbols in watchlist')
                  .fontSize(14)
                  .fontColor('#B0B0B0')

                Button('Add Symbols')
                  .width(140)
                  .height(40)
                  .fontSize(14)
                  .backgroundColor('#4A9EFF')
                  .fontColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.showAddSheet = true;
                  })
              }
              .width('80%')

            }
            .width('100%')
            .layoutWeight(1)
            // .justifyContent(FlexAlign.Center)
            .justifyContent(FlexAlign.Start)

          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#121212')

        AddSymbolSheet({
          visible: $showAddSheet,
          onAdded: () => {
            const assets = this.quoteService.getAssets();
            this.updateWatchlist(assets);
          }
        })

        SyncStatusSheet({
          visible: $showSyncSheet,
          onCompleted: () => {
            const assets = this.quoteService.getAssets();
            this.updateWatchlist(assets);
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
}
