import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../models/invoice_data.dart';
import '../utils/company_name_filter.dart';
import '../widgets/toast.dart';
import 'invoice_edit.dart';
import 'invoice_list.dart';

//TODO: Add Excel function to save data
//TODO: Removing companies and invoices will be added.

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Hero(
              tag: "InvoiX",
              child: RichText(
                  text: const TextSpan(
                    text: "InvoiX",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)))),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: "Export all data to Excel",
              onPressed: () => showSnackBar(context,
                  text: "Excel files are saved in ""Download"" file.", color: Colors.green),
            ),
          ]),
      body: const CompanyList(),
      floatingActionButton: Badge(
        label: const Icon(Icons.add, color: Colors.white, size: 25),
        largeSize: 30,
        backgroundColor: Colors.red,
        offset: const Offset(10, -10),
        child: FloatingActionButton(
            onPressed: getImageFromCamera,
            child: const Icon(Icons.receipt_long, size: 45)),
      ),
    );
  }

  // Get image from camera
  Future<void> getImageFromCamera() async {
    final bool isCameraGranted = await Permission.camera.request().isGranted;

    if (mounted && !isCameraGranted) {
      return showSnackBar(context,
          text: "You need to give permission to use camera.",
          color: Colors.redAccent);
    }

    // Generate filepath for saving
    final String imagePath = path.join(
        (await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    try {
      final bool success = await EdgeDetection.detectEdge(
        imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scanning',
        // use custom localizations for android
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );

      if (mounted && success) {
        unawaited(Navigator.push(
            context,
            MaterialPageRoute(
                builder: (final context) =>
                    InvoiceCaptureScreen(imageFile: XFile(imagePath)))));
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context,
            text: "Something went wrong."
                "$e",
            color: Colors.redAccent);
      }
    }
  }
}


// Return list of companies
class CompanyList extends StatelessWidget {
  const CompanyList({super.key});

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('InvoiceData').listenable(),
        builder: (final BuildContext context, final Box<dynamic> value,
            final Widget? child) {

          // Check if there is any invoice data
          if (invoiceDataBox.isEmpty) {
            return const Center(
              child: Text(
                "No invoice added yet.",
                style: TextStyle(fontSize: 25),
              ),
            );
          } else {
            return FutureBuilder<List<InvoiceData>>(
              future: getInvoiceDataList(
                  ListType.company, invoiceDataBox.cast<InvoiceData>()),
              builder: (final BuildContext context,
                  final AsyncSnapshot<List<InvoiceData>> company) {
                if (company.hasData) {
                  return ListView.separated(
                      padding:
                      const EdgeInsets.only(left: 10, right: 10, top: 20),
                      itemCount: company.data!.length,
                      separatorBuilder:
                          (final BuildContext context, final int index) =>
                      const Divider(),
                      itemBuilder:
                          (final BuildContext context, final int index) {
                        final companyListName =
                            company.data!.elementAt(index).companyName;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: ListTile(
                            tileColor: Colors.grey,
                            title: Text(
                              companyListName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (final context) =>
                                          InvoicePage(
                                              companyName: companyListName)));
                            },
                          ),
                        );
                      });
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          }
        });
  }
}
