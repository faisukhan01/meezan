enum TxnType { credit, debit }

class Account {
  final String id;
  final String title;
  final String type; // Current / Savings / Term Deposit
  final String number;
  final String iban;
  final String branch;
  final String currency; // PKR / USD
  final double balance;

  const Account({
    required this.id,
    required this.title,
    required this.type,
    required this.number,
    required this.iban,
    required this.branch,
    required this.currency,
    required this.balance,
  });

  Account copyWith({double? balance}) => Account(
        id: id,
        title: title,
        type: type,
        number: number,
        iban: iban,
        branch: branch,
        currency: currency,
        balance: balance ?? this.balance,
      );
}

class Txn {
  final String id;
  final String accountId;
  final String title;
  final String channel; // IBFT / Raast / Bill Payment / Top-up / ATM / Payroll
  final String ref;
  final TxnType type;
  final double amount;
  final DateTime date;

  const Txn({
    required this.id,
    required this.accountId,
    required this.title,
    required this.channel,
    required this.ref,
    required this.type,
    required this.amount,
    required this.date,
  });
}

class Beneficiary {
  final String id;
  final String name;
  final String bank;
  final String accountNo;
  final String iban;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.bank,
    required this.accountNo,
    required this.iban,
  });
}

class Biller {
  final String category; // Electricity / Gas / Water / Internet / Education / Donations / Credit Card / Telephone
  final String company;
  const Biller({required this.category, required this.company});
}

class TransferDraft {
  final String fromAccountId;
  final String fromTitle;
  final String toName;
  final String toAccount;
  final String bank;
  final double amount;
  final String purpose;
  final String channel;

  const TransferDraft({
    required this.fromAccountId,
    required this.fromTitle,
    required this.toName,
    required this.toAccount,
    required this.bank,
    required this.amount,
    required this.purpose,
    required this.channel,
  });
}

class BillDraft {
  final String fromAccountId;
  final String company;
  final String category;
  final String consumerNo;
  final double amount;

  const BillDraft({
    required this.fromAccountId,
    required this.company,
    required this.category,
    required this.consumerNo,
    required this.amount,
  });
}
