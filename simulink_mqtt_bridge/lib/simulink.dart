import 'dart:io';
import 'dart:typed_data';

import 'package:simulink_mqtt_bridge/topics.dart';

double _maxVout = -1.0, _maxIout = -1.0, _maxPout = -1.0;

Map<Topics, double> parsePacket(Uint8List data) {
  final packet = String.fromCharCodes(data);

  final attributes = _decodePacket(packet);

  var vOut = attributes.elementAt(0),
      iOut = attributes.elementAt(1),
      vIn = attributes.elementAt(2),
      iIn = attributes.elementAt(3);

  var pIn = vIn * iIn,
      pOut = vOut * iOut,
      efficiency = pOut * 1e2 / pIn,
      load = pOut / 1e3;

  if (_maxVout < vOut) _maxVout = vOut;
  if (_maxIout < iOut) _maxIout = iOut;
  if (_maxPout < pOut) _maxPout = pOut;

  return {
    // Directly propogating values
    Topics.outputVoltage: vOut,
    Topics.outputCurrent: iOut,
    Topics.inputVoltage: vIn,
    Topics.inputCurrent: iIn,

    // Calculated values
    Topics.inputPower: pIn,
    Topics.outputPower: pOut,
    Topics.efficiency: efficiency,
    Topics.load: load,

    // Values updated only if there's a change.
    if (_maxVout == vOut) Topics.maxVoltage: _maxVout,
    if (_maxIout == iOut) Topics.maxCurrent: _maxIout,
    if (_maxPout == pOut) Topics.maxPower: _maxPout,
  };
}

List<double> _decodePacket(String packet) {
  try {
    final attributes = packet.split(',');

    if (attributes.length != 4) {
      throw Exception(
        "packet.split(',').length != 4. Got: ${attributes.length}",
      );
    }

    return [
      for (final attribute in attributes) double.parse(attribute),
    ];
  } catch (ex) {
    stdout.writeln('could not decode.\nException: $ex\nReceived: $packet');

    // Voluntarily propogating the error to further stages.
    // (Not to be used in production).
    return List.filled(4, -1.0);
  }
}
