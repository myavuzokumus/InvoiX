import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit.dart';
import 'package:invoix/utils/document_scanner.dart';
import 'package:invoix/utils/read_mode.dart';
import 'package:invoix/widgets/toast.dart';

Future<void> nextPage(final BuildContext context, final ValueNotifier<bool> isLoadingNotifier, final ReadMode readMode) async {
  isLoadingNotifier.value = true;

  final DocumentScanningResult? result = await getDocumentScanner().catchError((final e) {
    if (context.mounted && e.message != "Operation cancelled") {
      showToast(text: context.l10n.status_somethingWentWrong, color: Colors.redAccent);
    }
    return null;
  });

  if (result != null && context.mounted && result.images.isNotEmpty) {
    unawaited(Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (final BuildContext context, final Animation<double> animation, final Animation<double> secondaryAnimation) =>
            InvoiceEditPage(imageFile: XFile(result.images[0]), readMode: readMode),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (final context, animation, final animationTime, final child) {
          animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ));
  }
  isLoadingNotifier.value = false;
}
