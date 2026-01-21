import 'package:flutter/material.dart';

class RefreshConfirmationDialog extends StatefulWidget {
  const RefreshConfirmationDialog({super.key});

  @override
  State<RefreshConfirmationDialog> createState() =>
      _RefreshConfirmationDialogState();
}

class _RefreshConfirmationDialogState extends State<RefreshConfirmationDialog> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Refresh from API'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action will fetch fresh data from the API and update your local cache.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _dontAskAgain,
                  onChanged: (value) {
                    setState(() {
                      _dontAskAgain = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text("Don't ask again", style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.grey),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_dontAskAgain),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows a refresh confirmation dialog and returns the result.
/// Returns null if cancelled, or a boolean indicating if "don't ask again" was checked.
Future<bool?> showRefreshConfirmationDialog(BuildContext context) {
  return showDialog<bool?>(
    context: context,
    builder: (context) => const RefreshConfirmationDialog(),
  );
}
