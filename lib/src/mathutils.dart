import 'package:vector_math/vector_math_64.dart';

void leftRotate(Matrix4 leftMatrix, double radians)
  => leftMatrix.multiply(new Matrix4.identity()
                      ..rotate(new Vector3.all(1.0), radians));

void leftScale(Matrix4 leftMatrix, double x, double y)
  => leftMatrix.multiply(new Matrix4.identity()
                      ..scale(x, y));
