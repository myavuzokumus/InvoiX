import 'package:opencv_dart/opencv_dart.dart' as cv;

Future<bool> blurDetection(final String imagePath, final int threshold) async {

  //Read the image
  final cv.Mat image = cv.imread(imagePath);

  //Convert image to grayscale
  final cv.Mat gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);

  //Apply Laplacian filter for edge detection
  final cv.Mat laplacian = cv.laplacian(gray, cv.CV_F64_MAX.toInt());

  final cv.Scalar laplacianVariance = laplacian.variance();

  return laplacianVariance.val1 < threshold;
}
