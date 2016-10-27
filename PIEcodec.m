% PIE coding/decoding
% mode = 0: code
% mode = 1: decode
% input must be row vector
function result = PIEcodec(input, mode)
if(mode == 0)
    length = size(input, 2);
    result = 1;
    % 数组变长，可考虑优化下。不过一般不会编解码很长的信号，所以没事
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
        %暂时没有用到，故未完成
    result = 0;
end