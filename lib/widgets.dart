import 'package:flutter/material.dart';
import 'package:hc05_bluetooth/styles.dart';

class MyTableContent extends StatelessWidget {
  final String text;
  MyTableContent(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      this.text,
      style: h6color,
    ));
  }
}

class MyTableContainer extends StatelessWidget {
  final String text;
  MyTableContainer(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 40,
          child: Center(
            child: Text(
              this.text,
              style: h6color,
            ),
          )),
    );
  }
}

class MyElevatedButton extends StatelessWidget {
  final Function loadProfile;
  final String text;
  final int functionArg;
  MyElevatedButton(this.loadProfile, this.functionArg, this.text);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          this.loadProfile(this.functionArg);
        },
        child: Text(this.text));
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController myController;
  final Function changeValue;
  final String text;
  const MyTextField(this.myController, this.changeValue, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 120,
      child: TextField(
        controller: this.myController,
        onChanged: (value) {
          this.changeValue(value != '' ? int.parse(value) : 0);
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: this.text,
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
    );
  }
}

class MyStatefulTextField extends StatefulWidget {
  const MyStatefulTextField({Key? key}) : super(key: key);

  @override
  _MyStatefulTextFieldState createState() => _MyStatefulTextFieldState();
}

class _MyStatefulTextFieldState extends State<MyStatefulTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 40,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          // enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //     width: .5,
          //   ),
          // ),
        ),
      ),
    );
  }
}
