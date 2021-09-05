import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hc05_bluetooth/styles.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class Hc05Communication extends StatefulWidget {
  final BluetoothDevice server;

  const Hc05Communication({required this.server});

  @override
  _Hc05CommunicationState createState() => _Hc05CommunicationState();
}

class _Hc05CommunicationState extends State<Hc05Communication> {
  num? usToDevice;
  num? frequencyToDevice;
  num? pressureToDevice;
  num? rpmToDevice;
  num? ampsToDevice;
  num? mainStdToDevice;
  num? overflowToDevice;

  final TextEditingController _uscontroller = TextEditingController();
  final TextEditingController _frequencycontroller = TextEditingController();
  final TextEditingController _pressurecontroller = TextEditingController();
  final TextEditingController _rpmcontroller = TextEditingController();
  final TextEditingController _ampscontroller = TextEditingController();

  String? recentValues;
  int? _chosenValue;
  List<List<dynamic>>? fields;
  BluetoothConnection? connection;
  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  String _messageBuffer = '';
  List<String> valuesFromDevice = ['NA', 'NA', 'NA', 'NA'];

  final rowSpacer = TableRow(children: [
    SizedBox(
      height: 4,
    ),
    SizedBox(
      height: 4,
    )
  ]);

  loadProfile(int index) {
    try {
      setState(() {
        usToDevice = fields![_chosenValue!][index];
        frequencyToDevice = fields![_chosenValue!][index + 1];
        pressureToDevice = fields![_chosenValue!][index + 2];
        rpmToDevice = fields![_chosenValue!][index + 3];
        ampsToDevice = fields![_chosenValue!][index + 4];
        mainStdToDevice = fields![_chosenValue!][index + 5];
        overflowToDevice = fields![_chosenValue!][index + 6];
        _uscontroller.text = usToDevice.toString();
        _frequencycontroller.text = frequencyToDevice.toString();
        _pressurecontroller.text = pressureToDevice.toString();
        _rpmcontroller.text = rpmToDevice.toString();
        _ampscontroller.text = ampsToDevice.toString();
      });
    } catch (e) {
      setState(() {
        recentValues =
            "Issue in csv file.Check for either of the 3 issues 1) Load a csv file 2)Check the values in csv file 3)please select a profile";
      });
      print('cannot load null values');
    }
  }

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
        appBar: AppBar(
            title: (isConnecting
                ? Text('Connecting chat to ' + serverName + '...')
                : isConnected
                    ? Text('Communication with ' + serverName)
                    : Text('Chat log with ' + serverName))),
        body: ListView(
          children: [
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    fields == null
                        ? Container(child: Text('Pls Load csv'))
                        : Container(
                            child: DropdownButton<int>(
                              focusColor: Colors.white,
                              value: _chosenValue,
                              //elevation: 5,
                              style: TextStyle(color: Colors.white),
                              iconEnabledColor: Colors.black,
                              items: fields?.map<DropdownMenuItem<int>>((inj) {
                                return DropdownMenuItem<int>(
                                  value: fields?.indexOf(inj),
                                  child: Text(
                                    inj[0],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                "Please choose a profile",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              onChanged: (int? value) {
                                setState(() {
                                  _chosenValue = value;
                                });
                              },
                            ),
                          ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      padding: EdgeInsets.only(left: 5),
                      child: Wrap(
                        spacing: 10,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                loadProfile(1);
                              },
                              child: Text('LEak Test')),
                          ElevatedButton(
                              onPressed: () {
                                loadProfile(8);
                              },
                              child: Text('VL Test')),
                          ElevatedButton(
                              onPressed: () {
                                loadProfile(15);
                              },
                              child: Text('EM Test')),
                          ElevatedButton(
                              onPressed: () {
                                loadProfile(22);
                              },
                              child: Text('LL Test')),
                          ElevatedButton(
                              onPressed: () {
                                loadProfile(29);
                              },
                              child: Text('VE Test')),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Wrap(
                    spacing: 10,
                    children: [
                      Container(
                        height: 80,
                        width: 120,
                        child: TextFormField(
                          controller: _uscontroller,
                          validator: (value) =>
                              value == null ? "Enter a valid us" : null,
                          onChanged: (value) {
                            setState(() {
                              usToDevice = int.parse(value);
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "US",
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: .5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 120,
                        child: TextFormField(
                          controller: _frequencycontroller,
                          validator: (value) =>
                              value == null ? "Enter a valid frequency" : null,
                          onChanged: (value) {
                            setState(() {
                              frequencyToDevice = int.parse(value);
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Frequency",
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: .5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 120,
                        child: TextFormField(
                          controller: _pressurecontroller,
                          validator: (value) =>
                              value == null ? "Enter a valid Pressure" : null,
                          onChanged: (value) {
                            setState(() {
                              pressureToDevice = int.parse(value);
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Pressure",
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: .5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 120,
                        child: TextFormField(
                          controller: _rpmcontroller,
                          validator: (value) =>
                              value == null ? "Enter a valid RPM" : null,
                          onChanged: (value) {
                            setState(() {
                              rpmToDevice = int.parse(value);
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "RPM",
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: .5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 120,
                        child: TextFormField(
                          controller: _ampscontroller,
                          validator: (value) =>
                              value == null ? "Enter a valid AMPS" : null,
                          onChanged: (value) {
                            setState(() {
                              ampsToDevice = int.parse(value);
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "AMPS",
                            fillColor: Colors.blue,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: .5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Main Std : " + mainStdToDevice.toString(),
                        style: bigPrice.copyWith(color: Colors.purple),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Overflow : " + overflowToDevice.toString(),
                        style: bigPrice.copyWith(color: Colors.purple),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: 250,
              color: Colors.white,
              padding: EdgeInsets.all(10.0),
              child: Table(
                children: [
                  TableRow(children: [
                    Container(
                      color: Colors.amber,
                      child: Text(
                        ' US From Device : ',
                        style: h6color,
                      ),
                    ),
                    Center(
                        child: Text(
                      valuesFromDevice[0],
                      style: h6color,
                    )),
                  ]),
                  rowSpacer,
                  TableRow(children: [
                    Container(
                        color: Colors.amber,
                        child: Text(
                          ' Frequency From Device :',
                          style: h6color,
                        )),
                    Center(
                        child: Text(
                      valuesFromDevice[1],
                      style: h6color,
                    )),
                  ]),
                  rowSpacer,
                  TableRow(children: [
                    Container(
                        color: Colors.amber,
                        child: Text(
                          ' Temperature From Device :',
                          style: h6color,
                        )),
                    Center(
                        child: Text(
                      valuesFromDevice[2],
                      style: h6color,
                    )),
                  ]),
                  rowSpacer,
                  TableRow(children: [
                    Container(
                        color: Colors.amber,
                        child: Text(
                          ' Resistance From Device :',
                          style: h6color,
                        )),
                    Center(
                        child: Text(
                      valuesFromDevice[3],
                      style: h6color,
                    )),
                  ])
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (await Permission.manageExternalStorage.isGranted) {
                        File file = File(
                            '/storage/emulated/0/Documents/mm_app/Injectors.csv');
                        final temp = await file
                            .openRead()
                            .transform(utf8.decoder)
                            .transform(new CsvToListConverter(eol: '\r'))
                            .toList();
                        setState(() {
                          temp.removeRange(0, 2);
                          fields = temp;
                        });
                      } else {
                        Permission.manageExternalStorage.request();
                      }
                    },
                    child: Text('Load csv')),
                ElevatedButton(
                    onPressed: () async {
                      final temp = usToDevice.toString() +
                          ',' +
                          frequencyToDevice.toString() +
                          ',' +
                          pressureToDevice.toString() +
                          ',' +
                          rpmToDevice.toString() +
                          ',' +
                          ampsToDevice.toString() +
                          ',' +
                          '!';
                      print(temp);
                      recentValues = "Send String : " + temp;
                      _sendMessage(temp);
                    },
                    child: Text('Send')),
              ],
            ),
            SizedBox(height: 10),
            recentValues != null
                ? Center(
                    child: Text(
                      recentValues!,
                      style: h6color.copyWith(color: Colors.red),
                    ),
                  )
                : Container(),
          ],
        ));
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        final split = _messageBuffer.split(',');
        for (int i = 0; i < split.length; i++) {
          valuesFromDevice[i] = split[i];
        }
        print(split);
        // _messageBuffer = dataString.substring(index);
        _messageBuffer = '';
      });
    } else {
      setState(() {
        if (backspacesCounter > 0) {
          _messageBuffer = _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter);
        } else {
          _messageBuffer = _messageBuffer + dataString;
        }
        // _messageBuffer = backspacesCounter > 0
        //     ? _messageBuffer.substring(
        //         0, _messageBuffer.length - backspacesCounter)
        //     : _messageBuffer + dataString;
      });
    }
  }
}
