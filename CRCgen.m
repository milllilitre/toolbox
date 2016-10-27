% CRCgen.m
% generate CRC
function result = CRCgen(input, polynomial)
zeros1 = zeros(1,size(polynomial,2)-1);
h = crc.generator('Polynomial', polynomial,'initialState',zeros1,'FinalXOR',zeros1);
encoded = generate(h, transpose(input)); % surfix with CRC16
result = transpose(encoded((size(input,2)+1):1:size(encoded,1),1));