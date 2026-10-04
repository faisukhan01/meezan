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

class AccountDetailPage extends StatefulWidget {
  final Account account;
  const AccountDetailPage({super.key, required this.account});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  final TextEditingController _search = TextEditingController();
  String _filter = 'all'; // all | in | out

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final Account account = widget.account;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    List<Txn> txns = app.txnsFor(account.id);
    final String q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      txns = txns
          .where((Txn t) =>
              t.title.toLowerCase().contains(q) ||
              t.ref.toLowerCase().contains(q) ||
              t.channel.toLowerCase().contains(q))
          .toList();
    }
    if (_filter == 'in') {
      txns = txns.where((Txn t) => t.type == TxnType.credit).toList();
    } else if (_filter == 'out') {
      txns = txns.where((Txn t) => t.type == TxnType.debit).toList();
    }

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
          // ----- Search + filter chips (real-app statement controls) -----
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search transactions',
              prefixIcon: const Icon(Icons.search_rounded, color: MColors.subtle),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: MColors.subtle),
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Money In',
                selected: _filter == 'in',
                onTap: () => setState(() => _filter = 'in'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Money Out',
                selected: _filter == 'out',
                onTap: () => setState(() => _filter = 'out'),
              ),
              const Spacer(),
              Text(
                '${txns.length} txn${txns.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 11.5, color: MColors.subtle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? MColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: txns.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        q.isEmpty && _filter == 'all'
                            ? 'No transactions yet'
                            : 'No matching transactions',
                        style: const TextStyle(color: MColors.subtle),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? MColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? MColors.green : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : MColors.subtle,
          ),
        ),
      ),
    );
  }
}
