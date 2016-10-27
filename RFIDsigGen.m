% IQ �ź�����
% ����һ��ȷ�����Ʒ�ʽ��IQ�źţ�ʹ֮����ĳ��RFIDЭ��
% millilitre
% 20160901 created
% 20160905 updated
% 20160912 18000-6A finished
% 20160913 18000-6A function confirmed

clear all; close all; clc;
%% ��ʼ�����ò���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   ע�⣺�������Է������õĵ�λ��ʾ�ġ���Щ�����ǿ��Ը���ʵ������������õġ�
%%%%%%   ע���еĲ������ܻᱻ�����Э����صĹ̶����ø��ǡ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs = 12.5e6;                                                    %�����ʣ���λΪ��ÿ��
randomFactor = 0.2;                                             %��Э��̶��Ĳ������ڴ˲�����Χ�䶯
randomDeviFactor = 0.05;                                        %Э��̶��Ĳ��������ƫ����
sigTime = 8;                                                    %�����źŵ��ܳ��ȣ���λΪms
phaseShiftRate = 1;                                             %�ز��źŵ���λƫ�ƴ�С����λΪ����/����
switch(1)
    case 1
        protocol = 'ISO 18000-6A';
    case 2
        protocol = 'ISO 18000-4';
end
        
CWlevel = 0.5;                                                  %�ز����ȣ���λΪV
tagSigStrength = 0.05;                                          %��ǩ���ȣ���λΪV
tagPhase = 2 * pi * rand() - pi;                                %��ǩ������Ķ����źŵ���λ����λ����
CWbeforeRiseTime = 0.01;                                        %�ز���ʼ֮ǰ������ʱ�䣬��λms
CWriseTime = 0.1;                                               %�ز�����/�½�ʱ�䣬��λms
CWsettlingTime = 0;                                             %�ز�ƽ��ʱ�䣬��λms
readerStartTime = CWbeforeRiseTime + CWriseTime / 0.8 + 1;      %�Ķ����źſ�ʼ��ʱ�䣬��λms
sigSNR = 60;                                                    %�ź������
hasFilterNoise = 1;                                             %�����˲����Ƿ������
filterSNR = 20;                                                 %�����˲������������
% ���������
phaseShiftRate = phaseShiftRate * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWlevel = CWlevel * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWbeforeRiseTime = CWbeforeRiseTime * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWsettlingTime = CWsettlingTime * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWriseTime = CWriseTime * (rand(1) * randomFactor * 2 + 1 - randomFactor);
%CWlevel = CWlevel * (rand(1) * randomFactor * 2 + 1 - randomFactor);

%% ��ʼ��ȫ�ֱ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ע�⣺�����������ʱ���������Ա�׼��λ��ʾ�ġ��ⲿ�ֲ����ǹ̶��ģ�һ�㲻����� %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deltaT = 1 / fs;                                                %ÿ���������ʱ����λ��
sigLen = floor(sigTime / 1000 * fs);                            %�ź��ܵĲ�������
initialPhase = rand(1) * pi;                                    %�źŵĳ�ʼ��λ������õ�
phaseChangeDirection = 2 * (floor(rand(1) + 0.5) - 0.5);        %��λ�ı仯�������-1��1
SOR = 0; EOR = 0; SOT = 0; EOT = 0;                             % ��¼�˷ֶε��λ�á���λΪ����

