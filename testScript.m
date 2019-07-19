clear all
close all
clc

%% Open Connection

sam = LoomoSocket('192.168.1.10',1337)

sam.open

%% Echo bits
 a = sam.echoTest()
 
 %% Echo string
tic
 b = char(sam.echoTest());
 toc
 
 %% Send jasonString
 struct.str = "hello";
 struct.num = 18; 
 struct.array = [2,3,5,6];
 struct.dec = 2.891;
 
 k = jsonencode(struct);
 
 sam.sendString(k)
 
 
 %% Calc avg echoTime
  avg = 0;
  samples = 50;
  text = double(sprintf('Hello World!\nNyLinje'));
  for i = 1:samples
     tic
     a = sam.echoTest(text);
     try
      s(i) = all(a==text);
     catch
      s(i) = false;
     end
     
     avg = avg + toc;
  end
  avg = avg/samples;
  disp(['Average responce time: ',num2str(avg),'s'])
  if all(s)==false
      disp(s)
     disp('Errors occured')
  end
  
  % res stringReply = 0.15452s
 %% Close
 
 sam.close()