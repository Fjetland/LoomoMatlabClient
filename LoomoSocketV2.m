classdef LoomoSocketV2
    %LoomoSocket Communicates with your loomo over WiFi
    %   Detailed explanation wil be filled in here
    %   Test
    
    % Constants   
    properties (Access = public)
        serverIp    char % Holds server IP
        serverPort  double  % Holds serve port
        
        t = tcpip('localhost'); % Holds TCP connection
                % As tcpip (at this time) do not support
                % class initialization, this object is
                % initiaized with a localhost dummy
    end
        %% Settings
    properties (Access = private, Hidden = true, Constant)
        ENCODING = 'utf-8'
        BIT_TYPE = 'uint8'
    end
    
    
    methods
        function obj = LoomoSocketV2(serverIp,serverPort)
            %LoomoSocket(serverIP,serverPort) Construct an instance of this class
            %   By initializing TCPip with desired IP and Port
            obj.serverIp = serverIp;
            obj.serverPort = serverPort;
            obj.t = tcpip(obj.serverIp, obj.serverPort, 'NetworkRole', 'client');
        end
        
        function open(obj)
            %open Open the TCP connection
            %   Opens the TCP connection, takes no arguments
            fopen(obj.t);
        end
        
        function close(obj)
            %close Closes the TCP connection
            %   Closes the TCP connection, takes no arguments
            
            fclose(obj.t);
        end
        
         function sendJsonString(obj, string)
            bitArray = obj.string2bytes(string);
            if length(bitArray)<255
               obj.sendByteArray(bitArray) 
            else
                error("String is to long")
            end
         end
        
         function string = reciveJsonString(obj)
            bytes = obj.readByteArray();
            string = obj.bytes2string(bytes);
         end
         
         function sendFollowUpString(obj,string)
            bytes = obj.string2bytes(string);
            fwrite(obj.t,bytes,obj.BIT_TYPE)
         end
        
    end
    
    % Private methodes
    methods (Access = protected, Hidden = true)
        
        function bytes = string2bytes(obj,string)
            bytes = unicode2native(string,obj.ENCODING);
        end
        
        function string = bytes2string(obj,bytes)
            string  = native2unicode(bytes',obj.ENCODING);
        end
        
        function sendByteArray(obj,bitArray)
            l = length(bitArray);
            fwrite(obj.t,[l, bitArray],obj.BIT_TYPE)
        end
        
        function bytes = readByteArray(obj)
           val = fread(obj.t,1);
           bytes = fread(obj.t,val);           
        end
        
    end
end

