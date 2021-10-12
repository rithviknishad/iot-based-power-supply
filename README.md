# IoT based power supply

A power supply that can be controlled and monitored using MQTT.

## Tasks

- [x] `node-red` server and `MQTT mosquitto` server setup (Rithvik)
- [ ] `node-red` based monitoring of PS (Karthik)
- [ ] `node-red` based controlling of PS (Karthik)
- [ ] IoT Firmware using `nonos-sdk` on ESP8266 (Rithvik)
- [ ] Simulink model for simple power converter (Rohith)
- [ ] Serial COM integration w/ Simulink (Rohith and Rithvik)

### Running the Simulink MQTT Bridge Server

```sh
dart run simulink_mqtt_bridge/bin/simulink_mqtt_bridge.dart
```

or run the compiled stable versions:

```sh
./simulink_mqtt_bridge_linux64
```

### Provisioned topics in MQTT ecosystem

```yaml
setters:
  - topic: ps/OutputVoltage
    expects:
      - <double>
    description: setter for PS's reference output voltage
    retain: True

  - topic: ps/Enabled
    expects:
      - 0 # Disabled
      - 1 # Enabled
    description: whether the converter should be enabled or not
    retain: True

getters:
  - topic: ps/state/OutputVoltage
    description: PS's output voltage (V)
    retain: True

  - topic: ps/state/OutputCurrent
    description: PS's output current (A)
    retain: True

  - topic: ps/state/InputVoltage
    description: PS's input voltage (V)
    retain: True

  - topic: ps/state/InputCurrent
    description: PS's input current (A)
    retain: True

  - topic: ps/state/InputPower
    description: PS's input power (W)
    retain: True

  - topic: ps/state/OutputPower
    description: PS's output power (W)
    retain: True

  - topic: ps/state/Efficiency
    description: PS's efficiency (%)
    retain: True

  - topic: ps/state/MaxVoltage
    description: PS's max design voltage (V)
    retain: True

  - topic: ps/state/MaxCurrent
    description: PS's max design current (A)
    retain: True

  - topic: ps/state/MaxPower
    description: PS's max design power (W)
    retain: True

  - topic: ps/state/Load
    description: PS's load wrt max design power (%)
    retain: True

```

#### SSH into the server

Run the following command in your favourite terminal.

```sh
ssh rithviknishad@xtensablade.ddns.net
```

If the server is up, it'll prompt for authentication. Contact the server admin to know the password.

**Note**: If your machine is connecting for the first time to the server, it'll ask to add permanently to known hosts. Enter `yes`.

#### Connecting to node-red hosted on the server

[http://xtensablade.ddns.net:1880](http://xtensablade.ddns.net:1880)

If the site can't be reached due to `ERR_CONNECTION_REFUSED`, probably node-red isn't launched in the server yet.

You can manually launch it, by accessing the server through `ssh` as dicussed above and running the following command:

```sh
node-red
```

If it outputs about failed to connect to mqtt-server, consider restarting the mosquitto server as discussed below.

If it outputs about listener 0.0.0.0:1880 already in use, consider terminating the current process by hitting `Ctrl+C` and following the *restart `node-red` process* guide below.

#### Restart existing `mosquitto` server process

Sometimes if you may want to restart mosquitto server, first `SIGKILL` the existing process by running the following and press tab followed by enter.

```sh
sudo kill mosq<PRESS_TAB>
```

Since the server's default shell is powered by `zsh` along with `oh-my-zsh`, it'll replace the process name (i.e, `mosquitto`) with the PID of the process automatically.

To start the `mosquitto` server run the following in `$HOME` directory.

```sh
cd # equivalent to cd $HOME, ignore if already in home dir.
mosquitto -c mosquitto.conf # Launch mosquitto w/ config file: mosquitto.conf
```

In bash, to know the PID of the process, run:

```sh
ps -A | grep mosquitto
```

#### Restart existing `node-red` server process

Sometimes if you may want to restart the node-red server, first `SIGKILL` the existing process by running the following and press tab followed by enter.

```sh
sudo kill node<PRESS_TAB>
```

Since the server's default shell is powered by `zsh` along with `oh-my-zsh`, it'll replace the process name (i.e, `node-red`) with the PID of the process automatically.

To start the `node-red` server run the following

```sh
node-red
```

In bash, to know the PID of the process, run:

```sh
ps -A | grep node-red
```

### Authors

- [19BEE1050 Rithvik Nishad](https://github.com/rithviknishad)
- [19BEE1088 Rohith Das](https://github.com/imrohiit)
- [19BEE1216 Karthik P Ajithkumar](https://github.com/karthikpaji)

B.Tech. Electrical and Electronics Engineering
VIT Chennai
