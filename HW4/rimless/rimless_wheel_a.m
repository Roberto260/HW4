% rimless_wheel_analysis.m
% This script simulates the rimless wheel dynamics for multiple initial angular velocities
% and compares their trajectories in time and phase space.

clc; clear all; close all;

%% Parameters
% g: gravity (m/s^2)
% l: leg length (m)
% alpha: half inter-leg angle (rad)
% gamma: slope angle (rad)
% tf: final simulation time (s)
% dt: maximum ODE solver step size (s)
g    = 9.81;       % gravity
l    = 1.0;        % leg length
alpha= pi/8;       % half inter-leg angle
gamma= 0.08;       % slope angle
tf   = 25;         % final time
dt   = 0.01;       % max step size

% Define a vector of 5 initial angular velocities (rad/s)
omega_vec = linspace(-3, 2, 5);  % from -2 to 2 rad/s

%% Define colors for consistent plotting
colors = lines(length(omega_vec)); % Generate distinct colors

%% Preallocate cell arrays for time and states
times  = cell(length(omega_vec),1);
states = cell(length(omega_vec),1);

%% Loop over each initial angular velocity
for i = 1:length(omega_vec)
    % Initial condition: choose theta0 based on sign of thetadot0
    thetadot0 = omega_vec(i);
    if thetadot0 >= 0
        theta0 = gamma - alpha;
    else
        theta0 = gamma + alpha;
    end
    y0 = [theta0; thetadot0];   % initial state [theta; thetadot]
    ds = 0;                     % double support flag
    t0 = 0;                     % start time
    T   = [];
    Y   = [];

    % Integrate dynamics with impact events until tf
    while t0 < tf
        options = odeset('Events', @(t,y) impact_event(t,y,alpha,gamma), 'MaxStep', dt);
        [t, y, te, ye, ie] = ode45(@(t,y) dynamics(t,y,g,l,ds), [t0 tf], y0, options);
        T = [T; t];
        Y = [Y; y];
        % If an impact occurred, apply impact map and continue
        if ~isempty(te)
            [y0, ds] = impact_map(ye, alpha, g, l);
            t0 = te;
        else
            break;
        end
    end

    % Store results
    times{i}  = T;
    states{i} = Y;

 
end

%% Plot comparison of theta(t) for all initial velocities
figure(2);
hold on;
for i = 1:length(omega_vec)
    plot(times{i}, states{i}(:,1), 'Color', colors(i,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('\\omega_0 = %.2f rad/s', omega_vec(i)));
end
xlabel('Time (s)', 'FontSize', 12); 
ylabel('\theta (rad)', 'FontSize', 12);
title('Comparison of \theta(t) for Different Initial Velocities', 'FontSize', 14);
legend('show', 'Location', 'best', 'FontSize', 10); 
grid on;
set(gca, 'FontSize', 10);

%% Plot comparison of theta_dot(t) for all initial velocities
figure(3);
hold on;
for i = 1:length(omega_vec)
    plot(times{i}, states{i}(:,2), 'Color', colors(i,:), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('\\omega_0 = %.2f rad/s', omega_vec(i)));
end
xlabel('Time (s)', 'FontSize', 12); 
ylabel('$\dot{\theta}$ (rad/s)', 'Interpreter', 'latex', 'FontSize', 12);
title('Comparison of $\dot{\theta}$(t) for Different Initial Velocities', 'Interpreter', 'latex', 'FontSize', 14);
legend('show', 'Location', 'best', 'FontSize', 10); 
grid on;
set(gca, 'FontSize', 10);

%% Additional Analysis: Final State Analysis for Convergence
 final_thetadot = zeros(length(omega_vec), 1);
 for i = 1:length(omega_vec)
 final_thetadot(i) = mean(states{i}(end-5:end, 2));
 end
%% Display convergence information
fprintf('\n=== CONVERGENCE ANALYSIS ===\n');
fprintf('Initial ω₀ (rad/s) | Final θ̇ (rad/s) | Converged to\n');
fprintf('-------------------|-----------------|-------------\n');
for i = 1:length(omega_vec)
    if abs(final_thetadot(i)) < 0.001
        status = 'Equilibrium';
    else
        status = 'Limit Cycle';
    end
    fprintf('%18.2f | %16.4f | %s\n', ...
            omega_vec(i), final_thetadot(i), status);
end

%% Dynamics function: continuous evolution
function dydt = dynamics(~, y, g, l, ds)
    theta = y(1);
    thetadot = y(2);
    if (~ds)
        dtheta = thetadot;
        dthetadot = (g/l) * sin(theta);
    else
        dtheta = 0;
        dthetadot = 0;
    end
    dydt = [dtheta; dthetadot];
end

%% Impact event: detect when a new leg contacts ground
function [value, isterminal, direction] = impact_event(~, y, alpha, gamma)
    % Two events: theta = gamma+alpha or theta = gamma-alpha
    value      = [y(1)-(gamma+alpha); y(1)-(gamma-alpha)];
    isterminal = [1; 1];    % stop integration
    direction  = [1; -1];   % positive crossing for first, negative for second
end

%% Impact map: instantaneously change angle and angular velocity
function [yplus, ds] = impact_map(y_minus, alpha, g, l)
    theta_minus  = y_minus(1);
    thetadot_minus = y_minus(2);
    % New stance leg selection based on direction of motion
    if thetadot_minus >= 0
        theta_plus = theta_minus - 2*alpha;
    else
        theta_plus = theta_minus + 2*alpha;
    end
    % Energy loss at impact (inelastic)
    thetadot_plus = cos(2*alpha) * thetadot_minus;
    % Check for near-zero velocity to enter double support
    if abs(thetadot_plus) < 0.01*sqrt(g/l)
        thetadot_plus = 0;
        ds = 1;
    else
        ds = 0;
    end
    yplus = [theta_plus; thetadot_plus];
end