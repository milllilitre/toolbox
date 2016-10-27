% qamGen.m 
% millilitre 
% 20150602 created

function sigOut = qamGen(fs,fc,bitrate,xqam,bitDef,maxLen)
% now only support 16qam
%% init parameters
t0 = 1/fs;
bitLen = 1/bitrate/t0;
N = double(uint32(size(bitDef,2) * fs / bitrate));
t = 0:t0:(N * t0 - t0);
%% generate waveform

code = binary2decimal(bitDef, log2(xqam)) + 1;
qam16 = [-3 -1 3 1 -3 -1 3 1 -3 -1 3 1 -3 -1 3 1
         -3 -3 -3 -3 -1 -1 -1 -1 3 3 3 3 1 1 1 1];

I = magGen(fs,bitrate,qam16(1,bitDef(1,:)),N);
Q = magGen(fs,bitrate,qam16(1,bitDef(1,:)),N);
sigOut = I .* sin(t) + Q .* cos(t);
