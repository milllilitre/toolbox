% IQ 信号生成
% 生成一段确定调制方式的IQ信号，使之符合某个RFID协议
% millilitre
% 20160901 created
% 20160905 updated
% 20160912 18000-6A finished
% 20160913 18000-6A function confirmed

clear all; close all; clc;
%% 初始化配置参数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   注意：参数是以方便设置的单位表示的。这些参数是可以根据实际需求进行配置的。
%%%%%%   注意有的参数可能会被后面的协议相关的固定设置覆盖。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs = 12.5e6;                                                    %采样率，单位为次每秒
randomFactor = 0.2;                                             %非协议固定的参数都在此参数范围变动
randomDeviFactor = 0.05;                                        %协议固定的参数的随机偏移率
sigTime = 8;                                                    %生成信号的总长度，单位为ms
phaseShiftRate = 1;                                             %载波信号的相位偏移大小，单位为弧度/毫秒
switch(1)
    case 1
        protocol = 'ISO 18000-6A';
    case 2
        protocol = 'ISO 18000-4';
end
        
CWlevel = 0.5;                                                  %载波幅度，单位为V
tagSigStrength = 0.05;                                          %标签幅度，单位为V
tagPhase = 2 * pi * rand() - pi;                                %标签相对于阅读器信号的相位，单位弧度
CWbeforeRiseTime = 0.01;                                        %载波开始之前的噪声时间，单位ms
CWriseTime = 0.1;                                               %载波上升/下降时间，单位ms
CWsettlingTime = 0;                                             %载波平静时间，单位ms
readerStartTime = CWbeforeRiseTime + CWriseTime / 0.8 + 1;      %阅读器信号开始的时间，单位ms
sigSNR = 60;                                                    %信号信噪比
hasFilterNoise = 1;                                             %成型滤波器是否加噪声
filterSNR = 20;                                                 %成型滤波器加噪信噪比
% 参数随机化
phaseShiftRate = phaseShiftRate * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWlevel = CWlevel * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWbeforeRiseTime = CWbeforeRiseTime * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWsettlingTime = CWsettlingTime * (rand(1) * randomFactor * 2 + 1 - randomFactor);
CWriseTime = CWriseTime * (rand(1) * randomFactor * 2 + 1 - randomFactor);
%CWlevel = CWlevel * (rand(1) * randomFactor * 2 + 1 - randomFactor);

%% 初始化全局变量
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% 注意：下面申请的临时变量都是以标准单位表示的。这部分参数是固定的，一般不需调整 %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deltaT = 1 / fs;                                                %每相邻两点的时间差，单位秒
sigLen = floor(sigTime / 1000 * fs);                            %信号总的采样点数
initialPhase = rand(1) * pi;                                    %信号的初始相位，随机得到
phaseChangeDirection = 2 * (floor(rand(1) + 0.5) - 0.5);        %相位的变化方向，随机-1或1
SOR = 0; EOR = 0; SOT = 0; EOT = 0;                             % 记录了分段点的位置。单位为点数

% 设置与协议有关的变量
if (strcmp(protocol, 'ISO 18000-6A'))
    readerSOF = [0 1 0 1 1 1 1 1];
    readerEOF = [0 1 1 1 1 1 1 1];
    readerSymbol0 = [0 1];
    readerSymbol1 = [0 1 1 1];
    readerModulationIndex = 0.27 + 0.72 * rand();               %调制指数为27%到100%
    readerModDepth = 2 * readerModulationIndex / (1 + readerModulationIndex);
    tagSOF = [0 0   0 0   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 0   0 1   1 0   1 1   0 0   0 1];
    tagEOF = [0 1 1 1];
    %readerCode = [0 1 0 0 0 0 0 1 0 0 0 1 0 0 0 0];            %1RFU 6命令码 4参数或标志 5CRC；短命令
    readerCode = [0   0 0 0 0 1 0   0 1 1 0   0 0 0 0 0];       % next_slot命令 1PE 6命令码 4参数或标志 5CRC；短命令
    %tagCode = [];                                              % 2标志 参数 数据 CRC；响应的一般格式
    tagCode = [0 1   0 0 0 1   0];                              % 2标志 4错误代码（可选） 1结束符‘0’；发生错误的结果。
    %tagCode = [];
    readerModType = 'ASK';                                      %阅读器调制类型
    readerCodType = 'PIE';                                      %阅读器编码类型
    readerBitrate = 33e3;                                       %阅读器比特率
    readerSymbolRate = readerBitrate * 2;
    readerTari = 0;              
    tagModType = 'ASK';
    tagCodType = 'FM0';                                         % 标签编码类型，11、00 -》1；10-》0
    tagBitrate = 40e3;                                          % 标签比特率
    tagSymbolRate = tagBitrate * 2;
    tagTari = 0;
    % Trs，最小值150us，最大值1150us，是阅读器最后一个脉冲下降沿到标签第一个上升沿的时间
    % 由于SOT - EOR多算了 7 个阅读器symbol和 5 个标签symbol，所以应该做一个补偿（用理想symbolLen值即可）
    tagResponseDelay = 150e-6 + 1000e-6 * rand();               % 随机的Trs，单位秒
    tagResponseDelay = tagResponseDelay - 7 * (1 / readerSymbolRate) - 5 * (1 / tagSymbolRate); % 补偿，这个结果是生成时实际采用的time(SOT - EOR)的值，单位秒
    readerResponseDelay = (2 + 2 * rand()) / tagBitrate;        % 最小值为2个标签字节时长，最大值为4个标签字节，单位为秒
