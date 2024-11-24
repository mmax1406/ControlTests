% MATLAB Script for Bilinear Transform Approximation with Symbolic T
syms s z T % Define symbolic variables

% Define your continuous-time transfer function H(s)
% Example: H(s) = (s + 2)/(s^2 + 3*s + 2)
H_s = 100*((10*s+10)/(10*s))*((2*2*pi)^2/(s^2 + 2*(2*2*pi)^2*s + (2*2*pi)^2))^2;

% Bilinear transformation: s -> (2/T)*(z-1)/(z+1)
s_to_z = (2/T) * (z - 1) / (z + 1);

% Substitute s with the bilinear transformation
H_z = subs(H_s, s, s_to_z);

% Simplify the resulting H(z)
H_z = simplify(H_z);

% Separate numerator and denominator
[num, den] = numden(H_z); % Numerator and denominator as symbolic expressions

% Collect terms in powers of z to ensure a polynomial form
num = collect(num, z);
den = collect(den, z);

% Extract the coefficients of numerator and denominator manually
num_coeffs = coeffs(num, z, 'All'); % Coefficients of the numerator in descending powers of z
den_coeffs = coeffs(den, z, 'All'); % Coefficients of the denominator in descending powers of z

% Optional: Normalize coefficients (denominator leading coefficient = 1)
if den_coeffs(1) ~= 1
    num_coeffs = num_coeffs / den_coeffs(1);
    den_coeffs = den_coeffs / den_coeffs(1);
end

% Display results in copy-paste-ready format
disp('Copy and paste the following coefficients into your script:');
fprintf('Num = [%s];\n', strjoin(arrayfun(@char, num_coeffs, 'UniformOutput', false), ', '));
fprintf('Den = [%s];\n', strjoin(arrayfun(@char, den_coeffs, 'UniformOutput', false), ', '));


%% Compare the results 

s = tf('s');
H_s = 100*((10*s+10)/(10*s))*((2*2*pi)^2/(s^2 + 2*(2*2*pi)^2*s + (2*2*pi)^2))^2;
bode(H_s); 
hold on

T = 1/2000;
Num = [(385877164740435665106183410011250*T^4*(T + 2))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, (385877164740435665106183410011250*T^4*(T - 2) + 1543508658961742660424733640045000*T^4*(T + 2))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, (1543508658961742660424733640045000*T^4*(T - 2) + 2315262988442613990637100460067500*T^4*(T + 2))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, (2315262988442613990637100460067500*T^4*(T - 2) + 1543508658961742660424733640045000*T^4*(T + 2))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, (1543508658961742660424733640045000*T^4*(T - 2) + 385877164740435665106183410011250*T^4*(T + 2))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, (385877164740435665106183410011250*T^4*(T - 2))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2];
Den = [(2778046668940015*T^2 + 11112186675760060*T + 70368744177664)^2/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, -((11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2 - 2*(5556093337880030*T^2 - 140737488355328)*(11112186675760060*T + 2778046668940015*T^2 + 70368744177664))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, ((5556093337880030*T^2 - 140737488355328)^2 + 2*(2778046668940015*T^2 - 11112186675760060*T + 70368744177664)*(2778046668940015*T^2 + 11112186675760060*T + 70368744177664) - 2*(5556093337880030*T^2 - 140737488355328)*(2778046668940015*T^2 + 11112186675760060*T + 70368744177664))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, -((5556093337880030*T^2 - 140737488355328)^2 + 2*(2778046668940015*T^2 - 11112186675760060*T + 70368744177664)*(11112186675760060*T + 2778046668940015*T^2 + 70368744177664) - 2*(5556093337880030*T^2 - 140737488355328)*(2778046668940015*T^2 - 11112186675760060*T + 70368744177664))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, ((2778046668940015*T^2 - 11112186675760060*T + 70368744177664)^2 - 2*(5556093337880030*T^2 - 140737488355328)*(2778046668940015*T^2 - 11112186675760060*T + 70368744177664))/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2, -(2778046668940015*T^2 - 11112186675760060*T + 70368744177664)^2/(11112186675760060*T + 2778046668940015*T^2 + 70368744177664)^2];
H_z = tf(Num,Den,T);
bode(H_z)
hold off