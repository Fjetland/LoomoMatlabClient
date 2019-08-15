function pc = depthImageToPointCloud(imgd,img)
%depthImageToPointCloud(imgd,img) Inneficient and innacurate way of
%   combining a depth and color image to a matlab point cloud

ircFOVh = 59*pi/180; % Depth Camera field of view
ircFOVv = 48*pi/180; % Depth Camera field of view

ircMaxD = 2.8; % Depth max camera
ircMaxB = hex2dec('FFFF'); % Depth max value
imgD = imgd*ircMaxD/ircMaxB; % Assume max depth is max value ;)

% Calc X, Y, Z from Base
% Y axis in picture is inverted
% X axis is depth
% Z axis is height

width = size(imgD,2);
height = size(imgD,1);

cameraHeight = 1; % Camera height off ground
cameraYaxis = -1; %is inverted
center = [height/2,width/2];

count = 1;
x=zeros(width*height,1);
y=zeros(width*height,1);
z=zeros(width*height,1);
color=zeros(width*height,3);
for yp = 1:width
    angleH = (center(2)-yp)/center(2)*ircFOVh; % Assume pixles evenly spaced :)
    for zp = 1:height
        angleV = (center(1)-zp)/center(1)*ircFOVv; % Assume pixles evenly spaced :)
        d = imgD(zp,yp);
        y(count) = cameraYaxis*sign(angleH)*d*tan(abs(angleH));
        z(count) = sign(angleV)*d*tan(abs(angleV))+cameraHeight;
        x(count) = d;
        color(count,1:3) = [img(zp,yp,1),img(zp,yp,2),img(zp,yp,3)]*255;
        count = count+1;
    end
end
lim = 200;
limX = 0.50;
throw = any([abs(y)>lim; abs(z)>lim; x<limX],1);
xyz = [x,y,z];
xyz(throw,:) = [];
color(throw,:) = [];

pc = pointCloud(xyz);
pc.Color = uint8(color);
end

