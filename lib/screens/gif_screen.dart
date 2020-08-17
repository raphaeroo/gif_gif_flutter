import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifScreen extends StatelessWidget {
  final Map _gifData;

  GifScreen(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(_gifData['images']['fixed_height']['url']);
              },
            )
          ],
          title: Text(_gifData['title']),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Image.network(_gifData['images']['fixed_height']['url']),
        ));
  }
}
