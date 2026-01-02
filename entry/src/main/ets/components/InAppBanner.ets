/**
 * InAppBanner - In-app notification banner
 */

@Component
export struct InAppBanner {
  @Link visible: boolean;
  @Prop message: string;
  @Prop duration: number = 3000;
  private timerId: number = -1;

  aboutToAppear() {
    if (this.visible) {
      this.startTimer();
    }
  }

  aboutToDisappear() {
    this.clearTimer();
  }

  private startTimer() {
    this.clearTimer();
    this.timerId = setTimeout(() => {
      this.visible = false;
    }, this.duration);
  }

  private clearTimer() {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Top }) {
        Row() {
          Text(this.message)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding(12)
        .backgroundColor('#323232')
        .borderRadius(8)
        .margin({ top: 12, left: 12, right: 12 })
        .shadow({ radius: 8, color: '#40000000' })
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
    }
  }
}
