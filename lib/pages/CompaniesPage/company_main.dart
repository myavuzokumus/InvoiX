import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:hive/hive.dart';
import 'package:invoix/models/selection_state.dart';
import 'package:invoix/pages/CompaniesPage/company_list.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit.dart';
import 'package:invoix/pages/list_page_scaffold.dart';
import 'package:invoix/utils/document_scanner.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/utils/read_mode.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';

part 'company_main_mixin.dart';

class CompanyPage extends ConsumerStatefulWidget {
  const CompanyPage({super.key});

  @override
  ConsumerState<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends ConsumerState<CompanyPage> with _CompanyPageMixin{

  @override
  Widget build(final BuildContext context) {
    final selectionState = ref.watch(companyProvider);

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvoked: (final bool bool) {
        if (selectionState.isSelectionMode) {
          ref.read(companyProvider.notifier).toggleSelectionMode();
        }
      },
      child: ListPageScaffold(
        selectionProvider: companyProvider,
        type: ListType.company,
        title: "InvoiX",
        body: Stack(
          children: [
            const CompanyList(),
            ValueListenableBuilder(
              valueListenable: _isLoadingNotifier,
              builder: (final BuildContext context, final value,
                  final Widget? child) {
                return value == true
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.black38,
                        child: const Center(child: LoadingAnimation()))
                    : const SizedBox();
              },
            )
          ],
        ),
        floatingActionButton: Badge(
          label: const Icon(Icons.add, color: Colors.white, size: 20),
          largeSize: 28,
          backgroundColor: Colors.red,
          offset: const Offset(10, -10),
          child: FloatingActionButton(
              onPressed: nextPage,
              child: const Icon(Icons.receipt_long, size: 46)),
        ),
      ),
    );
  }
}
