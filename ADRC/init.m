clear all; close all; clc;

% Sim params
fs_algo = 2000;
ts_algo = 1/fs_algo;

% plant params
l=0.5; m = 10000 * 0.1 * 0.01^2;

% controller params
kp = 0.5; kd = 0.25; 

disp('Good to go')