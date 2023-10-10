import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'graphic.dart';

class Limit extends StatefulWidget {
  Limit({
    Key? key,
  }) : super(key: key);

  @override
  _LimitState createState() => _LimitState();
  TextEditingController upperLimitController = TextEditingController();
  TextEditingController underLimitController = TextEditingController();
}

class _LimitState extends State<Limit> {
  _LimitState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grenzwerte'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 500,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Unteres Limit',
                      border: OutlineInputBorder(),
                    ),
                    controller: widget.underLimitController,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 500,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Oberes Limit',
                      border: OutlineInputBorder(),
                    ),
                    controller: widget.upperLimitController,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GraphicMeasurementValues(
                          under: double.parse(widget.underLimitController.text),
                          upper: double.parse(widget.upperLimitController.text),
                          title: 'Graphic',
                          channel: IOWebSocketChannel.connect(
                              'ws://localhost:8082/ws'),
                        ),
                      )),
                  child: const Text('Geh zum Graphic'))
            ],
          ),
        ),
      ),
    );
  }
}
