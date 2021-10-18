enum Topics {
  outputVoltage,
  outputCurrent,
  inputVoltage,
  inputCurrent,
  inputPower,
  outputPower,
  efficiency,
  maxVoltage,
  maxCurrent,
  maxPower,
  load,
  lastUpdatedOn,
  isRunning,
}

extension TopicsStringifier on Topics {
  String get topic {
    final value = toString().split('.').last;
    return 'ps/state/${value[0].toUpperCase()}${value.substring(1)}';
  }
}
