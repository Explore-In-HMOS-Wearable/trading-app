/**
 * QuoteRow - Reusable component for displaying asset quotes
 */

import { Asset } from '../model/Asset';
import { Formatters } from '../model/Formatters';

@Component
export struct QuoteRow {
  @Prop asset: Asset;
  onTap?: () => void;

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.asset.symbol)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text(this.asset.name)
          .fontSize(11)
          .fontColor('#B0B0B0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column({ space: 2 }) {
        Text(Formatters.formatPriceWithSymbol(this.asset.price))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')

        Text(Formatters.formatChange(this.asset.changePct))
          .fontSize(12)
          .fontColor(Formatters.formatChangeColor(this.asset.changePct))
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      top: 10,
      bottom: 10
    })
    .backgroundColor('#1E1E1E')
    .borderRadius(8)
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }
}
