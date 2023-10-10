import 'package:client/stichprobe_graphic.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'main.dart';

class GraphicMeasurementValues extends StatefulWidget {
  final String title;
  final double upper;
  final double under;
  final WebSocketChannel channel;

  GraphicMeasurementValues(
      {Key? key,
      required this.title,
      required this.channel,
      required this.under,
      required this.upper})
      : super(key: key);

  @override
  _GraphicMeasurementValuesState createState() =>
      _GraphicMeasurementValuesState();
  int toShowSample = 0;
}

class _GraphicMeasurementValuesState extends State<GraphicMeasurementValues> {
  _GraphicMeasurementValuesState();
  List<double> averages = [];
  @override
  void initState() {
    super.initState();
    widget.toShowSample = 0;
    _getValues();
  }

  @override
  Widget build(BuildContext context) {
    List<List<BarChartGroupData>> infoFromWebSocket = [];
    var counterOfSample = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red,
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(image: NetworkImage(""), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder(
            stream: widget.channel.stream,
            // ignore: missing_return
            builder: (context, snapshot) {
              counterOfSample = convertInfoFromWebSocket(
                  snapshot, infoFromWebSocket, counterOfSample);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ListView(
                  children: <Widget>[
                    if (snapshot.hasData &&
                        infoFromWebSocket[widget.toShowSample].isNotEmpty)
                      Text('Werte der Stichprobe ${widget.toShowSample}',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black)),
                    if (snapshot.hasData &&
                        infoFromWebSocket[widget.toShowSample].isNotEmpty)
                      StichprobeGraphic(
                        infoFromWebSocket: infoFromWebSocket,
                        toShowSample: widget.toShowSample,
                        average: averages[widget.toShowSample],
                        under: widget.under,
                        upper: widget.upper,
                        max: maxWert(infoFromWebSocket[widget.toShowSample]),
                        min: minWert(infoFromWebSocket[widget.toShowSample]),
                      ),
                    if (!snapshot.hasData)
                      Container(
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: const Text(
                              'Warten sie bitte, bis die Daten aus dem Server kommen!')),
                    if (snapshot.hasData)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'Scan with Restoring the Databases  ',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.green),
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          onPressed: () {
                            widget.toShowSample = 0;
                            _scan();
                          },
                        ),
                      ),
                    const SizedBox(width: 5),
                    if (snapshot.hasData)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'Scan without Restoring the Databases  ',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.blue),
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          onPressed: () {
                            _scanWithoutBeRestored();
                          },
                        ),
                      ),
                    for (int i = 0; i < counterOfSample; i++)
                      if (snapshot.hasData)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black54),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Stichprobe Nummer: $i',
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            onPressed: () {
                              setState(() {
                                widget.toShowSample = i;
                              });
                            },
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  int convertInfoFromWebSocket(AsyncSnapshot<dynamic> snapshot,
      List<List<BarChartGroupData>> infoFromWebSocket, int counterOfSample) {
    if (snapshot.hasData) {
      var lengthOfInfo = infoFromWebSocket.length;
      for (int i = 0; i < lengthOfInfo; i++) {
        infoFromWebSocket.removeAt(0);
        counterOfSample--;
      }
      Protocol.fromJson(json.decode(snapshot.data)).data.forEach(
        (element) {
          var counterOfSampling = 0;
          List<BarChartGroupData> sampling = [];
          double sum = 0;
          for (var element in (element as List)) {
            sampling.add(
              BarChartGroupData(
                x: counterOfSampling,
                barRods: [
                  BarChartRodData(
                    toY: element.toDouble(),
                    gradient: _barsGradient,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(1.0),
                    ),
                    borderSide: const BorderSide(style: BorderStyle.solid),
                  )
                ],
                showingTooltipIndicators: [0, 1, 2, 3, 4],
              ),
            );
            sum = sum + element;
            counterOfSampling++;
          }
          averages.add(sum / 5);
          infoFromWebSocket.add(sampling);
          counterOfSample++;
        },
      );
    }
    return counterOfSample;
  }

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          Colors.lightBlueAccent,
          Colors.greenAccent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  void _getValues() async {
    var protocol =
        Protocol(event: "getValues", isDataBaseToBeRestored: true, data: [[]]);

    widget.channel.sink.add(json.encode(protocol.toJson()));
  }

  void _scan() {
    var protocol =
        Protocol(event: "scan", isDataBaseToBeRestored: true, data: [[]]);

    widget.channel.sink.add(json.encode(protocol.toJson()));
  }

  void _scanWithoutBeRestored() {
    var protocol =
        Protocol(event: "scan", isDataBaseToBeRestored: false, data: [[]]);

    widget.channel.sink.add(json.encode(protocol.toJson()));
  }
}

double maxWert(List<BarChartGroupData> infoFromWebSocket) {
  double x = 0;
  for (int i = 0; i < infoFromWebSocket.length; i++) {
    if (infoFromWebSocket[i].barRods[0].toY > x) {
      x = infoFromWebSocket[i].barRods[0].toY;
    }
  }
  return x;
}

double minWert(List<BarChartGroupData> infoFromWebSocket) {
  double x = 19999999;
  for (int i = 0; i < infoFromWebSocket.length; i++) {
    if (infoFromWebSocket[i].barRods[0].toY < x) {
      x = infoFromWebSocket[i].barRods[0].toY;
    }
  }
  return x;
}
