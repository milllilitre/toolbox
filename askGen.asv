% askGen.m 
% millilitre 
% 20150602 created

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

