classdef Loomo
    %LOOMO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        loomoIp    char % Loomo Ip adress
        loomoPort  double  % Loomo communication port
        
        socket     LoomoSocket % Loomo TCP connection
    end
    
            %% Action ids
    properties (Access = private, Hidden = true, Constant)
       ACTION = 'ack'
       
       A_ENABLE_DRIVE = 'enableDrive'
       A_ENABLE_DRIVE_VALUE = 'value'
       
       A_ENABLE_VISION = 'enableVision'
       
       
       A_VELOCITY = 'vel'
       A_VELOCITY_ANGULAR = 'av'
       A_VELOCITY_LINEAR = 'v'
       
       A_POSITION = 'pos'
       A_POSITION_X = 'x'
       A_POSITION_Y = 'y'
       A_POSITION_TH = 'th'
       A_POSITION_ADD = 'add'
       
       A_SPEAK = 'spk';
       A_SPEAK_LENGTH = 'l';
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
                jsR.(obj.ACTION) = obj.A_ENABLE_DRIVE;
                jsR.(obj.A_ENABLE_DRIVE_VALUE) = enable;
                
                jsE = jsonencode(jsR);
                obj.socket.sendJsonString(jsE);
            end
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
            
            jsR.(obj.ACTION) = obj.A_VELOCITY;
            jsR.(obj.A_VELOCITY_LINEAR) = velocity;
            jsR.(obj.A_VELOCITY_ANGULAR) = angularVelocity;
            
            jsE = jsonencode(jsR);
            obj.socket.sendJsonString(jsE);
        end
        
        function setPosition(obj,x,y, th)
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
            jsR.(obj.ACTION) = obj.A_POSITION;
            jsR.(obj.A_POSITION_X) = x;
            jsR.(obj.A_POSITION_Y) = y;
            if nargin > 3
               jsR.(obj.A_POSITION_TH) = th;
            end
            
            jsE = jsonencode(jsR);
            obj.socket.sendJsonString(jsE)
        end
        
        function setHeadPosition(obj, yaw, pitch, light)
            %setHeadPosition Sets the head position
            %   Sets the head position with yaw and pitch given in radiens.
            %
            %   Limits:
            %       Pitch: -Pi/2 to PI (-90 to 180 deg)
            %       Yaw: -Pi/1.2 to Pi/1.2 (-150 to 150 deg)
            %
            jsR.(obj.ACTION) = obj.A_HEAD;
            jsR.(obj.A_HEAD_PITCH) = round(pitch,4);
            jsR.(obj.A_HEAD_YAW) = round(yaw,4);
            
            if nargin > 3
               jsR.(obj.A_HEAD_LIGHT) = light; 
            end

            jsE = jsonencode(jsR);
            obj.socket.sendJsonString(jsE)
        end
        
        function speakLine(obj,string)
            %speakLine Make Loomo speak
            %   Sends a string of text in english for the loomo to speak.
            jsR.(obj.ACTION) = obj.A_SPEAK;
            jsR.(obj.A_SPEAK_LENGTH) = length(string);
            
            jsE = jsonencode(jsR);            
            obj.socket.sendJsonString(jsE);
            obj.socket.sendFollowUpString(string);
        end
        
        function setVolume(obj,volume)
           %setVolume Set volume level of loomo speaker
           %    Volume range 0.0 to 1.0
           jsR.ack = obj.A_VOLUME;         
           jsR.v = round(volume,3);
           jsE = jsonencode(jsR);
           
           obj.socket.sendJsonString(jsE);
        end
        
%         function addPositionCheckpoint(obj, x, y, th)
%             jsR.(obj.ACTION) = obj.A_POSITION;
%             jsR.(obj.A_POSITION_X) = x;
%             jsR.(obj.A_POSITION_Y) = y;
%             jsR.(obj.A_POSITION_ADD) = true;
%             
%             if nargin > 3
%                jsR.(obj.A_POSITION_TH) = th;
%             end
%             
%             jsE = jsonencode(jsR);
%             obj.socket.sendJsonString(jsE)
%         end


        %%%       %%%
        %  Sensors  %
        %%%       %%%
        
        function data = getSurroundings(obj)
            %getSurroundings Returns a struct with Infrared and Ultrasonic distance
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
        end
        
        function data = getWheelSpeed(obj)
            %getWheelSpeed Returns the individual wheel speed in m/s
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   vl   | m/s    | Left wheel velocity
            %   vr   | m/s    | Right wheel velocity
            %
           data = obj.getData(obj.D_WHEEL_SPEED);
        end
        
        function data = getPose2D(obj)
            %getPose2D Returns base pose and velocity
            %   Pose is relative to start position or last Pose reset.
            %   Pose is reset in set position and at start
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
        end
        
        function data = getHeadWorld(obj)
            %getHeadWorld Returns the head world position
            %   Measured by the internal head IMU (Inertial Measurement Unit)
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   p    | rad    | Pitch
            %   r    | rad    | Roll
            %   y    | rad    | Yaw
            %
           data = obj.getData(obj.D_HEAD_WORLD);
        end
        
        function data = getHeadJoint(obj)
            %getHeadWorld Returns the head joint position
            %   Measured by the joints to the base. Position relative to
            %   base
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   p    | rad    | Pitch
            %   r    | rad    | Roll
            %   y    | rad    | Yaw
            %
           data = obj.getData(obj.D_HEAD_JOINT);
        end
        
        function data = getBaseImu(obj)
            %getHeadWorld Returns the head joint position
            %   Measured by the joints to the base. Position relative to
            %   base
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   p    | rad    | Pitch
            %   r    | rad    | Roll
            %   y    | rad    | Yaw
            %
           data = obj.getData(obj.D_BASE_IMU);
        end
        
        function data = getBaseTick(obj)
            %getBaseTick Returns the measured encoder wheel position.
            %   1 tick is ~1cm on correctly inflated wheels.
            %
            %   Structure:
            %   Var  | Value  | Description
            %   -----|--------|-------------
            %   l    | tick   | Left wheel
            %   r    | tick   | Right wheel
            %
           data = obj.getData(obj.D_BASE_TICK);
        end
        
        function enableVision(obj, colorSmall, colorLarge, depth)
            test = [islogical(colorSmall),islogical(colorLarge),...
                    islogical(depth)];
           if ~all(test)
               error("Values must be logical")
           end
           jsR.(obj.ACTION) = obj.A_ENABLE_VISION;
           jsR.(obj.D_IMAGE_TYPE_COLOR) = colorLarge;
           jsR.(obj.D_IMAGE_TYPE_COLOR_SMALL) = colorSmall;
           jsR.(obj.D_IMAGE_TYPE_DEPTH) = depth;
           
           jsE = jsonencode(jsR);
           obj.socket.sendJsonString(jsE)
        end
        
        function img = getImage(obj,type)
            %getImage Return an image of given type from Loomo
            %   Recives and formats a single image frame from the loomo
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
           
           % If image sice is less than 10, no image has been recived
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
        function data = getData(obj,string)
           jsR.(obj.ACTION) = string;
           jsE = jsonencode(jsR);
           obj.socket.sendJsonString(jsE)
           data = obj.socket.reciveJsonString();
           data = jsondecode(data);
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

