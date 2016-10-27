% FM0 coding/decoding
% mode = 0: code
% mode = 1: decode
% input must be row vector
% startState ��ʾ�˿�ʼʱ��һ��Ԫ�ص�ǰ����Ǹ߻��ǵͣ���ΪFM0������һλ�ı�����ʽ����һλ�йء�
function result = FM0codec(input, mode, startState)
lastState = ~startState;
if(mode == 0)
    length = size(input, 2);
    result = 1;
    % ����䳤���ɿ����Ż��£�����һ�㲻��ܳ��ı���룬����û��
    for i = 1:length
        if(input(i) == 0)
            if(lastState == 0)
                result = [result 1 0];
                lastState = 0;
            else
                result = [result 0 1];
                lastState = 1;
            end
        else
            if(lastState == 0)
                result = [result 1 1];
                lastState = 1;
            else
                result = [result 0 0];
                lastState = 0;
            end
        end
    end
    length = size(result, 2);
    result = result(1, 2:length);
elseif (mode == 1)
    % ��ʱû���õ�����δ���
    result = 0;
end