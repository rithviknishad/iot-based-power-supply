import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:simulink_mqtt_bridge/topics.dart';

late final MqttServerClient _client;

Future<void> connect(
  String server, {
  required int port,
  required String as,
  String? username,
  String? password,
}) async {
  _client = MqttServerClient.withPort(server, as, port);

  _client
    ..keepAlivePeriod = 20
    ..useWebSocket = true
    ..autoReconnect = true
    ..onAutoReconnect = (() => _log('auto-reconnecting to mqtt-server.'))
    ..onAutoReconnected = (() => _log('auto-reconnected to mqtt-server'))
    ..onConnected = (() => _log('connected to mqtt-server'))
    ..onDisconnected = (() => _log('disconnected from mqtt-server'));

  try {
    await _client.connect(username, password);
  } on NoConnectionException catch (e) {
    print(e);
    _client.disconnect();
    exit(1);
  } on SocketException catch (e) {
    print(e);
    _client.disconnect();
    exit(e.osError?.errorCode ?? 1);
  }
}

void updateState(
  Map<Topics, String> states, {
  MqttQos qos = MqttQos.atLeastOnce,
}) {
  states.forEach((key, value) {
    final payload = MqttClientPayloadBuilder().addString(value).payload!;
    _client.publishMessage(key.topic, qos, payload);
  });
}

void _log(String message) => stdout.writeln(message);
