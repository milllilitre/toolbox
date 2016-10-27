% modSigGen.m
close all;
clear all;
clc;
%addpath(genpath('E:\BaiduCloudDir\Document\RFID\millilitre\matlab\toolbox/.'));
%cd('E:\BaiduCloudDir\Document\RFID\millilitre\matlab\toolbox\signal');


%% note: all folders must be removed before executing this file

%% parameters
trainSNR = [-10 -8 -6 -4 -2 0 5 10];
% trainMod = ['ASK'
% 			'FSK'
% 			'singleSub'
% 			'dualSub'
% 			'PSK'
% 			'noise'
% 			'carrier'];
trainModIndex = [1  3 4 5 6 7];

% trainMod = [1       2       3         4        5      6        7];
%           ['ASK' 'FSK' 'singleSub' 'dualSub' 'PSK' 'noise' 'carrier'];

valSNR = [-10 -8 -6 -4 -2 0 5 10];
% valMod = ['ASK'
% 		'FSK'
% 		'singleSub'
% 		'dualSub'
% 		'PSK'
% 		'noise'
% 		'carrier'];
valModIndex = [1  3 4 5 6 7];
% valMod = [1     1         1          1      1       1        1];
%       ['ASK' 'FSK' 'singleSub' 'dualSub' 'PSK' 'noise' 'carrier'];
nTrain = 100;
nVal = 100;
fs = [64 ];
fc = [ 8];
bitrate = [2 ];
cyclePerSymbol = double(uint32(fc ./ bitrate));
bitLen = double(uint32(fs(1) / bitrate(1)));
% receivedLen = 10 * bitLen;
receivedLen = 250;
bits = [30];
trainInput = zeros(2 *receivedLen, nTrain * size(trainModIndex, 2) * size(trainSNR,2));
trainTarget = zeros(6, nTrain * size(trainModIndex, 2));
valInput = zeros(2 * receivedLen, nVal * size(valModIndex, 2) * size(valSNR,2));
valTarget = zeros(6, nVal * size(valModIndex, 2));

%% create all the folders
% mkdir('train');
% mkdir('val');
% for i = 1:1:size(valSNR,2)
%     folderName = ['val', int2str(valSNR(i))];
%     mkdir(folderName);
% end
%% 

