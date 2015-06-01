clear all;close all;clc;
iq212add = importdata('iq212add.txt', '  ',13);
amp = calculateAmp(iq212add);
figure();
plot(amp);