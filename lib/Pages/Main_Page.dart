import 'package:fastinvoicereader/Models/invoice_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

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
  Widget build(BuildContext context) {
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dosyalar "Download" klasörüne kaydedildi.')));
              },
            ),]
      ),
      body: _ListViewer(),

      floatingActionButton: Badge(
        child: SpeedDial(
            spaceBetweenChildren: 15,
            spacing: 15,
            overlayColor: Colors.black,
            overlayOpacity: 0.3,
            child: const Icon(Icons.receipt_long, size: 45),
            activeIcon: Icons.close,
            children: [
              for (int i = 0; i < icons.length; ++i)
                SpeedDialChild(
                  onTap: () {
                    switch(i) {
                      case 0:getImage(ImageSource.camera);break;
                      case 1:getImage(ImageSource.gallery);break;
                    }
                  },
                  child: Icon(
                      icons[i],
                      size: 45
                  ),
                ),
          ],
        ),
        label: Icon(Icons.add, color: Colors.white, size: 25),
        largeSize: 30,
        backgroundColor: Colors.red,
        offset: Offset(10, -10),
        ),
    );
  }

  Widget _ListViewer() {

    final InvoiceDataBox = Hive.box('InvoiceData');
    //InvoiceDataBox.watch().listen((event) { });
    print(InvoiceDataBox.values); //Debug

    //“No data were found.” was added to avoid an error."
    if (InvoiceDataBox.values.isEmpty) {
      return Center(
        child: Text("No data are found.", style: TextStyle(fontSize: 25),),
      );
    }
    else return GridView.builder(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.

      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      // Generate 100 widgets that display their index in the List.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.60,
      ),
        itemCount: InvoiceDataBox.values.length,
        //TODO: Invoice Type detection will be added.
      itemBuilder: (BuildContext context, int index) {
        final invoice = InvoiceDataBox.getAt(index) as InvoiceData;
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
                      margin: EdgeInsets.all(15),
                      color: Colors.blueGrey,
                    ),
                  ),
                  Container(
                    child: Text(
                      'Item $index',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  getImage(source) async {

    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null)
      Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceCaptureScreen(imageFile: pickedImage)));

  }

}