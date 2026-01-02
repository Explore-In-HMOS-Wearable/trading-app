/**
 * SectionHeader - Simple section header
 */

@Component
export struct SectionHeader {
  @Prop title: string;
  @Prop rightText?: string;
  onRightTap?: () => void;

  build() {
    Row() {
      Text(this.title)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#B0B0B0')
        .layoutWeight(1)
      
      if (this.rightText) {
        Text(this.rightText)
          .fontSize(12)
          .fontColor('#4A9EFF')
          .onClick(() => {
            if (this.onRightTap) {
              this.onRightTap();
            }
          })
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 4 })
  }
}
