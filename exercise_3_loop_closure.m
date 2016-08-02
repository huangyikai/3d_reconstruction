%% This example demonstrates how to do loop closure on a simple 2D problem
% input: 
%   N = 4: number of nodes
%   X, Y: coordinates
%   Dist: N-by-N distance matrix

close all; clear; clc

%% Create nodes
N = 4;
Pos = [0, 0; ...
       10, 20; ...
       20, 10; ...
       0, 0];

%% Create distance matrix
DIST = zeros(N);
for i = 1 : N
    for j = i+1 : N
        if i == j
            continue;
        else
            delta_x = Pos(i, 1) - Pos(j, 1);
            delta_y = Pos(i, 2) - Pos(j, 2);
            DIST(i, j) = norm([delta_x, delta_y], 2);
            DIST(j, i) = DIST(i, j);
        end
    end
end

%% Add noise
Pos_noisy = Pos + 2 * randn(4, 2);

%% Minimization
% load the error function script
error_func

options = optimoptions('fminunc','Algorithm','quasi-newton');

% Call fminunc, an unconstrained nonlinear minimizer:
[Pos_optimized, fval, exitflag, output] = fminunc(fun, Pos_noisy, options);
Pos_optimized

%% Visualization
figure; 
plot(Pos(:, 1), Pos(:, 2), 'g*-', 'LineWidth', 10);
hold on
plot(Pos_noisy(:, 1), Pos_noisy(:, 2), 'r*:', 'LineWidth', 7);
plot(Pos_optimized(:, 1), Pos_optimized(:, 2), 'b>-', 'LineWidth', 4);