import { TokenImporter } from './TokenImporter';
import { TokenConfig } from '../TokenConfig';
import { URIConfigDialog } from '../../dialogs/URIConfigDialog';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'URIImporter';

/**
 * URI 链接导入器
 *
 * 支持通过粘贴 otpauth:// URI 链接来导入令牌。
 * 复用现有 URIConfigDialog 的解析逻辑，与原主界面"输入URI链接"功能一致。
 * 迁移后，主界面添加按钮菜单中不再保留此入口。
 */
export class URIImporter implements TokenImporter {
  readonly id: string = 'uri';
  readonly name: ResourceStr = $r('app.string.importer_uri_name');
  readonly description: ResourceStr = $r('app.string.importer_uri_desc');
  readonly icon: Resource = $r('sys.symbol.link');

  import(uiContext: UIContext, onTokensImported: (tokens: Array<TokenConfig>) => void): void {
    const dialog = new CustomDialogController({
      builder: URIConfigDialog({
        confirm: async (tokens: Array<TokenConfig>): Promise<boolean> => {
          onTokensImported(tokens);
          return true; // 通知对话框关闭
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      customStyle: false,
      cornerRadius: 10,
    });
    dialog.open();
  }
}
