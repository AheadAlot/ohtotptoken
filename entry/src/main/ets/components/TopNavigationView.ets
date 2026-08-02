import { CommonConstants } from 'common';

@Builder
function DefaultBuilder() {
}

@ComponentV2
export struct TopNavigationView {
  @Param title?: ResourceStr = '';
  @BuilderParam menuView?: CustomBuilder = DefaultBuilder;
  @Param onBackClick?: Function = () => {};

  build() {
    Row() {
      if (this.onBackClick) {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(30)
          .fontColor([$r('app.color.str_main')])
          .width($r('app.float.interactive_button_height'))
          .height($r('app.float.interactive_button_height'))
          .margin({ right: $r('app.float.lg_padding_margin') })
          .onClick(() => this.onBackClick?.())
      }

      Text(this.title)
        .fontSize($r('app.float.title_text_size'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .layoutWeight(1)

      Row() {
        if (this.menuView) {
          this.menuView()
        }
      }
    }
    .backdropBlur(10)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.navigation_height'))
    .padding({
      left: $r('app.float.xxl_padding_margin'),
      right: $r('app.float.xxl_padding_margin')
    })
  }
}


