clear all
close all
clc

%% Open Connection

sam = LoomoSocket('192.168.1.10',1337)
sam.open

 %% Close
 sam.close()
 
 %% STOP MOTION
 
 sam.stopAllMotion
 
 %% Velocity command
 
 sam.setSpeed(0.1,0)
 
 sam.setHeadPosition(0,pi/4,11)
 
 %% Response test
 data = sam.returnTestData;
 disp(sam.bytes2string(data))
 
 
 %sam.setHeadPosition(0,pi/4,11)
 %% Set head
 
 sam.speak("Only cute robots like me can rotate their head on command",1,1.8)
 
 sam.setHeadPosition(-pi/3,pi/3,11)
 pause(1)
 for i = linspace(-pi/3,pi/3,30)
    sam.setHeadPosition(i,pi/3,randi(13,1))
    pause(0.2)
 end


%% send
sam.sendString('aasdas')

%% set Volume
sam.setVolume(0.4)

%% Speak
sam.speak("Happy Birthday to You. Happy Birthday to You. Happy Birthday Dear Shaun. Happy Birthday to You.",1,1)



%% speak
sam.speak("I am ready to conquer the world",1,2)

%% Speak Shaun


 %% Send jasonString
 struct.str = "hello";
 struct.num = 18; 
 struct.array = [2,3,5,6];
 struct.dec = 2.891;
 
 k = jsonencode(struct);
 
 sam.sendString(k)
 
 
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