% funtion:load a IQ file
% loaded number array, have length = 2*len
% return 2*len matrix
function IQ = loadIQ(loadedIQ)
length = size(loadedIQ,1) / 2
IQ = zeros(2,length);
for i = 1:1:length
    IQ(1,i) = loadedIQ(2*i-1);
    IQ(2,i) = loadedIQ(2*i);
end