import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hc05_bluetooth/styles.dart';
import 'package:hc05_bluetooth/widgets.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Results extends StatefulWidget {
  final List<dynamic>? injector;
  const Results({required this.injector});

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  Uint8List? _imageFile;
  final pdf = pw.Document();

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(5, 15, 5, 0),
        children: [
          Screenshot(
            controller: screenshotController,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              color: Colors.white,
              padding: EdgeInsets.all(10.0),
              child: Table(
                border: TableBorder.symmetric(
                    inside: BorderSide(width: 1, color: Colors.blue),
                    outside: BorderSide(width: 1)),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          child: Text(
                            ' Results ',
                            style: h6color,
                          ),
                        ),
                        MyTableContainer('Main STD'),
                        MyTableContainer('Main Obtained'),
                        MyTableContainer('Overflow STD'),
                        MyTableContainer('Overflow Obtained'),
                      ]),
                  TableRow(children: [
                    MyTableContainer('Leak Test'),
                    MyTableContent(widget.injector!.length > 5
                        ? "${widget.injector![6]}"
                        : ""),
                    MyStatefulTextField(),
                    MyTableContent(widget.injector!.length > 6
                        ? "${widget.injector![7]}"
                        : ""),
                    MyStatefulTextField(),
                  ]),
                  TableRow(children: [
                    MyTableContainer('VL Test'),
                    MyTableContent(widget.injector!.length > 12
                        ? "${widget.injector![13]}"
                        : ""),
                    MyStatefulTextField(),
                    MyTableContent(widget.injector!.length > 13
                        ? "${widget.injector![14]}"
                        : ""),
                    MyStatefulTextField(),
                  ]),
                  TableRow(children: [
                    MyTableContainer('EM Test'),
                    MyTableContent(widget.injector!.length > 19
                        ? "${widget.injector![20]}"
                        : ""),
                    MyStatefulTextField(),
                    MyTableContent(widget.injector!.length > 20
                        ? "${widget.injector![21]}"
                        : ""),
                    MyStatefulTextField(),
                  ]),
                  TableRow(children: [
                    MyTableContainer('LL Test'),
                    MyTableContent(widget.injector!.length > 27
                        ? "${widget.injector![27]}"
                        : ""),
                    MyStatefulTextField(),
                    MyTableContent(widget.injector!.length > 28
                        ? "${widget.injector![28]}"
                        : ""),
                    MyStatefulTextField(),
                  ]),
                  TableRow(children: [
                    MyTableContainer('VE Test'),
                    MyTableContent(widget.injector!.length > 33
                        ? "${widget.injector![34]}"
                        : ""),
                    MyStatefulTextField(),
                    MyTableContent(widget.injector!.length > 34
                        ? "${widget.injector![35]}"
                        : ""),
                    MyStatefulTextField(),
                  ]),
                ],
              ),
            ),
          ),
          // _imageFile != null
          //     ? Image.memory(_imageFile!)
          //     : Container(
          //         child: Text("Try rpinting"),
          //       ),
          ElevatedButton(
              onPressed: () async {
                screenshotController.captureAndSave(
                    '/storage/emulated/0/Download', //set path where screenshot will be saved
                    fileName: "result_hc05.png");
                await screenshotController.capture().then((Uint8List? image) {
                  setState(() {
                    _imageFile = image;
                  });
                }).catchError((onError) {
                  print(onError);
                });
                final image = pw.MemoryImage(
                  _imageFile!,
                );
                pdf.addPage(pw.Page(build: (pw.Context context) {
                  return pw.Center(child: pw.Image(image));
                }));
                final file =
                    File("/storage/emulated/0/Download/hc05_result.pdf");
                await file.writeAsBytes(await pdf.save());
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Result downloaded"),
                  duration: Duration(seconds: 1),
                ));
              },
              child: Text("Download"))
        ],
      ),
    );
  }
}
