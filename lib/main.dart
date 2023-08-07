import 'package:fastinvoicereader/capturedscreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Color ThemeTextColor(color) => color.computeLuminance() > 0.5 ? Colors.white : Colors.black;
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Invoicer Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
        decorationColor: Colors.white,
      ),
      primaryTextTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
        decorationColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white,),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white)
      ),
      scaffoldBackgroundColor: Colors.black87,
      useMaterial3: true,
      ),
      home: const CompanyList(title: 'Fast Invoicer Reader'),
    );
  }
}

class CompanyList extends StatefulWidget {
  const CompanyList({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<CompanyList> createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {

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
      body: GridView.builder(
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
      itemBuilder: (BuildContext context, int index) {
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
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );},

      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        distance: 75,
        fanAngle: 0,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
           child: Badge(
             child: const Icon(Icons.receipt_long, size: 45),
             label: Icon(Icons.add, color: Colors.white, size: 25),
             largeSize: 30,
             backgroundColor: Colors.red,
             offset: Offset(10, -10),
           ),
           fabSize: ExpandableFabSize.regular,
          heroTag: null,
        ),
        overlayStyle: ExpandableFabOverlayStyle(
          // color: Colors.black.withOpacity(0.5),
          blur: 5,
        ),
        children: [
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.camera, size: 45),
            onPressed: () {getImage(ImageSource.camera);},
          ),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.image, size: 45),
            onPressed: () {getImage(ImageSource.gallery);},
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  final _key = GlobalKey<ExpandableFabState>();


  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

  getImage(source) async {
    try
    {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null)
        Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceCaptureScreen(imageFile: pickedImage)));

    }
    catch (e)
    {
      setState(() {
        textScanning = false;
        imageFile = null;
        scannedText = "Error occured while scanning";
      });
    }
  }


}
