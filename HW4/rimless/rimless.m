clc
close all
clear all
%% Script per confronti su plot
% Parameters
g = 9.81;          % gravity (m/s^2)
l = 1;           % leg length (m) %%MODIFY HERE%% 
alpha = pi/8;      % half inter-leg angle (rad) %%MODIFY HERE%% 
gamma = 0.08;      % slope angle (rad) %%MODIFY HERE%% 

% Compute omega_1
omega_1 = sqrt(2 * (g/l) * (1 - cos(gamma - alpha)));

% Display the result
disp(['Minimum thetadot0 in order to have LC: ', num2str(omega_1)]);

% Define two initial conditions
thetadot0_values = [-1.4, -2];

% Create 2x2 subplot
figure;

for i = 1:2
    % Initial conditions
    thetadot0 = thetadot0_values(i);
    %gamma_max = alpha + acos(1 - (0.9025 * l) / (2 * g));
    if (thetadot0 >= 0)
     theta0 = gamma-alpha;
    else
     theta0 = gamma+alpha;
    end
    double_support = 0;
    y0 = [theta0; thetadot0];
    % Simulation settings
    t0 = 0; %initial time
    tf = 10; %final time
    dt = 0.01; %max step time
    % Time/state storage
    T = [];
    Y = [];
    while t0 < tf
     options = odeset('Events', @(t, y) impact_event(t, y, alpha,gamma), 'MaxStep', dt);
     [t, y, te, ye, ie] = ode45(@(t, y) dynamics(t, y, g, l, double_support), [t0 tf], y0, options);
     T = [T; t];
     Y = [Y; y];
    if ~isempty(te)
     [y0,double_support] = impact_map(ye, alpha,g,l); % apply impact map
     t0 = te;
    else
    break;
    end
    end
       % First plot: Time series
    subplot(2, 2, 2*i-1);
    plot(T, Y(:,1), 'b', 'DisplayName', '\theta');
    hold on;
    plot(T, Y(:,2), 'r', 'DisplayName', '\theta dot');
    xlabel('Time (s)');
    ylabel('State');
    title(['Rimless Dynamics (\theta_{dot0} = ' num2str(thetadot0) ')']);
    legend('Location', 'eastoutside');
    grid on;
    
    % Second plot: Phase portrait
    subplot(2, 2, 2*i);
    plot(Y(:,1), Y(:,2), 'b', 'DisplayName', '\theta');
    hold on
    plot(Y(1,1), Y(1,2), 'r', 'Marker','*', 'MarkerSize', 8, 'LineStyle', 'none', 'DisplayName','Initial point');
    xlabel('\theta (rad)');
    ylabel('\theta dot (rad/s)');
    title(['Rimless Limit Cycle (\theta_{dot0} = ' num2str(thetadot0) ')']);
    legend('Location', 'eastoutside');
    grid on;
    set(gcf, 'Units', 'inches', 'Position', [1, 1, 10, 6]); % Width=12", Height=6"
end
exportgraphics(gcf, 'figure1Es4.pdf', 'ContentType', 'vector');

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

function [value, isterminal, direction] = impact_event(~, y, alpha,gamma)
    
    value = [y(1)-alpha-gamma; y(1)-gamma+alpha];% Trigger when theta = gamma+alpha
                                     %Trigger when theta = gamma-alpha
    isterminal = [1;1];         % Stop the integration
    direction = [1;-1];          % Detect only when increasing
end

function [yplus,ds] = impact_map(y_minus, alpha,g,l)%minus: before impact time; plus: after impact time
    if (y_minus(2)>=0)
        theta_plus = y_minus(1)-2*alpha;
    else
        theta_plus = y_minus(1)+2*alpha;
    end
    thetadot_plus = cos(2*alpha) * y_minus(2); %conservazione momento angolare
    if (thetadot_plus < 0.01*sqrt(g/l) && thetadot_plus >-0.01*sqrt(g/l)) 
        thetadot_plus = 0;
        ds = 1;
    else
        ds = 0;
    end
    yplus = [theta_plus; thetadot_plus];
end