classdef Loomo < handle 
    %LOOMO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        loomoIp    char % Loomo Ip adress
        loomoPort  double  % Loomo communication port
        
        socket     LoomoSocket % Loomo TCP connection
        
        sendDirectly = false        % NB:SLOW! - Send every command at once and await reply (do not require .send-.recive)
    end
    
    properties (SetAccess = private, SetObservable = true)
        
        sensorDistanceFront double  % (RO) Ultrasonic front sensor [mm] (Surroundings)
        sensorDistanceLeft  double  % (RO) Inrared left front ground sensor [mm] (Surroundings)
        sensorDistanceRight double  % (RO) Inrared right front ground sensor [mm] (Surroundings)
        
        sensorBaseVelocity 	double  % (RO) Linear Velocity [m/s] (Pose2D)
        sensorBaseTurnRate  double  % (RO) Angular Velocity [rad/s] (Pose2D)
        sensorBasePoseX     double  % (RO) X position [m] (Pose2D)
        sensorBasePoseY     double  % (RO) Y position [m] (Pose2D)
        sensorBasePoseTh    double  % (RO) Th rotation [rad] (Pose2D)
        
        sensorWheelVelocityLeft  double % (RO) Left wheel velocity [m/s] (WheelSpeed)
        sensorWheelVelocityRight double % (RO) Right wheel velocity [m/s] (WheelSpeed)
        
        sensorWheelTickLeft  double % (RO) Left wheel ticks, ~1cm/tick [ticks] (WheelTick)
        sensorWheelTickRight double % (RO) Right wheel ticks, ~1cm/tick [ticks] (WheelTick)
        
        sensorBaseImuPitch  double  % (RO) Base Pitch [rad] (BaseImu)
        sensorBaseImuRoll   double  % (RO) Base Roll [rad] (BaseImu)
        sensorBaseImuYaw    double  % (RO) Base Yaw [rad] (BaseImu)
        
        sensorHeadWorldPitch double % (RO) Head Pitch in world frame [rad] (HeadWorld)
        sensorHeadWorldRoll  double % (RO) Head Roll in world frame [rad] (HeadWorld)
        sensorHeadWorldYaw   double % (RO) Head Yaw in world frame [rad] (HeadWorld)
        
        sensorHeadJointPitch double % (RO) Head Pitch in base frame [rad] (HeadJoint)
        sensorHeadJointRoll  double % (RO) Head Roll in base frame [rad] (HeadJoint)
        sensorHeadJointYaw   double % (RO) Head Yaw in base frame [rad] (HeadJoint)
        
        sendStructure % Structure containing commands to be sent
    end
    
    properties (Access = private,  Hidden=true)
       awaitingData = false;
       dataIsRequested = false; 
    end
    
            %% Action ids
    properties (Access = private, Hidden = true, Constant)
       ACTION = 'ack'
       A_SEQUENCE = 'seq'
       
       A_ENABLE_DRIVE = 'enableDrive'
       A_ENABLE_DRIVE_VALUE = 'value'
       
       A_ENABLE_VISION = 'enableVision'
       

       A_VELOCITY = 'vel'
       A_VELOCITY_ANGULAR = 'av'
       A_VELOCITY_LINEAR = 'v'
       
       A_POSITION = 'pos'
       A_POSITION_ARRAY = 'posar';
       A_POSITION_X = 'x'
       A_POSITION_Y = 'y'
       A_POSITION_TH = 'th'
       A_POSITION_ADD = 'add'
       A_POSITION_VLS = 'vls'
       
       A_SPEAK = 'spk';
       A_SPEAK_LENGTH = 'l';
       A_SPEAK_STRING = 's'
       A_SPEAK_QUE = 'q';
       A_SPEAK_PITCH = 'p';
       A_SPEAK_QUE_DEFAULT = 0; % Play now, (0 play now, 1 play after)
       A_SPEAK_PITCH_DEFAULT = 1.0;
       
       A_VOLUME = 'vol';
       A_VOLUME_VALUE = 'v';
       
       A_HEAD = 'hed';
       A_HEAD_PITCH = 'p';
       A_HEAD_YAW = 'y';
       A_HEAD_LIGHT = 'li';
       A_HEAD_MODE = 'm';
    end
    
            %% Data ids
    properties (Access = private, Hidden = true, Constant)
        D_DATA_LBL = 'dat';
        
        D_IMAGE = 'img';
        
        D_IMAGE_TYPE = 'type';
        D_IMAGE_TYPE_COLOR = 'Color';
        D_IMAGE_TYPE_COLOR_SMALL = 'ColorSmall'
        D_IMAGE_TYPE_DEPTH = 'Depth'
        
        % Data return types
        D_SURROUNDINGS = 'sSur';
        D_WHEEL_SPEED = 'sWS';
        D_POSE2D = 'sP2d';
        D_HEAD_WORLD = 'sHPw';
        D_HEAD_JOINT = 'sHPj';
        D_BASE_IMU = 'sBP';
        D_BASE_TICK = 'sBT';
        
        % Data labels
        D_TIME_LBL = 'time';
        D_SURROUNDINGS_IRLEFT = 'irl';
        D_SURROUNDINGS_IRRIGHT = 'irr';
        D_SURROUNDINGS_ULTRASONIC = 'uss';
        D_WHEEL_SPEED_L = 'vl';
        D_WHEEL_SPEED_R = 'vr';
        D_POSE2D_X = 'x';
        D_POSE2D_Y = 'y';
        D_POSE2D_TH = 'th';
        D_POSE2D_VL = 'vl';
        D_POSE2D_VA = 'va';
        D_BASE_TICK_L = 'l';
        D_BASE_TICK_R = 'r';
        D_BASE_IMU_PITCH = 'p';
        D_BASE_IMU_ROLL = 'r';
        D_BASE_IMU_YAW = 'y';
        D_HEAD_PITCH = 'p';
        D_HEAD_ROLL = 'r';
        D_HEAD_YAW = 'y';
    end
    
    methods
        %%%                %%%
        %  Base Opperations  %
        %%%                %%%
        function obj = Loomo(loomoIp,loomoPort)
            %LOOMO Construct an instance of this class
            %   Detailed explanation goes here
            obj.loomoIp = loomoIp;
            obj.loomoPort = loomoPort;
            obj.socket = LoomoSocket(loomoIp,loomoPort);
            obj.socket.t.InputBufferSize = 1000000;
            obj.socket.t.OutputBufferSize = 65535;
            
        end
        
        function connect(obj)
            %connect Connect to Loomo
            %   Establish a TCP Connection to Loomo
            obj.socket.open()
        end
        
        function disconnect(obj)
            %DISCONNECT Disconnect from Loomo
            %   Close TCP connection with Loomo
           obj.socket.close() 
        end
        
        function send(obj)
           if ~isempty(obj.sendStructure)
              obj.socket.flush();
              obj.sendStructure.(obj.ACTION) = obj.A_SEQUENCE;
              jsE = jsonencode(obj.sendStructure);
              obj.socket.sendJsonString(jsE)
              obj.sendStructure = [];
              if obj.awaitingData
                 obj.dataIsRequested = true;
                 obj.awaitingData = false;
              end
           else
               warning('No information found in send que')
           end
        end
        
        function recive(obj)
            if obj.dataIsRequested
                data = obj.socket.reciveJsonString();
                data = jsondecode(data);
                if isfield(data,obj.D_SURROUNDINGS)
                    obj.sensorDistanceFront = data.(obj.D_SURROUNDINGS).(obj.D_SURROUNDINGS_ULTRASONIC);
                    obj.sensorDistanceLeft = data.(obj.D_SURROUNDINGS).(obj.D_SURROUNDINGS_IRLEFT);
                    obj.sensorDistanceRight = data.(obj.D_SURROUNDINGS).(obj.D_SURROUNDINGS_IRRIGHT);
                end
                
                if isfield(data,obj.D_WHEEL_SPEED)
                    obj.sensorWheelVelocityLeft = data.(obj.D_WHEEL_SPEED).(obj.D_WHEEL_SPEED_L);
                    obj.sensorWheelVelocityRight = data.(obj.D_WHEEL_SPEED).(obj.D_WHEEL_SPEED_R);
                end
                
                if isfield(data,obj.D_POSE2D)
                    obj.sensorBasePoseX = data.(obj.D_POSE2D).(obj.D_POSE2D_X);
                    obj.sensorBasePoseY = data.(obj.D_POSE2D).(obj.D_POSE2D_Y);
                    obj.sensorBasePoseTh = data.(obj.D_POSE2D).(obj.D_POSE2D_TH);
                    obj.sensorBaseVelocity = data.(obj.D_POSE2D).(obj.D_POSE2D_VL);
                    obj.sensorBaseTurnRate = data.(obj.D_POSE2D).(obj.D_POSE2D_VA);
                end
                
                if isfield(data,obj.D_HEAD_WORLD)
                    obj.sensorHeadWorldPitch = data.(obj.D_HEAD_WORLD).(obj.D_HEAD_PITCH);
                    obj.sensorHeadWorldRoll = data.(obj.D_HEAD_WORLD).(obj.D_HEAD_ROLL);
                    obj.sensorHeadWorldYaw = data.(obj.D_HEAD_WORLD).(obj.D_HEAD_YAW);
                end
                
                if isfield(data,obj.D_HEAD_JOINT)
                    obj.sensorHeadJointPitch = data.(obj.D_HEAD_JOINT).(obj.D_HEAD_PITCH);
                    obj.sensorHeadJointRoll = data.(obj.D_HEAD_JOINT).(obj.D_HEAD_ROLL);
                    obj.sensorHeadJointYaw = data.(obj.D_HEAD_JOINT).(obj.D_HEAD_YAW);
                end
                
                if isfield(data,obj.D_BASE_IMU)
                    obj.sensorBaseImuPitch = data.(obj.D_BASE_IMU).(obj.D_BASE_IMU_PITCH);
                    obj.sensorBaseImuRoll = data.(obj.D_BASE_IMU).(obj.D_BASE_IMU_ROLL);
                    obj.sensorBaseImuYaw = data.(obj.D_BASE_IMU).(obj.D_BASE_IMU_YAW);
                end
                
                if isfield(data,obj.D_BASE_TICK)
                    obj.sensorWheelTickLeft = data.(obj.D_BASE_TICK).(obj.D_BASE_TICK_L);
                    obj.sensorWheelTickRight = data.(obj.D_BASE_TICK).(obj.D_BASE_TICK_R);
                end
            else
               warning('Recive was called but no data requested since last .send()') 
            end
            obj.dataIsRequested = false;
        end
        
        function clearSendQue(obj)
           obj.sendStructure = []; 
        end
        
        %%%       %%%
        %  Actions  %
        %%%       %%%
        
        function enableDrive(obj, enable)
            %ENABLEDRIVE Enable or Disable locomotion
            %   enableDrive(enable) takes a boolean argument, enable,
            %   and activates (true) or disables and clears (false)
            %   the locomotion commands for loomo
            %
            %   enable: 
            %       true: Enables drive commands
            %       false(Default): Disables and clears drive commands
            
            if islogical(enable)
                jsR.(obj.A_ENABLE_DRIVE_VALUE) = enable;
                obj.sendOrQueMessage(jsR,obj.A_ENABLE_DRIVE)
            end
        end
        
        function enableVision(obj, colorSmall, colorLarge, depth)
            test = [islogical(colorSmall),islogical(colorLarge),...
                    islogical(depth)];
           if ~all(test)
               error("Values must be logical")
           end
           jsR.(obj.D_IMAGE_TYPE_COLOR) = colorLarge;
           jsR.(obj.D_IMAGE_TYPE_COLOR_SMALL) = colorSmall;
           jsR.(obj.D_IMAGE_TYPE_DEPTH) = depth;
           
           obj.sendOrQueMessage(jsR,obj.A_ENABLE_VISION)
        end
        
        function setVelocity(obj, velocity, angularVelocity)
            %setVelocity Set angular and linear velocity for 700ms
            %   setVelocity(velocity, angularVelocity) takes to arguments,
            %   velocity and angularVelocity, and sets the desired loomo
            %   velocities for the next 700ms. To sustain this speed over a
            %   longer periode the command needs to be repeated within the
            %   given time frame.
            %
            %   velocity: Linear Velocity in m/s [-4 to 4]
            %   angularVelocity: CCW Angular velocity in rad/s
            jsR.(obj.A_VELOCITY_LINEAR) = velocity;
            jsR.(obj.A_VELOCITY_ANGULAR) = angularVelocity;
            
            obj.sendOrQueMessage(jsR,obj.A_VELOCITY)
        end
        
        function setPosition(obj,x,y, th, add, vls)
            %setPosition Move Loomo to absolute pose from current pose
            %   setPosition(x,y) moves Loomo to the absolute position [x,y]
            %   in meters, based on it's current referance frame. 
            %   
            %   setPosition(x,y,th) moves Loomo to the absolute pose 
            %   and rotation [x, y, th], in metters and radians, based on 
            %   it's current referance frame.
            %
            %   Loomo coordinate system:
            %       x-axis: Positive in front of Loomo
            %       y-axis: Positve to the left
            %       th: CCW rotation in radians around its own z-axis
            %
            if length(x)>1
               act = obj.A_POSITION_ARRAY;
            else
                act = obj.A_POSITION;
            end
            jsR.(obj.A_POSITION_X) = x;
            jsR.(obj.A_POSITION_Y) = y;
            if nargin > 3 && ~isempty(th)
               jsR.(obj.A_POSITION_TH) = th;
            end
            
            if nargin > 4 && ~isempty(add)
               jsR.(obj.A_POSITION_ADD) = add;
            end
            
            if nargin > 5 && ~isempty(vls)
               jsR.(obj.A_POSITION_VLS) = vls;
            end
            
            obj.sendOrQueMessage(jsR,act)
        end
        
        function setHeadPosition(obj, yaw, pitch, light, mode)
            %setHeadPosition Sets the head position
            %   Sets the head position with yaw and pitch given in radiens.
            %
            %   Limits:
            %       Pitch: -Pi/2 to PI (-90 to 180 deg)
            %       Yaw: -Pi/1.2 to Pi/1.2 (-150 to 150 deg)
            %
            jsR.(obj.A_HEAD_PITCH) = round(pitch,4);
            jsR.(obj.A_HEAD_YAW) = round(yaw,4);
            
            if nargin > 3 && ~isempty(light)
               jsR.(obj.A_HEAD_LIGHT) = light; 
            end
            
            if nargin > 4 && ~isempty(mode)
               jsR.('m') = mode; 
            end
            
            obj.sendOrQueMessage(jsR,obj.A_HEAD)
        end
        
        function speakLine(obj,string, pitch, que)
            %speakLine Make Loomo speak
            %   Sends a string of text in english for the loomo to speak.
            jsR.(obj.A_SPEAK_LENGTH) = length(string);
            jsR.(obj.A_SPEAK_STRING) = string;
            
            if nargin > 2 && ~isempty(pitch)
               jsR.(obj.A_SPEAK_PITCH) = pitch; 
            end
            
            if nargin > 3 && ~isempty(que)
               jsR.(obj.A_SPEAK_QUE) = pitch; 
            end
            
            obj.sendOrQueMessage(jsR,obj.A_SPEAK)
        end
        
        function setVolume(obj,volume)
           %setVolume Set volume level of loomo speaker
           %    Volume range 0.0 to 1.0
           jsR.v = round(volume,3);
           obj.sendOrQueMessage(jsR,obj.A_VOLUME)
        end

        %%%       %%%
        %  Sensors  %
        %%%       %%%
        
        function [varargout] = getSurroundings(obj)
            %getSurroundings Read Infrared and Ultrasonic distances
            %
            %   [sendDirectly == false]
            %   If sequential sender is used (Recommended), 
            %   fetch values in the following class values after executing
            %   a .send() and .recive() command
            %
            %   .sensorDistanceFront - Ultrasonic front sensor [mm]
            %   .sensorDistanceLeft - Inrared left front ground sensor [mm]
            %   .sensorDistanceRight - Inrared right front ground sensor [mm]
            %
            %   [sendDirectly == true]
            %   When using send directly readings will be returned in the
            %   following structure
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   irl  | mm     | Left infrared sensor
            %   irr  | mm     | Right infrared sensor 
            %   uss  | mm     | Forward ultrasonic sensor
            %
            %   The infrared sensors are pointed at a downwards angle and 
            %   designed to detect obstacles in the driving path.
            %
            %   The ultrasonic sensor is designed to detect obstacles 
            %   and avoid collisions. The ultrasonic sensor is mounted in 
            %   the front of Loomo, with a detection distance from 
            %   250 millimeters to 1500 millimeters and an angle beam of 
            %   40 degrees.
            %
            %   NOTE: There is a known issue that when the distance between 
            %   the obstacle and the ultrasonic sensor is less than 
            %   250 millimeters, an incorrect value may be returned.
           data = obj.getData(obj.D_SURROUNDINGS);
           if nargout>0
               varargout{1} = data;
               if ~obj.sendDirectly
                  warnig('When sendDirectly == false, .send() and .recive() must be used to gather readings')
               end
           end
           obj.awaitingData = true;
        end
        
        function [varargout] = getWheelSpeed(obj)
            %getWheelSpeed Read individual wheel speed in m/s
            %
            %   [sendDirectly == false]
            %   If sequential sender is used (Recommended), 
            %   fetch values in the following class values after executing
            %   a .send() and .recive() command
            %
            %   sensorWheelVelocityLeft - Left wheel velocity [m/s]
            %   sensorWheelVelocityRight - Right wheel velocity [m/s]
            %
            %   [sendDirectly == true]
            %   When using send directly readings will be returned in the
            %   following structure
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   vl   | m/s    | Left wheel velocity
            %   vr   | m/s    | Right wheel velocity
            %
           data = obj.getData(obj.D_WHEEL_SPEED);
           if nargout>0
               varargout{1} = data;
               if ~obj.sendDirectly
                  warnig('When sendDirectly == false, .send() and .recive() must be used to gather readings')
               end
           end
           obj.awaitingData = true;
        end
        
        function [varargout] = getPose2D(obj)
            %getPose2D Read base pose and velocity
            %   Pose is relative to start position or last Pose reset.
            %   Pose is reset in set position and at start
            %
            %   [sendDirectly == false]
            %   If sequential sender is used (Recommended), 
            %   fetch values in the following class values after executing
            %   a .send() and .recive() command
            %
            %   .sensorBaseVelocity - Linear Velocity [m/s] (Pose2D)
            %   .sensorBaseTurnRate - Angular Velocity [rad/s] (Pose2D)
            %   .sensorBasePoseX    - X position [m] (Pose2D)
            %   .sensorBasePoseY    - Y position [m] (Pose2D)
            %   .sensorBasePoseTh   - Th rotation [rad] (Pose2D)
            %
            %   [sendDirectly == true]
            %   When using send directly readings will be returned in the
            %   following structure
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   x   | m      | x - displacment
            %   y   | m      | y - displacement
            %   th  | rad    | Rotational displacment
            %   vl  | m/s    | Linear velocity
            %   va  | rad/s  | Angular velocity
            %
           data = obj.getData(obj.D_POSE2D);
           if nargout>0
               varargout{1} = data;
               if ~obj.sendDirectly
                  warnig('When sendDirectly == false, .send() and .recive() must be used to gather readings')
               end
           end
           obj.awaitingData = true;
        end
        
        function [varargout] = getHeadWorld(obj)
            %getHeadWorld Read the head world position
            %   Measured by the internal head IMU (Inertial Measurement Unit)
            %
            %   [sendDirectly == false]
            %   If sequential sender is used (Recommended), 
            %   fetch values in the following class values after executing
            %   a .send() and .recive() command
            %
            %   .sensorHeadWorldPitch - Head Pitch in world frame [rad]
            %   .sensorHeadWorldRoll  - Head Roll in world frame [rad]
            %   .sensorHeadWorldYaw   - Head Yaw in world frame [rad]
            %
            %   [sendDirectly == true]
            %   When using send directly readings will be returned in the
            %   following structure
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   p    | rad    | Pitch
            %   r    | rad    | Roll
            %   y    | rad    | Yaw
            %
           data = obj.getData(obj.D_HEAD_WORLD);
           if nargout>0
               varargout{1} = data;
               if ~obj.sendDirectly
                  warnig('When sendDirectly == false, .send() and .recive() must be used to gather readings')
               end
           end
           obj.awaitingData = true;
        end
        
        function [varargout] = getHeadJoint(obj)
            %getHeadWorld Read the head joint position
            %   Measured by the joints to the base. Position relative to
            %   base
            %
            %   [sendDirectly == false]
            %   If sequential sender is used (Recommended), 
            %   fetch values in the following class values after executing
            %   a .send() and .recive() command
            %
            %   .sensorHeadJointPitch - Head Pitch in base frame [rad]
            %   .sensorHeadJointRoll  - Head Roll in base frame [rad]
            %   .sensorHeadJointYaw   - Head Yaw in base frame [rad]
            %
            %   [sendDirectly == true]
            %   When using send directly readings will be returned in the
            %   following structure
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   p    | rad    | Pitch
            %   r    | rad    | Roll
            %   y    | rad    | Yaw
            %
           data = obj.getData(obj.D_HEAD_JOINT);
           if nargout>0
               varargout{1} = data;
               if ~obj.sendDirectly
                  warnig('When sendDirectly == false, .send() and .recive() must be used to gather readings')
               end
           end
           obj.awaitingData = true;
        end
        
        function [varargout] = getBaseImu(obj)
            %getHeadWorld Returns the head joint position
            %   Measured by the joints to the base. Position relative to
            %   base
            %
            %   [sendDirectly == false]
            %   If sequential sender is used (Recommended), 
            %   fetch values in the following class values after executing
            %   a .send() and .recive() command
            %
            %   .sensorBaseImuPitch - Base Pitch [rad]
            %   .sensorBaseImuRoll  - Base Roll [rad]
            %   .sensorBaseImuYaw   - Base Yaw [rad]
            %
            %   [sendDirectly == true]
            %   When using send directly readings will be returned in the
            %   following structure
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   p    | rad    | Pitch
            %   r    | rad    | Roll
            %   y    | rad    | Yaw
            %
           data = obj.getData(obj.D_BASE_IMU);
           if nargout>0
               varargout{1} = data;
               if ~obj.sendDirectly
                  warnig('When sendDirectly == false, .send() and .recive() must be used to gather readings')
               end
           end
           obj.awaitingData = true;
        end
        
        function [varargout] = getWheelTick(obj)
            %getBaseTick Returns the measured encoder wheel position.
            %   1 tick is ~1cm on correctly inflated wheels.
            %
            %   [sendDirectly == false]
            %   If sequential sender is used (Recommended), 
            %   fetch values in the following class values after executing
            %   a .send() and .recive() command
            %
            %   sensorWheelTickLeft - Left wheel ticks, ~1cm/tick [ticks] (WheelTick)
            %   sensorWheelTickRight - Right wheel ticks, ~1cm/tick [ticks] (WheelTick)
            %
            %   [sendDirectly == true]
            %   When using send directly readings will be returned in the
            %   following structure
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   l    | tick   | Left wheel
            %   r    | tick   | Right wheel
            %
           data = obj.getData(obj.D_BASE_TICK);
           if nargout>0
               varargout{1} = data;
               if ~obj.sendDirectly
                  warnig('When sendDirectly == false, .send() and .recive() must be used to gather readings')
               end
           end
           obj.awaitingData = true;
        end
        
        function img = getImage(obj,type)
            %getImage Return an image of given type from Loomo
            %   Recives and formats a single image frame from the loomo
            %
            %   getImage is not affected by sendDirectly
            %       as such it must never be used while avaiting to
            %       recive data between .send() and .recive()
            %
            %   type:
            %       0 - Color small 320x240 (Default)
            %       1 - Color large 640x480
            %       2 - Depth       320x240
            
            jsR.(obj.ACTION) = obj.D_IMAGE; %Set image action label
            if nargin < 2
                type = 0; % If type is not specified set to '0'
            end
            
            % Match type with protocole
            switch type
                case 1
                    jsR.(obj.D_IMAGE_TYPE) = obj.D_IMAGE_TYPE_COLOR;
                case 2
                    jsR.(obj.D_IMAGE_TYPE) = obj.D_IMAGE_TYPE_DEPTH;
                otherwise
                    jsR.(obj.D_IMAGE_TYPE) = obj.D_IMAGE_TYPE_COLOR_SMALL;
            end
            jsE = jsonencode(jsR); % Encode structure to json string
            
            obj.socket.sendJsonString(jsE); % Send json to Loomo
            meta = obj.socket.reciveJsonString(); % Recive image metadata
            meta = jsondecode(meta); % Decode Image Metadata
           raw = obj.socket.readLongByteArray(meta.size); % Recive image bytes
           
           % If image size is less than 10, no image has been recived
           if meta.size > 10 
               
               %Convert byte array to image
               img = obj.convertByte2Image(raw,meta.width,meta.height, type~=2);
           else
               %Throw warning
               img = 0;
               warning('Error in reciving image')
           end
        end
        
    end
    
    
    methods (Access = private)
        
        function sendOrQueMessage(obj,jsR,action)
           if obj.sendDirectly
                jsR.(obj.ACTION) = action;
                jsE = jsonencode(jsR);
                obj.socket.sendJsonString(jsE);
            else
                obj.sendStructure.(action) = jsR;
            end 
        end
        
        function data = getData(obj,string)
            if obj.sendDirectly
                jsR.(obj.ACTION) = string;
                jsE = jsonencode(jsR);
                obj.socket.sendJsonString(jsE);
                data = obj.socket.reciveJsonString();
                data = jsondecode(data);
            else
                obj.sendStructure.(string) = true;
                data = [];
            end 
        end
        
        function img = convertByte2Image(~,raw, w, h, color)
            if color
            l = length(raw);
                img = zeros(w,h,3);
                img(:,:,1) = reshape(raw(1:3:l),[w,h]);
                img(:,:,2) = reshape(raw(2:3:l),[w,h]);
                img(:,:,3) = reshape(raw(3:3:l),[w,h]);
                img = img/255;
                img = permute(img,[2,1,3]);
            else
                bits = reshape(raw,[2,length(raw)/2]); % Rearange higer and lower order bits
                img = bitor(bitshift(bits(1,:),8),bits(2,:)); % Shift and combine bits
                img = reshape(img,w,h); % Reshape to image form
                img = permute(img,[2,1]); % Rotate 90deg
                %img = img / hex2dec('FFFF'); % Scale to double
                %img(img<255) = nan%hex2dec('FFFF'); % Move noice to the distance
            end
         end
    end
end