elseif (strcmp(protocol, 'ISO 18000-4'))
    sigTime = 10;                                                    %生成信号的总长度，单位为ms
    sigLen = floor(sigTime / 1000 * fs);                            %信号总的采样点数
    readerPreamble = [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1];     % reader preamble是9 bit manchester 0；
    readerDelimiter = [1 1 0 0 1 1 1 0 1 0];                    % reader delimiter，含有manchester的违例
    readerSOF = [readerPreamble readerDelimiter];
    readerEOF = 0;                                              % 18000-4没有阅读器EOF，这里用一个零代替
    readerSymbol0 = [0 1];
    readerSymbol1 = [1 0];
    readerModulationIndex = 0.9 + 0.1 * rand();                 %调制指数为27%到100%
    readerModDepth = 2 * readerModulationIndex / (1 + readerModulationIndex);
    tagSOF = [0 0   0 0   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 1   0 0   0 1   1 0   1 1   0 0   0 1];
    tagEOF = 0;                                                 % 标签无EOF，以零代替
    % reader:group_select_eq命令 data、CRC是随便输的，凑够位数
    readerCode = [              0 0 0 0  0 0 0 0    0 1 0 0  0 1 1 0];      % 8位 command 8位 address
    readerCode = [readerCode    0 0 0 0  0 0 0 0    0 0 0 0  0 1 0 0];      % 8位 mask 8/64位 word_data
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
    readerModType = 'ASK';                                      %阅读器调制类型
    readerCodType = 'Manchester';                               %阅读器编码类型
    readerBitrate = 30e3 + 10e3 * rand();                       %阅读器比特率为30-40kbps
    readerSymbolRate = readerBitrate * 2;
    readerTari = 0;              
    tagModType = 'ASK';
    tagCodType = 'FM0';                                         %标签编码类型，11、00 ->1；10、01->0
    tagBitrate = readerBitrate;                                 %标签比特率根据阅读器比特率调整
    tagSymbolRate = tagBitrate * 2;
    tagTari = 0;
    % 阅读器发信号之前至少要有400us的载波信号，作为preamble detect，为标签提供能量
    % Trib, Tflb：forward link bit time
    % 标签preamble开始前有quiet时间，即阅读器传完后标签等待时间，不返回信号，持续 16 * Trib - 0.75 * Tflb
    % Wait时间，如果阅读器发送的是写指令并且得到了标签的确认，那么交互成功后阅读器会等至少15ms的纯载波时间为标签写操作提供能量。这个时间从阅读器发完开始算
    % Trs，最小值150us，最大值1150us，是阅读器最后一个脉冲下降沿到标签第一个上升沿的时间
    % 由于SOT - EOR多算了 7 个阅读器symbol和 5 个标签symbol，所以应该做一个补偿（用理想symbolLen值即可）
    tagResponseDelay = 150e-6 + 1000e-6 * rand();               % 随机的Trs，单位秒
    tagResponseDelay = tagResponseDelay - 7 * (1 / readerSymbolRate) - 5 * (1 / tagSymbolRate); % 补偿，这个结果是生成时实际采用的time(SOT - EOR)的值，单位秒
    readerResponseDelay = (2 + 2 * rand()) / tagBitrate;        % 最小值为2个标签字节时长，最大值为4个标签字节，单位为秒
