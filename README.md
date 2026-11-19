# Cashflow

Cashflow is a simple Flutter app for recording and reviewing money coming in
and going out. It shows your current balance, total income, and total expenses
in one place.

## Features

- Add income and expense transactions.
- Assign a category and date to each transaction.
- View the current balance, total cash in, and total cash out.
- Filter the transaction history by all transactions, cash in, or cash out.
- Swipe a transaction to delete it, with an option to undo the deletion.
- Save transactions locally on the device so they are available when the app is
  opened again.

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) with Dart 3.14 or
  later.
- A configured device or emulator. You can use Android, iOS, Chrome, Windows,
  macOS, or Linux, depending on the Flutter platforms enabled on your machine.

Check that Flutter is installed and that a device is available:

```bash
flutter doctor
flutter devices
```

## Run the app

Clone the repository and open its directory:

```bash
git clone https://github.com/Naufal-A/cashflow-app.git
cd cashflow
```

Install the project dependencies:

```bash
flutter pub get
```

Start the app on the default connected device:

```bash
flutter run
```

To select a specific device, first list available devices with
`flutter devices`, then pass its identifier:

```bash
flutter run -d <device-id>
```

For example, to run the app in Chrome:

```bash
flutter run -d chrome
```

## Using the app

1. Select **Add Transaction**.
2. Choose **Cash In** for income or **Cash Out** for an expense.
3. Enter a title, amount, category, and date.
4. Save the transaction to update the balance and transaction history.
5. Use the **All**, **Cash In**, and **Cash Out** filters to narrow the history.
6. Swipe a transaction to delete it. Select **Undo** in the message that appears
   if it was removed by mistake.

Transactions are stored locally using the device's preferences storage. They
are not uploaded to a remote server or shared between devices.

## Build a release version

For an Android release APK:

```bash
flutter build apk --release
```

For a web release:

```bash
flutter build web
```

The generated files are placed in the `build/` directory.

## Project structure

```text
lib/
├── constants/   Shared colors and categories
├── models/      Transaction data model
├── providers/   State management and local persistence
├── screens/     App screens
├── utils/       Formatting helpers
└── widgets/     Reusable UI components
```

For more information about Flutter development, see the
[Flutter documentation](https://docs.flutter.dev/).
