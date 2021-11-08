import 'dart:io';

import 'package:args/args.dart';
import 'package:simulink_mqtt_bridge/simulink.dart' as simulink;
import 'package:simulink_mqtt_bridge/mqtt.dart' as mqtt;
import 'package:simulink_mqtt_bridge/topics.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'listen',
      defaultsTo: '8081',
      help: 'The port which the ServerSocket should listen to.',
    )
    ..addOption(
      'mqtt-server',
      defaultsTo: 'ws://rithviknishad.ddns.net',
      help: 'The address of the MQTT server',
    )
    ..addOption(
      'mqtt-username',
      defaultsTo: '',
      help:
          'The username that is to be used to establish connection to the MQTT server.',
    )
    ..addOption(
      'mqtt-password',
      defaultsTo: '',
      help:
          'The password that is to be used to establish connection to the MQTT server.',
    )
    ..addOption(
      'mqtt-port',
      defaultsTo: '9001',
      help: "MQTT server's port",
    );

  final argResults = parser.parse(args);

  final server = await ServerSocket.bind(
    InternetAddress.anyIPv4,
    int.tryParse(argResults['listen']) ?? 8081,
  );

  await mqtt.connect(
    argResults['mqtt-server'] ?? 'ws://rithviknishad.ddns.net',
    port: int.tryParse(argResults['mqtt-port']) ?? 8080,
    as: 'simulink-push-pull-${server.hashCode}',
    username: argResults['mqtt-username'],
    password: argResults['mqtt-password'],
  );

  server.listen(handleConnection);

  stdout.writeln(
    'SocketServer listening at: ${server.address.address}:${server.port}',
  );
}

void handleConnection(Socket client) {
  stdout.writeln('>>> ${DateTime.now()} Simulink run started.');

  mqtt.updateState({
    Topics.isRunning: 'true',
  });

  client.listen(
    (data) => mqtt.updateState(
      {
        // All attributes
        ...simulink.parsePacket(data).map(
              (topic, value) => MapEntry(topic, value.toStringAsFixed(4)),
            ),
        // Timestamp
        Topics.lastUpdatedOn: DateTime.now().toString(),
      },
    ),

    // Log the error.
    onError: (error) {
      stdout.writeln(
        'Error in `handleConnection` for client ${client.address.address}:${client.port}. Error: $error',
      );

      client.close();

      mqtt.updateState({
        Topics.isRunning: '-1',
      });
    },

    // Log end of simulink simulation
    onDone: () {
      stdout.writeln('>>> ${DateTime.now()} Simulink run stopped.');
      client.close();

      mqtt.updateState({
        Topics.isRunning: '0',
      });
    },
  );
}
