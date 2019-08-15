clear all
close all
clc

%% List

ips = {'192.168.137.84',...
       '192.168.137.110'}
   
   
%% Connect

for i = 1:length(ips)
   loomo(i) = Loomo(ips{i},1337);
   loomo(i).connect();
end


%% Drive circle

for i = 1:length(ips)
    loomo(i).setVolume(0.6)
   loomo(i).speakLine('Ready for a dance')
   loomo(i).enableDrive(true);
   loomo(i).setPosition([1,1,0,0],[0,1,1,0],[pi/2,pi,-pi/2,0])  
end

for i = 1:length(ips)
   loomo(i).send()
end

%% Speak

for i = 1:length(ips)
    
   loomo(i).send()
end

%% disconnect
return

%%
for i = 1:length(ips)
   loomo(i).disconnect()
end