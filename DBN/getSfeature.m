function output = getSfeature(input)
    [tmpST,t,f] = st(input,-1,-1,-1,-1);
    length = floor(size(input,2) / 2) + 1;
    output = zeros(1,length * 2);
    for i = 1:1:length
        for j = 1:1:size(input,2)
            output(i) = output(i) + tmpST(i,j) * tmpST(i,j);
        end
        output(i + length) = std(tmpST(i,:)) / mean(tmpST(i,:));
    end


end