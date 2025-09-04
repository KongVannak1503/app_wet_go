import 'package:flutter/material.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';

class UserEditScreen extends StatefulWidget {
  final String dataId;
  const UserEditScreen({super.key, required this.dataId});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.profile ?? 'Edit User'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(children: [Text(widget.dataId)]),
    );
  }
}
