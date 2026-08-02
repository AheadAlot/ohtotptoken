import { TokenImporter } from './TokenImporter';
import { TokenConfig } from '../TokenConfig';

/**
 * URI 链接导入器
 *
 * 支持通过粘贴 otpauth:// URI 链接来导入令牌。
 * 注意：由于 CustomDialogController 需要组件上下文，
 * 实际的对话框创建和打开由 BackupAndMigrationSheet 组件负责。
 * 此类仅提供导入器的元数据（名称、图标、描述）。
 */
export class URIImporter implements TokenImporter {
  readonly id: string = 'uri';
  readonly name: ResourceStr = $r('app.string.importer_uri_name');
  readonly description: ResourceStr = $r('app.string.importer_uri_desc');
  readonly icon: Resource = $r('sys.symbol.link');

  /**
   * URI 导入的实际逻辑由 BackupAndMigrationSheet 组件处理
   * （因为 CustomDialogController 必须在组件上下文中创建）
   */
  import(uiContext: UIContext, onTokensImported: (tokens: Array<TokenConfig>) => void): void {
    // 不在此处实现，由 BackupAndMigrationSheet 的 onClick 按 importer.id === 'uri' 分发
  }
}
