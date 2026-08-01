/**
 * Centralized font family constants.
 *
 * OTP/TOTP codes only ever contain ASCII characters (digits 0-9, and for the
 * Steam variant the ASCII base-26 alphabet), so the generic 'monospace'
 * family renders identically across all locales. Keeping it as a named
 * constant gives a single source of truth for all code-display sites.
 */
export class AppFonts {
  static readonly CODE_FONT: string = 'monospace';
}
