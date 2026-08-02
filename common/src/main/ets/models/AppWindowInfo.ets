import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

@ObservedV2
export class AppWindowInfo {
  @Trace AvoidTopHeight: number = 0;
  @Trace AvoidBottomHeight: number = 0;
  @Trace WidthBreakpoint: WidthBreakpoint = 0;
  @Trace HeightBreakpoint: HeightBreakpoint = 0;
  @Trace Size: window.Size = { width: 0, height: 0 };
  @Trace ColorMode: ConfigurationConstant.ColorMode = -1;
  @Trace Context?: common.UIAbilityContext;
  @Trace uiContext?: UIContext;
  @Trace WindowClass?: window.Window;
}
