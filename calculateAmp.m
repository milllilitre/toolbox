% function: calculate mag signal from IQ input
% IQsig is a 2*len matrix
function amp = calculateAmp(IQsig)
length = size(IQsig, 2);
amp = zeros(1,length);
for i = 1:1:length
    amp(i) = sqrt(IQsig(1,i)^2 + IQsig(2,i)^2);
end