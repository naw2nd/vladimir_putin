import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_arcgis/flutter_map_arcgis.dart';
import 'package:json_table/json_table.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _earth = false;
  MapController _mapController = MapController();

  void toggle() {
    setState(() {
      _earth = !_earth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nuclear Detonation 1945 - 2016',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                String data = await DefaultAssetBundle.of(context)
                    .loadString("assets/table.json");
                final jsonResult = jsonDecode(data);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: JsonTable(jsonResult,
                            filterTitle: 'SELECT HEADER',
                            allowRowHighlight: true,
                            rowHighlightColor:
                                Colors.yellow[500]?.withOpacity(0.7),
                            paginationRowCount: 20, onRowSelect: (index, map) {
                          _mapController.move(
                              LatLng(map['y_coord'], map['x_coord']), 10);
                        }, showColumnToggle: true),
                      );
                    });
              },
              icon: Icon(
                Icons.view_column_rounded,
                color: Colors.white,
              ))
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              minZoom: 2,
              zoom: 4,
              maxZoom: 22.0,
              center: LatLng(-2.285, 111.533),
              interactiveFlags: ~InteractiveFlag.rotate,
              plugins: [EsriPlugin()],
            ),
            layers: [
              // :
              TileLayerOptions(
                urlTemplate: _earth
                    ? 'http://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}'
                    : 'http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                tileProvider: NetworkTileProvider(),
              ),
              FeatureLayerOptions(
                "https://services.arcgis.com/WCO2nS2UODxbS83z/arcgis/rest/services/nuke_explosions2/FeatureServer/0",
                "point",
                render: (dynamic attributes) {
                  // You can render by attribute
                  return Marker(
                    width: 30.0,
                    height: 30.0,
                    builder: (ctx) => Icon(
                      Icons.dangerous_outlined,
                      color: attributes['Purpose'] == 'Weapon Development'
                          ? Colors.blue
                          : attributes['Purpose'] == 'Combat'
                              ? Colors.red
                              : Colors.yellow,
                    ),
                    point: LatLng(attributes['y_coord'], attributes['x_coord']),
                  );
                },
                onTap: (attributes, LatLng location) {
                  print(attributes);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Container(
                            child: Wrap(
                              children: [
                                Text(
                                  attributes['Name'],
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                Divider(color: Colors.black),
                                Row(children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Date',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Size',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Location',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Delivery',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Purpose',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      attributes['URL'] != null
                                          ? Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 5),
                                              child: InkWell(
                                                  child: Text(
                                                    'More Info',
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                  onTap: () => launch(
                                                      attributes['URL'])),
                                            )
                                          : Text(''),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                              ' :' + attributes['Date'],
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                                ' : ' + attributes['Size'],
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                                ' : ' + attributes['Location1'],
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                                ' : ' + attributes['Delivery'],
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Text(
                                                ' : ' + attributes['Purpose'],
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        Text('')
                                      ],
                                    ),
                                  ),
                                ])
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 15),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dangerous_outlined,
                          color: Colors.red,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                            )
                          ]),
                      Text('Combat',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                )
                              ])),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.dangerous_outlined,
                          color: Colors.blue,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                            )
                          ]),
                      Text('Weapon Development',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                )
                              ]))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.dangerous_outlined,
                          color: Colors.yellow,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                            )
                          ]),
                      Text('Others',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                )
                              ]))
                    ],
                  ),
                ],
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          toggle();
          print(_earth.toString());
        },
        backgroundColor: _earth ? Colors.green : Colors.orange,
        child: _earth
            ? const Icon(Icons.toggle_on, size: 35, color: Colors.white)
            : const Icon(Icons.toggle_off_outlined,
                size: 35, color: Colors.white),
      ),
    );
  }
}
