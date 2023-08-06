import 'package:fastinvoicereader/capturedscreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Color ThemeTextColor() => Colors.black87.computeLuminance() > 0.5 ? Colors.white : Colors.black;
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Invoicer Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        textTheme: Theme.of(context).textTheme.apply(
        bodyColor: ThemeTextColor(),
        displayColor: ThemeTextColor(),
        decorationColor: ThemeTextColor(),
      ),
      primaryTextTheme: Theme.of(context).textTheme.apply(
        bodyColor: ThemeTextColor(),
        displayColor: ThemeTextColor(),
        decorationColor: ThemeTextColor(),
      ),
      appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(color: ThemeTextColor()),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.5)),
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
        actionsIconTheme: IconThemeData(
            size: 30.0,
            color: Colors.white,
            opacity: 10.0
        ),
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
      floatingActionButton: Badge(
        label: Icon(Icons.add),
        largeSize: 25,
        child: FloatingActionButton(
          onPressed: () {getImage();},
          child: const Icon(Icons.receipt_long, size: 35,),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

  getImage() async {
    try
    {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
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
