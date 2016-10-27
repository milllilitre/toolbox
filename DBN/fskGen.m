% fskGen.m 
% millilitre 
% 20150601 created
% 20150602 tested

function sigOut = fskGen(fs,fc0,fc1,bitrate,bitDef,maxLen)
% bitDef is a row vector containing only 0 and 1
% The length of sigOut is no greater than maxLen. No 0 padding when
% size(sigOut, 2) < maxLen
% fc1:0, fc2:1

%% init parameters
t0 = 1 / fs;
bitLen = 1 ./ bitrate ./ t0;
T = zeros(1,2);
T(1) = 1 / bitrate; % 0
T(2) = 1 / bitrate; % 1
fc = zeros(1,2);
fc(1) = fc0;
fc(2) = fc1;
startTime = 0;
endTime = 0;
freqDeviation = 0;

%% generate waveform
delay = 0;
N = double(uint32(fs * (T(2) * sum(bitDef) + T(1) * (size(bitDef,2) - sum(bitDef)))));       % number of sample points
signal = zeros(1,N);
t = 0:t0:(double(N) * t0 - t0);
code = bitDef;
xthBit = 1;         % current bit number, tmp value
bitContent = 0;     % current bit content
currentTime = 0;    % current time value(from delayed start point)
tmpPhase = 0;
frequency = 0;
if(bitDef(1))
	endTime = T(2);
else
	endTime = T(1);
end


for i = 1:1:N
	if(t(i) > endTime)
		xthBit = xthBit + 1;
		startTime = endTime;
		endTime = startTime + T(bitDef(xthBit) + 1);
	end
	signal(i) = sin(fc(bitDef(xthBit) + 1) * (1 + freqDeviation) * 2 * pi * t(i));
end

%% concatenate
if size(signal,2) > maxLen
    sigOut = signal(1:1:maxLen);
else
    sigOut = signal;
end

