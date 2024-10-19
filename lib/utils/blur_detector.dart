import 'package:opencv_dart/opencv_dart.dart' as cv;

Future<bool> blurDetection(final String imagePath, final int threshold) async {
  // Read the image
  final cv.Mat image = cv.imread(imagePath);

  // Convert image to grayscale and apply Laplacian filter in one step
  final cv.Mat laplacian = cv.laplacian(cv.cvtColor(image, cv.COLOR_BGR2GRAY), cv.MatType.CV_32F);

  // Calculate the Laplacian variance
  final cv.Scalar laplacianVariance = laplacian.variance();

  // Release memory
  image.dispose();
  laplacian.dispose();

  // Dynamically set the threshold as 10% of the Laplacian variance
  //final double dynamicThreshold = laplacianVariance.val1 * 0.1;

  // Return whether the image is blurry based on the dynamic threshold
  return laplacianVariance.val1 < threshold;
}
