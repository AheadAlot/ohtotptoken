import { TokenImporter } from './TokenImporter';
import { TokenConfig, otpType } from '../TokenConfig';
import { showSelectFilePicker, readFileContent } from '../FileUtils';
import { showSnackBar, SnackBarNotifyType } from '../HdsSnackBarUtils';
import { base32Decode } from '../TokenUtils';
import { HMACAlgorithm } from '../TokenUtils';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TwoFAImporter';
/** "2FA验证器" 导出文件的魔数，用于格式校验 */
const MAGIC_TWOFA = 1131796;

/** "2FA验证器" 导出文件中的原始令牌结构 */
interface TwoFATokenRaw {
  id: string;
  span: number;
  rank: number;
  groupId: string;
  createdAt: number;
  updatedAt: number;
  type: number;
  issuer: string;
  label: string;
  secret: string;
  algorithm: string;
  digits: number;
}

/** "2FA验证器" 导出文件的顶层结构 */
interface TwoFABackup {
  magic: number;
  tokens: TwoFATokenRaw[];
  groups: Object[];
  appVersionCode: number;
  appVersionName: string;
  appOrigin: string;
  tokensEncrypted: string;
  reference: string;
  updatedAt: number;
}

/**
 * "2FA验证器" APP 导入器
 *
 * 支持导入来源：2FA验证器 (HarmonyOS) 导出的 .json 备份文件
 * 文件格式：Base32 编码的 JSON，包含令牌数组
 * 加密检测：tokensEncrypted 非空时提示暂不支持
 */
export class TwoFAImporter implements TokenImporter {
  readonly id: string = 'twofa';
  readonly name: ResourceStr = $r('app.string.importer_twofa_name');
  readonly description: ResourceStr = $r('app.string.importer_twofa_desc');
  readonly icon: Resource = $r('sys.symbol.transfer');

  import(uiContext: UIContext, onTokensImported: (tokens: Array<TokenConfig>) => void): void {
    showSelectFilePicker(1, ['JSON|.json']).then((uris: Array<string>) => {
      if (!uris || uris.length === 0 || !uris[0]) {
        return; // 用户取消文件选择
      }
      this.parseFile(uris[0], onTokensImported);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `File picker failed: ${err.message}`);
      showSnackBar($r('app.string.importer_twofa_decode_failed'), SnackBarNotifyType.ERROR);
    });
  }

  /**
   * 解析 2FA验证器 导出的 .json 备份文件
   * 流程：Base32 解码 → JSON 解析 → 魔数校验 → 加密检测 → 字段映射
   */
  private async parseFile(uri: string, onTokensImported: (tokens: Array<TokenConfig>) => void): Promise<void> {
    try {
      const content = await readFileContent(uri);
      const trimmed = content.trim();
      if (trimmed.length === 0) {
        showSnackBar($r('app.string.importer_twofa_empty'), SnackBarNotifyType.WARNING);
        return;
      }

      // Base32 解码
      const decoded = base32Decode(trimmed);

      // Uint8Array → UTF-8 字符串
      const decoder = new util.TextDecoder('utf-8');
      const jsonStr = decoder.decodeWithStream(decoded, { stream: false });

      const backup: TwoFABackup = JSON.parse(jsonStr);

      // 魔数校验
      if (!backup || backup.magic !== MAGIC_TWOFA) {
        showSnackBar($r('app.string.importer_twofa_invalid_file'), SnackBarNotifyType.ERROR);
        return;
      }

      // 加密检测
      if (backup.tokensEncrypted && backup.tokensEncrypted.length > 0) {
        showSnackBar($r('app.string.importer_twofa_encrypted_unsupported'), SnackBarNotifyType.WARNING);
        return;
      }

      const rawTokens = backup.tokens || [];
      if (rawTokens.length === 0) {
        showSnackBar($r('app.string.importer_twofa_empty'), SnackBarNotifyType.WARNING);
        return;
      }

      // 字段映射：TwoFATokenRaw → TokenConfig
      const SUPPORTED_ALGOS: string[] = ['SHA1', 'SHA224', 'SHA256', 'SHA384', 'SHA512', 'SM3', 'MD5'];
      const tokens = rawTokens
        .filter((raw: TwoFATokenRaw): boolean => raw !== null && raw.secret !== null && raw.secret.length > 0)
        .map((raw: TwoFATokenRaw): TokenConfig => {
          let token = new TokenConfig();
          token.TokenSecret = raw.secret;
          token.TokenIssuer = raw.issuer || 'Unknown';
          token.TokenName = raw.label || 'Unknown';
          const algo = (raw.algorithm || 'SHA1').toUpperCase();
          token.TokenAlgorithm = (SUPPORTED_ALGOS.includes(algo) ? algo : 'SHA1') as HMACAlgorithm;
          token.TokenDigits = raw.digits || 6;
          token.TokenPeriod = raw.span || 30;
          token.TokenType = raw.type === 0 ? otpType.TOTP : otpType.HOTP;
          token.TokenUUID = util.generateRandomUUID();
          return token;
        });

      onTokensImported(tokens);
    } catch (err) {
      const error = err as Error;
      hilog.error(0x0000, TAG, `Parse failed: ${error.message}`);
      showSnackBar($r('app.string.importer_twofa_decode_failed'), SnackBarNotifyType.ERROR);
    }
  }
}
