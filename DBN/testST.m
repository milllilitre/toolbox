close all;
nTrain = 100;
nVal = 100;
fs = [64 ];
fc = [ 8];
bitrate = [2 ];
cyclePerSymbol = double(uint32(fc ./ bitrate));
bitLen = double(uint32(fs / bitrate));
% receivedLen = 10 * bitLen;
receivedLen = 250;
tmpIn = trainInput(:,6);
[st1,t,f] = st(tmpIn,-1,-1,-1,-1);

figure();
subplot(2,1,1);
plot(tmpIn);
subplot(2,1,2);
plot(abs(st1(size(st1,1), :)));
figure();
imagesc(abs(st1));

tmp22 = zeros(1,251);
for(i = 1:1:251)
    for(j = 1:1:500)
        tmp22(j) = tmp22(j) + st1(i,j);
    end
end
figure();
plot(abs(tmp22));