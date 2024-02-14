import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/models/invoice_data.dart';
import 'package:invoix/utils/company_name_filter.dart';
import 'package:invoix/utils/export_to_excel.dart';
import 'package:invoix/utils/image_to_text_regex.dart';
import 'package:invoix/widgets/loading_animation.dart';
import 'package:invoix/widgets/warn_icon.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
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
  late bool _isLoading;
  late bool _excelExporting;

  @override
  void initState() {
    // TODO: implement initState
    _isLoading = false;
    _excelExporting = false;
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return AbsorbPointer(
      absorbing: _isLoading,
      child: Scaffold(
        appBar: AppBar(
            title: Hero(
                tag: "InvoiX",
                child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                        text: "InvoiX",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)))),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: _excelExporting
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.table_chart),
                tooltip: "Export all data to Excel",
                onPressed: _excelExporting
                    ? null
                    : () {
                        setState(() {
                          _excelExporting = true;
                        });

                        exportToExcel(listType: ListType.company)
                          ..catchError((final Object e) => showSnackBar(context,
                              text: e.toString(), color: Colors.redAccent))
                          ..then((final _) => showSnackBar(context,
                              text: "Excel output is saved in "
                                  """Download"""
                                  " file.",
                              color: Colors.green))
                          ..whenComplete(() => setState(() {
                                _excelExporting = false;
                              }));
                      },
              ),
            IconButton(onPressed: () {
              showSnackBar(context,
                  text: "Company deletion very soon!",
                  color: Colors.redAccent);
            }, icon: const Icon(Icons.restore_from_trash_outlined))
            ]),

        //CompanyList widget is added to the body of the scaffold
        body: Stack(children: [
          const CompanyList(),
          if (_isLoading)
            Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black38,
                child: const Center(child: LoadingAnimation()))
        ]),

        //Invoice Capture button
        floatingActionButton: Badge(
          label: const Icon(Icons.add, color: Colors.white, size: 20),
          largeSize: 28,
          backgroundColor: Colors.red,
          offset: const Offset(10, -10),
          child: FloatingActionButton(
              onPressed: getImageFromCamera,
              child: const Icon(Icons.receipt_long, size: 46)),
        ),
      ),
    );
  }

  // Get image from camera
  Future<void> getImageFromCamera() async {
    final isCameraGranted = await Permission.camera.request();

    if (mounted) {
      if (isCameraGranted.isPermanentlyDenied) {
        unawaited(openAppSettings());
        return showSnackBar(context,
            text: "You need to give permission to use camera.",
            color: Colors.redAccent);
      } else if (!isCameraGranted.isGranted) {
        return showSnackBar(context,
            text: "You need to give permission to use camera.",
            color: Colors.redAccent);
      }
    }

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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Return list of companies
class CompanyList extends StatefulWidget {
  const CompanyList({super.key, this.onTap});

  final Function(String)? onTap;

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  late Set<String> filters;
  late final TextEditingController companyNameTextController;
  late final GlobalKey<FormState> _companyNameformKey;

  @override
  void initState() {
    filters = <String>{};
    companyNameTextController = TextEditingController();
    _companyNameformKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('InvoiceData').listenable(),
        builder: (final BuildContext context, final Box<dynamic> value,
            final Widget? child) {
          // Check if there is any invoice data
          if (invoiceDataBox.values.isEmpty) {
            return const Center(
              child: Text(
                "No invoice added yet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
              ),
            );
          } else {
            return FutureBuilder<List<InvoiceData>>(
              future: getInvoiceDataList(
                  ListType.company, invoiceDataBox.values.cast<InvoiceData>()),
              builder: (final BuildContext context,
                  final AsyncSnapshot<List<InvoiceData>> company) {
                if (company.hasData) {
                  // Create a list of companies with copy of company data
                  final List<InvoiceData> companyList =
                      List.from(company.data!);

                  if (filters.length == 1) {
                    companyList.removeWhere((final InvoiceData element) =>
                        !filters.every((final e) {
                          return element.companyName
                              .toUpperCase()
                              .contains(e.toUpperCase());
                        }));
                  } else if (filters.length > 1) {
                    companyList.removeWhere(
                        (final InvoiceData element) => !filters.any((final e) {
                              return element.companyName
                                  .toUpperCase()
                                  .contains(e.toUpperCase());
                            }));
                  }

                  final List<Widget> filterlist = filterList(company.data!);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        child: FilledButton(
                          onPressed: () {},
                          child: Text(companyList.length.toString()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                              spacing: 10.0,
                              children: filterlist.length > 1
                                  ? filterlist
                                  : const [SizedBox()]),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 20),
                            itemCount: companyList.length,
                            separatorBuilder:
                                (final BuildContext context, final int index) =>
                                    const Divider(),
                            itemBuilder:
                                (final BuildContext context, final int index) {
                              final companyListName =
                                  companyList.elementAt(index).companyName;
                        
                              return ListTile(
                                title: Text(
                                  companyListName,
                                ),
                                onLongPress: () {
                                  showDialog(
                                      context: context,
                                      builder: (final BuildContext context) {
                        
                                        return AlertDialog(
                                          title: Text(companyListName),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                  "What would you like to change new company name?"),
                                              const SizedBox(height: 12),
                                              Form(
                                                key: _companyNameformKey,
                                                autovalidateMode: AutovalidateMode
                                                    .onUserInteraction,
                                                child: TextFormField(
                                                  maxLength: 50,
                                                  controller:
                                                      companyNameTextController,
                                                  decoration: const InputDecoration(
                                                      labelText:
                                                          "New company name:",
                                                      labelStyle:
                                                          TextStyle(fontSize: 16),
                                                      hintText:
                                                          "Enter new company name",
                                                      suffixIcon: WarnIcon(
                                                          message:
                                                              "You must enter a valid company name.\nNeed include 'LTD., ŞTİ., A.Ş., LLC, PLC, INC, GMBH'")),
                                                  validator: (final value) {
                                                    if (value == null ||
                                                        value.isEmpty ||
                                                        !companyRegex
                                                            .hasMatch(value)) {
                                                      return 'Please enter some text';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (_companyNameformKey
                                                    .currentState!
                                                    .validate()) {
                                                  invoiceDataBox.put(
                                                      invoiceDataBox.values
                                                          .cast<InvoiceData>()
                                                          .toList()
                                                          .indexOf(companyList
                                                              .elementAt(index)),
                                                      InvoiceData(
                                                          ImagePath: companyList
                                                              .elementAt(index)
                                                              .ImagePath,
                                                          companyName:
                                                              companyNameTextController
                                                                  .text,
                                                          invoiceNo: companyList
                                                              .elementAt(index)
                                                              .invoiceNo,
                                                          date: companyList
                                                              .elementAt(index)
                                                              .date,
                                                          totalAmount: companyList
                                                              .elementAt(index)
                                                              .totalAmount,
                                                          taxAmount: companyList
                                                              .elementAt(index)
                                                              .taxAmount));
                                                  Navigator.pop(context);
                                                  showSnackBar(context,
                                                      text:
                                                          "Company name has been changed successfully.",
                                                      color: Colors.greenAccent);
                                                } else {
                                                  showSnackBar(context,
                                                      text:
                                                          "Please enter a valid company name.\nNeed include 'LTD., ŞTİ., A.Ş., LLC, PLC, INC, GMBH'",
                                                      color: Colors.redAccent);
                                                }
                                              },
                                              child: const Text("Change"),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                onTap: () {
                                  if (widget.onTap != null) {
                                    widget.onTap!(companyListName);
                                    return;
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (final context) => InvoicePage(
                                              companyName: companyListName)));
                                },
                              );
                            }),
                      ),
                    ],
                  );
                } else {
                  return const LoadingAnimation();
                }
              },
            );
          }
        });
  }

  List<Widget> filterList(final List<InvoiceData> company) {
    return CompanyType.values.map((final CompanyType types) {
      if (company.any((final InvoiceData element) => element.companyName
          .toUpperCase()
          .contains(types.name.toUpperCase()))) {
        return FilterChip(
          label: Text(types.name),
          selected: filters.contains(types.name),
          onSelected: (final bool selected) {
            setState(() {
              if (selected) {
                filters.add(types.name);
              } else {
                filters.remove(types.name);
              }
            });
          },
        );
      } else {
        return const SizedBox();
      }
    }).toList();
  }
}
