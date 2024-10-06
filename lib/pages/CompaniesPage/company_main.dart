import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:invoix/pages/CompaniesPage/company_list.dart';
import 'package:invoix/pages/CompaniesPage/invox_ai_card.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit.dart';
import 'package:invoix/pages/list_page_scaffold.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/selection_state.dart';
import 'package:invoix/utils/document_scanner.dart';
import 'package:invoix/utils/read_mode.dart';
import 'package:invoix/widgets/status/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'company_main_mixin.dart';

class CompanyPage extends ConsumerStatefulWidget {
  const CompanyPage({super.key});

  @override
  ConsumerState<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends ConsumerState<CompanyPage>
    with _CompanyPageMixin, AutomaticKeepAliveClientMixin {

  @override
  Widget build(final BuildContext context) {
    final selectionState = ref.watch(companySelectionProvider);

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvokedWithResult: (final bool bool, final dynamic result) {
        if (selectionState.isSelectionMode) {
          ref.read(companySelectionProvider.notifier).toggleSelectionMode();
        }
      },
      child: ListPageScaffold(
        selectionProvider: companySelectionProvider,
        type: ListType.company,
        title: "InvoiX",
        body: Column(
          children: [
            Expanded(
              child: Stack(
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
            ),
            Theme(
              data: Theme.of(context).copyWith(
                listTileTheme: const ListTileThemeData(
                  shape: Border(bottom: BorderSide(color: Colors.white, width: 2)),
                  tileColor: Colors.transparent,
                ),
                dividerColor: Colors.transparent,
                expansionTileTheme: ExpansionTileThemeData(
                  collapsedShape: const Border(bottom: BorderSide(color: Colors.white, width: 1.5)),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  collapsedBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              child: ExpansionTile(
                expansionAnimationStyle: AnimationStyle(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 600),
                ),
                controller: expansionTileController,
                onExpansionChanged: (final bool isExpanded) {
                  prefs.setBool('isAITurnOff', isExpanded);
                },
                title: const Text("AI Insights",
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                children: const [
                  SizedBox(
                    height: 128,
                    child: CarouselView(
                      padding: EdgeInsets.only(
                          top: 8, bottom: 20, right: 8, left: 8),
                      itemSnapping: true,
                      itemExtent: 328,
                      shrinkExtent: 128,
                      children: [
                        InvoixAICard(
                          children: <Widget>[
                            Text("I'm InvoiX, your AI assistant.\n"
                                "Just click on the invoice add icon to get started."),
                          ],
                        ),
                        InvoixAICard(
                          children: <Widget>[
                            Text(
                                "You can also select multiple invoices to delete or excel output them."),
                          ],
                        ),
                        InvoixAICard(
                          children: <Widget>[
                            Text(
                                "AI Insights are available for subscribers only very soon. Work in progress."),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}
