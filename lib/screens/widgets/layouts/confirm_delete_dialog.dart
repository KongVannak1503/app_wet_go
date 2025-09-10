import 'package:flutter/material.dart';
import 'package:wet_go/l10n/app_localizations.dart';

Future<bool> showConfirmDeleteDialog(BuildContext context) async {
  final loc = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${loc?.confirmDelete}'),
      content: Text('${loc?.deleteDescription}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('${loc?.cancel}'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            '${loc?.delete}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
