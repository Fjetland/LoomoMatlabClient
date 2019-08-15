classdef BackgroundLoomoConnector < handle
    %DEMOCONNECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        ip          % IpAdress
        port        % Port
        
        % Timers
        lastTic = 0;
        dt = 0;
        
        % Commands
        newVolume = false;
        volume = 0.5;
        
        % Speak
        newSpeak = false;
        speakString
        
        % EnableDrive
        newEnableDrive = false;
        enableDriveValue = false;
        
        % enableImage
        newEnableImages = false;
        colorFast = false;
        colorLarge = false;
        depth = false;
        
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
        
        % Image
        getImage = 0; % 0 = none, 1 = color fast, 2 = color large, 3 = depth
        getImage2 = 0;
        imgFreq = 2;
        imgCount = 0;
        imgData = [0,0,0];
        imgData2 = [0,0,0];
        fetchImage = false;
        
        % Pose 2D
        velocity = 0;
        turnRate = 0;
        xBase = 0;
        yBase = 0;
        thBase = 0;
        
        % Surroundings
        ir_left = 0;
        ir_right = 0;
        uss = 0;
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
        
        function bool = checkError(obj)
            bool = false;
           if ~isempty(obj.worker.Error)
               disp(obj.worker)
               bool = true;
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
            obj.worker = parfeval(obj.cpuPool,...
                @obj.par_enableDrive,0,obj.loomo, bool);
        end
        
        function enableVision(obj,color,colorLarge, depth)
            %obj.waitUntilDone();
            obj.worker = parfeval(obj.cpuPool,...
                @obj.par_enableVision,0,obj.loomo,color,colorLarge, depth);            
        end
        
        function getImageFun(obj,imgType)
            obj.worker = parfeval(obj.cpuPool,...
                @obj.par_getImage,1,obj.loomo,imgType);            
        end
        
        function runMainLoop(obj)
            
            set.newEnableImages = obj.newEnableImages;
            if obj.newEnableImages
               set.colorFast = obj.colorFast;
               set.colorLarge = obj.colorLarge;
               set.depth = obj.depth;
               obj.newEnableImages = false;
            end
            
            set.newEnableDrive = obj.newEnableDrive;
            if obj.newEnableDrive
               set.enableDriveValue = obj.enableDriveValue;
               obj.newEnableDrive = false;
            end
            
            set.newVolume = obj.newVolume;
            if obj.newVolume
               set.volume = obj.volume;
               obj.newVolume = false;
            end
            
            set.newSpeak = obj.newSpeak;
            if obj.newSpeak
               set.speakString = obj.speakString; 
               obj.newSpeak = false;
            end
            
            
            set.readVelocity = obj.readVelocity;
            set.readSurroundings = obj.readSurroundings;
            
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
            
            set.getImage = obj.getImage;
            set.getImage2 = obj.getImage2;
            obj.fetchImage = false;
            if obj.getImage >0 || obj.getImage2 >0
               if mod(obj.imgCount,obj.imgFreq) ~= 0
                   set.getImage = 0;
                   set.getImage2 = 0;
               else
                   obj.fetchImage = true;
               end
               %disp(['Main Run set Image: ',num2str(set.getImage)])
               obj.imgCount = obj.imgCount+1;
            end
            
            
            obj.waitUntilDone();
            obj.worker = parfeval(obj.cpuPool,...
               @obj.mainPar,1,obj.loomo,set);
           
        end
        
        function getMainResults(obj)
            %disp('2-2: Getting Main')
            %obj.worker
            if ~obj.checkError()
                data = fetchOutputs(obj.worker);
               if obj.readVelocity && isfield(data,'sP2d')
                   obj.velocity = data.sP2d.vl;
                   obj.turnRate = data.sP2d.va;
                   obj.xBase = data.sP2d.x;
                   obj.yBase = data.sP2d.y;
                   obj.thBase = data.sP2d.th;
               end

               if obj.readSurroundings && isfield(data,'sSur')
                   obj.ir_left = data.sSur.irl;
                   obj.ir_right = data.sSur.irr;
                   obj.uss = data.sSur.uss;
               end
               
               if obj.fetchImage
                   try
                       if obj.getImage>0
                           obj.imgData = data.img;
                       end
                       if obj.getImage2 > 0
                          obj.imgData2 = data.img2; 
                       end
                   catch me
                       warning('Did not find image')
                       warning(me.message)
                   end
               end
            end
           
        end
    end
    
    % Paralell Main function
    
    methods (Static)
        function data = mainPar(loomo,set)
           tStart = tic;
           
           if set.newEnableDrive
              loomo.enableDrive(set.enableDriveValue) 
           end
           
           if set.newEnableImages
              loomo.enableVision(set.colorFast,set.colorLarge,set.depth)
           end
           
           if set.newVolume
              loomo.setVolume(set.volume);
           end
           
           if set.newSpeak
              loomo.speakLine(set.speakString); 
           end
           
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
           
           if set.getImage > 0
                data.img = loomo.getImage(set.getImage-1);
           end
           if set.getImage2 > 0
                data.img2 = loomo.getImage(set.getImage2-1);
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

