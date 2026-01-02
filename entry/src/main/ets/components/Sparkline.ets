/**
 * Sparkline - Lightweight sparkline chart component
 */

@Component
export struct Sparkline {
  @Prop data: number[];
  @Prop canvasWidth: number = 150;
  @Prop canvasHeight: number = 40;
  @Prop color: string = '#4A9EFF';
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.context)
      .width(this.canvasWidth)
      .height(this.canvasHeight)
      .onReady(() => {
        this.drawSparkline();
      })
  }

  private drawSparkline() {
    if (this.data.length < 2) {return;}

    const ctx = this.context;
    const width = this.canvasWidth;
    const height = this.canvasHeight;
    const padding = 4;

    ctx.clearRect(0, 0, width, height);

    const min = Math.min(...this.data);
    const max = Math.max(...this.data);
    const range = max - min || 1;

    ctx.strokeStyle = this.color;
    ctx.lineWidth = 2;
    ctx.beginPath();

    this.data.forEach((value, index) => {
      const x = padding + (index / (this.data.length - 1)) * (width - 2 * padding);
      const y = height - padding - ((value - min) / range) * (height - 2 * padding);

      if (index === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    });

    ctx.stroke();
  }
}
