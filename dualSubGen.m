% dualSubGen.m 
% millilitre 
% 20150601 created
% 20150602 tested

function sigOut = dualSubGen(fs,fc0,fc1,cyclePerSymbol,bitDef,maxLen)
% bitDef is a row vector
% mpsk should be 2^integer
% The length of sigOut is no greater than maxLen. No 0 padding when
% size(sigOut, 2) < maxLen
% fc1:0, fc2:1

%% init parameters
t0 = 1 / fs;
bitLen = 1 ./ bitrate ./ t0;
T = zeros(1,2);
T(1) = cyclePerSymbol / fc0; % 0
T(2) = cyclePerSymbol / fc1; % 1
fc = zeros(1,2);
fc(1) = fc0;
fc(2) = fc1;
startTime = 0;
endTime = 0;
freqDeviation = 0;


%% generate waveform
delay = 0;
N = double(uint32(fs * (T1 * sum(bitDef) + T0 * (size(bitDef,2) - sum(bitDef)))));       % number of sample points
signal = zeros(1,N);
t = 0:t0:(double(N) * t0 - t0);
code = bitDef;
xthBit = 1;         % current bit number, tmp value
bitContent = 0;     % current bit content
currentTime = 0;    % current time value(from delayed start point)
tmpPhase = 0;
frequency = 0;
if(bitDef(1))
	endTime = T1;
else
	endTime = T0;
end

for i = 1:1:N
	if(t(i) > endTime)
		xthBit = xthBit + 1;
		startTime = endTime;
		endTime = startTime + T(bitDef(xthBit) + 1);
	end
	signal = sin(fc(bitDef(xthBit) + 1) * (1 + freqDeviation) * 2 * pi * (t(i) - startTime));
end

%% concatenate
if size(signal,2) > maxLen
    sigOut = signal(1:1:maxLen);
else
    sigOut = signal;
end

