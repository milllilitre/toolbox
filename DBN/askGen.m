% askGen.m 
% millilitre 
% 20150602 created
% 20150603 tested

function sigOut = askGen(fs,fc,bitrate,mask,bitDef,maxLen)
% mask should be greater than 2.
% 
if mask < 2
    disp('askGen.m: Warning: mask should be greater than 2.');
    mask = 2;
end
%% init parameters
t0 = 1/fs;
bitLen = 1/bitrate/t0;

%% generate waveform
code = bitDef;
nBits = size(code, 2);
N = double(uint32(nBits * fs / bitrate)); % points needed
signal = zeros(1,N);
t = 1:t0:((N - 1) * t0);
currentBit = 1;
bitContent = 0;
currentTime = 0;
for i = 1:1:N
    currentBit = ceil((i) / bitLen);
    if currentBit == 0
        currentBit = 1;
    end
    currentTime = i * t0;
    if(currentBit <= nBits)
        signal(i) = code(currentBit) * sin(fc * 2 * pi * currentTime);
    end
end

%% concatenate
if size(signal,2) > maxLen
    sigOut = signal(1:1:maxLen);
else
    sigOut = signal;
end

    