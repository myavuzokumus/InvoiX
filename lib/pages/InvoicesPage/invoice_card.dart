import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit.dart';
import 'package:invoix/pages/InvoicesPage/ai_button.dart';
import 'package:invoix/services/invoice_data_service.dart';
import 'package:invoix/states/selection_state.dart';

class InvoiceCard extends ConsumerWidget {
  const InvoiceCard({super.key, required this.invoiceData, this.selectionMode});

  final InvoiceData invoiceData;
  final bool? selectionMode;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final selectionState = ref.watch(invoiceSelectionProvider);

    return Hero(
      tag: invoiceData.imagePath,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.20, 0.5, 0.65],
            colors: [Color(0xBF614385), Color(0x59C2E9FB), Color(0xBF516395)],
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onLongPress: () {
              if (!selectionState.isSelectionMode && selectionMode == null) {
                selectionState.isSelectionMode = !selectionState.isSelectionMode;
                ref.read(invoiceSelectionProvider.notifier).toggleItemSelection(company: invoiceData.companyName, invoiceData: invoiceData);
              }
            },
            onTap: () {
              selectionState.isSelectionMode
                  ? ref.read(invoiceSelectionProvider.notifier).toggleItemSelection(company: invoiceData.companyName, invoiceData: invoiceData)
                      :
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (final context) =>
                          InvoiceEditPage(
                            imageFile: XFile(invoiceData.imagePath),
                                invoiceData: invoiceData,
                          )));
            },
            splashColor: Colors.blue,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: <Widget>[
                        if (selectionMode != null) Text("Company Name\n${invoiceData.companyName}", overflow: TextOverflow.ellipsis,),
                        if (selectionMode != null) const Divider(height: 2),
                        Text("Date\n${DateFormat("dd-MM-yyyy").format(invoiceData.date)}"),
                        const Divider(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Total\n${invoiceData.unit} ${invoiceData.totalAmount}"),
                            const SizedBox(width: 16),
                            Text("Tax\n${invoiceData.unit} ${invoiceData.taxAmount}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8, top: 8, left: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image(image: InvoiceCategory.parse(invoiceData.category)!.icon,
                          width: selectionMode != null ? 92 : 76,
                          fit: BoxFit.cover,
                          frameBuilder: (final BuildContext context, final Widget child, final int? frame, final bool wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(right: 0, bottom: 0,
                        child: AIButton(invoice: invoiceData)
                    ),
                    if (selectionState.isSelectionMode)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Checkbox(
                            onChanged: (final bool? x) => ref.read(invoiceSelectionProvider.notifier).toggleItemSelection(company: invoiceData.companyName, invoiceData: invoiceData),
                            value: selectionState.selectedItems[invoiceData.companyName]?.contains(invoiceData) ?? false,
                      ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
