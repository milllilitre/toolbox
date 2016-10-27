% main.m
close all;
clear all;
clc;
a = [0 1 0 1 1 1 0 0 1 1];
b = binary2decimal(a,2);
out1 = pskGen(6.25, 13.56, 0.122,4,b,20000);
figure();
plot(out1);
out2 = askGen(6.25, 13.56, 0.122,2,a,20000);
figure();
plot(out2);
m = [ 0 1 0 1 0 1 0 0 1 0 1 0 1 0 1 0];
n = binary2decimal(m, 4);
out3 = qamGen(6.25,13.56,0.122,16,n,20000);
figure();
plot(out3);

%% signal genaration
fc = 1;
fs = 10;
x = [1 3 3 4 5 6 7 8 9 10 11 12 13 14 15];
symbolRate = fc/64;

    tmpSig = qamGen(fs,fc,symbolRate,16,n,20000);
    
figure();
plot(tmpSig);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          

