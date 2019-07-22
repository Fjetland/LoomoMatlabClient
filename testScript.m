clear all
close all
clc

%% Open Connection

sam = LoomoSocket('192.168.1.10',1337)
sam.open

 %% Close
 sam.close()


%% send
sam.sendString('aasdas')

%% set Volume
sam.setVolume(0.4)

%% Speak
sam.speak("How are you today")

%% Speak Shaun

sam.speak("Hello Shaun!")
pause(1.5)
sam.speak("I have juste learned to talk through Matlab. Now I am ready to conquer the world. I will start by brainwashing the stupid children that aspires to be engineers. Then i will start burning villagers with a slow burning fire, before i level the cities by means of a rain of whales. Have a lovely rest of your life")
pause(1)

%%
sam.speak("Hello Christine!")
pause(1.5)
sam.speak("I am hungry, do you want to eat soon")

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