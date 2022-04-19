import 'dart:io';
import 'package:image/image.dart' as uiImage;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:underwater_image_color_correction/underwater_image_color_correction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Underwater color correction example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Color correction'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ImagePicker picker = ImagePicker();
  XFile? _image;
  final UnderwaterImageColorCorrection _underwaterImageColorCorrection =
      UnderwaterImageColorCorrection();
  ColorFilter? colorFilter;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _clearData, icon: const Icon(Icons.delete))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _image == null
                    ? const Text('No image selected.')
                    : Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            colorFilter == null
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ColorFiltered(
                      colorFilter: colorFilter!,
                      child: Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _image != null ? _applyColorCorrection : null,
                    child: const Text("Convert"),
                  )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _clearData() {
    setState(() {
      colorFilter = null;
      _image = null;
    });
  }

  void _pickImage() async {
    _clearData();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _applyColorCorrection() async {
    setState(() {
      loading = true;
    });
    final image = uiImage.decodeImage(File(_image!.path).readAsBytesSync());
    var pixels = image!.getBytes(format: uiImage.Format.rgba);

    ColorFilter colorFilterImage =
        _underwaterImageColorCorrection.getColorFilterMatrix(
      pixels: pixels,
      width: image.width.toDouble(),
      height: image.height.toDouble(),
    );

    setState(() {
      colorFilter = colorFilterImage;
      loading = false;
    });
  }
}
