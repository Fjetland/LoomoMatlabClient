classdef BackgroundLoomoConnector < handle
    %DEMOCONNECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        ip          % IpAdress
        port        % Port
        
        % Timers
        lastTic = 0;
        dt = 0;
        
        
        % Drive on keys
        driveOnKeys = false;
        keyVelocity = 0;
        keyTurnRate = 0;
        keyNewHead = false;
        keyHeadPitch = pi/5;
        keyHeadYaw = 0;
        
        % Data to read
        readVelocity = false;
        readSurroundings = false;
        
        % Status
        velocity = nan;
        turnRate = nan;
        
        ir_left = nan;
        ir_right =nan;
        uss = nan;
    end
    
    properties % ToBe Private
        %Loomo values
        loomo Loomo
        
        % Prossesing values
        cpuPool     parallel.Pool
        workers = 1
        worker      parallel.FevalFuture
    end
    
    methods
        function obj = BackgroundLoomoConnector(ip, port)
            %DEMOCONNECTOR Construct an instance of this class
            %   Detailed explanation goes here
            
            warning off 'parallel:cluster:CannotSaveCorrectly'
            
            obj.ip = ip;
            obj.port = port;
            
            obj.cpuPool = gcp('nocreate');
            if isempty(obj.cpuPool)
                obj.cpuPool = parpool(obj.workers);
            end
            
        end
        
        function bool = isPoolReady(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            bool = obj.cpuPool.Connected;
        end
        
        function closePool(obj)
           obj.cpuPool.delete();
        end
        
        function runTest(obj)
            obj.worker = parfeval(obj.cpuPool,@magic,1,10);
        end
        
        function bool = isFinished(obj)
            bool = strcmp(obj.worker.State,'finished');
        end
        
        function bool = isRunning(obj)
            bool = strcmp(obj.worker.State,'running');
        end
        
        function res = getResult(obj)
            if ~isempty(obj.worker.Error)
                error(obj.worker.Error)
            end
           res = fetchOutputs(obj.worker);
        end
        
        function bool = waitUntilDone(obj)
            try
                while strcmp(obj.worker.State,'running')
                    % Wait til finished
                end
                bool = true;
            catch e
                warning(e.message)
                bool = false;
            end
        end
        
        function checkError(obj)
           if ~isempty(obj.worker.Error)
               error(obj.worker.Error)
           end
        end
        
        %% Loomo Functions
        
        function connect(obj)
            obj.worker = parfeval(obj.cpuPool,...
                @obj.par_connect,1,obj.ip,obj.port);

            obj.loomo = obj.getResult();
        end
        
        function disconnect(obj)
           obj.waitUntilDone();
           obj.worker = parfeval(obj.cpuPool,...
                @obj.par_disconnect,0,obj.loomo);
        end
        
        function enableDrive(obj, bool)
            %obj.waitUntilDone();
            obj.getMainResults();
            obj.worker = parfeval(obj.cpuPool,...
                @obj.par_enableDrive,0,obj.loomo, bool);
            obj.runMainLoop()
            
        end
        
        function enableVision(obj,color,colorLarge, depth)
            %obj.waitUntilDone();
            obj.getMainResults();
            obj.worker = parfeval(obj.cpuPool,...
                @obj.par_enableVision,0,obj.loomo,color,colorLarge, depth);
            obj.runMainLoop()
        end
        
        function runMainLoop(obj)
            
            set.readVelocity = true;
            set.readSurroundings = true;
            
            set.driveOnKey = obj.driveOnKeys;
            if obj.driveOnKeys
                set.keyVelocity = obj.keyVelocity;
                set.keyTurnRate = obj.keyTurnRate;
                
                set.keyNewHead = obj.keyNewHead;
                set.keyHeadPitch = obj.keyHeadPitch;
                set.keyHeadYaw = obj.keyHeadYaw;
                
            end
            %obj.keyVelocity = 0;
            %obj.keyTurnRate = 0;
            
            
            obj.waitUntilDone();
            obj.worker = parfeval(obj.cpuPool,...
               @obj.mainPar,1,obj.loomo,set);
           
        end
        
        function getMainResults(obj)
            %disp('2-2: Getting Main')
            %obj.worker
            obj.checkError();
           data = fetchOutputs(obj.worker);
           if isfield(data,'sP2d')
               obj.velocity = data.sP2d.vl;
               obj.turnRate = data.sP2d.va;
           end
           
           if isfield(data,'sSur')
               obj.ir_left = data.sSur.irl;
               obj.ir_right = data.sSur.irr;
               obj.uss = data.sSur.uss;
           end
        end
    end
    
    % Paralell Main function
    
    methods (Static)
        function data = mainPar(loomo,set)
           tStart = tic;
           
           if set.driveOnKey
               loomo.setVelocity(set.keyVelocity,set.keyTurnRate) 
              
               if set.keyNewHead
                  loomo.setHeadPosition(set.keyHeadYaw, set.keyHeadPitch)
               end
           end
           
           if set.readVelocity
               data.sP2d = loomo.getPose2D();
           end
           
           if set.readSurroundings
                data.sSur = loomo.getSurroundings();
           end

           data.time = toc(tStart);
        end
    end
    
    %% Parallel base functions
    
    methods (Static)
        function loomo = par_connect(ip, port)
            loomo = Loomo(ip,port);
            loomo.connect();
        end
        
        function par_disconnect(loomo)
           loomo.disconnect();
        end
        
        function par_enableDrive(loomo, bool)
            loomo.enableDrive(bool);
        end
        
        function par_enableVision(loomo, color,colorLarge, depth)
             loomo.enableVision(color, colorLarge, depth);
        end
        
        function ret = par_getBaseImu(loomo)
            ret = loomo.getBaseImu();
        end
        
        function ret = par_getBaseTick(loomo)
           ret = loomo.getBaseTick(); 
        end
        
        function ret = par_getHeadJoint(loomo)
           ret = loomo.getHeadJoint(); 
        end
        
        function ret = par_getHeadWorld(loomo)
           ret = loomo.getHeadWorld(); 
        end
        
        function ret = par_getImage(loomo,type)
           ret = loomo.getImage(type); 
        end
        
        function par_speakLine(loomo,string)
           loomo.speakLine(string); 
        end
    end
end

