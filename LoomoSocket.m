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
        
        function sendString(obj, str)
           fprintf(obj.t,str); 
        end
        
        function answer = echoTest(obj,text)
            %echoTest Sends string and awaits reply
            %   Test connection, by sending a string and
            %   listening for the reply.
            %
            %   Needs no arguments
            %   text (optional) - to send costum string
            
            % Check if test string is supplied
            if nargin<2 || isempty(text)
                % Create text string
                text = double(sprintf('Hello World!\nNyLinje'));
            end
           fprintf(obj.t,text); 
           obj.waitForData();
           
           answer = obj.readAllBytes()';
        end
    end
    
    methods (Access = protected, Hidden = true)
        function bitArray = readAllBytes(obj)
            %readAllBytes Reads until buffer is empty
            %   Reads TCP input buffer untill empty, wait
            %   at the end to enshure empty
            bitArray = [];
            count = 0;
           while(obj.t.BytesAvailable)
               read = fread(obj.t,obj.t.BytesAvailable);
               if count>0
                    bitArray= [bitArray; 10; read];
               else
                   bitArray= [read];
               end
               count = count+1;
              obj.waitForData(obj.WAIT_EMPTY);
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

