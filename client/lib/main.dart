import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';

import 'limit.dart';

Protocol welcomeFromJson(String str) => Protocol.fromJson(json.decode(str));

String protocolToJson(Protocol data) => json.encode(data.toJson());

class Protocol {
  Protocol({
    required this.event,
    this.isDataBaseToBeRestored,
    required this.data,
  });

  String event;
  bool? isDataBaseToBeRestored;
  List<dynamic> data;

  factory Protocol.fromJson(Map<String, dynamic> json) => Protocol(
        event: json["event"],
        isDataBaseToBeRestored: json["isDataBaseToBeRestored"] ?? true,
        data: json["data"] as List<dynamic>,
      );

  Map<String, dynamic> toJson() => {
        "event": event,
        "isDataBaseToBeRestored": isDataBaseToBeRestored,
        "data": data,
      };
}

void main() => runApp(GraphicApp());

class GraphicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Graphic';

    return GetMaterialApp(
      title: title,
      home: Limit(),
    );
  }
}
