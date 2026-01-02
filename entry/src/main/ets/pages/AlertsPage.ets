/**
 * AlertsPage - Manage price alerts with Navigation component
 */

import { PriceAlert } from '../model/PriceAlert';
import { AlertStore, AlertTriggerHistory } from '../store/AlertStore';
import { AlertEngine, AlertTriggerEvent } from '../services/AlertEngine';
import { Formatters } from '../model/Formatters';
import { SectionHeader } from '../components/SectionHeader';
import { EditAlertSheet } from '../components/EditAlertSheet';
import { InAppBanner } from '../components/InAppBanner';

@Builder
export function AlertsPageBuilder(name: string, param: Object) {
  AlertsPage()
}

@Component
export struct AlertsPage {
  pageInfos: NavPathStack = new NavPathStack();
  @State alerts: PriceAlert[] = [];
  @State recentTriggers: AlertTriggerHistory[] = [];
  @State showEditSheet: boolean = false;
  @State showBanner: boolean = false;
  @State bannerMessage: string = '';
  private alertStore: AlertStore = AlertStore.getInstance();
  private alertEngine: AlertEngine = AlertEngine.getInstance();
  private unsubscribe?: () => void;

  aboutToAppear() {
    this.alertEngine.start();
    this.loadAlerts();

    this.unsubscribe = this.alertEngine.onTrigger((event: AlertTriggerEvent) => {
      this.handleAlertTrigger(event);
    });
  }

  aboutToDisappear() {
    if (this.unsubscribe) {
      this.unsubscribe();
    }
  }

  private loadAlerts() {
    this.alerts = this.alertStore.getAlerts();
    this.recentTriggers = this.alertStore.getRecentTriggers(5);
  }

  private handleAlertTrigger(event: AlertTriggerEvent) {
    const conditionText = event.alert.condition === 'ABOVE' ? 'above' : 'below';
    this.bannerMessage = `${event.alert.symbol} is ${conditionText} ${Formatters.formatPriceWithSymbol(event.alert.target)}`;
    this.showBanner = true;
    this.loadAlerts();
  }

  private async handleToggle(id: string) {
    await this.alertStore.toggleEnabled(id);
    this.loadAlerts();
  }

  private async handleDelete(id: string) {
    await this.alertStore.remove(id);
    this.loadAlerts();
  }

  private getConditionSymbol(condition: string): string {
    return condition === 'ABOVE' ? '≥' : '≤';
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

            Text('Price Alerts')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .layoutWeight(1)
              .margin({ left: 0 })

            Text('+ New')
              .fontSize(14)
              .fontColor('#4A9EFF')
              .onClick(() => {
                this.showEditSheet = true;
              })

          }
          .width('100%')
          .padding({left:'40fp',right: '40fp'})
          .backgroundColor('#1A1A1A')
          .height('65fp')

          Scroll() {
            Column({ space: 16 }) {
              if (this.alerts.length > 0) {
                Column({ space: 8 }) {
                  SectionHeader({ title: `${this.alerts.length} Alerts` })

                  ForEach(this.alerts, (alert: PriceAlert) => {
                    Row() {
                      Column({ space: 4 }) {
                        Text(alert.symbol)
                          .fontSize(15)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#FFFFFF')

                        Text(`${this.getConditionSymbol(alert.condition)} ${Formatters.formatPriceWithSymbol(alert.target)}`)
                          .fontSize(12)
                          .fontColor('#B0B0B0')

                        if (alert.lastTriggeredAt) {
                          Text(`Triggered ${Formatters.formatRelativeTime(alert.lastTriggeredAt)}`)
                            .fontSize(10)
                            .fontColor('#FFA726')
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Row({ space: 8 }) {
                        Toggle({ type: ToggleType.Switch, isOn: alert.enabled })
                          .onChange((isOn: boolean) => {
                            this.handleToggle(alert.id);
                          })

                        Button('✕')
                          .width(32)
                          .height(32)
                          .fontSize(14)
                          .backgroundColor('#FF3D00')
                          .fontColor('#FFFFFF')
                          .borderRadius(6)
                          .onClick(() => {
                            this.handleDelete(alert.id);
                          })
                      }
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#1E1E1E')
                    .borderRadius(8)
                  }, (item: string, index: number) => item)
                }
                .width('90%')
              } else {
                Column({ space: 12 }) {
                  Text('🔔')
                    .fontSize(40)

                  Text('No alerts yet')
                    .fontSize(14)
                    .fontColor('#B0B0B0')
                  
                  Button('Create Alert')
                    .width(140)
                    .height(42)
                    .fontSize(16)
                    .backgroundColor('#4A9EFF')
                    .fontColor('#FFFFFF')
                    .borderRadius(8)
                    .onClick(() => {
                      this.showEditSheet = true;
                    })
                }
                .width('100%')
              }

              if (this.recentTriggers.length > 0) {
                Column({ space: 8 }) {
                  SectionHeader({ title: 'Recent Triggers' })

                  ForEach(this.recentTriggers, (item: AlertTriggerHistory) => {
                    Row() {
                      Column({ space: 2 }) {
                        Text(item.alert.symbol)
                          .fontSize(13)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#FFFFFF')

                        Text(`${this.getConditionSymbol(item.alert.condition)} ${Formatters.formatPriceWithSymbol(item.alert.target)}`)
                          .fontSize(11)
                          .fontColor('#B0B0B0')
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Text(Formatters.formatRelativeTime(item.timestamp))
                        .fontSize(11)
                        .fontColor('#FFA726')
                    }
                    .width('100%')
                    .padding(10)
                    .backgroundColor('#2A2A2A')
                    .borderRadius(6)
                  }, (item: string, index: number) => item)
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding({ top: 5, bottom: 50 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#121212')

        EditAlertSheet({
          visible: $showEditSheet,
          onSaved: () => {
            this.loadAlerts();
          }
        })

        InAppBanner({
          visible: $showBanner,
          message: this.bannerMessage
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
