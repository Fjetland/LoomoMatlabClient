classdef LoomoSocket < handle
    %LoomoSocket Communicates with your loomo over WiFi
    %   Loomo socket is a class for handeling string and byte communication
    %   with the LoomoSocketServerApp. The protocoles displayed here for
    %   reading and writing bytes is mached with the LoomoSockedServerApp
    %   and they must be changed in unison.
    %
    
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
        
        maxLength =65535;
    end
    
    
    methods
        function obj = LoomoSocket(serverIp,serverPort)
            %LoomoSocket(serverIP,serverPort) Construct an instance of this class
            %   By initializing TCPip with desired IP and Port
            obj.serverIp = serverIp;
            obj.serverPort = serverPort;
            obj.t = tcpip(obj.serverIp, obj.serverPort, 'NetworkRole', 'client');
        end
        
        function open(obj)
            %open Open the TCP connection
            %   Opens the TCP connection, takes no arguments
            try
                fopen(obj.t);
                %disp('Connected to Loomo')
            catch e
                disp('Connection failed...')
                error(e.message)
            end
        end
        
        function close(obj)
            %close Closes the TCP connection
            %   Closes the TCP connection, takes no arguments
            try 
                fclose(obj.t);
            catch e
                warning(e.message)
            end
            disp('Disconnected from Loomo')
        end
        
         function sendJsonString(obj, string)
             % sendJsonString(obj, string)
            bitArray = obj.string2bytes(string);
            if length(bitArray)<obj.maxLength
               obj.sendByteArray(bitArray) 
            else
                error("String is to long")
            end
         end
        
         function string = reciveJsonString(obj)
            bytes = obj.readByteArray();
            string = obj.bytes2string(bytes);
         end
         
%          function sendFollowUpString(obj,string)
%             bytes = obj.string2bytes(string);
%             fwrite(obj.t,bytes,obj.BIT_TYPE)
%          end
         
         function bytes = readLongByteArray(obj, length)
            bytes = fread(obj.t,length); 
         end
         
         function flush(obj)
            flushinput(obj.t)
         end
        
    end
    
    % Private methodes
    methods %(Access = protected, Hidden = true)
        
        function bytes = string2bytes(obj,string)
            bytes = unicode2native(string,obj.ENCODING);
        end
        
        function string = bytes2string(obj,bytes)
            string  = native2unicode(bytes',obj.ENCODING);
        end
        
        function sendByteArray(obj,bitArray)
            l = length(bitArray);
            b1 = bitshift(l,-8);
            b2 = bitand(l,255); % 255 = 0x00FF - hex2dec('00FF')
            fwrite(obj.t,[b1, b2, bitArray],obj.BIT_TYPE)
        end
        
        function bytes = readByteArray(obj)
           val = fread(obj.t,2);
           length = bitor(bitshift(val(1),8),val(2));
           bytes = fread(obj.t,length,obj.BIT_TYPE);           
        end
    end
end

