# 🌊 Underwater Image Color Correction

## Usage

```nodejs
    final UnderwaterImageColorCorrection _underwaterImageColorCorrection = UnderwaterImageColorCorrection();
    _underwaterImageColorCorrection.getColorFilterMatrix(pixels: pixels, width: width, height: height);
```


The arguments in the function is the following:
- __pixels__.  4 channel pixel array [R0, G0, B0, A0, R1, G1, B1, A1, ...]
- __width__.  The width of the image.
- __heigth__.  The height of the image.

The output of the function is a color filter matrix:
```nodejs
[
    RedRed,     RedGreen,    RedBblue,   RedAlpha,     RedOffset,
    GreenRed,   GreenGreen,  GreenBlue,  GreenAlpha,   GOffset,
    BlueRed,    BlueGreen,   BlueBlue,   BlueAlpha,    BOffset,
    AlphaRed,   AlphaGreen,  AlphaBlue,  AlphaAlpha,   AOffset,
]
```

Test in browser: https://colorcorrection.firebaseapp.com/

## Motivation
As you descent underwater some colors are absorbed more than others.
The red color will disappear as the first thing which will make the image appear more blue and green.

By adjusting each color channel, the colors can be restored and make the image appear more natural with higher contrast.
This algorithm aims at doing this automatically.

## Examples
![alt text](https://github.com/nikolajbech/underwater-image-color-correction/raw/master/example1.jpg)

![alt text](https://github.com/nikolajbech/underwater-image-color-correction/raw/master/example2.jpg)

![alt text](https://github.com/nikolajbech/underwater-image-color-correction/raw/master/example3.jpg)

## The algorithm

1. Calculate the average color for image.
2. Hueshift the colors into the red channel until a minimum red average value of 60.
3. Create RGB histogram with new red color.
4. Find low threshold level and high threshold level.
5. Normalize array so threshold level is equal to 0 and threshold high is equal to 255.
6. Create color filter matrix based on the new values.

## 📦 Install the Package  
This package is available on [Pub.dev](https://pub.dev/packages/underwater_image_color_correction).  
To use it, add the following to your `pubspec.yaml`:      

```yaml
dependencies:
  underwater_image_color_correction: latest_version
```

Then, run:

```sh
flutter pub get
```

## 🚀 Share the Knowledge  
If this repository has been helpful, consider sharing it with others who might find it useful!  

## 🔗 Built on Great Ideas  
This project was inspired by the brilliant algorithm from [nikolajbech's repository](https://github.com/nikolajbech/underwater-image-color-correction). Huge thanks to **nikolajbech** for their amazing work!
