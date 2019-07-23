clear
close
clc

%% Open Connection

sam = LoomoSocket('192.168.1.10',1337)
sam.open

%%
data = sam.getIrAndUltraSound()
%% Plot
%close all
clf
clc


timeMax = 30; %seconds
figure(1)
data = sam.getIrAndUltraSound();
startTime = tic;
tid = 0;
ail = animatedline(tid,data.irl,'Color','b','LineStyle','-');
hold on
air = animatedline(tid,data.irr,'Color','b','LineStyle','--');
ass = animatedline(tid,data.uss,'Color','r','LineStyle','-');
legend('IR Left','IR Right','UltraSonic')
drawnow()

count = 1;
while tid< timeMax
    data = sam.getIrAndUltraSound();
    tid = toc(startTime);
    addpoints(ail,tid,data.irl)
    addpoints(air,tid,data.irr)
    addpoints(ass,tid,data.uss)
    count = count+1;
    drawnow()
    pause(0.1)
end
avgDt = tid/count




%% Close
%sam.close

%% dt