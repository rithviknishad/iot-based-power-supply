% Connects to MQTT server on first invocation and publishes the data to 
% MQTT Ecosystem to it's respective topics.
function iot_ppc_broadcast_to_mqtt(data)
    
    persistent client;
    persistent topics;
    
    % Initialize client and topics if necessary (runs only once)
    if isempty(client)

        % Connect to Mosquitto server hosted at `rithviknishad.ddns.net`
        client = mqtt("tcp://rithviknishad.ddns.net");

        topics = [
            "ps/state/OutputVoltage"
            "ps/state/OutputCurrent"
            "ps/state/OutputPower"
            "ps/state/InputVoltage"
            "ps/state/InputCurrent"
            "ps/state/InputPower"
            "ps/state/Efficiency"
        ];
    end

    % Stringify all elements of `data`
    data = string(data);

    % Publish all elements of `data` to it's respective topics.
    for i = 1 : length(topics)
        publish(client, topics(i), data(i));
    end
    
    timestamp = string(datetime(now, 'ConvertFrom', 'datenum'));
    publish(client, "ps/state/LastUpdatedOn", timestamp);
end

