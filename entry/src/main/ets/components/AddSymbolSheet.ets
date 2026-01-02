/**
 * AddSymbolSheet - Sheet for searching and adding symbols
 */

import { Asset } from '../model/Asset';
import { QuoteService } from '../services/QuoteService';
import { WatchlistStore } from '../store/WatchlistStore';

@Component
export struct AddSymbolSheet {
  @Link visible: boolean;
  @State searchQuery: string = '';
  @State searchResults: Asset[] = [];
  @State popularSymbols: Asset[] = [];
  private quoteService: QuoteService = QuoteService.getInstance();
  private watchlistStore: WatchlistStore = WatchlistStore.getInstance();
  onAdded?: () => void;

  aboutToAppear() {
    const popular = ['AAPL', 'TSLA', 'BTC', 'ETH', 'GOLD'];
    this.popularSymbols = popular
      .map(symbol => this.quoteService.getAsset(symbol))
      .filter(asset => asset !== undefined) as Asset[];
  }

  private handleSearch(query: string) {
    this.searchQuery = query;
    if (query.length > 0) {
      this.searchResults = this.quoteService.searchAssets(query);
    } else {
      this.searchResults = [];
    }
  }

  private async handleAdd(symbol: string) {
    if (this.watchlistStore.has(symbol)) {
      return;
    }

    await this.watchlistStore.add(symbol);
    this.visible = false;

    if (this.onAdded) {
      this.onAdded();
    }
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#80000000')
          .onClick(() => {
            this.visible = false;
          })

        Column({ space: 4 }) {
          Row() {
            Text('Add Symbol')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .layoutWeight(1)
              .width('76.55vp')

            Text('✕')
              .fontSize(20)
              .fontColor('#B0B0B0')
              .onClick(() => {
                this.visible = false;
              })
          }
          .width('100%')
          .padding(2)

          TextInput({ placeholder: 'Search symbols...' })
            .width('90%')
            .height(28)
            .fontSize(11)
            .backgroundColor('#2A2A2A')
            .placeholderFont({
              size: '11fp'
            })
            .placeholderColor('#707070')
            .onChange((value: string) => {
              this.handleSearch(value);
            })

          Scroll() {
            Column({ space: 4 }) {
              if (this.searchQuery.length > 0) {
                if (this.searchResults.length > 0) {
                  ForEach(this.searchResults, (asset: Asset) => {
                    this.symbolItem(asset);
                  }, (item: string, index: number) => item)

                } else {
                  Text('No results found')
                    .fontSize(13)
                    .fontColor('#707070')
                    .margin({ top: 20 })
                }
              } else {
                Text('Popular')
                  .fontSize(12)
                  .fontColor('#B0B0B0')
                  .alignSelf(ItemAlign.Start)
                  .margin({ left: 12, top: 8 })

                ForEach(this.popularSymbols, (asset: Asset) => {
                  this.symbolItem(asset);
                }, (item: string, index: number) => item)
              }
            }
            .width('100%')

          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .padding({ bottom: '40fp' })

        }
        .width('75%')
        .height('90%')
        .backgroundColor('#1A1A1A')
        .borderRadius({ topLeft: 16, topRight: 16 })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  symbolItem(asset: Asset) {
    Row() {
      Column({ space: 2 }) {
        Text(asset.symbol)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text(asset.name)
          .fontSize(11)
          .fontColor('#B0B0B0')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.watchlistStore.has(asset.symbol)) {
        Text('✓ Added')
          .fontSize(12)
          .fontColor('#4A9EFF')
      } else {
        Text('+ Add')
          .fontSize(12)
          .fontColor('#4A9EFF')
      }
    }
    .width('100%')
    .padding(3)
    .backgroundColor('#2A2A2A')
    .borderRadius(6)
    .onClick(() => {
      this.handleAdd(asset.symbol);
    })
  }
}
