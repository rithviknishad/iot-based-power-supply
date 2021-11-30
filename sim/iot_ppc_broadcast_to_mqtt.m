% This potentially extrinsic function maybe invoked hundreds of times a second.
% When modifying the method, keep in mind about performance and time complexity.
%
% Time Complexity = O(1)
function iot_ppc_broadcast_to_mqtt(data)
    
    % Not crazy to reinitialize client and topics 1000 times a second.
    % So marked as persistent.
    persistent client;
    persistent topics;
    
    % Initialize client and topics if necessary (runs only once)
    if isempty(client)

        % Connect to Mosquitto server hosted at `rithviknishad.ddns.net`
        % 
        % TODO: consider changing it to WebSockets based MQTT for improved network performance.
        % TODO: mask or obscure the url on release.
        client = mqtt("tcp://rithviknishad.ddns.net");

        % To re-order vector data's corresponding topics, or add new topics
        % modify below vector.
        % (Note: ORDER OF DATA VECTOR AND TOPIC MUST BE IN SYNC)
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

    % Convert type Vector<dynamic> to Vector<String>
    data = string(data);

    % Publish all data for available topics.
    for i = 1 : length(topics)
        publish(client, topics(i), data(i));
    end

    timestamp = string(datetime(now, 'ConvertFrom', 'datenum'));

    publish(client, "ps/state/LastUpdatedOn", timestamp);
end