end
beta = 0.95;                        % 阅读器脉冲成型滤波器的滚降系数
span = 10;                          % 阅读器脉冲成型滤波器的长度，单位为symbol
sps = floor(fs / readerBitrate / 2);% 阅读器脉冲成型滤波器每个symbol的采样点数

%% 生成整段理想载波信号,随机初始相位，相位偏移速度为常数
% 首先生成原始信号
signal = zeros(2, sigLen);                                      %最后生成的信号
for i = 1:sigLen
    currentTime = deltaT * (i - 1); %秒为单位
    currentPhase = initialPhase + currentTime * 1000 * phaseShiftRate * phaseChangeDirection;
    signal(1,i) = CWlevel * cos(currentPhase);
    signal(2,i) = CWlevel * sin(currentPhase);
end
% 然后增加载波上升和载波下降段
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

%% 生成阅读器信号（ASK），在原始载波信号上进行乘性调制
% 编码
readerSymbol = [0 0];
if(strcmp(readerCodType, 'PIE'))
    readerSymbol = PIEcodec(readerCode, 0);
end
readerSymbol = [readerSOF readerSymbol readerEOF];

% 调制
readerSig = ASK2gen(fs, readerBitrate, readerModDepth, readerSymbol);
figure();plot(readerSig);title('readerSig');

% 将阅读器信号加在合适的地方
readerLen = size(readerSig, 2);
SOR = floor(readerStartTime / 1000 * fs);  % 因为readerStartTime是ms单位，所以除以1000
EOR = SOR + readerLen - 1;
for i = 1:2
    signal(i, SOR:EOR) = signal(i, SOR:EOR) .* readerSig;
end

% 脉冲成型
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

%% 生成标签回应信号
% 编码
tagSymbol = [0 0];
if(strcmp(tagCodType, 'FM0'))
    tagSymbol = FM0codec(tagCode, 0, 0);
end

% 组帧
tagSymbol = [tagSOF tagSymbol tagEOF];

% 调制
tagSig = tagSigStrength * ASK2gen(fs, tagBitrate, 1, tagSymbol);

% 脉冲成型
if(1)
    span = floor(fs / tagSymbolRate / 10);
    averageFilter = rand(1,span);
    averageFilter = averageFilter ./ sum(averageFilter);
    tmpSig = filter(averageFilter, 1, tagSig);
    tagSig = tmpSig;
    figure();plot(tmpSig);title('tag signal filtered');
else
    shapedTagSig = tagSig;      % 没有做标签信号的脉冲成型；（标签信号靠控制负载通断控制发射系数，是没有脉冲成型的）
end
figure();plot(tagSig);title('tagSig');

% 将标签信号加在合适的地方，注意，与标签信号是以一定的phase加在原始信号上面的
SOT = floor(EOR + fs * tagResponseDelay);
tagLen = size(tagSig, 2);
EOT = SOT + tagLen - 1;
for i = SOT:EOT
    currentTime = deltaT * (i - 1); %秒为单位
    currentPhase = initialPhase + currentTime * 1000 * phaseShiftRate * phaseChangeDirection + tagPhase;
    signal(1,i) = signal(1,i) + tagSig(i - SOT + 1) * cos(currentPhase);
    signal(2,i) = signal(2,i) + tagSig(i - SOT + 1) * sin(currentPhase);
end
% signal(1, SOT:EOT) = signal(1, SOT:EOT) + tagSig .* cos(tagPhase);
% signal(2, SOT:EOT) = signal(2, SOT:EOT) + tagSig .* sin(tagPhase);

%% 信号整体后期处理
% 加噪声
tmpSig = signal(1,:) + 1i * signal(2,:);
tmpSig = awgn(tmpSig, sigSNR, 'measured');
signal(1,:) = real(tmpSig);
signal(2,:) = imag(tmpSig);
clear tmpSig;
ampSig = sqrt(signal(1,:) .* signal(1,:) + signal(2,:) .* signal(2,:));

figure();subplot(3,1,1);plot(ampSig);title('generated signal');
subplot(3,1,2);plot(signal(1,:));title('I');
subplot(3,1,3);plot(signal(2,:));title('Q');

%% 输出仿真信号，保存成文件
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

%% 保存参数文件（是加噪音之前的数据，加噪音后求出来的会略有差别）
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
