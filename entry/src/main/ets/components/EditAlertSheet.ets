/**
 * EditAlertSheet - Sheet for creating/editing price alerts
 */

import { PriceAlert } from '../model/PriceAlert';
import { AlertCondition } from '../model/Types';
import { AlertStore } from '../store/AlertStore';
import { WatchlistStore } from '../store/WatchlistStore';
import { QuoteService } from '../services/QuoteService';
import { Formatters } from '../model/Formatters';

@Component
export struct EditAlertSheet {
  @Link visible: boolean;
  @Prop alertId?: string;
  @Prop prefilledSymbol?: string;
  @State selectedSymbol: string = '';
  @State condition: AlertCondition = 'ABOVE';
  @State targetPrice: string = '';
  @State alertEnabled: boolean = true;
  private alertStore: AlertStore = AlertStore.getInstance();
  private watchlistStore: WatchlistStore = WatchlistStore.getInstance();
  private quoteService: QuoteService = QuoteService.getInstance();
  onSaved?: () => void;

  aboutToAppear() {
    if (this.alertId) {
      const alert = this.alertStore.getAlert(this.alertId);
      if (alert) {
        this.selectedSymbol = alert.symbol;
        this.condition = alert.condition;
        this.targetPrice = alert.target.toString();
        this.alertEnabled = alert.enabled;
      }
    } else {
      if (this.prefilledSymbol) {
        this.selectedSymbol = this.prefilledSymbol;
        const asset = this.quoteService.getAsset(this.prefilledSymbol);
        if (asset) {
          this.targetPrice = asset.price.toFixed(2);
        }
      }
    }
  }

  private async handleSave() {
    if (!this.selectedSymbol || !this.targetPrice) {
      return;
    }

    const target = parseFloat(this.targetPrice);
    if (isNaN(target)) {
      return;
    }

    let alert: PriceAlert;
    if (this.alertId) {
      alert = new PriceAlert(this.alertId, this.selectedSymbol, this.condition, target, this.alertEnabled);
      const existing = this.alertStore.getAlert(this.alertId);
      if (existing) {
        alert.triggeredCount = existing.triggeredCount;
        alert.lastTriggeredAt = existing.lastTriggeredAt;
      }
    } else {
      const id = Formatters.generateId();
      alert = new PriceAlert(id, this.selectedSymbol, this.condition, target, this.alertEnabled);
    }

    await this.alertStore.upsert(alert);
    this.visible = false;

    if (this.onSaved) {
      this.onSaved();
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

        Column({ space: 12 }) {
          Row() {
            Text(this.alertId ? 'Edit Alert' : 'New Alert')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .layoutWeight(1)

            Text('✕')
              .fontSize(20)
              .fontColor('#B0B0B0')
              .onClick(() => {
                this.visible = false;
              })
          }
          .width('100%')
          .padding(5)

          Scroll() {
            Column({ space: 6 }) {
              Column({ space: 6 }) {
                Text('Symbol')
                  .fontSize(12)
                  .fontColor('#B0B0B0')
                  .alignSelf(ItemAlign.Start)

                if (!this.alertId && !this.prefilledSymbol) {
                  Scroll() {
                    Row({ space: 6 }) {
                      ForEach(this.watchlistStore.getSymbols(), (symbol: string) => {
                        Text(symbol)
                          .fontSize(13)
                          .fontColor(this.selectedSymbol === symbol ? '#1A1A1A' : '#FFFFFF')
                          .padding({
                            left: 10,
                            right: 10,
                            top: 6,
                            bottom: 6
                          })
                          .backgroundColor(this.selectedSymbol === symbol ? '#4A9EFF' : '#2A2A2A')
                          .borderRadius(6)
                          .onClick(() => {
                            this.selectedSymbol = symbol;
                            const asset = this.quoteService.getAsset(symbol);
                            if (asset) {
                              this.targetPrice = asset.price.toFixed(2);
                            }
                          })
                      }, (item: string, index: number) => item)
                    }
                  }
                  .scrollable(ScrollDirection.Horizontal)
                  .scrollBar(BarState.Off)
                } else {
                  Text(this.selectedSymbol)
                    .fontSize(15)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                }
              }
              .width('100%')

              Column({ space: 6 }) {
                Text('Condition')
                  .fontSize(12)
                  .fontColor('#B0B0B0')
                  .alignSelf(ItemAlign.Start)

                Row({ space: 3 }) {
                  this.conditionButton('ABOVE', '≥')
                  this.conditionButton('BELOW', '≤')
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')

              Column({ space: 8 }) {
                Text('Target Price')
                  .fontSize(12)
                  .fontColor('#B0B0B0')
                  .alignSelf(ItemAlign.Start)

                TextInput({ text: this.targetPrice })
                  .width('90%')
                  .height(40)
                  .fontSize(14)
                  .type(InputType.Number)
                  .backgroundColor('#2A2A2A')
                  .onChange((value: string) => {
                    this.targetPrice = value;
                  })
              }
              .width('100%')
              .margin({ top: '5fp' })

              Row() {
                Text('Enabled')
                  .fontSize(13)
                  .fontColor('#FFFFFF')
                  .layoutWeight(1)

                Toggle({ type: ToggleType.Switch, isOn: this.alertEnabled })
                  .onChange((isOn: boolean) => {
                    this.alertEnabled = isOn;
                  })
              }
              .width('90%')
              .padding(5)
              .backgroundColor('#2A2A2A')
              .borderRadius(8)
              .margin({ top: '5fp' })

              Button('Save Alert')
                .width('90%')
                .height(44)
                .fontSize(15)
                .backgroundColor('#4A9EFF')
                .fontColor('#FFFFFF')
                .borderRadius(8)
                .onClick(() => {
                  this.handleSave();
                })
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ bottom: 32, left: '15fp', right: '15fp' })

          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('85%')
        .height('80%')
        .backgroundColor('#1A1A1A')
        .borderRadius({ topLeft: 16, topRight: 16 })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  conditionButton(value: AlertCondition, symbol: string) {
    Text(`${symbol} ${value}`)
      .fontSize(12)
      .fontColor(this.condition === value ? '#1A1A1A' : '#FFFFFF')
      .padding({
        left: 16,
        right: 16,
        top: 10,
        bottom: 10
      })
      .backgroundColor(this.condition === value ? '#4A9EFF' : '#2A2A2A')
      .borderRadius(8)
      .onClick(() => {
        this.condition = value;
      })
  }
}
