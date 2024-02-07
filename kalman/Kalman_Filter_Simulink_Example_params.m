% Copyright 2018 The MathWorks, Inc.
% Pendulum model
% Gravity
g = 9.81; % [m/s^2]
% Pendulum mass
m = 1; % [kg]
% Pendulum length
l = 0.5; % [m]
% Sampling time
Ts = 1/2000; % [s] 

% State space representation
A = [0 1; -g/l 0];
B = [0; 1/(m*l^2)];
C = [1 0];
D = 0;

A = eye(2)+Ts*A;
B = Ts*B;

% Measurments to take
H = [1, 0];
% Process noise covariance
Q = 1e-5;
% Measurement noise covariance
R = 1e-3;





