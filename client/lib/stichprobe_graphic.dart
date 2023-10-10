import 'package:bezier_chart/bezier_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StichprobeGraphic extends StatefulWidget {
  List<List<BarChartGroupData>> infoFromWebSocket;
  int toShowSample;
  double average;
  double under;
  double upper;
  double max;
  double min;
  StichprobeGraphic({
    Key? key,
    required this.average,
    required this.infoFromWebSocket,
    required this.max,
    required this.min,
    required this.toShowSample,
    required this.under,
    required this.upper,
  }) : super(key: key);

  @override
  _StichprobeGraphicState createState() => _StichprobeGraphicState();
}

class _StichprobeGraphicState extends State<StichprobeGraphic> {
  _StichprobeGraphicState();
  List<double> averages = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        await warningDialog();
      },
    );
  }

  @override
  void didUpdateWidget(StichprobeGraphic oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(
      Duration.zero,
      () async {
        await warningDialog();
      },
    );
  }

  Future<void> warningDialog() async {
    if (widget.min < widget.under && widget.max > widget.upper) {
      await Get.dialog(
        Center(
          child: Container(
            width: 400,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                children: [
                  const Expanded(flex: 1, child: SizedBox()),
                  Center(
                    child: SizedBox(
                      width: 350,
                      child: Column(
                        children: const [
                          Text(
                            'Achtung!!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Die Untergrenze  und Obergrenze sind überschritten!!!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton(
                            child: const Text("OK"),
                            onPressed: () {
                              //Put your code here which you want to execute on Yes button click.
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (widget.max > widget.upper) {
      await Get.dialog(
        Center(
          child: Container(
            width: 400,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                children: [
                  const Expanded(flex: 1, child: SizedBox()),
                  Center(
                    child: SizedBox(
                      width: 350,
                      child: Column(
                        children: const [
                          Text(
                            'Achtung!!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Die Obergrenze ist überschritten!!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton(
                            child: const Text("OK"),
                            onPressed: () {
                              //Put your code here which you want to execute on Yes button click.
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (widget.min < widget.under) {
      await Get.dialog(
        Center(
          child: Container(
            width: 400,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                children: [
                  const Expanded(flex: 1, child: SizedBox()),
                  Center(
                    child: SizedBox(
                      width: 350,
                      child: Column(
                        children: const [
                          Text(
                            'Achtung!!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Die Untergrenze ist überschritten!!!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton(
                            child: const Text("OK"),
                            onPressed: () {
                              //Put your code here which you want to execute on Yes button click.
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Card(
            elevation: 12,
            child: Container(
              height: 600,
              width: MediaQuery.of(context).size.width * 0.9,
              child: BezierChart(
                bezierChartScale: BezierChartScale.CUSTOM,
                selectedValue: 1,
                xAxisCustomValues: const [1, 2, 3, 4, 5],
                series: [
                  BezierLine(
                    dataPointFillColor: Colors.amber,
                    lineColor: Colors.blue,
                    lineStrokeWidth: 2.0,
                    label: "Messwerte",
                    data: fromInfoFromWebSocketToDataPoint(
                        widget.infoFromWebSocket[widget.toShowSample]),
                  ),
                  BezierLine(
                    lineStrokeWidth: 1.0,
                    lineColor: Colors.white,
                    label: "Durchschnitt",
                    data: [
                      DataPoint<double>(value: widget.average, xAxis: 1),
                      DataPoint<double>(value: widget.average, xAxis: 2),
                      DataPoint<double>(value: widget.average, xAxis: 3),
                      DataPoint<double>(value: widget.average, xAxis: 4),
                      DataPoint<double>(value: widget.average, xAxis: 5),
                    ],
                  ),
                  BezierLine(
                    lineStrokeWidth: 1.0,
                    lineColor: Colors.green,
                    label: "oberes Limit",
                    data: [
                      DataPoint<double>(value: widget.upper, xAxis: 1),
                      DataPoint<double>(value: widget.upper, xAxis: 2),
                      DataPoint<double>(value: widget.upper, xAxis: 3),
                      DataPoint<double>(value: widget.upper, xAxis: 4),
                      DataPoint<double>(value: widget.upper, xAxis: 5),
                    ],
                  ),
                  BezierLine(
                    lineStrokeWidth: 1.0,
                    lineColor: Colors.black,
                    label: "unteres Limit",
                    data: [
                      DataPoint<double>(value: widget.under, xAxis: 1),
                      DataPoint<double>(value: widget.under, xAxis: 2),
                      DataPoint<double>(value: widget.under, xAxis: 3),
                      DataPoint<double>(value: widget.under, xAxis: 4),
                      DataPoint<double>(value: widget.under, xAxis: 5),
                    ],
                  ),
                ],
                config: BezierChartConfig(
                  startYAxisFromNonZeroValue: true,
                  bubbleIndicatorColor: Colors.white.withOpacity(1),
                  footerHeight: 10,
                  verticalIndicatorStrokeWidth: 3.0,
                  verticalIndicatorColor: Colors.black26,
                  showVerticalIndicator: false,
                  verticalIndicatorFixedPosition: false,
                  displayLinesXAxis: true,
                  displayYAxis: true,
                  updatePositionOnTap: true,
                  stepsYAxis: 1,
                  backgroundGradient: LinearGradient(
                    colors: [
                      Colors.grey[200]!,
                      Colors.grey[300]!,
                      Colors.grey[300]!,
                      Colors.grey[300]!,
                      Colors.grey[300]!,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  snap: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

List<DataPoint<double>> fromInfoFromWebSocketToDataPoint(
  List<BarChartGroupData> infoFromWebSocket,
) {
  List<DataPoint<double>> output = [];
  for (int i = 0; i < infoFromWebSocket.length; i++) {
    output.add(
      DataPoint<double>(
        value: infoFromWebSocket[i].barRods[0].toY,
        xAxis: infoFromWebSocket[i].x.toDouble(),
      ),
    );
  }
  return output;
}
