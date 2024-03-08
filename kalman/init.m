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

% Put all in a single vector
params = [g,m,l,Ts];

% Process noise covariance
Q = 1e-5;
% Measurement noise covariance
R = 1e-3;





