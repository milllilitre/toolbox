% main.m
close all;
clear all;
clc;
a = [0 1 0 1 1 1 0 0 1 1];
b = binary2decimal(a,2);
out1 = pskGen(6.25, 13.56, 0.122,4,b,20000);
figure();
plot(out1);