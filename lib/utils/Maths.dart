

double lerp(double a, double b, double percentage) => a + percentage * (b - a);
int lerpInt(int a, int b, double percentage) => (a + percentage * (b - a)).toInt();
