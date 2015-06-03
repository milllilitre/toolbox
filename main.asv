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
m = [ 0 1 0 1 0 0 0 0 1 0 1 1 1 1 1 0];
out3 = qamGen(6.25,13.56,16,m,20000);
figure();
plot(out3);
