classdef LoomoSocket
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
    
    properties (Access = private, Hidden = true, Constant)
        ENCODING = 'utf-8'
        BIT_TYPE = 'uint8'
        WAIT_DELAY = 2; % waitForData
        WAIT_EMPTY = 0.08; % Wait at end of read
        IN_LOOP_WAIT = 0.01; % Pause time in loop to prevent spamming
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
            fopen(obj.t);
        end
        
        function close(obj)
            %close Closes the TCP connection
            %   Closes the TCP connection, takes no arguments
            fclose(obj.t);
        end
        
        function sendString(obj, string)
            bitArray = unicode2native(string,obj.ENCODING);
            if length(bitArray)<256
               obj.sendShortBytes(bitArray) 
            else
                warning('Loog sting not implemented')
                warning(string)
            end
            
        end
        
    end %Method
        
        
    
    methods (Access = protected, Hidden = true)
        
        function sendShortBytes(obj,bitArray)
            l = length(bitArray);
            if l >255
                warning('Bit Array to long, use sendLongArray')
            else
                fwrite(obj.t,[l, bitArray],obj.BIT_TYPE)
            end
        end
                
        function sucsess = waitForData(obj,delay)
            %waitForData wait a given time (default 2s) for available data
            %   Checks if data is available on socket if data
            %   is available it returns true, if timeout returns false
            %
            %   Takes one optional argument, delay, which is the desired
            %   wait time
            
            sucsess = true;
            if nargin < 2
                delay = obj.WAIT_DELAY; %Max wait time
                deadlineMax = true;
            else
                deadlineMax = false;
            end
           pauseStart = tic;
            %Wait for responce on server
           while(obj.t.BytesAvailable < 1)
               pause(obj.IN_LOOP_WAIT)
               if toc(pauseStart)> delay
                   if deadlineMax
                      warning('Timeout in waitForData')
                      toc(pauseStart)
                   end
                   sucsess = false;
                   return
               end
           end
        end
    end
end

