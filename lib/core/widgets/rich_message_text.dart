// lib/core/widgets/rich_message_text.dart
import 'package:flutter/material.dart';

/// Texto com suporte simples a **negrito** (formato usado pelas respostas da IA).
class RichMessageText extends StatelessWidget {
  const RichMessageText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final parts = text.split('**');
    return SelectableText.rich(
      TextSpan(
        style: base,
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null,
            ),
        ],
      ),
    );
  }
}
