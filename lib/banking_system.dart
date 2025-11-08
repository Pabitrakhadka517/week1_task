// 📘 Banking System OOP Challenge
// Demonstrates all four OOP principles in Dart.

abstract class BankAccount {
  // ------------------- Encapsulation -------------------
  int _accountNumber;
  String _holderName;
  double _balance;
  final List<String> _transactions = [];

  // Constructor
  BankAccount(this._accountNumber, this._holderName, this._balance);

  // Getters & Setters (Encapsulation)
  int get accountNumber => _accountNumber;
  String get holderName => _holderName;
  double get balance => _balance;

  set holderName(String name) {
    if (name.isNotEmpty) {
      _holderName = name;
    }
  }

  // Protected helper method to modify balance
  void updateBalance(double amount) {
    _balance = amount;
  }

  // Record transaction
  void recordTransaction(String detail) {
    _transactions.add("${DateTime.now()}: $detail");
  }

  // Display transaction history
  void showTransactions() {
    print('Transaction History for $_holderName:');
    for (var t in _transactions) {
      print(t);
    }
    print('------------------------------------');
  }

  // Abstract methods (Abstraction)
  void deposit(double amount);
  void withdraw(double amount);

  // Display account information
  void displayInfo() {
    print('Account Number: $_accountNumber');
    print('Holder Name: $_holderName');
    print('Balance: \$${_balance.toStringAsFixed(2)}');
  }

  void calculateInterest() {}
}

// ------------------- Abstraction via Interface -------------------
abstract class InterestBearing {
  void calculateInterest();
}

// ------------------- Savings Account -------------------
class SavingsAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 500.0;
  static const double _interestRate = 0.02;
  int _withdrawalCount = 0;

  SavingsAccount(int accNo, String holder, double balance)
    : super(accNo, holder, balance);

  @override
  void deposit(double amount) {
    if (amount <= 0) {
      print("Deposit amount must be positive.");
      return;
    }
    updateBalance(balance + amount);
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    if (_withdrawalCount >= 3) {
      print('Withdrawal limit reached.');
      return;
    }
    if (balance - amount < _minBalance) {
      print('Cannot withdraw: Minimum balance of \$$_minBalance required.');
      return;
    }
    updateBalance(balance - amount);
    _withdrawalCount++;
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }

  @override
  void calculateInterest() {
    double interest = balance * _interestRate;
    updateBalance(balance + interest);
    recordTransaction("Interest of \$${interest.toStringAsFixed(2)} added.");
  }
}

// ------------------- Checking Account -------------------
class CheckingAccount extends BankAccount {
  static const double _overdraftFee = 35.0;

  CheckingAccount(int accNo, String holder, double balance)
    : super(accNo, holder, balance);

  @override
  void deposit(double amount) {
    if (amount <= 0) {
      print("Deposit amount must be positive.");
      return;
    }
    updateBalance(balance + amount);
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    updateBalance(balance - amount);
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
    if (balance < 0) {
      updateBalance(balance - _overdraftFee);
      recordTransaction("Overdraft fee of \$$_overdraftFee applied.");
      print('Overdraft! A fee of \$$_overdraftFee applied.');
    }
  }
}

// ------------------- Premium Account -------------------
class PremiumAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 10000.0;
  static const double _interestRate = 0.05;

  PremiumAccount(int accNo, String holder, double balance)
    : super(accNo, holder, balance);

  @override
  void deposit(double amount) {
    if (amount <= 0) {
      print("Deposit amount must be positive.");
      return;
    }
    updateBalance(balance + amount);
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    if (balance - amount < _minBalance) {
      print('Cannot withdraw below minimum balance of \$$_minBalance.');
      return;
    }
    updateBalance(balance - amount);
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }

  @override
  void calculateInterest() {
    double interest = balance * _interestRate;
    updateBalance(balance + interest);
    recordTransaction(
      "Premium interest of \$${interest.toStringAsFixed(2)} added.",
    );
  }
}

// ------------------- Student Account -------------------
class StudentAccount extends BankAccount {
  static const double _maxBalance = 5000.0;

  StudentAccount(int accNo, String holder, double balance)
    : super(accNo, holder, balance);

  @override
  void deposit(double amount) {
    if (balance + amount > _maxBalance) {
      print('Cannot exceed maximum balance of \$$_maxBalance.');
      return;
    }
    updateBalance(balance + amount);
    recordTransaction("Deposited \$${amount.toStringAsFixed(2)}");
  }

  @override
  void withdraw(double amount) {
    if (amount > balance) {
      print('Insufficient balance.');
      return;
    }
    updateBalance(balance - amount);
    recordTransaction("Withdrew \$${amount.toStringAsFixed(2)}");
  }
}

// ------------------- Bank Class -------------------
class Bank {
  final List<BankAccount> _accounts = [];

  void addAccount(BankAccount account) {
    _accounts.add(account);
  }

  BankAccount? findAccount(int accountNumber) {
    try {
      return _accounts.firstWhere((acc) => acc.accountNumber == accountNumber);
    } catch (e) {
      print("Account not found!");
      return null;
    }
  }

  void transfer(int fromAcc, int toAcc, double amount) {
    var sender = findAccount(fromAcc);
    var receiver = findAccount(toAcc);

    if (sender == null || receiver == null) {
      print('One or both accounts not found.');
      return;
    }

    if (amount <= 0) {
      print("Invalid transfer amount.");
      return;
    }

    sender.withdraw(amount);
    receiver.deposit(amount);
    print(
      'Transferred \$${amount.toStringAsFixed(2)} from $fromAcc to $toAcc.',
    );
    sender.recordTransaction(
      "Transferred \$${amount.toStringAsFixed(2)} to $toAcc",
    );
    receiver.recordTransaction(
      "Received \$${amount.toStringAsFixed(2)} from $fromAcc",
    );
  }

  void showAllAccounts() {
    print('\n===== Bank Account Report =====');
    for (var acc in _accounts) {
      acc.displayInfo();
      print('-----------------------------');
    }
  }

  void applyMonthlyInterest() {
    for (var acc in _accounts) {
      if (acc is InterestBearing) {
        acc.calculateInterest();
      }
    }
  }
}

// ------------------- Main Function -------------------
void main() {
  Bank bank = Bank();

  var acc1 = SavingsAccount(1001, 'Pratima Khadka', 2000);
  var acc2 = CheckingAccount(1002, 'Naresh Oli', 500);
  var acc3 = PremiumAccount(1003, 'Suresh Khatri', 15000);
  var acc4 = StudentAccount(1004, 'Aayushma Acharya', 3000);

  bank.addAccount(acc1);
  bank.addAccount(acc2);
  bank.addAccount(acc3);
  bank.addAccount(acc4);

  // Transactions
  acc1.withdraw(200);
  acc2.withdraw(600);
  acc3.calculateInterest();
  acc4.deposit(1000);

  bank.transfer(1001, 1002, 100);
  bank.applyMonthlyInterest();

  // Display results
  bank.showAllAccounts();

  // Show transaction histories
  acc1.showTransactions();
  acc2.showTransactions();
  acc3.showTransactions();
  acc4.showTransactions();
}
