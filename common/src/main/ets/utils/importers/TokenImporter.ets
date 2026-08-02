import { TokenConfig } from '../TokenConfig';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TwoFAImporter } from './TwoFAImporter';
import { URIImporter } from './URIImporter';

/**
 * 令牌导入器接口
 * 每个第三方验证器 APP 对应一个实现，统一注册到 TokenImporterRegistry。
 * 新增导入器只需实现此接口并注册即可，UI 层无需修改。
 */
export interface TokenImporter {
  /** 唯一标识（如 'twofa'），用于注册表索引 */
  readonly id: string;
  /** 列表显示名称（如 '2FA验证器'），支持 $r() 资源引用 */
  readonly name: ResourceStr;
  /** 简短描述（如 '导入 .json 备份文件'），支持 $r() 资源引用 */
  readonly description: ResourceStr;
  /** 列表项图标，支持 $r('sys.symbol.xxx') */
  readonly icon: Resource;

  /**
   * 启动导入流程
   * @param uiContext - UIContext，用于弹窗或错误提示
   * @param onTokensImported - 解析成功后的回调，传入 TokenConfig 数组
   */
  import(uiContext: UIContext, onTokensImported: (tokens: Array<TokenConfig>) => void): void;
}

/**
 * 导入器注册表（单例模式）
 *
 * 使用方式：
 * 1. 应用启动时调用 TokenImporterRegistry.getInstance().init()
 * 2. UI 层通过 getAll() 获取所有已注册导入器并渲染列表
 * 3. 新增导入器：在 init() 中加一行 register() 即可
 */
export class TokenImporterRegistry {
  private static instance: TokenImporterRegistry;
  private importers: Map<string, TokenImporter> = new Map();
  private initialized: boolean = false;

  static getInstance(): TokenImporterRegistry {
    if (!TokenImporterRegistry.instance) {
      TokenImporterRegistry.instance = new TokenImporterRegistry();
    }
    return TokenImporterRegistry.instance;
  }

  /** 注册一个导入器 */
  register(importer: TokenImporter): void {
    if (this.importers.has(importer.id)) {
      hilog.warn(0x0000, 'TokenImporterRegistry',
        `Importer '${importer.id}' already registered, overwriting.`);
    }
    this.importers.set(importer.id, importer);
  }

  /** 获取所有已注册导入器（按注册顺序） */
  getAll(): TokenImporter[] {
    return Array.from(this.importers.values());
  }

  /**
   * 初始化内置导入器
   * 在此处注册所有导入器，新增导入器只需加一行 register()
   */
  init(): void {
    if (this.initialized) {
      return;
    }
    this.initialized = true;
    this.register(new TwoFAImporter());
    this.register(new URIImporter());
    // 后续扩展点：
    // this.register(new GoogleAuthImporter());
    // this.register(new MicrosoftAuthImporter());
  }
}
