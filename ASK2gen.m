% askGen.m 
% millilitre 
% 20150905 created
% 

function sigOut = ASK2gen(fs,bitrate,modDepth,bitDef)
%% init parameters
t0 = 1 / fs;
bitLen = 1 / bitrate / t0;

%% generate waveform
code = bitDef;
nBits = size(code, 2);
N = floor(nBits * fs / bitrate); % points needed
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
        %signal(i) = code(currentBit) * sin(fc * 2 * pi * currentTime);
        if(code(currentBit) == 0)
            signal(i) = 1 - modDepth;
        else
            signal(i) = 1;
        end
    end
end
sigOut = signal;
%% concatenate
% if size(signal,2) > maxLen
%     sigOut = signal(1:1:maxLen);
% else
%     sigOut = signal;
% end

    