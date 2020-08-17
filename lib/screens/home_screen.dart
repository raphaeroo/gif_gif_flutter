import 'package:flutter/material.dart';
import 'package:gif_flutter/screens/gif_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

const api_trending =
    'https://api.giphy.com/v1/gifs/trending?api_key=p2xhiAOGkLfkIifRmotiHKPTHZG5TKXA&limit=26&rating=g';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search;
  int _offset;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty) {
      response = await http.get(api_trending);
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=p2xhiAOGkLfkIifRmotiHKPTHZG5TKXA&q=$_search&limit=25&offset=$_offset&rating=g&lang=en');
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Image.network(
              'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        ),
        backgroundColor: Colors.black,
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  onSubmitted: (value) {
                    setState(() {
                      _search = value;
                      _offset = 0;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purpleAccent[700], width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purpleAccent[700], width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purpleAccent[700], width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: _getGifs(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Container(
                              width: 130,
                              height: 130,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 5,
                              ));
                        default:
                          if (snapshot.hasError) {
                            return Container();
                          } else {
                            return _createGifTable(context, snapshot);
                          }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data['data'].length) {
          return GestureDetector(
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifScreen(snapshot.data['data'][index])));
            },
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']
                    ['url'],
                height: 300,
                fit: BoxFit.cover),
          );
        } else {
          return Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _offset += 25;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 60),
                  Text('Load More...',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
