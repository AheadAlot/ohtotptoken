
import { SETTING_DIVIDER_INSET_LEFT, SETTING_DIVIDER_INSET_RIGHT } from './SettingStyle';

@Preview
@ComponentV2
export struct SubItemDivider {
  /** 左侧缩进，默认 16 与行内文字对齐；特殊布局可由调用方覆盖 */
  @Param insetLeft: number = SETTING_DIVIDER_INSET_LEFT;
  @Param insetRight: number = SETTING_DIVIDER_INSET_RIGHT;

  build() {
    Divider()
      .strokeWidth(0.5)
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({ left: this.insetLeft, right: this.insetRight })
  }
}
