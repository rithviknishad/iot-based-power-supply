modelToRun = 'basic_buck'; timeToRun = 60;

% Create and instance of MQTT Client that is connected to the server, using
% websockets protocol on port 8080.
client = mqtt("ws://xtensablade.ddns.net", 'port', 8080);

% This is the topic where the service of the power supply will be running.
srvc_addr = 'iot_ps/ps1';

% Listen to inputs on the service address topic.
subscribe(client, srvc_addr, 'Callback', @setVoltageMsgCallback);

v_out = 0;

% Deploy the simulation to run for some pre-defined time
% Make sure the following simulation has `Real-Time Synchronization` block
sim(modelToRun, timeToRun);

function setVoltageMsgCallback(~, msg)
    global v_out;
    
    v_out = str2double(msg);
    fprintf('Setting voltage to: %s V', msg);
end