/**
 * SymbolDetailPage - Symbol detail with Navigation component
 */

import { Asset } from '../model/Asset';
import { QuoteService } from '../services/QuoteService';
import { WatchlistStore } from '../store/WatchlistStore';
import { Formatters } from '../model/Formatters';
import { Sparkline } from '../components/Sparkline';
import { EditAlertSheet } from '../components/EditAlertSheet';

// Interface for navigation params
interface NavParams {
  symbol?: string;
}

@Builder
export function SymbolDetailPageBuilder(name: string, param: Object) {
  SymbolDetailPage()
}

@Component
export struct SymbolDetailPage {
  pageInfos: NavPathStack = new NavPathStack();
  @State symbol: string = '';
  @State asset?: Asset = undefined;
  @State inWatchlist: boolean = false;
  @State showAlertSheet: boolean = false;
  @State notFound: boolean = false;
  private quoteService: QuoteService = QuoteService.getInstance();
  private watchlistStore: WatchlistStore = WatchlistStore.getInstance();
  private unsubscribe?: () => void;

  aboutToAppear() {
    this.quoteService.start();
    this.updateAsset();
    
    this.unsubscribe = this.quoteService.subscribe(() => {
      this.updateAsset();
    });
  }

  aboutToDisappear() {
    if (this.unsubscribe) {
      this.unsubscribe();
    }
  }

  onPageShow() {
    try {
      const allParams = this.pageInfos.getAllPathName();
      if (allParams && allParams.length > 0) {
        const lastIndex = allParams.length - 1;
        const paramObj = this.pageInfos.getParamByIndex(lastIndex) as NavParams;
        if (paramObj && paramObj.symbol) {
          this.symbol = paramObj.symbol;
        }
      }
    } catch (e) {
      console.error('[SymbolDetailPage] Error getting params:', e);
    }
  }

  private updateAsset() {
    if (!this.symbol) {
      this.notFound = true;
      return;
    }

    const foundAsset = this.quoteService.getAsset(this.symbol);
    if (foundAsset) {
      this.asset = foundAsset;
      this.inWatchlist = this.watchlistStore.has(this.symbol);
      this.notFound = false;
    } else {
      this.notFound = true;
    }
  }

  private async toggleWatchlist() {
    if (this.inWatchlist) {
      await this.watchlistStore.remove(this.symbol);
    } else {
      await this.watchlistStore.add(this.symbol);
    }
    this.inWatchlist = !this.inWatchlist;
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

            Text(this.symbol)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .layoutWeight(1)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#1A1A1A')

          if (this.notFound) {
            Column({ space: 16 }) {
              Text('❌')
                .fontSize(48)
              
              Text('Symbol not found')
                .fontSize(14)
                .fontColor('#B0B0B0')
              
              Button('Go Back')
                .width(120)
                .height(40)
                .fontSize(14)
                .backgroundColor('#4A9EFF')
                .fontColor('#FFFFFF')
                .borderRadius(8)
                .onClick(() => {
                  this.pageInfos.pop();
                })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else if (this.asset) {
            Scroll() {
              Column({ space: 20 }) {
                Text(this.asset.name)
                  .fontSize(13)
                  .fontColor('#B0B0B0')
                  .width('90%')

                Column({ space: 4 }) {
                  Text(Formatters.formatPriceWithSymbol(this.asset.price))
                    .fontSize(32)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')

                  Text(Formatters.formatChange(this.asset.changePct))
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Formatters.formatChangeColor(this.asset.changePct))
                }
                .width('90%')

                if (this.asset.history.length > 1) {
                  Column({ space: 6 }) {
                    Text('Price History')
                      .fontSize(12)
                      .fontColor('#B0B0B0')
                      .alignSelf(ItemAlign.Start)

                    Sparkline({
                      data: this.asset.history,
                      canvasWidth: 280,
                      canvasHeight: 60,
                      color: this.asset.changePct >= 0 ? '#00C853' : '#FF3D00'
                    })
                  }
                  .width('90%')
                  .padding(16)
                  .backgroundColor('#1E1E1E')
                  .borderRadius(12)
                }

                Row({ space: 16 }) {
                  Column({ space: 4 }) {
                    Text('High')
                      .fontSize(11)
                      .fontColor('#B0B0B0')
                    Text(Formatters.formatPriceWithSymbol(this.asset.getHigh()))
                      .fontSize(14)
                      .fontColor('#FFFFFF')
                  }

                  Column({ space: 4 }) {
                    Text('Low')
                      .fontSize(11)
                      .fontColor('#B0B0B0')
                    Text(Formatters.formatPriceWithSymbol(this.asset.getLow()))
                      .fontSize(14)
                      .fontColor('#FFFFFF')
                  }

                  Column({ space: 4 }) {
                    Text('Updated')
                      .fontSize(11)
                      .fontColor('#B0B0B0')
                    Text(Formatters.formatRelativeTime(this.asset.lastUpdated))
                      .fontSize(14)
                      .fontColor('#FFFFFF')
                  }
                }
                .width('90%')
                .justifyContent(FlexAlign.SpaceAround)
                .padding(16)
                .backgroundColor('#1E1E1E')
                .borderRadius(12)

                Column({ space: 10 }) {
                  Button(this.inWatchlist ? `✓ In Watchlist` : `+ Add to Watchlist`)
                    .width('90%')
                    .height(44)
                    .fontSize(14)
                    .backgroundColor(this.inWatchlist ? '#2A2A2A' : '#4A9EFF')
                    .fontColor('#FFFFFF')
                    .borderRadius(8)
                    .onClick(() => {
                      this.toggleWatchlist();
                    })

                  Button('🔔 Create Alert')
                    .width('90%')
                    .height(44)
                    .fontSize(14)
                    .backgroundColor('#2A2A2A')
                    .fontColor('#FFFFFF')
                    .borderRadius(8)
                    .onClick(() => {
                      this.showAlertSheet = true;
                    })
                }
                .width('100%')
                .padding({ bottom: 20 })
              }
              .width('100%')
              .padding({ top: 16 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Auto)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#121212')

        EditAlertSheet({
          visible: $showAlertSheet,
          prefilledSymbol: this.symbol
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
