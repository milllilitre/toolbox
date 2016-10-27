% FM0 coding/decoding
% mode = 0: code
% mode = 1: decode
% input must be row vector
% startState 表示了开始时第一个元素的前半段是高还是低，因为FM0编码下一位的编码形式与上一位有关。
function result = FM0codec(input, mode, startState)
lastState = ~startState;
if(mode == 0)
    length = size(input, 2);
    result = 1;
    % 数组变长，可考虑优化下，不过一般不会很长的编解码，所以没事
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
    % 暂时没有用到，故未完成
    result = 0;
end