import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _confirmLogout(BuildContext context) {
    final AppState app = context.read<AppState>();
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
            'Are you sure you want to log out of Meezan Mobile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              app.logout();
              Navigator.of(context, rootNavigator: true)
                  .pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (Route<dynamic> r) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Profile ----------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00543D), Color(0xFF003D2C)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: MColors.gold,
                  child: Text(
                    app.userName.isEmpty
                        ? 'U'
                        : app.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF053D23),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${app.userId} • ${app.maskedMobile}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const MeezanEmblem(size: 30),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _GroupCard(
            children: [
              _MenuTile(
                icon: Icons.credit_card_rounded,
                title: 'My Debit Cards',
                subtitle: 'Manage limits, block or unblock cards',
                onTap: () => showSnack(
                    context,
                    '2 debit cards linked • Meezan Visa Classic (demo)'),
              ),
              _MenuTile(
                icon: Icons.people_alt_rounded,
                title: 'Beneficiary Management',
                subtitle: 'Saved IBFT & Raast payees',
                onTap: () => showSnack(context,
                    '${app.beneficiaries.length} saved beneficiaries (demo).'),
              ),
              _MenuTile(
                icon: Icons.description_rounded,
                title: 'Statements & Certificates',
                subtitle: 'Account statements, tax certificates',
                onTap: () => showSnack(context,
                    'Request received — documents will be emailed (demo).'),
              ),
              _MenuTile(
                icon: Icons.menu_book_rounded,
                title: 'Cheque Book Requests',
                subtitle: 'Track and request cheque books',
                onTap: () => showSnack(
                    context, '1 active request • In process (demo)'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _GroupCard(
            children: [
              _MenuTile(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'Theme, security, notifications',
                onTap: () => _openSettings(context),
              ),
              _MenuTile(
                icon: Icons.favorite_rounded,
                title: 'About & Disclaimer',
                subtitle: 'Version 1.0.0 • Educational project',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _GroupCard(
            children: [
              _MenuTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'End this session',
                titleColor: MColors.danger,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Assalam-u-Alaikum — JazakAllah for banking with us.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.white38 : MColors.subtle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Unofficial educational UI clone • Mock data only',
              style: TextStyle(fontSize: 10.5, color: MColors.subtle),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Row(
          children: [
            MeezanEmblem(size: 26),
            SizedBox(width: 10),
            Text('About'),
          ],
        ),
        content: const Text(
          'Meezan Mobile — Educational UI Clone v1.0.0\n\n'
          'This app is an unofficial Flutter UI recreation made for learning '
          'purposes only. It is NOT affiliated with, endorsed by, or connected '
          'to Meezan Bank Limited. All balances, accounts and transactions are '
          'mock/demo data. Do not enter real banking credentials, and never '
          'use lookalike banking apps to deceive anyone.\n\n'
          'Built with Flutter + Provider.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings page
// ---------------------------------------------------------------------------

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Appearance'),
          _GroupCard(
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: app.themeMode,
                onChanged: (ThemeMode? v) => app.setThemeMode(v ?? ThemeMode.light),
                title: const Text('Light'),
                secondary: const Icon(Icons.light_mode_rounded,
                    color: MColors.goldDeep),
              ),
              Divider(
                  height: 1, indent: 16, color: Theme.of(context).dividerColor),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: app.themeMode,
                onChanged: (ThemeMode? v) => app.setThemeMode(v ?? ThemeMode.dark),
                title: const Text('Dark'),
                secondary: const Icon(Icons.dark_mode_rounded,
                    color: MColors.green),
              ),
              Divider(
                  height: 1, indent: 16, color: Theme.of(context).dividerColor),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: app.themeMode,
                onChanged: (ThemeMode? v) =>
                    app.setThemeMode(v ?? ThemeMode.system),
                title: const Text('System Default'),
                secondary: const Icon(Icons.settings_suggest_rounded,
                    color: MColors.subtle),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Security & Privacy'),
          _GroupCard(
            children: [
              SwitchListTile(
                value: app.biometricsEnabled,
                onChanged: app.setBiometrics,
                title: const Text('Biometric Login'),
                subtitle:
                    const Text('Fingerprint / face unlock on login screen'),
                secondary: const Icon(Icons.fingerprint_rounded,
                    color: MColors.green),
              ),
              Divider(
                  height: 1, indent: 16, color: Theme.of(context).dividerColor),
              SwitchListTile(
                value: app.balanceHidden,
                onChanged: (_) => app.toggleBalanceHidden(),
                title: const Text('Hide Balances'),
                subtitle: const Text('Mask amounts across the app'),
                secondary:
                    const Icon(Icons.visibility_off_rounded, color: MColors.subtle),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Notifications'),
          _GroupCard(
            children: [
              SwitchListTile(
                value: app.notificationsEnabled,
                onChanged: app.setNotifications,
                title: const Text('Push Notifications'),
                subtitle: const Text('Transaction alerts and offers'),
                secondary:
                    const Icon(Icons.notifications_rounded, color: MColors.goldDeep),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MColors.green.withOpacity(isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MColors.green.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: MColors.green, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Security tip: Meezan staff never ask for your MPIN or OTP. '
                    '(This is a demo app — no real security exists.)',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small building blocks
// ---------------------------------------------------------------------------

class _GroupCard extends StatelessWidget {
  final List<Widget> children;
  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, indent: 16, color: Theme.of(context).dividerColor),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: MColors.green.withOpacity(0.09),
        child: Icon(icon, size: 20, color: MColors.green),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: titleColor ?? (isDark ? Colors.white : MColors.ink),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: MColors.subtle),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: MColors.subtle),
    );
  }
}
