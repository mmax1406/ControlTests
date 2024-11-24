%% Create the signal 
clear all; close all; clc;

ff_max = 500;
Amp = 5;
dt = 1/4000;
repetetions = 10;
uu = [];
ffVec = [];
ffToSample = 1:2:ff_max;
for ff=ffToSample
    T = 1/ff;
    tmp = Amp*sin(2*pi*ff*(0:dt:(repetetions*T)));
    ffVec = [ffVec zeros(1,100) ff*ones(1,size(tmp,2))];  
    uu = [uu zeros(1,100) tmp];    
end
ffVec = [ffVec zeros(1,100)]; 
uu = [uu zeros(1,100)];
tt = dt * (0:size(uu,2)-1);

figure(); title('Input');
subplot(2,1,1);
plot(tt, ffVec)
subplot(2,1,2); 
plot(tt, uu)

%% Create the plant + simulate the response + Add some noise
s = tf('s');
P = ((100*2*pi)^2/(s^2+0.707*(100*2*pi)*s+(100*2*pi)^2));
yy = lsim(P, uu, tt);
yy = awgn(yy,10,'measured'); % Add gaussian noise

figure(); title('Output');
subplot(2,1,1);
plot(tt, ffVec)
subplot(2,1,2); 
plot(tt, yy)

% Find the indices where theres a recording
indexMatrix = extractSinusoidIndices(uu);
indexMatrix(:,1) = indexMatrix(:,1)-1; %Cause we start with zero

% Extract the signals to cells
yys = {}; tts = {}; kk = 1;
for ii = indexMatrix'
    yys{kk} = yy(ii(1):ii(2));
    uus{kk} = uu(ii(1):ii(2));
    tts{kk} = tt(ii(1):ii(2))-tt(ii(1));
    kk = kk+1;
end

%% Estimate the transfer function and compare to GT
ffs = []; gains = []; phases = []; kk = 1;
repetitons = 10;
freq_estimated = [];
amp_estimated = [];

for kk = 1:size(yys,2)
    % Need to know the tested freq and amplitude (can estimate from input
    % probably)
    tts_filtered = tts{kk};
    ff = ffToSample(kk);
    
    % This estimates the freq and amplitude from the input signal (Its
    % better cause the user dosent have to to remember the params)
    uu = uus{kk};
    [amplitude, frequency] = estimateSineParams(uu, 1/dt);
    freq_estimated = [freq_estimated frequency];
    amp_estimated = [amp_estimated amplitude];
    Amp = amplitude;
    ff = frequency;
    
    % Clean the signals (no phase filter filtfilt)
    wn = ff*2*pi;
    BF = s*wn^2/(s+wn)^2;
    BF = (1/abs(evalfr(BF,1i*wn)))*BF;
    BF_dig = c2d(BF, dt);    
    yy_filtered = filtfilt(BF_dig.Numerator{:}, BF_dig.Denominator{:}, yys{kk});  
    
    % Estimate the output sinus
    [gain, phase] = FitResponse(tts_filtered', yy_filtered, ff);
    ffs = [ffs ff];
    gains = [gains gain/Amp]; 
    phases = [phases phase];
end
close all

figure(); title('Estimate Errors of freq and amp');
subplot(2,1,1);
plot(abs(freq_estimated-ffToSample))
subplot(2,1,2); 
plot(abs(amp_estimated-5))

phases = phaseFixer(phases);
%% Compare the results
[gain_GT, phase_GT, wout, ~, ~] = bode(P, ffs*2*pi);

% Filter using the frequency we know we recorded (Using filtfilt to not affect the phase)
figure()
subplot(2,1,1);
semilogx(ffs, mag2db(squeeze(gain_GT)), '-o');hold on;
semilogx(ffs, mag2db(gains), '-o');hold off;
subplot(2,1,2); 
semilogx(ffs, squeeze(phase_GT), '-o');hold on;
semilogx(ffs, phases*180/pi, '-o');hold off;
legend('GT', 'Measured');

%% Functions
function [gain, phase] = FitResponse(tts_filtered, yy_filtered, ff)
    %% Fit: 'FitResponse'.
    [xData, yData] = prepareCurveData( tts_filtered, yy_filtered );

    % Set up fittype and options.
    ft = fittype( 'a*sin(2*pi*'+string(ff)+'*x+b)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 -Inf];
    opts.Upper = [Inf 0];
    opts.StartPoint = [0.620968655826104 0.690192179535585];

    % Fit model to data.
    [fitresult, ~] = fit( xData, yData, ft, opts );
    gain = fitresult.a;
    phase = fitresult.b;
end

function indexMatrix = extractSinusoidIndices(paddedArray)
    % Initialize variables
    indices = []; % Matrix to hold start and end indices of sinusoidal segments
    currentStartIndex = -1; % Start index of the current sinusoidal segment
    zeroPaddingCount = 0; % Counter for zeros
    
    % Iterate through the array
    for i = 1:length(paddedArray)
        if paddedArray(i) ~= 0
            % If a non-zero element is found, reset zero padding count
            zeroPaddingCount = 0;
            % If it's the start of a new sinusoidal segment, set the start index
            if currentStartIndex == -1
                currentStartIndex = i;
            end
        else
            % If a zero element is found, increment the zero padding count
            zeroPaddingCount = zeroPaddingCount + 1;
            % If the zero padding is more than 10 and a sinusoidal segment was ongoing
            if zeroPaddingCount > 10 && currentStartIndex ~= -1
                % Store the start and end indices of the current sinusoidal segment
                indices = [indices; currentStartIndex, i - zeroPaddingCount]; %#ok<*AGROW>
                % Reset the start index
                currentStartIndex = -1;
            end
        end
    end
    
    % If the array ends with a non-zero segment, store its indices
    if currentStartIndex ~= -1
        indices = [indices; currentStartIndex, length(paddedArray)];
    end
    
    % Convert the indices matrix to the desired format
    indexMatrix = indices;
end

function [amplitude, frequency] = estimateSineParams(signal, Fs)
    % signal: The input sine signal
    % Fs: Sampling frequency of the signal

    % Length of the signal
    L = length(signal);

    % Perform FFT
    Y = fft(signal);

    % Compute the two-sided spectrum and then the single-sided spectrum
    P2 = abs(Y / L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);

    % Define the frequency domain f
    f = Fs * (0:(L/2)) / L;

    % Find the index of the maximum value in P1 (ignoring the DC component)
    [~, index] = max(P1(2:end));
    index = index + 1; % Adjust index because we ignored the DC component

    % The frequency corresponding to the maximum value in P1
    frequency = f(index);

    % The amplitude is twice the magnitude at this frequency (because we consider single-sided spectrum)
    amplitude = P1(index);
end

function o_phases = phaseFixer(i_phases)
    o_phases = [];
    for kk=1:size(i_phases,2)
        if kk==1
            o_phases(kk) = i_phases(kk);
            continue 
        else
            phase = i_phases(kk);
            % Decide where the current angle is relative to its predecessor
            if phase<o_phases(kk-1)
                dir = 1;
            else
                dir = -1;
            end
            intiDist = abs(phase-o_phases(kk-1));
            while true
                if (phase+dir*pi)>0 % Dont want to go above zero
                    break
                end
                % Depoending on the direction we want to add incremetns
                % this is done while were getting close to the value
                if abs(phase+dir*pi-o_phases(kk-1))<intiDist
                    phase = phase+dir*pi;
                    intiDist = abs(phase-o_phases(kk-1));
                else 
                    break
                end    
            end
            o_phases(kk) = phase;
        end
    end
end