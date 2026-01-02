/**
 * SyncStatusSheet - Shows sync progress and results
 */

import { SyncState } from '../model/Types';
import { MockSyncService, SyncSession } from '../services/MockSyncService';
import { WatchlistStore } from '../store/WatchlistStore';

@Component
export struct SyncStatusSheet {
  @Link visible: boolean;
  @State syncState: SyncState = 'IDLE';
  @State message: string = '';
  @State remoteSymbols: string[] = [];
  private syncService: MockSyncService = MockSyncService.getInstance();
  private watchlistStore: WatchlistStore = WatchlistStore.getInstance();
  onCompleted?: () => void;

  aboutToAppear() {
    if (this.visible) {
      this.startSync();
    }
  }

  private async startSync() {
    this.syncState = 'REQUESTED';
    this.message = 'Starting sync...';

    try {
      const session: SyncSession = await this.syncService.requestSync();
      this.syncState = session.state;
      this.message = session.message;
      this.remoteSymbols = session.remoteSymbols;

      if (session.state === 'APPROVED' && session.remoteSymbols.length > 0) {
        await this.watchlistStore.addMultiple(session.remoteSymbols);
        if (this.onCompleted) {
          this.onCompleted();
        }
      }
    } catch (error) {
      let syncState = this.syncState
      syncState = 'TIMEOUT';
      this.syncState = syncState

      let message = this.message
      message = 'Sync failed. Please try again.'
      this.message = message
    }
  }

  private getStateIcon(): string {
    switch (this.syncState) {
      case 'REQUESTED':
      case 'WAITING_APPROVAL':
        return '⏳';
      case 'APPROVED':
        return '✓';
      case 'REJECTED':
      case 'TIMEOUT':
        return '✕';
      default:
        return '';
    }
  }

  private getStateColor(): string {
    switch (this.syncState) {
      case 'APPROVED':
        return '#00C853';
      case 'REJECTED':
      case 'TIMEOUT':
        return '#FF3D00';
      default:
        return '#4A9EFF';
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
            if (this.syncState === 'APPROVED' || this.syncState === 'REJECTED' || this.syncState === 'TIMEOUT') {
              this.visible = false;
            }
          })

        Column({ space: 20 }) {
          Row() {
            Text('Sync with Phone')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .layoutWeight(1)

            if (this.syncState === 'APPROVED' || this.syncState === 'REJECTED' || this.syncState === 'TIMEOUT') {
              Text('✕')
                .fontSize(20)
                .fontColor('#B0B0B0')
                .onClick(() => {
                  this.visible = false;
                })
            }
          }
          .width('100%')
          .padding(12)

          Column({ space: 12 }) {
            Text(this.getStateIcon())
              .fontSize(48)
              .fontColor(this.getStateColor())

            Text(this.message)
              .fontSize(13)
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center)
              .maxLines(3)

            if (this.syncState === 'APPROVED' && this.remoteSymbols.length > 0) {
              Column({ space: 6 }) {
                Text('Added symbols:')
                  .fontSize(11)
                  .fontColor('#B0B0B0')

                Text(this.remoteSymbols.join(', '))
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .textAlign(TextAlign.Center)
              }
              .margin({ top: 8 })
            }

            if (this.syncState === 'REJECTED' || this.syncState === 'TIMEOUT') {
              Button('Try Again')
                .width('80%')
                .height(40)
                .fontSize(14)
                .backgroundColor('#4A9EFF')
                .fontColor('#FFFFFF')
                .borderRadius(8)
                .margin({ top: 12 })
                .onClick(() => {
                  this.startSync();
                })
            }
          }
          .width('100%')
          .padding({ top: 20, bottom: 30 })
        }
        .width('100%')
        .backgroundColor('#1A1A1A')
        .borderRadius({ topLeft: 16, topRight: 16 })
      }
      .width('100%')
      .height('100%')
    }
  }
}
