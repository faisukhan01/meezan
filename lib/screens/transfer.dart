import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Funds Transfer'),
          bottom: const TabBar(
            indicatorColor: MColors.gold,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            tabs: [
              Tab(text: 'Within Meezan'),
              Tab(text: 'Other Banks (IBFT)'),
              Tab(text: 'Raast'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TransferForm(channel: 'Within Meezan', internalOnly: true),
            _TransferForm(channel: 'IBFT', internalOnly: false),
            _RaastForm(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets for forms
// ---------------------------------------------------------------------------

class _SourceAccountField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _SourceAccountField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final List<Account> pkrAccounts =
        app.accounts.where((Account a) => a.currency == 'PKR').toList();
    final String current =
        pkrAccounts.any((Account a) => a.id == value) ? value! : pkrAccounts.first.id;

    return DropdownButtonFormField<String>(
      value: current,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'From Account',
        prefixIcon: Icon(Icons.account_balance_wallet_outlined,
            color: MColors.subtle),
      ),
      items: pkrAccounts
          .map(
            (Account a) => DropdownMenuItem<String>(
              value: a.id,
              child: Text(
                '${a.title} — ${maskAccount(a.number)}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: 'Amount (PKR)',
        prefixIcon:
            Icon(Icons.payments_outlined, color: MColors.subtle),
      ),
    );
  }
}

class _PurposeField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _PurposeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: MockData.purposes.contains(value) ? value : MockData.purposes.first,
      decoration: const InputDecoration(
        labelText: 'Purpose of Payment',
        prefixIcon: Icon(Icons.category_outlined, color: MColors.subtle),
      ),
      items: MockData.purposes
          .map((String p) =>
              DropdownMenuItem<String>(value: p, child: Text(p)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

void _showAddBeneficiary(BuildContext context) {
  final TextEditingController name = TextEditingController();
  final TextEditingController acc = TextEditingController();
  String bank = MockData.banks.first;
  final AppState app = context.read<AppState>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext ctx) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Beneficiary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration:
                  const InputDecoration(labelText: 'Beneficiary Name'),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (BuildContext sctx, void Function(void Function()) ss) {
                return DropdownButtonFormField<String>(
                  value: bank,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Bank'),
                  items: MockData.banks
                      .map((String b) => DropdownMenuItem<String>(
                          value: b, child: Text(b, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (String? v) => ss(() => bank = v ?? bank),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: acc,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Account / IBAN'),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty || acc.text.trim().length < 6) {
                  showSnack(ctx,
                      'Enter a name and a valid account number.',
                      error: true);
                  return;
                }
                app.addBeneficiary(
                    name.text.trim(), bank, acc.text.trim(), 'PKXXMEZN0000${acc.text.trim()}');
                Navigator.of(ctx).pop();
                showSnack(ctx, 'Beneficiary added successfully.');
              },
              child: const Text('SAVE BENEFICIARY'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Standard transfer form (Meezan / IBFT)
// ---------------------------------------------------------------------------

class _TransferForm extends StatefulWidget {
  final String channel;
  final bool internalOnly;
  const _TransferForm({required this.channel, required this.internalOnly});

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  String? _from;
  String? _beneficiaryId;
  String? _bank;
  final TextEditingController _account = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  String _purpose = MockData.purposes.first;

  @override
  void dispose() {
    _account.dispose();
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AppState app = context.read<AppState>();
    final double amount = double.tryParse(_amount.text.trim()) ?? 0;

    if (_beneficiaryId == null &&
        (_name.text.trim().isEmpty || _account.text.trim().length < 6)) {
      showSnack(context, 'Select a beneficiary or enter name + account.',
          error: true);
      return;
    }
    if (amount <= 0) {
      showSnack(context, 'Enter a valid amount.', error: true);
      return;
    }

    final Beneficiary? b = app.beneficiaries
        .where((Beneficiary x) => x.id == _beneficiaryId)
        .firstOrNull;
    final String toName =
        b?.name ?? _name.text.trim();
    final String toAccount = b?.accountNo ?? _account.text.trim();
    final String bank = widget.internalOnly
        ? 'Meezan Bank (Within Bank)'
        : (b?.bank ?? _bank ?? MockData.banks.first);

    final Account from = app.accounts.firstWhere((Account a) => a.id == _from,
        orElse: () => app.accounts.first);

    if (from.balance < amount) {
      showSnack(context, 'Insufficient balance in selected account.',
          error: true);
      return;
    }

    final TransferDraft draft = TransferDraft(
      fromAccountId: from.id,
      fromTitle: '${from.title} ${maskAccount(from.number)}',
      toName: toName,
      toAccount: toAccount,
      bank: bank,
      amount: amount,
      purpose: _purpose,
      channel: widget.channel,
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OtpPage(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SourceAccountField(
            value: _from,
            onChanged: (String? v) => setState(() => _from = v),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Beneficiary',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              TextButton.icon(
                onPressed: () => _showAddBeneficiary(context),
                icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                label: const Text('Add New'),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: _beneficiaryId,
            isExpanded: true,
            hint: const Text('Select saved beneficiary'),
            items: app.beneficiaries
                .map((Beneficiary b) => DropdownMenuItem<String>(
                      value: b.id,
                      child: Text('${b.name} • ${maskAccount(b.accountNo)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (String? v) => setState(() {
              _beneficiaryId = v;
              if (v != null) {
                final Beneficiary b = app.beneficiaries
                    .firstWhere((Beneficiary x) => x.id == v);
                _name.text = b.name;
                _account.text = b.accountNo;
                if (!widget.internalOnly) _bank = b.bank;
              }
            }),
          ),
          const SizedBox(height: 14),
          if (!widget.internalOnly) ...[
            DropdownButtonFormField<String>(
              value: MockData.banks.contains(_bank) ? _bank : null,
              isExpanded: true,
              hint: const Text('Select bank'),
              items: MockData.banks
                  .map((String b) => DropdownMenuItem<String>(
                      value: b,
                      child: Text(b,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (String? v) => setState(() => _bank = v),
            ),
            const SizedBox(height: 14),
          ],
          TextField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: 'Beneficiary Name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _account,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: widget.internalOnly
                  ? 'Meezan Account Number'
                  : 'Beneficiary Account Number / IBAN',
            ),
          ),
          const SizedBox(height: 14),
          _AmountField(controller: _amount),
          const SizedBox(height: 14),
          _PurposeField(
            value: _purpose,
            onChanged: (String? v) => setState(() => _purpose = v ?? _purpose),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Text('CONTINUE'),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              widget.internalOnly
                  ? 'Instant • Free within Meezan Bank'
                  : 'IBFT • Fee PKR 0.00 (demo) • Usually instant',
              style: const TextStyle(fontSize: 11.5, color: MColors.subtle),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Raast form
// ---------------------------------------------------------------------------

class _RaastForm extends StatefulWidget {
  const _RaastForm();

  @override
  State<_RaastForm> createState() => _RaastFormState();
}

class _RaastFormState extends State<_RaastForm> {
  String? _from;
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  String _purpose = MockData.purposes.first;

  @override
  void dispose() {
    _mobile.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final AppState app = context.read<AppState>();
    final double amount = double.tryParse(_amount.text.trim()) ?? 0;
    final String mobile = _mobile.text.trim().replaceAll(' ', '');

    if (mobile.length < 10) {
      showSnack(context, 'Enter a valid Raast-registered mobile number.',
          error: true);
      return;
    }
    if (amount <= 0) {
      showSnack(context, 'Enter a valid amount.', error: true);
      return;
    }
    final Account from = app.accounts.firstWhere((Account a) => a.id == _from,
        orElse: () => app.accounts.first);
    if (from.balance < amount) {
      showSnack(context, 'Insufficient balance.', error: true);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OtpPage(
          draft: TransferDraft(
            fromAccountId: from.id,
            fromTitle: '${from.title} ${maskAccount(from.number)}',
            toName: 'Raast ID ($mobile)',
            toAccount: mobile,
            bank: 'Raast (SBP)',
            amount: amount,
            purpose: _purpose,
            channel: 'Raast',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: MColors.goldDeep),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Raast transfers are instant and free. Send using the recipient\u2019s mobile number (Raast ID).',
                    style: TextStyle(fontSize: 12.5, color: MColors.ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SourceAccountField(
            value: _from,
            onChanged: (String? v) => setState(() => _from = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Raast ID (Mobile Number)',
              prefixIcon: Icon(Icons.smartphone_rounded, color: MColors.subtle),
            ),
          ),
          const SizedBox(height: 14),
          _AmountField(controller: _amount),
          const SizedBox(height: 14),
          _PurposeField(
            value: _purpose,
            onChanged: (String? v) => setState(() => _purpose = v ?? _purpose),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OTP verification page
// ---------------------------------------------------------------------------

class OtpPage extends StatefulWidget {
  final TransferDraft draft;
  const OtpPage({super.key, required this.draft});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otp = TextEditingController();
  bool _busy = false;
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otp.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _seconds--;
        if (_seconds <= 0) t.cancel();
      });
    });
  }

  void _verify() {
    if (_busy) return;
    if (_otp.text.trim() != '123456') {
      showSnack(context, 'Invalid OTP. Demo OTP is 123456.', error: true);
      return;
    }
    setState(() => _busy = true);
    final AppState app = context.read<AppState>();
    final bool ok = app.transfer(widget.draft);
    if (!mounted) return;

    final TransferDraft d = widget.draft;
    final String ref =
        'FT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptPage(
          title: ok ? 'Transfer Successful!' : 'Transfer Failed',
          amountLine: money(d.amount),
          success: ok,
          rows: [
            ['From', d.fromTitle],
            ['To', d.toName],
            ['Bank', d.bank],
            ['Account', d.toAccount],
            ['Purpose', d.purpose],
            ['Channel', d.channel],
            ['Reference No', ok ? ref : '—'],
            ['Date & Time', dateTime(DateTime.now())],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TransferDraft d = widget.draft;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? MColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transfer Summary',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 10),
                  InfoRow(label: 'To', value: d.toName),
                  Divider(color: Theme.of(context).dividerColor),
                  InfoRow(label: 'Account', value: maskAccount(d.toAccount)),
                  Divider(color: Theme.of(context).dividerColor),
                  InfoRow(label: 'Bank', value: d.bank),
                  Divider(color: Theme.of(context).dividerColor),
                  InfoRow(label: 'Amount', value: money(d.amount)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.sms_outlined,
                      size: 44, color: MColors.green),
                  const SizedBox(height: 10),
                  Text(
                    'Enter the 6-digit OTP sent to\n${'03•• ••• 2101'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white70 : MColors.ink,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              obscureText: true,
              style: const TextStyle(
                  fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '••••••',
                hintStyle: TextStyle(letterSpacing: 12),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Demo OTP: 123456',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: MColors.goldDeep,
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('VERIFY & TRANSFER'),
            ),
            const SizedBox(height: 12),
            Center(
              child: _seconds > 0
                  ? Text(
                      'Resend OTP in 00:${_seconds.toString().padLeft(2, '0')}',
                      style:
                          const TextStyle(fontSize: 12.5, color: MColors.subtle),
                    )
                  : TextButton(
                      onPressed: _startTimer,
                      child: const Text('Resend OTP'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
