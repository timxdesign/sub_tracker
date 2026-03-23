String formatCurrency(String currencyCode, double amount) {
  final symbol = switch (currencyCode.toUpperCase()) {
    'NGN' => 'N',
    'USD' => r'$',
    _ => '$currencyCode ',
  };
  final decimalPlaces = amount.truncateToDouble() == amount ? 0 : 2;
  final fixedAmount = amount.toStringAsFixed(decimalPlaces);
  final parts = fixedAmount.split('.');
  final wholePart = _withThousandsSeparators(parts.first);
  final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
  return '$symbol$wholePart$decimalPart';
}

String formatShortDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatPaymentDate(DateTime date) {
  const months = <String>[
    'Jan.',
    'Feb.',
    'Mar.',
    'Apr.',
    'May',
    'Jun.',
    'Jul.',
    'Aug.',
    'Sept.',
    'Oct.',
    'Nov.',
    'Dec.',
  ];

  return '${date.day} ${months[date.month - 1]}, ${date.year}';
}

String formatTwoDigits(int value) => value.toString().padLeft(2, '0');

String _withThousandsSeparators(String digits) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    buffer.write(digits[index]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