% ������Э���йصı���
if (strcmp(protocol, 'ISO 18000-6A'))
    readerSOF = [0 1 0 1 1 1 1 1];
    readerEOF = [0 1 1 1 1 1 1 1];
    readerSymbol0 = [0 1];
    readerSymbol1 = [0 1 1 1];
    readerModulationIndex = 0.27 + 0.72 * rand();               %����ָ��Ϊ27%��100%
    readerModDepth = 2 * readerModulationIndex / (1 + readerModulationIndex);
    tagSOF = [0 0   0 0   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 0   0 1   1 0   1 1   0 0   0 1];
    tagEOF = [0 1 1 1];
    %readerCode = [0 1 0 0 0 0 0 1 0 0 0 1 0 0 0 0];            %1RFU 6������ 4�������־ 5CRC��������
    readerCode = [0   0 0 0 0 1 0   0 1 1 0   0 0 0 0 0];       % next_slot���� 1PE 6������ 4�������־ 5CRC��������
    %tagCode = [];                                              % 2��־ ���� ���� CRC����Ӧ��һ���ʽ
    tagCode = [0 1   0 0 0 1   0];                              % 2��־ 4������루��ѡ�� 1��������0������������Ľ����
    %tagCode = [];
    readerModType = 'ASK';                                      %�Ķ�����������
    readerCodType = 'PIE';                                      %�Ķ�����������
    readerBitrate = 33e3;                                       %�Ķ���������
    readerSymbolRate = readerBitrate * 2;
    readerTari = 0;              
    tagModType = 'ASK';
    tagCodType = 'FM0';                                         % ��ǩ�������ͣ�11��00 -��1��10-��0
    tagBitrate = 40e3;                                          % ��ǩ������
    tagSymbolRate = tagBitrate * 2;
    tagTari = 0;
    % Trs����Сֵ150us�����ֵ1150us�����Ķ������һ�������½��ص���ǩ��һ�������ص�ʱ��
    % ����SOT - EOR������ 7 ���Ķ���symbol�� 5 ����ǩsymbol������Ӧ����һ��������������symbolLenֵ���ɣ�
    tagResponseDelay = 150e-6 + 1000e-6 * rand();               % �����Trs����λ��
    tagResponseDelay = tagResponseDelay - 7 * (1 / readerSymbolRate) - 5 * (1 / tagSymbolRate); % ������������������ʱʵ�ʲ��õ�time(SOT - EOR)��ֵ����λ��
    readerResponseDelay = (2 + 2 * rand()) / tagBitrate;        % ��СֵΪ2����ǩ�ֽ�ʱ�������ֵΪ4����ǩ�ֽڣ���λΪ��
elseif (strcmp(protocol, 'ISO 18000-4'))
    sigTime = 10;                                                    %�����źŵ��ܳ��ȣ���λΪms
    sigLen = floor(sigTime / 1000 * fs);                            %�ź��ܵĲ�������
    readerPreamble = [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1];     % reader preamble��9 bit manchester 0��
    readerDelimiter = [1 1 0 0 1 1 1 0 1 0];                    % reader delimiter������manchester��Υ��
    readerSOF = [readerPreamble readerDelimiter];
    readerEOF = 0;                                              % 18000-4û���Ķ���EOF��������һ�������
    readerSymbol0 = [0 1];
    readerSymbol1 = [1 0];
    readerModulationIndex = 0.9 + 0.1 * rand();                 %����ָ��Ϊ27%��100%
    readerModDepth = 2 * readerModulationIndex / (1 + readerModulationIndex);
    tagSOF = [0 0   0 0   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 0   0 1   1 0   1 1   0 0   0 1];
    tagEOF = 0;                                                 % ��ǩ��EOF���������
    % reader:group_select_eq���� data��CRC�������ģ��չ�λ��
    readerCode = [              0 0 0 0  0 0 0 0    0 1 0 0  0 1 1 0];      % 8λ command 8λ address
    readerCode = [readerCode    0 0 0 0  0 0 0 0    0 0 0 0  0 1 0 0];      % 8λ mask 8/64λ word_data
    readerCode = [readerCode    1 1 0 0  0 1 0 1    0 0 1 1  1 0 1 0];      % 24/64
    readerCode = [readerCode    0 1 0 0  1 1 1 1    1 0 1 1  0 1 1 1];      % 40/64
    readerCode = [readerCode    1 0 0 0  0 0 0 1    0 0 1 0  1 1 0 1];      % 56/64
    readerCode = [readerCode    1 1 1 1  0 0 0 0    1 0 1 0  0 1 0 1];      % 64/64 word_data 8/16 CRC-16
    readerCode = [readerCode    1 0 1 0  1 1 1 0];                          % 16/16 CRC-16
    tagCode = [           0 0 0 1  0 0 1 0    0 0 1 1  0 1 0 0];            % 16/64 tag ID
    tagCode = [tagCode    0 1 0 1  0 1 1 0    0 1 1 1  1 0 0 0];            % 32/64 tag ID
    tagCode = [tagCode    1 0 0 1  1 0 1 0    1 0 1 1  1 1 0 0];            % 48/64 tag ID
    tagCode = [tagCode    1 1 0 1  1 1 1 0    1 1 1 1  0 0 0 0];            % 64/64 tag ID
    tagCode = [tagCode    1 0 1 0  0 1 1 1    1 1 0 0  1 0 0 0];            % 16 CRC-16
    readerModType = 'ASK';                                      %�Ķ�����������
    readerCodType = 'Manchester';                               %�Ķ�����������
    readerBitrate = 30e3 + 10e3 * rand();                       %�Ķ���������Ϊ30-40kbps
    readerSymbolRate = readerBitrate * 2;
    readerTari = 0;              
    tagModType = 'ASK';
    tagCodType = 'FM0';                                         %��ǩ�������ͣ�11��00 ->1��10��01->0
    tagBitrate = readerBitrate;                                 %��ǩ�����ʸ����Ķ��������ʵ���
    tagSymbolRate = tagBitrate * 2;
    tagTari = 0;
    % �Ķ������ź�֮ǰ����Ҫ��400us���ز��źţ���Ϊpreamble detect��Ϊ��ǩ�ṩ����
    % Trib, Tflb��forward link bit time
    % ��ǩpreamble��ʼǰ��quietʱ�䣬���Ķ���������ǩ�ȴ�ʱ�䣬�������źţ����� 16 * Trib - 0.75 * Tflb
    % Waitʱ�䣬����Ķ������͵���дָ��ҵõ��˱�ǩ��ȷ�ϣ���ô�����ɹ����Ķ����������15ms�Ĵ��ز�ʱ��Ϊ��ǩд�����ṩ���������ʱ����Ķ������꿪ʼ��
    % Trs����Сֵ150us�����ֵ1150us�����Ķ������һ�������½��ص���ǩ��һ�������ص�ʱ��
    % ����SOT - EOR������ 7 ���Ķ���symbol�� 5 ����ǩsymbol������Ӧ����һ��������������symbolLenֵ���ɣ�
    tagResponseDelay = 150e-6 + 1000e-6 * rand();               % �����Trs����λ��
    tagResponseDelay = tagResponseDelay - 7 * (1 / readerSymbolRate) - 5 * (1 / tagSymbolRate); % ������������������ʱʵ�ʲ��õ�time(SOT - EOR)��ֵ����λ��
    readerResponseDelay = (2 + 2 * rand()) / tagBitrate;        % ��СֵΪ2����ǩ�ֽ�ʱ�������ֵΪ4����ǩ�ֽڣ���λΪ��
