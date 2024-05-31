clear all; close all; clc;

% --- Pendulum model --- %
g = 9.81; % [m/s^2]
m = 1; % [kg]
l = 0.5; % [m]

% --- noise --- %
% Process noise covariance
Q = 1e-3;
% Measurement noise covariance
R = 1e-4;

% --- Sampling time --- %
Ts = 1/2000; % [s] 


% --- Testing the code against the matlab function --- %
% Pendulum model
A = [0 1; -(9.81/0.5) 0];
B = [0; 1/(1*0.5^2)];
H = [1 0];
D = 0;
% Make the model discrete
A = eye(2)+Ts*A;
F = A;
B = Ts*B;






