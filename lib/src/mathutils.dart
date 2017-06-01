import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

double lerp(double a, double b, double percentage) => a + percentage * (b - a);

int lerpInt(int a, int b, double percentage) =>
    (a + percentage * (b - a)).toInt();

void preTranslate(Matrix4 matrix, double dx, double dy) {
  if(dx == 0 && dy == 0) {
    return;
  }

  for (int i = 0; i < 4; ++i) {
    double value = matrix.entry(i, 0) * dx + matrix.entry(i, 1)  * dy + matrix.entry(i, 3);
    matrix.setEntry(i, 3, value);
  }
}

void preScale(Matrix4 matrix, double sx, double sy) {
  if(sx == 1 && sy == 1) {
    return;
  }

  for (int i = 0; i < 4; ++i) {
    matrix.setEntry(i, 0, matrix.entry(i, 0) * sx);
    matrix.setEntry(i, 1, matrix.entry(i, 1) * sy);
  }
}

void leftRotate(Matrix4 leftMatrix, double radians)
  => leftMatrix.rotateZ(radians);


double hypot(double x, double y) => pow(x, 2) + pow(y, 2);

double calculateScale(Matrix4 matrix) {
  final sqrt2 = sqrt(2);
  final transform = matrix.transform(new Vector4(0.0, 0.0, sqrt2, sqrt2));
  return hypot(transform.z - transform.x, transform.w - transform.y) / 2;
}