for index = 1:size(fs,2)
	% training data
	fTrain = fopen('train.txt','w');
	for j = 1:1:size(trainSNR,2)
		for i=1:1:nTrain
		    flag = 0;
		    while(flag == 0) 
		        bitDef = randi(2,1,bits(index)) - 1;
		        if((sum(bitDef) == 0)||(sum(bitDef) == bits(index)))
		            flag = 0;
		        else
		            flag = 1;
		        end
		    end
		    fs1 = fs * (0.4 * rand() + 0.8);
		    fc1 = fc * (0.4 * rand() + 0.8);
		    bitrate1 = bitrate * (0.4 * rand() + 0.8);
            fs1 = fs(index);
            fc1 = fc(index);
            bitrate1 = bitrate(index);
            maxLen1 = bits(index) * fs(index) / bitrate(index);
		    for k = 1:1:size(trainModIndex,2)
                % tmpString = (trainMod(k,:));
		    	modulated = zeros(1,maxLen1);
		    	received = zeros(1,maxLen1);
		    	switch trainModIndex(k)
					case 1 %'ASK'
						modulated = magGen(fs1(index),bitrate1(index),bitDef,maxLen1);
						currentType = 'ASK';
						num = 1;
					case 2 % 'FSK'
						modulated = fskGen(fs1(index), fc1(index) * (1 + 0.05 * rand() + 0.05), fc1(index) * (1 - 0.05 * rand() - 0.05),bitrate1(index), bitDef, maxLen1);
						currentType = 'FSK';
						num = 2;
					case 3 % 'singleSub'
						modulated = singleSubGen(fs1(index), fc1(index), bitrate1(index), bitDef, maxLen1);
						currentType = 'singleSub';
						num = 3;
					case 4 % 'dualSub'
						modulated = dualSubGen(fs1(index), fc1(index) * (1 + 0.05 * rand() + 0.05), fc1(index) * (1- 0.05 * rand() - 0.05), cyclePerSymbol(index), bitDef, maxLen1);
						currentType = 'dualSub';
						num = 4;
					case 5 % 'PSK'
						modulated = pskGen(fs1(index), fc1(index), bitrate1(index), 2,bitDef, maxLen1);
						currentType = 'PSK';
						num = 5;
					case 6 % 'noise'
						modulated = zeros(1,maxLen1);
						currentType = 'noise';
						num = 6;
					case 7 % 'carrier'
						modulated = ones(1,maxLen1);
						currentType = 'carrier';
						num = 7;
					otherwise
						disp('no such definition');
						disp(tmpString);
				end
				if(num == 6)
					received = awgn(modulated, trainSNR(j));
				else
					received = awgn(modulated,trainSNR(j),'measured');
                end
                if(num > 2)
                    num = num - 1;
                end
				%received = received / max(received);
				tmp117 = double(uint32(bitLen * rand())) + 1;
				received = received(tmp117:1:(tmp117 + receivedLen - 1));
                tmp123 = abs(fft(received));
                if(min(received) < 0)
                    received = received - min(received);
                end
                if(min(tmp123) < 0)
                    tmp123 = tmp123 - min(tmp123);
                end
                received = transpose([(received / max(received))  (tmp123 / max(tmp123))]);
                trainInput(:, ((j - 1) * nTrain * size(trainModIndex,2) + (i - 1) * size(trainModIndex, 2) + k)) = received;
                trainTarget(num, (j - 1) * nTrain * size(trainModIndex, 2) + (i - 1) * size(trainModIndex, 2) + k) = 1;
% 				imwrite(received,['train/' currentType int2str(trainSNR(j)) 'dB_' int2str(i) '.bmp']);
% 				fprintf(fTrain, ['train/' currentType int2str(trainSNR(j)) 'dB_' int2str(i) '.bmp']);
% 				fprintf(fTrain, ' %g\n', num);
			end
		end
		trainSNR(j)
	end

	fclose(fTrain);

	
	fVal = fopen('val.txt','w');
	for j = 1:1:size(valSNR,2)
		for i=1:1:nVal
		    flag = 0;
		    while(flag == 0) 
		        bitDef = randi(2,1,bits(index)) - 1;
		        if((sum(bitDef) == 0)||(sum(bitDef) == bits(index)))
		            flag = 0;
		        else
		            flag = 1;
		        end
		    end
		    fs1 = fs * (0.4 * rand() + 0.8);
		    fc1 = fc * (0.4 * rand() + 0.8);
		    bitrate1 = bitrate * (0.4 * rand() + 0.8);
            fs1 = fs(index);
            fc1 = fc(index);
            bitrate1 = bitrate(index);
            maxLen1 = bits(index) * fs(index) / bitrate(index);
		    for k = 1:1:size(valModIndex,2)
		    	switch valModIndex(k)
		    	case 1 % 'ASK'
		    		modulated = magGen(fs1(index),bitrate1(index),bitDef,maxLen1);
		    		currentType = 'ASK';
		    		num = 1;
				case 2 % 'FSK'
					modulated = fskGen(fs1(index), fc1(index) * (1 + 0.05 * rand() + 0.05), fc1(index) * (1 - 0.05 * rand() - 0.05), bitrate1(index), bitDef, maxLen1);
					currentType = 'FSK';
					num = 2;
				case 3 %'singleSub'
					modulated = singleSubGen(fs1(index), fc1(index), bitrate1(index), bitDef, maxLen1);
					currentType = 'singleSub';
					num = 3;
				case 4 % 'dualSub'
					modulated = dualSubGen(fs1(index), fc1(index) * (1 + 0.05 * rand() + 0.05), fc1(index) * (1- 0.05 * rand() - 0.05), cyclePerSymbol(index), bitDef, maxLen1);
					currentType = 'dualSub';
					num = 4;
				case 5 % 'PSK'
					modulated = pskGen(fs1(index), fc1(index), bitrate1(index), 2,bitDef, maxLen1);
					currentType = 'PSK';
					num = 5;
				case 6 % 'noise'
					modulated = zeros(1,maxLen1);
					currentType = 'noise';
					num = 6;
				case 7 % 'carrier'
					modulated = ones(1,maxLen1);
					currentType = 'carrier';
					num = 7;
				end
				if(num == 6)
					received = awgn(modulated, trainSNR(j));
				else
					received = awgn(modulated,trainSNR(j),'measured');
                end
                if (num > 2)
                    num = num - 1;
                end
				%received = received / max(received);
				tmp117 = double(uint32(bitLen * rand())) + 1;
				received = received(tmp117:1:(tmp117 + receivedLen - 1));
                tmp123 = abs(fft(received));
                if(min(received) < 0)
                    received = received - min(received);
                end
                if(min(tmp123) < 0)
                    tmp123 = tmp123 - min(tmp123);
                end
                received = transpose([(received / max(received))  (tmp123 / max(tmp123))]);
                valInput(:, ((j - 1) * nVal * size(valModIndex,2) + (i - 1) * size(valModIndex, 2) + k)) = received;
                valTarget(num, (j - 1) * nVal * size(valModIndex, 2) + (i - 1) * size(valModIndex, 2) + k) = 1;
