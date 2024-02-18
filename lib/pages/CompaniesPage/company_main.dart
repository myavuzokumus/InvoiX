import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/pages/CompaniesPage/company_list.dart';
import 'package:invoix/pages/CompaniesPage/mode_selection.dart';
import 'package:invoix/pages/InvoiceEditPage/invoice_edit_page.dart';
import 'package:invoix/pages/general_page_scaffold.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/invoice_data_service.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  late bool _isLoading;
  late ReadMode readMode;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    readMode = ReadMode.legacy;
  }

  void handleModeChange(final ReadMode mode) {
    setState(() {
      readMode = mode;
    });
  }

  void onDelete(final context) {

    final selectionData = SelectionData.of(context);
    final selectedItems = selectionData.selectedInvoices;

    if (selectedItems.isNotEmpty) {
      for (final InvoiceData invoiceData in selectedItems) {
        InvoiceDataService.deleteInvoiceData(invoiceData);
      }
      Toast(context,
        text: "${selectionData.selectedCompanies.length.toString()} company deleted successfully!",
        color: Colors.green,
      );
    } else {
      Toast(context,
        text: "No company selected for deletion!",
        color: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    return GeneralPage(
      title: "InvoiX",
      companyName: "",
      body: Stack(
        children: [
          const CompanyList(),
          if (_isLoading)
            Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black38,
                child: const Center(child: LoadingAnimation()))
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
    );
  }

  // Get image from camera
  Future<void> getImageFromCamera() async {
    final isCameraGranted = await Permission.camera.request();

    if (!mounted) return;

    if (isCameraGranted.isPermanentlyDenied) {
      unawaited(openAppSettings());
      Toast(context,
          text: "You need to give permission to use camera.",
          color: Colors.redAccent);
    } else if (!isCameraGranted.isGranted) {
      Toast(context,
          text: "You need to give permission to use camera.",
          color: Colors.redAccent);
    } else {
      // Generate filepath for saving
      final String imagePath = path.join(
          (await getApplicationSupportDirectory()).path,
          "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

      try {
        setState(() {
          _isLoading = true;
        });

        final bool success = await EdgeDetection.detectEdge(imagePath,
            canUseGallery: true,
            androidScanTitle: 'Scanning',
            androidCropTitle: 'Crop');

        if (mounted && success) {
          unawaited(Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (final context) => InvoiceEditPage(
                      imageFile: XFile(imagePath), readMode: readMode))));
        }
      } catch (e) {
        if (mounted) {
          Toast(context,
              text: "Something went wrong."
                  "$e",
              color: Colors.redAccent);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

}
