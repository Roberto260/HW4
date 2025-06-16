clc
%close all
clear all

% Parameters
g = 9.81;          % gravity (m/s^2)
l = 1;           % leg length (m) %%MODIFY HERE%% 
alpha= pi/8;      % half inter-leg angle (rad) %%MODIFY HERE%% 
gamma= 0.2;     % slope angle (rad) %%MODIFY HERE%% 

% Compute omega_1
omega_1 = sqrt(2 * (g/l) * (1 - cos(gamma - alpha)));

% Display the result
disp(['Minimum thetadot0 in order to have LC: ', num2str(omega_1)]);

% Initial conditions
thetadot0 =0.95;%%MODIFY HERE%% 

%gamma_max = alpha + acos(-(0.9025 * l) / (2 * g)+1)
l_min = (2 * g * (1 - cos(gamma - alpha))) / 0.9025
%alpha_min = gamma + acos(1 - (0.9025 * l) / (2 * g))
if (thetadot0 >= 0)
    theta0 = gamma-alpha;
else
    theta0 = gamma+alpha;
end

double_support = 0;

y0 = [theta0; thetadot0];

% Simulation settings
t0 = 0; %initial time
tf = 15; %final time
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

% Plot results
figure(1)
plot(T, Y(:,1), 'b', 'DisplayName', '\theta (rad)');
hold on;
plot(T, Y(:,2), 'r', 'DisplayName', '\theta dot (rad/s)');
xlabel('Time (s)');
ylabel('State');
title('Wheel Dynamics (gamma = 0.2)');
legend show;
grid on;

figure(2)
plot(Y(:,1), Y(:,2), 'b', 'DisplayName', '\theta (rad)');
hold on
plot(Y(1,1), Y(1,2), 'r', 'Marker','*','LineWidth',5,'DisplayName','Initial point');
xlabel('\theta (rad)');
ylabel('\theta dot (rad/s)');
title('Wheel Limit Cycle (gamma= 0.2)');
legend show;
grid on;

%% 
% Create a new figure for the 2x2 subplot
figure(5); % or any new figure number

% Copy figure 1 to subplot position 1 (top-left)
subplot(2,2,1);
figure(1); % Make figure 1 active
h1 = gca; % Get current axes handle
fig1_children = get(h1, 'Children'); % Get all plot objects
fig1_title = get(get(h1, 'Title'), 'String'); % Get title
fig1_xlabel = get(get(h1, 'XLabel'), 'String'); % Get x-label  
fig1_ylabel = get(get(h1, 'YLabel'), 'String'); % Get y-label

figure(5); subplot(2,2,1); % Go back to subplot
copyobj(fig1_children, gca); % Copy plot objects
title(fig1_title);
xlabel(fig1_xlabel);
ylabel(fig1_ylabel);

% Copy figure 2 to subplot position 2 (top-right)
subplot(2,2,2);
figure(2);
h2 = gca;
fig2_children = get(h2, 'Children');
fig2_title = get(get(h2, 'Title'), 'String');
fig2_xlabel = get(get(h2, 'XLabel'), 'String');
fig2_ylabel = get(get(h2, 'YLabel'), 'String');

figure(5); subplot(2,2,2);
copyobj(fig2_children, gca);
title(fig2_title);
xlabel(fig2_xlabel);
ylabel(fig2_ylabel);

% Copy figure 3 to subplot position 3 (bottom-left)
subplot(2,2,3);
figure(3);
h3 = gca;
fig3_children = get(h3, 'Children');
fig3_title = get(get(h3, 'Title'), 'String');
fig3_xlabel = get(get(h3, 'XLabel'), 'String');
fig3_ylabel = get(get(h3, 'YLabel'), 'String');

figure(5); subplot(2,2,3);
copyobj(fig3_children, gca);
title(fig3_title);
xlabel(fig3_xlabel);
ylabel(fig3_ylabel);


% Copy figure 4 to subplot position 4 (bottom-right)
subplot(2,2,4);
figure(4);
h4 = gca;
fig4_children = get(h4, 'Children');
fig4_title = get(get(h4, 'Title'), 'String');
fig4_xlabel = get(get(h4, 'XLabel'), 'String');
fig4_ylabel = get(get(h4, 'YLabel'), 'String');

figure(5); subplot(2,2,4);
copyobj(fig4_children, gca);
title(fig4_title);
xlabel(fig4_xlabel);
ylabel(fig4_ylabel);
exportgraphics(gcf, 'figure2Es4.pdf', 'ContentType', 'vector');


% Optional: Add an overall title to the entire subplot
%sgtitle('Combined 2x2 Subplot'); % Requires MATLAB R2018b or later
% For older versions, use: suptitle('Combined 2x2 Subplot');

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