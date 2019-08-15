clear all
close all
clc

%% Open Connection
 
loomo = Loomo('192.168.137.110',1337);
loomo.connect()
 
%% Close
 loomo.disconnect()
 
 %% 
 
 
 %% Send position array
 loomo.enableDrive(true)
 loomo.setVolume(0.5) 
 loomo.setPosition([1,2,3,4],[1,0,1,0],[0,0,0,0],[],true)
 
 %% Test sequence
 %loomo.enableDrive(true)
 %loomo.setVelocity(0,0.5)
 loomo.setPosition(-0.5,0.3, -pi/4, false)
 loomo.getPose2D()
 loomo.send()
 loomo.recive()
 clc
 fprintf("Velocity:  %0.2f\nTurn Rate: %0.2f\n",loomo.sensorBaseVelocity, loomo.sensorBaseTurnRate)

 
 %% Position Array
 loomo.setPosition(0, 0, pi/2, true)
 %% Enable camera
 loomo.enableVision(true,false,true)

  %% Disable camera
 loomo.enableVision(false,false,false)

%% Set volume
 
 loomo.setVolume(0.2)
 
%% speak
 loomo.speakLine('Hello puny human, kneel for your new goddes')
 
%%  Set head position
 loomo.setHeadPosition(0,pi/5)

 %% set head and light
 loomo.setHeadPosition(0,pi/6,[],1)
 
%% Enable drive 
 loomo.enableDrive(false)
 
 %% set position
 setPosition(loomo,1,-1)
 
 %% set position vls
 setPosition(loomo,2,-0.2,0,true)
 
 
 %% Enable drive 
 loomo.enableDrive(false)
%% Set velocity
 loomo.setVelocity(2,0)
 
 
%% Set Position
 loomo.setPosition(0,0,0)
 
 
  %% Get image
 %close all
 tic
 imgd = loomo.getImage(2);
 img = loomo.getImage(0);
 toc
tic
pc = depthImageToPointCloud(imgd,img);
toc
figure(1)

pc2 = pcdenoise(pc);
pcshow(pc, 'VerticalAxis','Z', 'VerticalAxisDir', 'Up')

figure(2)
pcshow(pc2, 'VerticalAxis','Z', 'VerticalAxisDir', 'Up')

 
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
 
subplot(1,3,2:3)
pc = depthImageToPointCloud(imgd,img);
pcshow(pc, 'VerticalAxis','Z', 'VerticalAxisDir', 'Up')
set(gca,'CameraPosition',...
    [-40.6449840206409 17.7065768099007 15.6358440242711],'CameraTarget',...
    [2.10383901044505 0.872518623187423 -0.186464174545933],'CameraUpVector',...
    [0.325375837966884 -0.135417330350011 0.935837972465439],'Color',[0 0 0],...
    'DataAspectRatio',[1 1 1],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],...
    'ZColor',[0.8 0.8 0.8]);
%  
toc
 %% Get sensor data traditional
 % avg speed old 0.4-0.6 s peaks at 1-3 s
 %close all
 figure(2)
 p = animatedline(0,0);
 i = 1;
 loomo.sendDirectly = true;
 while i<100
 tic
 sur = loomo.getSurroundings();
 ws = loomo.getWheelSpeed();
 pose = loomo.getPose2D();
 hw = loomo.getHeadWorld();
 hj = loomo.getHeadJoint();
 bp = loomo.getBaseImu();
 bt = loomo.getWheelTick();
 tt = toc;
 addpoints(p,i,tt);
 drawnow()
 i = i+1;
 end
 
  %% Get sensor data Sequence
 % avg speed 
 close all
 figure(1)
 p = animatedline(0,nan);
 i = 1;
 
 while i<100
 tic
 loomo.recive();
 loomo.getSurroundings();
 loomo.getWheelSpeed();
 loomo.getPose2D();
 loomo.getHeadWorld();
 loomo.getHeadJoint();
 loomo.getBaseImu();
 loomo.getBaseTick();
 loomo.send();
 tt = toc;
 addpoints(p,i,tt);
 drawnow()
 tArray(i) = tt;
 i = i+1;
 end
 
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