// Use this instead of [Color.lerp] because it interpolates through the gamma color
// space which looks better to us humans.
//
// Writted by Romain Guy and Francois Blavoet.
// https://androidstudygroup.slack.com/archives/animation/p1476461064000335

import 'dart:math';
import 'package:flutter/painting.dart' show Color;

double lerp(double a, double b, double percentage) => a + percentage * (b - a);

int lerpInt(int a, int b, double percentage) => (a + percentage * (b - a)).toInt();

/// Parse the color string and return the corresponding Color.
/// Supported formatS are:
/// #RRGGBB and #AARRGGBB
Color parseColor(String colorString) {
  if(colorString[0] == '#') {
    int color = int.parse(colorString.substring(0), radix: 16, onError: (source) => null);
    if(colorString.length == 7) {
      return new Color(color |= 0x00000000ff000000);
    }

    if(colorString.length == 9) {
      return new Color(color);
    }
  }

  throw new ArgumentError.value(colorString, "colorString", "Unknown color");
}

class GammaEvaluator {

  GammaEvaluator._();

  static Color evaluate(double fraction, Color start, Color end) {
    double startA = start.alpha / 255.0;
    double startR = start.red  / 255.0;
    double startG = start.green / 255.0;
    double startB = start.blue / 255.0;

    double endA = end.alpha / 255.0;
    double endR = end.red  / 255.0;
    double endG = end.green  / 255.0;
    double endB = end.blue  / 255.0;

    // convert from sRGB to linear
    startR = _EOCF_sRGB(startR);
    startG = _EOCF_sRGB(startG);
    startB = _EOCF_sRGB(startB);

    endR = _EOCF_sRGB(endR);
    endG = _EOCF_sRGB(endG);
    endB = _EOCF_sRGB(endB);

    // compute the interpolated color in linear space
    double a = startA + fraction * (endA - startA);
    double r = startR + fraction * (endR - startR);
    double g = startG + fraction * (endG - startG);
    double b = startB + fraction * (endB - startB);

    // convert back to sRGB in the [0..255] range
    a = a * 255.0;
    r = _OECF_sRGB(r) * 255.0;
    g = _OECF_sRGB(g) * 255.0;
    b = _OECF_sRGB(b) * 255.0;

    return new Color(a.round() << 24 | r.round() << 16 | g.round() << 8 | b.round());
  }

  // Opto-electronic conversion function for the sRGB color space
  // Takes a gamma-encoded sRGB value and converts it to a linear sRGB value
  static double _OECF_sRGB(double linear) {
    // IEC 61966-2-1:1999
    return linear <= 0.0031308 ?
    linear * 12.92 :
    (pow(linear, 1.0 / 2.4) * 1.055) - 0.055;
  }

  // Electro-optical conversion function for the sRGB color space
  // Takes a linear sRGB value and converts it to a gamma-encoded sRGB value
  static double _EOCF_sRGB(double srgb) {
    // IEC 61966-2-1:1999
    return srgb <= 0.04045 ? srgb / 12.92 : pow((srgb + 0.055) / 1.055, 2.4);
  }
}