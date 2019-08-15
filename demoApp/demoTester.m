clear all
close all
clc

frameWorkPath = '../';
addpath(frameWorkPath)

loomo = BackgroundLoomoConnector('192.168.137.84',1337);
%%
loomo.connect()

while ~loomo.isFinished
   disp('Working...')
   pause(0.5)
end
%%
loomo.enableVision(true,false,false)


%pause(2)
%%

loomo.getImageFun(0);

data = loomo.getResult()

%%
loomo.disconnect()
% p = gcp
% 
% f = parfeval(p,@testMe,1,10)
% while ~strcmp(f.State,'finished')
%     disp('YoYo')
%     pause(1)
% end
% k = fetchOutputs(f)
% 
% 
% function k = testMe(l)
%     pause(3)
%     k = 2*l;
% end