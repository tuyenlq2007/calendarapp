import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';

class SyncStatusTile extends StatelessWidget {
  const SyncStatusTile({
    super.key,
    required this.lastUpdated,
    required this.onRetry,
    this.isSyncing = false,
  });

  final DateTime? lastUpdated;
  final VoidCallback onRetry;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final subtitle = lastUpdated == null
        ? localizations.notUpdatedYet
        : localizations.lastUpdated(
            DateFormat.yMMMd(locale).add_jm().format(lastUpdated!.toLocal()),
          );

    return ListTile(
      title: Text(localizations.syncStatus),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: isSyncing ? null : onRetry,
        child: Text(isSyncing ? localizations.syncing : localizations.retry),
      ),
    );
  }
}
