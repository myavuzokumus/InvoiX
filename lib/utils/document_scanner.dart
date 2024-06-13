import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

Future<DocumentScanningResult?> getDocumentScanner() async {
  final DocumentScannerOptions documentOptions = DocumentScannerOptions(
    documentFormat: DocumentFormat.jpeg, // set output document format
    mode: ScannerMode.full, // to control what features are enabled
    pageLimit: 1, // setting a limit to the number of pages scanned
    isGalleryImport: true, // importing from the photo gallery
  );

  final documentScanner = DocumentScanner(options: documentOptions);

  return documentScanner.scanDocument();
}
