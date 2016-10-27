% main.m
close all;
clear all;
clc;
%addpath(genpath('E:\BaiduCloudDir\Document\RFID\millilitre\matlab\toolbox/.'));
%cd('E:\BaiduCloudDir\Document\RFID\millilitre\matlab\toolbox\signal');




%% note: all folders must be removed before executing this file


%% parameters
trainSNR = [5 0 -5 10 -10];
valSNR = [-10];
nTrain = 1000;
nVal = 10000;
fs = 32;
fc = 4;
bitrate = 1;
bits =  8;


maxLen = bits * fs / bitrate;
%% create all the folders
mkdir('train');
mkdir('val');
for i = 1:1:size(valSNR,2)
    folderName = ['val', int2str(valSNR(i))];
    mkdir(folderName);
end


%% training data
fTrain = fopen('train.txt','w');
for j = 1:1:size(trainSNR,2)
    for i=1:1:nTrain
        flag = 0;
        while(flag == 0) 
            bitDef = randi(2,1,bits) - 1;
            if((sum(bitDef) == 0)||(sum(bitDef) == bits))
                flag = 0;
            else
                flag = 1;
            end
        end
        modulated = magGen(fs,bitrate,bitDef,maxLen);
        received = awgn(modulated,trainSNR(j),'measured');
        received = received / max(received);
        imwrite(received,['train/ask' int2str(trainSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fTrain, ['train/ask' int2str(trainSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fTrain, ' %g\n', 1);
    end
    for i = 1:1:nTrain
        noise = zeros(1,maxLen);
        noise = awgn(noise, trainSNR(j));
        noise = noise / max(noise);
        imwrite(noise,['train/noise' int2str(trainSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fTrain, ['train/noise' int2str(trainSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fTrain, ' %g\n', 0);
    end
    trainSNR(j)
end


fclose(fTrain);
%% validation data
fVal = fopen('val.txt','w');
for j = 1:1:size(valSNR,2)
    for i=1:1:nVal
        flag = 0;
        while(flag == 0) 
            bitDef = randi(2,1,bits) - 1;
            if((sum(bitDef) == 0)||(sum(bitDef) == bits))
                flag = 0;
            else
                flag = 1;
            end
        end
        modulated = magGen(fs,bitrate,bitDef,maxLen);
        received = awgn(modulated,valSNR(j),'measured');
        received = received / max(received);
        imwrite(received,['val/ask' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ['val/ask' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ' %g\n', 1);
    end
    for i = 1:1:nVal
        noise = zeros(1,maxLen);
        noise = awgn(noise, valSNR(j));
        noise = noise / max(noise);
        imwrite(noise,['val/noise' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ['val/noise' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ' %g\n', 0);
    end
    valSNR(j)
end
fclose(fVal);


%% separate validation data of different SNR
for j = 1:1:size(valSNR,2)
    fVal = fopen(['val' int2str(valSNR(j)) '.txt'],'w');
    for i=1:1:nVal
        flag = 0;
        while(flag == 0) 
            bitDef = randi(2,1,bits) - 1;
            if((sum(bitDef) == 0)||(sum(bitDef) == bits))
                flag = 0;
            else
                flag = 1;
            end
        end
        modulated = magGen(fs,bitrate,bitDef,maxLen);
        received = awgn(modulated,valSNR(j),'measured');
        received = received / max(received);
        imwrite(received,['val' int2str(valSNR(j)) '/ask' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ['val' int2str(valSNR(j)) '/ask' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ' %g\n', 1);
    end
    for i = 1:1:nVal
        noise = zeros(1,maxLen);
        noise = awgn(noise, valSNR(j));
        noise = noise / max(noise);
        imwrite(noise,['val' int2str(valSNR(j)) '/noise' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ['val' int2str(valSNR(j)) '/noise' int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
        fprintf(fVal, ' %g\n', 0);
    end
    fclose(fVal);
    valSNR(j)
end
