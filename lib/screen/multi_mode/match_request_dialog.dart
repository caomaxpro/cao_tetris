import 'package:flutter/material.dart';

class MatchRequestDialog extends StatelessWidget {
  final String opponentName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const MatchRequestDialog({
    Key? key,
    required this.opponentName,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Match Request'),
      content: Text('Do you want to play with $opponentName?'),
      actions: [
        TextButton(onPressed: onDecline, child: const Text('Decline')),
        ElevatedButton(onPressed: onAccept, child: const Text('Accept')),
      ],
    );
  }
}
