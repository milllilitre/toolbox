% binary2decimal.m
% 20150601 millilitre: create
% 20150602 millilitre: function test
function result = binary2decimal(input, n)
% n must be an integer.
% input must have length = x * n, x is an integer.
% input can be a row vector of a 2d matrix. If input is a matrix, the
% fuction computes the result of each row vector.
nRow = int32(size(input, 1));
nCol = int32(size(input, 2));
divisible = 1; % whether nCol is divisible by n
loop = uint32(nCol / n);
%% input check
if(mod(nCol, int32(n)))
    disp('binary2decimal.m: Warning: input column is not divisible by n.Might lose data.');
    divisible = 0;
end
if(~loop)
    error('binary2decimal.m: Error: nCol / n = 0, check input vector.');
end
%% main logic
result = zeros(size(input,1),loop);
tmpSum = 0;
if 1
    for k = 1:1:size(input,1)
        for i = 1:1:loop
            tmpSum = 0;
            for j = 1:1:n
                tmpSum = tmpSum + input(k, (i - 1) * n + j) * 2^(n - j);
            end
            result(k, i) = tmpSum;
        end
    end
end