end
beta = 0.95;                        % �Ķ�����������˲����Ĺ���ϵ��
span = 10;                          % �Ķ�����������˲����ĳ��ȣ���λΪsymbol
sps = floor(fs / readerBitrate / 2);% �Ķ�����������˲���ÿ��symbol�Ĳ�������

%% �������������ز��ź�,�����ʼ��λ����λƫ���ٶ�Ϊ����
% ��������ԭʼ�ź�
signal = zeros(2, sigLen);                                      %������ɵ��ź�
for i = 1:sigLen
    currentTime = deltaT * (i - 1); %��Ϊ��λ
    currentPhase = initialPhase + currentTime * 1000 * phaseShiftRate * phaseChangeDirection;
    signal(1,i) = CWlevel * cos(currentPhase);
    signal(2,i) = CWlevel * sin(currentPhase);
end
% Ȼ�������ز��������ز��½���
CWstartPoint = floor(CWbeforeRiseTime / 1000 * fs);
CWendPoint = floor(CWstartPoint + CWriseTime / 1000 * fs / 0.8);
signal(:,1:CWstartPoint) = zeros(2,CWstartPoint);
signal(:,(sigLen - CWendPoint + 1):sigLen) = zeros(2,CWendPoint);
tmpSig =[0 1:(CWendPoint - CWstartPoint)] / (CWendPoint - CWstartPoint);
tmpSig1 = fliplr(tmpSig);
for i = 1:2
    signal(i,CWstartPoint:CWendPoint) = signal(i,CWstartPoint:CWendPoint) .* tmpSig;
    signal(i, (sigLen - 2 * CWendPoint + CWstartPoint):(sigLen - CWendPoint)) = signal(i, (sigLen - 2 * CWendPoint + CWstartPoint):(sigLen - CWendPoint)) .* tmpSig1;
end
ampSig = sqrt(signal(1,:) .* signal(1,:) + signal(2,:) .* signal(2,:));
figure();plot(ampSig);title('generated CW seg');

%% �����Ķ����źţ�ASK������ԭʼ�ز��ź��Ͻ��г��Ե���
% ����
readerSymbol = [0 0];
if(strcmp(readerCodType, 'PIE'))
    readerSymbol = PIEcodec(readerCode, 0);
end
readerSymbol = [readerSOF readerSymbol readerEOF];

