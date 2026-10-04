import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Accounts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? MColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total PKR Balance',
                        style: TextStyle(fontSize: 12, color: MColors.subtle),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        app.balanceHidden
                            ? 'PKR ••••••'
                            : money(app.totalPkrBalance),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: app.toggleBalanceHidden,
                  icon: Icon(
                    app.balanceHidden
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: MColors.subtle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...app.accounts.map(
            (Account a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AccountRow(account: a),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final Account account;
  const _AccountRow({required this.account});

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => AccountDetailPage(account: account)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? MColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            const MeezanEmblem(size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? Colors.white : MColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${account.type} • ${maskAccount(account.number)}',
                    style:
                        const TextStyle(fontSize: 12, color: MColors.subtle),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  app.balanceHidden
                      ? '${account.currency} ••••••'
                      : '${account.currency} ${money(account.balance, withSymbol: false)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: MColors.green,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: MColors.subtle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AccountDetailPage extends StatelessWidget {
  final Account account;
  const AccountDetailPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final List<Txn> txns = app.txnsFor(account.id);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(account.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalanceCard(account: account, compact: true),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? MColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                InfoRow(
                  label: 'IBAN',
                  value: account.iban,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: account.iban));
                    showSnack(context, 'IBAN copied to clipboard');
                  },
                ),
                Divider(color: Theme.of(context).dividerColor),
                InfoRow(label: 'Account No', value: account.number),
                Divider(color: Theme.of(context).dividerColor),
                InfoRow(label: 'Branch', value: account.branch),
                Divider(color: Theme.of(context).dividerColor),
                InfoRow(label: 'Currency', value: account.currency),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => showSnack(
                context, 'Statement emailed to your registered address (demo).'),
            child: const Text('Email Statement'),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Mini Statement'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? MColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: txns.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: MColors.subtle),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: txns.length,
                    itemBuilder: (BuildContext _, int i) => TxnTile(txn: txns[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
