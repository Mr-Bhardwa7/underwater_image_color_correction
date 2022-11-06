library underwater_image_color_correction;

import 'dart:math' show pi, cos, sin, min, max;
import 'dart:typed_data';
import 'dart:ui';

class UnderwaterImageColorCorrection {
  ColorFilter getColorFilterMatrix({
    required Uint8List pixels,
    required double width,
    required double height,
  }) {
    // Magic values:
    final double _numOfPixels = width * height;
    const int _thresholdRatio = 2000;
    final double thresholdLevel = _numOfPixels / _thresholdRatio;
    const int _minAvgRed = 60;
    const int _maxHueShift = 120;
    const double _blueMagicValue = 1.2;

    // Objects:
    Map _hist = {'r': [], 'g': [], 'b': []};
    Map _normalize = {'r': [], 'g': [], 'b': []};
    Map _adjust = {'r': [], 'g': [], 'b': []};
    int _hueShift = 0;

    // Initialize objects
    for (int i = 0; i < 256; i++) {
      _hist['r'].add(0);
      _hist['g'].add(0);
      _hist['b'].add(0);
    }

    var avg = _calculateAverageColor(pixels, width, height);

    // Calculate shift amount:
    var _newAvgRed = avg['r'];
    while (_newAvgRed < _minAvgRed) {
      var shifted = _hueShiftRed(avg['r'], avg['g'], avg['b'], _hueShift);
      _newAvgRed = shifted['r'] + shifted['g'] + shifted['b'];
      _hueShift++;
      if (_hueShift > _maxHueShift) _newAvgRed = 60; // Max value
    }

    // Create hisogram with new red values:
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width * 4; x += 4) {
        int pos = (x + (width * 4) * y).toInt();

        int red = (pixels[pos + 0]).round();
        int green = (pixels[pos + 1]).round();
        int blue = (pixels[pos + 2]).round();

        var shifted = _hueShiftRed(
          red,
          green,
          blue,
          _hueShift,
        );
        // Use new calculated red value
        double _sumOfShifted = shifted['r'] + shifted['g'] + shifted['b'];
        red = _sumOfShifted.toInt();
        red = min(255, max(0, red));
        red = red.round();

        _hist['r'][red] += 1;
        _hist['g'][green] += 1;
        _hist['b'][blue] += 1;
      }
    }

    // Push 0 as start value in _normalize array:
    _normalize['r'].add(0);
    _normalize['g'].add(0);
    _normalize['b'].add(0);

    // Find values under threshold:
    for (int i = 0; i < 256; i++) {
      if (_hist['r'][i] - thresholdLevel < 2) _normalize['r'].add(i);
      if (_hist['g'][i] - thresholdLevel < 2) _normalize['g'].add(i);
      if (_hist['b'][i] - thresholdLevel < 2) _normalize['b'].add(i);
    }

    // Push 255 as end value in _normalize array:
    _normalize['r'].add(255);
    _normalize['g'].add(255);
    _normalize['b'].add(255);

    _adjust['r'] = _normalizingInterval(_normalize['r']);
    _adjust['g'] = _normalizingInterval(_normalize['g']);
    _adjust['b'] = _normalizingInterval(_normalize['b']);

    // Make _histogram:
    var _shifted = _hueShiftRed(1, 1, 1, _hueShift);

    final double _redGain = 256 / (_adjust['r']['high'] - _adjust['r']['low']);
    final double _greenGain =
        256 / (_adjust['g']['high'] - _adjust['g']['low']);
    final double _blueGain = 256 / (_adjust['b']['high'] - _adjust['b']['low']);

    final double _redOffset = (-_adjust['r']['low'] / 256) * _redGain;
    final double _greenOffset = (-_adjust['g']['low'] / 256) * _greenGain;
    final double _blueOffset = (-_adjust['b']['low'] / 256) * _blueGain;

    final double _adjstRed = _shifted['r'] * _redGain;
    final double _adjstRedGreen = _shifted['g'] * _redGain;
    final double _adjstRedBlue = _shifted['b'] * _redGain * _blueMagicValue;

    return ColorFilter.matrix(<double>[
      _adjstRed,
      _adjstRedGreen,
      _adjstRedBlue,
      0,
      _redOffset,
      0,
      _greenGain,
      0,
      0,
      _greenOffset,
      0,
      0,
      _blueGain,
      0,
      _blueOffset,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  Map<String, dynamic> _calculateAverageColor(
      pixels, double width, double height) {
    Map<String, dynamic> avg = {'r': 0, 'g': 0, 'b': 0};

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width * 4; x += 4) {
        int pos = (x + (width * 4) * y).toInt();

        // Sum values:
        avg['r'] = avg['r'] + pixels[pos + 0];
        avg['g'] = avg['g'] + pixels[pos + 1];
        avg['b'] = avg['b'] + pixels[pos + 2];
      }
    }

    // Calculate average:
    avg['r'] = avg['r'] / (width * height);
    avg['g'] = avg['g'] / (width * height);
    avg['b'] = avg['b'] / (width * height);

    return avg;
  }

  Map<String, dynamic> _hueShiftRed(r, g, b, h) {
    var U = cos(h * pi / 180);
    var W = sin(h * pi / 180);

    r = (0.299 + 0.701 * U + 0.168 * W) * r;
    g = (0.587 - 0.587 * U + 0.330 * W) * g;
    b = (0.114 - 0.114 * U - 0.497 * W) * b;

    return {'r': r, 'g': g, 'b': b};
  }

  Map<String, int> _normalizingInterval(normArray) {
    int high = 255;
    int low = 0;
    int maxDist = 0;

    for (int i = 1; i < normArray.length; i++) {
      int dist = normArray[i] - normArray[i - 1];
      if (dist > maxDist) {
        maxDist = dist;
        high = normArray[i];
        low = normArray[i - 1];
      }
    }

    return {'low': low, 'high': high};
  }
}
