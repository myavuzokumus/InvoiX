import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:fastinvoicereader/Models/invoice_data.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart'as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '/Pages/Captured_Page.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({super.key, required this.title});

  final String title;

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {

  List icons = [Icons.camera, Icons.image];

  @override
  Widget build(final BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: 'Tüm verileri indir',
              onPressed: () => showSnackBar(context, "Dosyalar ""Download"" klasörüne kaydedildi."),
            ),]
      ),
      body: listViewer(),

      floatingActionButton: Badge(
        label: const Icon(Icons.add, color: Colors.white, size: 25),
        largeSize: 30,
        backgroundColor: Colors.red,
        offset: const Offset(10, -10),
        child: FloatingActionButton(
            onPressed: getImageFromCamera,
            child: const Icon(Icons.receipt_long, size: 45)
        ),
        ),
    );
  }

  Widget listViewer() {

    final invoiceDataBox = Hive.box('InvoiceData');
    //InvoiceDataBox.watch().listen((event) { });
    print(invoiceDataBox.values); //Debug

    //“No data were found.” was added to avoid an error."
    if (invoiceDataBox.values.isEmpty) {
      return const Center(
        child: Text("No data are found.", style: TextStyle(fontSize: 25),),
      );
    }
    else {
      return GridView.builder(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.

      padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
      // Generate 100 widgets that display their index in the List.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.60,
      ),
        itemCount: invoiceDataBox.values.length,
        //TODO: Invoice Type detection will be added.
      itemBuilder: (final BuildContext context, final int index) {
        final invoice = invoiceDataBox.getAt(index) as InvoiceData;
        print(invoice);
        return ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            color: Colors.grey,
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    'Item $index',
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
    }
  }

  void showSnackBar(final BuildContext context, final String text) {
    final snackBar = SnackBar(
        content: Text(text),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(50),
        elevation: 30,
        duration: const Duration(milliseconds: 10000),
        showCloseIcon: true,
        );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getImageFromCamera() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      return showSnackBar(context, "You need to give permission to use camera.");
    }

    // Generate filepath for saving
    final String imagePath = path.join(
        (await getApplicationSupportDirectory()).path,
        "${(DateTime
            .now()
            .millisecondsSinceEpoch / 1000).round()}.jpeg"
    );

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

      if(success) {
        unawaited(Navigator.push(
            context,
            MaterialPageRoute(
                builder: (final context) =>
                    InvoiceCaptureScreen(
                        imageFile: XFile(imagePath)
                    )
            )
        ));
      }

    } catch (e) {
      print(e);

    }



  }


}
