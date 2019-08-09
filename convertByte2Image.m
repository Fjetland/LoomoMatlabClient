function img = convertByte2Image(raw)
tic
l = length(raw);

w = 640;
h = 480;
img(:,:,1) = reshape(raw(1:3:l),[w,h]);
img(:,:,2) = reshape(raw(2:3:l),[w,h]);
img(:,:,3) = reshape(raw(3:3:l),[w,h]);
img = img/255;
img = permute(img,[2,1,3]);
toc

end