% 				imwrite(received,['val/' currentType int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
% 				fprintf(fVal, ['val/' currentType int2str(valSNR(j)) 'dB_' int2str(i) '.bmp']);
% 				fprintf(fVal, ' %g\n', num);
			end
		end
		valSNR(j)
	end
	fclose(fVal);

end


NodeNum = [1000 1000 1000];
TypeNum = 1; %Êä³öÎ¬Êý
TF1 = 'tansig';TF2 = 'logsig';
TF3 = 'purelin'; TF4 = TF3;% transfer function of each layer
% all kinds of transfer fucntions
%TF1 = 'tansig';TF2 = 'logsig';
%TF1 = 'logsig';TF2 = 'purelin';
%TF1 = 'tansig';TF2 = 'tansig';
%TF1 = 'logsig';TF2 = 'logsig';
%TF1 = 'purelin';TF2 = 'purelin'; 
net = newff(trainInput,trainTarget, NodeNum, {'tansig' 'tansig' 'purelin'}, 'traingdx');
% net.efficiency.memoryReduction = 2;

net.trainParam.epochs = 3000;
net.trainParam.goal = 0;
net.trainParam.lr = 0.01
net.trainParam.lr_dec = 0.1;
net.trainParam.max_fail = 60;
net.trainParam.min_grad = 1e-10;
% net.trainParam.mu = 0.001;
% net.trainParam.mu_dec = 0.1;
% net.trainParam.mu_inc = 10;
% net.trainParam.mu_max = 1e10;
net.trainParam.show = 100;
net.trainParam.showCommandLine = 0;
net.trainParam.showWindow = 1;
net.trainParam.time = inf;

%net.trainfcn = 'traingdx';
[net,tr] = train(net, trainInput, trainTarget,'useGPU','no');

%% output
outputs = net(valInput);
accuracy = 0;
for i = 1:1:size(outputs,2)
    for j = 1:1:size(outputs,1)
        if(outputs(j,i) == max(outputs(:,i)))
            if(valTarget(j,i) == 1)
                accuracy = accuracy + 1;
            end
        end
    end
end
accuracy
accuracy = accuracy / size(outputs,2)
% figure();
% hold on;
% plot(outputs,'color','red');
% plot(valTarget);
% perf = perform(net, outputs, valTarget);

