import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/company_list.dart';
import 'package:invoix/pages/CompaniesPage/mode_selection.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit_page.dart';
import 'package:invoix/pages/SelectionState.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/general_page_scaffold.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'company_main_mixin.dart';

class CompanyPage extends ConsumerStatefulWidget {
  const CompanyPage({super.key});

  @override
  ConsumerState<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends ConsumerState<CompanyPage> with _CompanyPageMixin{


  @override
  Widget build(final BuildContext context) {
    final selectionState = ref.watch(companySelectionProvider);

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvoked: (final bool bool) {
        if (selectionState.isSelectionMode) {
          ref.read(companySelectionProvider.notifier).toggleSelectionMode();
        }
      },
      child: GeneralPage(
        selectionProvider: companySelectionProvider,
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
        onExcelExport: () => exportToExcel(listType: ListType.company),
        onDelete: () => onDelete(context),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ModeSelection(onModeChanged: handleModeChange),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Badge(
                label: const Icon(Icons.add, color: Colors.white, size: 20),
                largeSize: 28,
                backgroundColor: Colors.red,
                offset: const Offset(10, -10),
                child: FloatingActionButton(
                    onPressed: getImageFromCamera,
                    child: const Icon(Icons.receipt_long, size: 46)),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
