classdef Loomo
    %LOOMO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        loomoIp    char % Holds server IP
        loomoPort  double  % Holds serve port
        
        socket     LoomoSocketV2
    end
    
            %% Action ids
    properties (Access = private, Hidden = true, Constant)
       ACTION = 'ack'
       
       A_ENABLE_DRIVE = 'enableDrive'
       A_ENABLE_DRIVE_VALUE = 'value'
       
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
        
        % Data return types
        D_SURROUNDINGS = 'sSur';
        D_WHEEL_SPEED = 'sWS';
        D_POSE2D = 'sP2d';
        D_HEAD_WORLD = 'sHPw';
        D_HEAD_JOINT = 'sHPj';
        D_BASE_POSE = 'sBP';
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
        D_BASE_POSE_PITCH = 'p';
        D_BASE_POSE_ROLL = 'r';
        D_BASE_POSE_YAW = 'p';
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
            obj.socket = LoomoSocketV2(loomoIp,loomoPort);
            obj.socket.t.InputBufferSize = 1000000;
        end
        
        function connect(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.socket.open()
        end
        
        function disconnect(obj)
           obj.socket.close() 
        end
        
        %%%       %%%
        %  Actions  %
        %%%       %%%
        
        function enableDrive(obj, enable)
            if islogical(enable)
                jsR.(obj.ACTION) = obj.A_ENABLE_DRIVE;
                jsR.(obj.A_ENABLE_DRIVE_VALUE) = enable;
                
                jsE = jsonencode(jsR);
                obj.socket.sendJsonString(jsE);
            end
        end
        
        function setVelocity(obj, velocity, angularVelocity)
            jsR.(obj.ACTION) = obj.A_VELOCITY;
            jsR.(obj.A_VELOCITY_LINEAR) = velocity;
            jsR.(obj.A_VELOCITY_ANGULAR) = angularVelocity;
            
            jsE = jsonencode(jsR);
            obj.socket.sendJsonString(jsE);
        end
        
        function setPosition(obj,x,y, th)
            jsR.(obj.ACTION) = obj.A_POSITION;
            jsR.(obj.A_POSITION_X) = x;
            jsR.(obj.A_POSITION_Y) = y;
            if nargin > 3
               jsR.(obj.A_POSITION_TH) = th;
            end
            
            jsE = jsonencode(jsR);
            obj.socket.sendJsonString(jsE)
        end
        
        function addPositionCheckpoint(obj, x, y, th)
            jsR.(obj.ACTION) = obj.A_POSITION;
            jsR.(obj.A_POSITION_X) = x;
            jsR.(obj.A_POSITION_Y) = y;
            jsR.(obj.A_POSITION_ADD) = true;
            
            if nargin > 3
               jsR.(obj.A_POSITION_TH) = th;
            end
            
            jsE = jsonencode(jsR);
            obj.socket.sendJsonString(jsE)
        end
        
        function setHeadPosition(obj, yaw, pitch)
            jsR.(obj.ACTION) = obj.A_HEAD;
            jsR.(obj.A_HEAD_PITCH) = round(pitch,4);
            jsR.(obj.A_HEAD_YAW) = round(yaw,4);

            jsE = jsonencode(jsR);
            obj.socket.sendJsonString(jsE)
        end
        
        function speakLine(obj,string)
            jsR.(obj.ACTION) = obj.A_SPEAK;
            jsR.(obj.A_SPEAK_LENGTH) = length(string);
            
            jsE = jsonencode(jsR);            
            obj.socket.sendJsonString(jsE);
            obj.socket.sendFollowUpString(string);
        end
        
        function setVolume(obj,volume)
           jsR.ack = obj.A_VOLUME;         
           jsR.v = round(volume,3);
           jsE = jsonencode(jsR);
           
           obj.socket.sendJsonString(jsE);
        end
        
    end
end

