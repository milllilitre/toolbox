% pskGen.m 
% millilitre 
% 20150601 created
% 20150602 tested

function sigOut = pskGen(fs,fc,bitrate,mpsk,bitDef,maxLen)
% bitDef is a row vector
% mpsk should be 2^integer
% The length of sigOut is no greater than maxLen. No 0 padding when
% size(sigOut, 2) < maxLen
%% init parameters
t0 = 1 / fs;
bitLen = 1 ./ bitrate ./ t0;
subcarrierFreq = fc;
freqDeviation = 0;
%% generate waveform
delay = 0;
N = double(uint32(size(bitDef,2) * fs / bitrate));
signal = zeros(1,N);
t = 0:t0:(double(N) * t0 - t0);
code = bitDef;
xthBit = 1;         % current bit number, tmp value
bitContent = 0;     % current bit content
currentTime = 0;    % current time value(from delayed start point)
tmpPhase = 0;
frequency = 0;
for bitrateIndex = 1:1:1
    for i = 1:1:N
        xthBit = ceil((i - delay + 1) / bitLen(bitrateIndex));
        if xthBit == 0
            xthBit = 1;
        end
        if(xthBit <= size(bitDef,2))
            bitContent = code(xthBit);
            tmpPhase = 2 * pi * bitContent / mpsk;
            currentTime = (i - delay) * t0;
            signal(bitrateIndex,i) = sin(subcarrierFreq * 2 * pi * currentTime * (1 + freqDeviation) + tmpPhase);
        end
    end
end
%% concatenate
if size(signal,2) > maxLen
    sigOut = signal(1:1:maxLen);
else
    sigOut = signal;
end

