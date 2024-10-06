import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GeopointDialogAlert extends StatefulWidget {
  const GeopointDialogAlert({Key? key}) : super(key: key);

  @override
  State<GeopointDialogAlert> createState() => _GeopointDialogAlertState();
}

class _GeopointDialogAlertState extends State<GeopointDialogAlert> {
  final TextEditingController _textFieldController = TextEditingController();

  GeoPoint? insertedLocation;
  int? insertedMarketId;
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add a new Market'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  insertedLocation = value as GeoPoint;
                });
              },
              controller: _textFieldController,
              decoration:
                  const InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    //codeDialog = valueText;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
