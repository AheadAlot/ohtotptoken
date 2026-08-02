import {
  common,
  AbilityConstant,
  UIAbility, Want, Configuration,
  ConfigurationConstant,
} from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { AppPreference, AppWindowInfo } from 'common';

const TAG: string = 'WearableEntry';

export default class EntryAbility extends UIAbility {
  private uiContext?: UIContext;
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let win: AppWindowInfo = AppStorageV2.connect(AppWindowInfo) as AppWindowInfo;
    win.WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    win.HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
    win.Size = windowSize;
  };

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate("appContext", this.context);
    hilog.info(0x0000, TAG, 'Ability onCreate');
  }

  onDestroy(): void {
    AppPreference.saveSettings();
    hilog.info(0x0000, TAG, 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      let win: AppWindowInfo = AppStorageV2.connect(AppWindowInfo, () => new AppWindowInfo())!;
      win.ColorMode = this.context.config.colorMode ?? -1;
      win.Context = this.context;

      await AppPreference.loadSettings();

      windowStage.loadContent('pages/ArcTokenListPage', (err) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }

        let windowClass: window.Window = windowStage.getMainWindowSync();
        this.uiContext = windowClass.getUIContext();
        win.uiContext = this.uiContext;
        win.WindowClass = windowClass;

        windowClass.setWindowLayoutFullScreen(true);

        const avoidAreaTop = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        const avoidAreaBottom = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        win.AvoidTopHeight = this.uiContext!.px2vp(avoidAreaBottom.topRect.height);
        win.AvoidBottomHeight = this.uiContext!.px2vp(avoidAreaTop.bottomRect.height);

        windowClass.on('avoidAreaChange', (data) => {
          if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
            win.AvoidBottomHeight = this.uiContext!.px2vp(data.area.bottomRect.height);
          }
          if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
            win.AvoidTopHeight = this.uiContext!.px2vp(data.area.topRect.height);
          }
        });

        win.Size = windowClass.getWindowProperties().windowRect;
        win.WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
        win.HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
        windowClass.on('windowSizeChange', this.onWindowSizeChange);

        hilog.info(0x0000, TAG, 'Succeeded in loading the content.');
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `onWindowStageCreate: ${err}`);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    let win: AppWindowInfo = AppStorageV2.connect(AppWindowInfo) as AppWindowInfo;
    win.ColorMode = newConfig.colorMode ?? -1;
  }
}
