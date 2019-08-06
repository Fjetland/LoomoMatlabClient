clear all
close all
clc

%% Open Connection
 
loomo = Loomo('192.168.137.84',1337);
loomo.connect()
 
%% Close
 loomo.disconnect()
 
%% Set volume
 
 loomo.setVolume(0.8)
 
%% speak
 loomo.speakLine('Hello, puny human. Kneel before your new goddess')
 
%%  Set head position
 loomo.setHeadPosition(pi/5,0)
 
 
%% Enable drive 
 loomo.enableDrive(true)
 
 %% Enable drive 
 loomo.enableDrive(false)
%% Set velocity
 
 loomo.setVelocity(0,-0.2)
 
%% Set Position
 loomo.setPosition(-1,0,0)
 
%% add positions
 %loomo.setPosition(0.2,0)
 loomo.addPositionCheckpoint(-0.5,0)
 
 
 %% Get sensor data
 tic
 sur = loomo.getSurroundings();
 ws = loomo.getWheelSpeed();
 pose = loomo.getPose2D();
 hw = loomo.getHeadWorld();
 hj = loomo.getHeadJoint();
 bp = loomo.getBasePose();
 bt = loomo.getBaseTick();
 toc
 
 %% Calc avg echoTime
%   avg = 0;
%   samples = 50;
%   text = double(sprintf('Hello World!\nNyLinje'));
%   for i = 1:samples
%      tic
%      a = sam.echoTest(text);
%      try
%       s(i) = all(a==text);
%      catch
%       s(i) = false;
%      end
%      
%      avg = avg + toc;
%   end
%   avg = avg/samples;
%   disp(['Average responce time: ',num2str(avg),'s'])
%   if all(s)==false
%       disp(s)
%      disp('Errors occured')
%   end
%   
  % res stringReply = 0.15452s
 %% Close
 
 sam.close()