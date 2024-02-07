function x_hat = kalman_function(A, B, H, Q, R, u, measurement)
    persistent x_hat_prev P_prev
    
    if isempty(x_hat_prev)
        x_hat_prev = [0; 0];
        P_prev = eye(2);
    end

    % Prediction step
    x_minus = A * x_hat_prev + B * u;
    P_minus = A * P_prev * A' + Q;

    % Update step
    K = P_minus * H' / (H * P_minus * H' + R);
    x_hat = x_minus + K * (measurement - H * x_minus);
    P = (eye(2) - K * H) * P_minus;

    % Update persistent variables for the next iteration
    x_hat_prev = x_hat;
    P_prev = P;
end