% ����
readerSig = ASK2gen(fs, readerBitrate, readerModDepth, readerSymbol);
figure();plot(readerSig);title('readerSig');

% ���Ķ����źż��ں��ʵĵط�
readerLen = size(readerSig, 2);
SOR = floor(readerStartTime / 1000 * fs);  % ��ΪreaderStartTime��ms��λ�����Գ���1000
EOR = SOR + readerLen - 1;
for i = 1:2
    signal(i, SOR:EOR) = signal(i, SOR:EOR) .* readerSig;
end

% �������
pulseShapeFilter = rcosdesign(beta, span, sps);
if(hasFilterNoise)
    pulseShapeFilter = awgn(pulseShapeFilter, filterSNR, 'measured');
end
pulseShapeFilter = pulseShapeFilter ./ sum(pulseShapeFilter);
figure();plot(pulseShapeFilter);title('pulseShapeFilter');
tmpSig = zeros(2, sigLen);
tmpSig(1,:) = filter(pulseShapeFilter, 1, signal(1,:));
tmpSig(2,:) = filter(pulseShapeFilter, 1, signal(2,:));
ampSig = sqrt(tmpSig(1,:) .* tmpSig(1,:) + tmpSig(2,:) .* tmpSig(2,:));
signal = tmpSig(:,1:sigLen);
figure();plot(ampSig);title('signal');
%readerLen = size(shapedReaderSig, 2);

%% ���ɱ�ǩ��Ӧ�ź�
% ����
tagSymbol = [0 0];
if(strcmp(tagCodType, 'FM0'))
    tagSymbol = FM0codec(tagCode, 0, 0);
end

% ��֡
tagSymbol = [tagSOF tagSymbol tagEOF];

% ����
tagSig = tagSigStrength * ASK2gen(fs, tagBitrate, 1, tagSymbol);

% �������
if(1)
    span = floor(fs / tagSymbolRate / 10);
    averageFilter = rand(1,span);
    averageFilter = averageFilter ./ sum(averageFilter);
    tmpSig = filter(averageFilter, 1, tagSig);
    tagSig = tmpSig;
    figure();plot(tmpSig);title('tag signal filtered');
else
    shapedTagSig = tagSig;      % û������ǩ�źŵ�������ͣ�����ǩ�źſ����Ƹ���ͨ�Ͽ��Ʒ���ϵ������û��������͵ģ�
end
figure();plot(tagSig);title('tagSig');

% ����ǩ�źż��ں��ʵĵط���ע�⣬���ǩ�ź�����һ����phase����ԭʼ�ź������
SOT = floor(EOR + fs * tagResponseDelay);
tagLen = size(tagSig, 2);
EOT = SOT + tagLen - 1;
for i = SOT:EOT
    currentTime = deltaT * (i - 1); %��Ϊ��λ
    currentPhase = initialPhase + currentTime * 1000 * phaseShiftRate * phaseChangeDirection + tagPhase;
    signal(1,i) = signal(1,i) + tagSig(i - SOT + 1) * cos(currentPhase);
    signal(2,i) = signal(2,i) + tagSig(i - SOT + 1) * sin(currentPhase);
end
% signal(1, SOT:EOT) = signal(1, SOT:EOT) + tagSig .* cos(tagPhase);
% signal(2, SOT:EOT) = signal(2, SOT:EOT) + tagSig .* sin(tagPhase);

%% �ź�������ڴ���
% ������
tmpSig = signal(1,:) + 1i * signal(2,:);
tmpSig = awgn(tmpSig, sigSNR, 'measured');
signal(1,:) = real(tmpSig);
signal(2,:) = imag(tmpSig);
clear tmpSig;
ampSig = sqrt(signal(1,:) .* signal(1,:) + signal(2,:) .* signal(2,:));

figure();subplot(3,1,1);plot(ampSig);title('generated signal');
subplot(3,1,2);plot(signal(1,:));title('I');
subplot(3,1,3);plot(signal(2,:));title('Q');

