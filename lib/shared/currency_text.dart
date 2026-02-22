import 'package:flutter/material.dart';
import 'package:hms_app/utils/formatters.dart';

class CurrencyText extends StatelessWidget {
  final num amount;
  final TextStyle? style;
  final bool compact;

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      compact ? 'TZS ${Formatters.compactNumber(amount)}' : Formatters.currency(amount),
      style: style,
    );
  }
}
