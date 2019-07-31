clear all
close all
clc

%% Open Connection

loomo = Loomo('192.168.1.10',1337)
loomo.connect()

%% Close
 loomo.disconnect()
 
%% Set volume
 
 loomo.setVolume(0.5)
 
%% speak
loomo.speakLine('Whazzzza you dawg')
 
%%  Set head position
 
 loomo.setHeadPosition(pi/3,0)
 
 
%% Enable drive 

 loomo.enableDrive(true)
 
%% Set velocity
 
 loomo.setVelocity(0.2,0)
 
%% Set Position
 loomo.setPosition(0.2,-0.7)
 
%% add positions
 %loomo.setPosition(0.2,0)
 loomo.addPositionCheckpoint(-0.5,0)
 
 
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