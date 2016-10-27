% PIE coding/decoding
% mode = 0: code
% mode = 1: decode
% input must be row vector
function result = PIEcodec(input, mode)
if(mode == 0)
    length = size(input, 2);
    result = 1;
    % ����䳤���ɿ����Ż��¡�����һ�㲻������ܳ����źţ�����û��
    for i = 1:length
        if(input(i) == 0)
            result = [result 0 1];
        else
            result = [result 0 1 1 1];
        end
    end
    length = size(result, 2);
    result = result(1, 2:length);
elseif (mode == 1)
        %��ʱû���õ�����δ���
    result = 0;
end