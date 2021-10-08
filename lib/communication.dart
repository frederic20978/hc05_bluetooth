import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:hc05_bluetooth/resultPage.dart';
import 'package:hc05_bluetooth/styles.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hc05_bluetooth/widgets.dart';
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

  changeUsToDevice(_value) {
    setState(() {
      usToDevice = _value;
    });
  }

  changeFrequencyToDevice(_value) {
    setState(() {
      frequencyToDevice = _value;
    });
  }

  changePressureToDevice(_value) {
    setState(() {
      pressureToDevice = _value;
    });
  }

  changeRPMToDevice(_value) {
    setState(() {
      rpmToDevice = _value;
    });
  }

  changeAMPSToDevice(_value) {
    setState(() {
      ampsToDevice = _value;
    });
  }

  String sendData() {
    final temp = usToDevice.toString() +
        ',' +
        frequencyToDevice.toString() +
        ',' +
        pressureToDevice.toString() +
        ',' +
        rpmToDevice.toString() +
        ',' +
        ampsToDevice.toString();
    print(temp);
    return temp;
  }

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

  loadCsv() async {
    try {
      File file = File('/storage/emulated/0/Documents/Injectors.csv');
      final temp = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(new CsvToListConverter(eol: '\r'))
          .toList();
      setState(() {
        temp.removeRange(0, 2);
        fields = temp;
      });
    } catch (e) {
      setState(() {
        recentValues =
            "Error in loading CSV. Please provide the Injectors.csv file in Documents/ folder";
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Permission.storage.request();
    Permission.manageExternalStorage.request();

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

    loadCsv();
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
                  : Text('Chat log with ' + serverName)),
          actions: [
            ElevatedButton(
                onPressed: () {
                  if (fields != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return Results(
                              injector: _chosenValue == null
                                  ? fields![0]
                                  : fields![_chosenValue!]);
                        },
                      ),
                    );
                  }
                },
                child: Text("Result"))
          ],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 8),
          children: [
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    fields == null
                        ? Container(
                            child: Text("Pls load csv file"),
                          )
                        : Container(
                            height: 60,
                            width: 200,
                            child: DropdownSearch<int>(
                                mode: Mode.MENU,
                                itemAsString: (int? u) => fields![u!][0],
                                items: fields?.map<int>((inj) {
                                  return fields!.indexOf(inj);
                                }).toList(),
                                compareFn: (item, selectedItem) =>
                                    item == selectedItem,
                                onChanged: (value) {
                                  setState(() {
                                    _chosenValue = value;
                                  });
                                },
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "select Injector",
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
                                showSelectedItems: true,
                                showSearchBox: true,
                                selectedItem: _chosenValue),
                          ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Wrap(
                        spacing: 10,
                        children: [
                          MyElevatedButton(loadProfile, 1, 'LeaK Test'),
                          MyElevatedButton(loadProfile, 8, 'VL Test'),
                          MyElevatedButton(loadProfile, 15, 'EM Test'),
                          MyElevatedButton(loadProfile, 22, 'LL Test'),
                          MyElevatedButton(loadProfile, 29, 'VE Test'),
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
                      MyTextField(_uscontroller, changeUsToDevice, "US"),
                      MyTextField(_frequencycontroller, changeFrequencyToDevice,
                          "Frequency"),
                      MyTextField(_pressurecontroller, changePressureToDevice,
                          "Pressure"),
                      MyTextField(_rpmcontroller, changeRPMToDevice, "RPM"),
                      MyTextField(_ampscontroller, changeAMPSToDevice, "AMPS"),
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
                border: TableBorder.symmetric(
                    inside: BorderSide(width: 1, color: Colors.blue),
                    outside: BorderSide(width: 1)),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(children: [
                    MyTableContainer(' US From Device : '),
                    MyTableContent(valuesFromDevice[0]),
                  ]),
                  TableRow(children: [
                    MyTableContainer(' Frequency From Device :'),
                    MyTableContent(valuesFromDevice[1]),
                  ]),
                  TableRow(children: [
                    MyTableContainer(' Temperature From Device :'),
                    MyTableContent(valuesFromDevice[2]),
                  ]),
                  TableRow(children: [
                    MyTableContainer(' Resistance From Device :'),
                    MyTableContent(valuesFromDevice[3]),
                  ])
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      try {
                        File file =
                            File('/storage/emulated/0/Documents/Injectors.csv');
                        final temp = await file
                            .openRead()
                            .transform(utf8.decoder)
                            .transform(new CsvToListConverter(eol: '\r'))
                            .toList();
                        setState(() {
                          temp.removeRange(0, 2);
                          fields = temp;
                        });
                      } catch (e) {
                        setState(() {
                          recentValues =
                              "Error in loading CSV. Please provide the Injectors.csv file in Documents/ folder";
                        });
                      }
                    },
                    child: Text(
                      'Load csv',
                      style: TextStyle(color: Colors.purple[900]),
                    )),
                ElevatedButton(
                    onPressed: () async {
                      final String temp = sendData();
                      recentValues =
                          "Send String : " + "#" + temp + "," + "strt" + "!";
                      _sendMessage("#" + temp + "strt" + "!");
                    },
                    child: Text('Start')),
                ElevatedButton(
                    onPressed: () async {
                      final String temp = sendData();

                      recentValues = "Send String : " + "#" + temp + "!";
                      _sendMessage("#" + temp + "!");
                    },
                    child: Text('Send')),
                ElevatedButton(
                    onPressed: () async {
                      final String temp = sendData();
                      recentValues =
                          "Send String : " + "#" + temp + "," + "stop" + "!";
                      _sendMessage("#" + temp + "stop" + "!");
                    },
                    child: Text('Stop')),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
                style: TextButton.styleFrom(primary: Colors.amber),
                onPressed: () {},
                child: Text("Received message buffer:" + _messageBuffer)),
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

    int index = buffer.indexOf(35);
    if (~index != 0) {
      setState(() {
        _messageBuffer = '';
      });
    }
    index = buffer.indexOf(33);
    if (~index != 0) {
      setState(() {
        recentValues = " Received String : " + _messageBuffer;
        final split = _messageBuffer.split(',');
        for (int i = 0; i < split.length; i++) {
          valuesFromDevice[i] = split[i];
        }
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
