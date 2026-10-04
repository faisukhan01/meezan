import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class PaymentsScreen extends StatefulWidget {
  final String initialSection; // '' | 'topup'
  const PaymentsScreen({super.key, this.initialSection = ''});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 2, vsync: this, initialIndex: widget.initialSection == 'topup' ? 1 : 0);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: MColors.gold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: const [Tab(text: 'Bill Payments'), Tab(text: 'Mobile Top-up')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_BillSection(), _TopUpSection()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bills
// ---------------------------------------------------------------------------

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Electricity':
      return Icons.bolt_rounded;
    case 'Gas':
      return Icons.local_fire_department_rounded;
    case 'Water':
      return Icons.water_drop_rounded;
    case 'Internet':
      return Icons.wifi_rounded;
    case 'Telephone':
      return Icons.call_rounded;
    case 'Education':
      return Icons.school_rounded;
    case 'Donations':
      return Icons.volunteer_activism_rounded;
    case 'Credit Card':
      return Icons.credit_card_rounded;
    default:
      return Icons.receipt_rounded;
  }
}

class _BillSection extends StatelessWidget {
  const _BillSection();

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final Map<String, List<Biller>> byCategory = <String, List<Biller>>{};
    for (final Biller b in MockData.billers) {
      byCategory.putIfAbsent(b.category, () => <Biller>[]).add(b);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          childAspectRatio: 0.78,
          children: byCategory.keys
              .map(
                (String c) => QuickAction(
                  icon: _categoryIcon(c),
                  label: c,
                  onTap: () => _openCategory(context, c, byCategory[c]!),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        const SectionHeader(title: 'Frequently Paid'),
        ...app.recentTxns
            .where((Txn t) => t.channel == 'Bill Payment')
            .take(4)
            .map((Txn t) => TxnTile(txn: t)),
      ],
    );
  }

  void _openCategory(BuildContext context, String category, List<Biller> billers) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            ...billers.map(
              (Biller b) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: MColors.green.withOpacity(0.09),
                  child: Icon(_categoryIcon(category),
                      color: MColors.green, size: 20),
                ),
                title: Text(b.company,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openBillForm(context, b);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBillForm(BuildContext context, Biller biller) {
    final TextEditingController consumer = TextEditingController();
    final TextEditingController amount = TextEditingController();
    final AppState app = context.read<AppState>();
    String fromId = app.selectedAccount.currency == 'PKR'
        ? app.selectedAccount.id
        : app.accounts.first.id;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: StatefulBuilder(
            builder: (BuildContext sctx, void Function(void Function()) ss) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    biller.company,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(biller.category,
                      style:
                          const TextStyle(fontSize: 12.5, color: MColors.subtle)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: consumer,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Consumer / Reference Number'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration:
                        const InputDecoration(labelText: 'Amount (PKR)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: fromId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'From Account'),
                    items: app.accounts
                        .where((Account a) => a.currency == 'PKR')
                        .map((Account a) => DropdownMenuItem<String>(
                              value: a.id,
                              child: Text('${a.title} — ${maskAccount(a.number)}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (String? v) => ss(() => fromId = v ?? fromId),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () {
                      final double amt =
                          double.tryParse(amount.text.trim()) ?? 0;
                      if (consumer.text.trim().length < 5 || amt <= 0) {
                        showSnack(ctx,
                            'Enter a valid consumer number and amount.',
                            error: true);
                        return;
                      }
                      final BillDraft draft = BillDraft(
                        fromAccountId: fromId,
                        company: biller.company,
                        category: biller.category,
                        consumerNo: consumer.text.trim(),
                        amount: amt,
                      );
                      Navigator.of(ctx).pop();
                      _confirmBill(context, draft);
                    },
                    child: const Text('FETCH & PAY (DEMO)'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmBill(BuildContext context, BillDraft draft) {
    final AppState app = context.read<AppState>();
    final Account from = app.accounts
        .firstWhere((Account a) => a.id == draft.fromAccountId);

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Confirm Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              InfoRow(label: 'Biller', value: draft.company),
              InfoRow(label: 'Consumer No', value: draft.consumerNo),
              InfoRow(label: 'From', value: maskAccount(from.number)),
              InfoRow(label: 'Amount', value: money(draft.amount)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final bool ok = app.payBill(draft);
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReceiptPage(
                        title: ok ? 'Bill Paid Successfully!' : 'Payment Failed',
                        amountLine: money(draft.amount),
                        success: ok,
                        rows: [
                          ['Biller', draft.company],
                          ['Category', draft.category],
                          ['Consumer No', draft.consumerNo],
                          ['From', maskAccount(from.number)],
                          ['Reference No', 'BE${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'],
                          ['Date & Time', dateTime(DateTime.now())],
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('PAY NOW'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top-up
// ---------------------------------------------------------------------------

class _TopUpSection extends StatefulWidget {
  const _TopUpSection();

  @override
  State<_TopUpSection> createState() => _TopUpSectionState();
}

class _TopUpSectionState extends State<_TopUpSection> {
  String _operator = MockData.mobileOperators.first;
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _amount = TextEditingController();

  Color _opColor(String op) {
    switch (op) {
      case 'Jazz':
        return const Color(0xFFB3282D);
      case 'Zong':
        return const Color(0xFF7CB92C);
      case 'Telenor':
        return const Color(0xFF2B62A7);
      default:
        return const Color(0xFFF5A800);
    }
  }

  void _submit() {
    final AppState app = context.read<AppState>();
    final double amount = double.tryParse(_amount.text.trim()) ?? 0;
    final String mobile = _mobile.text.trim().replaceAll(' ', '');
    if (mobile.length < 10) {
      showSnack(context, 'Enter a valid mobile number.', error: true);
      return;
    }
    if (amount < 10 || amount > 5000) {
      showSnack(context, 'Top-up amount must be between PKR 10 and 5,000.',
          error: true);
      return;
    }
    final Account from = app.accounts.firstWhere(
        (Account a) => a.currency == 'PKR',
        orElse: () => app.accounts.first);

    final bool ok = app.topUp(_operator, mobile, amount, from.id);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptPage(
          title: ok ? 'Top-up Successful!' : 'Top-up Failed',
          amountLine: money(amount),
          success: ok,
          rows: [
            ['Operator', _operator],
            ['Mobile No', mobile],
            ['From', maskAccount(from.number)],
            ['Reference No', 'MT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'],
            ['Date & Time', dateTime(DateTime.now())],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: MockData.mobileOperators
                .map(
                  (String op) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _operator = op),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _operator == op
                              ? _opColor(op).withOpacity(0.14)
                              : (isDark ? MColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _operator == op
                                ? _opColor(op)
                                : Theme.of(context).dividerColor,
                            width: _operator == op ? 1.6 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: _opColor(op),
                              child: Text(
                                op[0],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              op,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : MColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon:
                  Icon(Icons.smartphone_rounded, color: MColors.subtle),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: 'Amount (PKR 10 – 5,000)',
              prefixIcon: Icon(Icons.payments_outlined, color: MColors.subtle),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('TOP UP NOW')),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Instant load • Demo only, no real balance changes',
              style: TextStyle(fontSize: 11.5, color: MColors.subtle),
            ),
          ),
        ],
      ),
    );
  }
}
