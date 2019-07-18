classdef LoomoSocket
    %LoomoSocket Communicates with your loomo over WiFi
    %   Detailed explanation wil be filled in here
    %   Test
    
    % Constants   
    properties (Access = protected)
        serverIp    string % Holds server IP
        serverPort  int16  % Holds serve port
    end
    
    properties
        t           TCPcli % Holds TCP connection
    end
    
    
    methods
        function obj = init(serverIp,serverPort)
            %init(serverIP,serverPort) Construct an instance of this class
            %   By initializing TCPip with desired IP and Port
            obj.serverIp = serverIp;
            obj.serverPort = serverPort;
        end
        
        function start(obj)
            %start Start the TCP connection
            %   Opens the TCP connection, takes no arguments
            fopen(obj.t);
        end
    end
end

