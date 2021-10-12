import 'dart:io';

import 'package:simulink_mqtt_bridge/simulink.dart' as simulink;
import 'package:simulink_mqtt_bridge/mqtt.dart' as mqtt;

void main() async {
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 8081);

  stdout.writeln(
    'socket server listening at: ${server.address.address}:${server.port}',
  );

  await mqtt.connect(
    'ws://xtensablade.ddns.net',
    port: 8080,
    as: 'simulink-push-pull-${server.hashCode}',
  );

  server.listen(handleConnection);
}

void handleConnection(Socket client) {
  stdout.writeln('>>> ${DateTime.now()} Simulink run started.');

  client.listen(
    (data) => mqtt.updateState(
      simulink.parsePacket(data).map(
            (topic, value) => MapEntry(topic, value.toStringAsFixed(4)),
          ),
    ),

    // Log the error.
    onError: (error) {
      stdout.writeln(
        'Error in `handleConnection` for client ${client.address.address}:${client.port}. Error: $error',
      );

      client.close();
    },

    // Log end of simulink simulation
    onDone: () {
      stdout.writeln('>>> ${DateTime.now()} Simulink run stopped.');
      client.close();
    },
  );
}