%% ��������źţ�������ļ�
fileHeader1 = 'InputZoom\tTRUE\r\nInputCenter\t915000000.000000000\r\nInputRange\t2.000000000\r\nInputRefImped\t50.000000000\r\n';
fileHeader2 = ['XStart\t0.000000000\r\nXDelta\t' num2str(1 / fs)];
fileHeader3 = '\r\nXDomain\t0\r\nXUnit\tSec\r\nYUnit\tV\r\nFreqValidMax\t920000000.000000000\r\n';
fileHeader4 = 'FreqValidMin\t910000000.000000000\r\nTimeString\tSat Sep 12 10:32:5.267 2016\r\nY\r\n';
fileHeader = [fileHeader1 fileHeader2 fileHeader3 fileHeader4];
clockStr = datestr(clock);
clockStr = [protocol '_' clockStr '.txt'];
tmpPosi = strfind(clockStr, ':');
tmpLen = size(tmpPosi, 2);
for i = 1:tmpLen
    clockStr(tmpPosi(i)) = '-';
end
clockStr = ['/data/' clockStr];
saveFile = fopen(clockStr, 'w');
%for i = 1:sigLen
fprintf(saveFile, fileHeader);
for i = 1:sigLen
    fprintf(saveFile, '%f\t%f\r\n', signal(1,i),signal(2,i));
end
%end

%% ��������ļ����Ǽ�����֮ǰ�����ݣ���������������Ļ����в��
tmpPosi = strfind(clockStr, '.txt');
clockStr = clockStr(1:(tmpPosi - 1));
clockStr = [clockStr '_params.txt'];
saveFile = fopen(clockStr, 'w');
fprintf(saveFile, 'randomFactor \t%12.8f\r\n', randomFactor);
fprintf(saveFile, 'randomDeviFactor \t%12.8f\r\n', randomDeviFactor);
fprintf(saveFile, 'phaseShiftRate \t%12.8f\r\n', phaseShiftRate);
fprintf(saveFile, 'CWlevel \t%12.8f\r\n', CWlevel);
fprintf(saveFile, 'tagSigStrength \t%12.8f\r\n', tagSigStrength);
fprintf(saveFile, 'tagPhase \t%12.8f\r\n', tagPhase);
fprintf(saveFile, 'CWbeforeRiseTime \t%12.8f\r\n', CWbeforeRiseTime);
fprintf(saveFile, 'CWriseTime \t%12.8f\r\n', CWriseTime);
fprintf(saveFile, 'CWsettlingTime \t%12.8f\r\n', CWsettlingTime);
fprintf(saveFile, 'readerStartTime \t%12.8f\r\n', readerStartTime);
fprintf(saveFile, 'sigSNR \t%12.8f\r\n', sigSNR);
fprintf(saveFile, 'hasFilterNoise \t%12.8f\r\n', hasFilterNoise);
fprintf(saveFile, 'filterSNR \t%12.8f\r\n', filterSNR);
fprintf(saveFile, 'initialPhase \t%12.8f\r\n', initialPhase);
fprintf(saveFile, 'hasFilterNoise \t%12.8f\r\n', hasFilterNoise);
fprintf(saveFile, 'SOR \t%12.8f\r\n', SOR);
fprintf(saveFile, 'EOR \t%12.8f\r\n', EOR);
fprintf(saveFile, 'SOT \t%12.8f\r\n', SOT);
fprintf(saveFile, 'EOT \t%12.8f\r\n', EOT);
fprintf(saveFile, 'readerModulationIndex \t%12.8f\r\n', readerModulationIndex);
fprintf(saveFile, 'readerModDepth \t%12.8f\r\n', readerModDepth);
fprintf(saveFile, 'readerCode \t%12.8f\r\n', readerCode);
fprintf(saveFile, 'tagCode \t%12.8f\r\n', tagCode);
fprintf(saveFile, 'readerBitrate \t%12.8f\r\n', readerBitrate);
fprintf(saveFile, 'readerSymbolRate \t%12.8f\r\n', readerSymbolRate);
fprintf(saveFile, 'readerTari \t%12.8f\r\n', readerTari);
fprintf(saveFile, 'tagBitrate \t%12.8f\r\n', tagBitrate);
fprintf(saveFile, 'tagSymbolRate \t%12.8f\r\n', tagSymbolRate);
fprintf(saveFile, 'tagTari \t%12.8f\r\n', tagTari);
fprintf(saveFile, 'tagResponseDelay \t%12.8f\r\n', tagResponseDelay);
fprintf(saveFile, 'readerResponseDelay \t%12.8f\r\n', readerResponseDelay);
fprintf(saveFile, 'beta \t%12.8f\r\n', beta);
fprintf(saveFile, 'span \t%12.8f\r\n', span);
fprintf(saveFile, 'sps \t%12.8f\r\n', sps);
disp('file generated');
