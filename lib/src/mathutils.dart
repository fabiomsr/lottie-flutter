import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

double lerp(double a, double b, double percentage) => a + percentage * (b - a);

int lerpInt(int a, int b, double percentage) =>
    (a + percentage * (b - a)).toInt();


void leftRotate(Matrix4 leftMatrix, double radians)
  => leftMatrix.multiply(new Matrix4.identity()
                      ..rotate(new Vector3.all(1.0), radians));

void leftScale(Matrix4 leftMatrix, double x, double y)
  => leftMatrix.multiply(new Matrix4.identity()
                      ..scale(x, y));


double hypot(double x, double y) => pow(x, 2) + pow(y, 2);

double calculateScale(Matrix4 matrix) {
  final sqrt2 = sqrt(2);
  final transform = matrix.transform(new Vector4(0.0, 0.0, sqrt2, sqrt2));
  return hypot(transform.z - transform.x, transform.w - transform.y) / 2;
}