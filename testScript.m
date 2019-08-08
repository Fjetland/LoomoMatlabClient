clear all
close all
clc

%% Open Connection
 
loomo = Loomo('192.168.137.84',1337);
loomo.connect()
 
%% Close
 loomo.disconnect()
 
 %% Enable camera
 loomo.enableVision(true,true,true)

  %% Disable camera
 loomo.enableVision(false,false,false)

 %% Get image
 
 tic
 img = loomo.getImage(2);
 %imshow(img)
 toc

 % depth image
 waterfall(-img)
 view(gca,[208.962140992167 71.0147601476015]);
 
%% Set volume
 
 loomo.setVolume(0.6)
 
%% speak
 loomo.speakLine('Hello, puny human. Kneel before your new goddess')
 
%%  Set head position
 loomo.setHeadPosition(pi/5,0)

 %% set head and light
 loomo.setHeadPosition(pi/5,0,10)
 
%% Enable drive 
 loomo.enableDrive(true)
 
 %% Enable drive 
 loomo.enableDrive(false)
%% Set velocity
 loomo.setVelocity(-0.5,0)
 
%% Set Position
 loomo.setPosition(1,0,0)
 
%% add positions
 %loomo.setPosition(0.2,0)
 
 
 %% Get sensor data
 tic
 sur = loomo.getSurroundings()
 ws = loomo.getWheelSpeed()
 pose = loomo.getPose2D()
 hw = loomo.getHeadWorld()
 hj = loomo.getHeadJoint()
 bp = loomo.getBaseImu()
 bt = loomo.getBaseTick()
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