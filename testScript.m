clear all
close all
clc

%% Open Connection
 
loomo = Loomo('192.168.137.84',1337);
%loomo.connect()
 
%% Close
 loomo.disconnect()
 
 %% Enable camera
 loomo.enableVision(true,false,true)

  %% Disable camera
 loomo.enableVision(false,false,false)

 %%
 f2 = figure('Position',[50,50,1200,800],'Name','3D-Plot')
 %% Get image
 %close all
 tic
 imgd = loomo.getImage(2);
 img = loomo.getImage(0);
 toc

pc = depthImageToPointCloud(imgd,img);

figure(1)

pc2 = pcdenoise(pc);
pcshow(pc, 'VerticalAxis','Z', 'VerticalAxisDir', 'Up')
set(gca,'CameraPosition',...
    [-40.6449840206409 17.7065768099007 15.6358440242711],'CameraTarget',...
    [2.10383901044505 0.872518623187423 -0.186464174545933],'CameraUpVector',...
    [0.325375837966884 -0.135417330350011 0.935837972465439],'Color',[0 0 0],...
    'DataAspectRatio',[1 1 1],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],...
    'ZColor',[0.8 0.8 0.8]);
 

figure(2)
pcshow(pc, 'VerticalAxis','Z', 'VerticalAxisDir', 'Up')
set(gca,'CameraPosition',...
    [-40.6449840206409 17.7065768099007 15.6358440242711],'CameraTarget',...
    [2.10383901044505 0.872518623187423 -0.186464174545933],'CameraUpVector',...
    [0.325375837966884 -0.135417330350011 0.935837972465439],'Color',[0 0 0],...
    'DataAspectRatio',[1 1 1],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],...
    'ZColor',[0.8 0.8 0.8]);
 
%% Set volume
 
 loomo.setVolume(0.3)
 
%% speak
 loomo.speakLine('Bye')
 
%%  Set head position
 loomo.setHeadPosition(pi/5,0)

 %% set head and light
 loomo.setHeadPosition(pi/5,0,10)
 
%% Enable drive 
 loomo.enableDrive(true)
 
 %% Enable drive 
 loomo.enableDrive(false)
%% Set velocity
 loomo.setVelocity(0,-0.2)
 
%% Set Position
 loomo.setPosition(0,0,0)
 
 %% Start Drive and look
 close all
 f2 = figure('Position',[50,50,1500,800],'Name','3D-Plot')
 ax = gca;
 loomo.enableDrive(true)
 loomo.enableVision(true,false,true)
 imgd = loomo.getImage(2);
 img = loomo.getImage(0);
%% Drive and Look
 tic
 loomo.setVelocity(0,-0)
 pause(0)
 imgd = loomo.getImage(2);
 img = loomo.getImage(0);

subplot(1,3,1)
imshow(img)
 
% subplot(1,3,2:3)
% pc = depthImageTestScript(imgd,img);
% pcshow(pc, 'VerticalAxis','Z', 'VerticalAxisDir', 'Up')
% set(gca,'CameraPosition',...
%     [-40.6449840206409 17.7065768099007 15.6358440242711],'CameraTarget',...
%     [2.10383901044505 0.872518623187423 -0.186464174545933],'CameraUpVector',...
%     [0.325375837966884 -0.135417330350011 0.935837972465439],'Color',[0 0 0],...
%     'DataAspectRatio',[1 1 1],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],...
%     'ZColor',[0.8 0.8 0.8]);
%  
toc
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