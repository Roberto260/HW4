function [] = myplot(t,X,U,Xd,Ud,Ue,p,gaitName)
    arguments
        t
        X
        U
        Xd
        Ud
        Ue
        p
        gaitName = ''
    end
% myplot  Static plots for quadruped simulation (no animation)
%  t, X, U, Xd, Ud, Ue, p    -- data from simulation
%  gaitName                 -- string, name of current gait


%% Figure 2: Error Values (Real - Desired)
figure('Name',['Error Values - ' gaitName]);

subplot(4,1,1);
pos_error = X(:,1:3) - Xd(:,1:3);
plot(t,pos_error(:,1),'r',...
     t,pos_error(:,2),'g',...
     t,pos_error(:,3),'b','linewidth',1);
xlim([t(1) t(end)]);
title(['Position Error [m] - ' gaitName]);
legend('e_x','e_y','e_z','Location','northeast');
grid on;

subplot(4,1,2);
vel_error = X(:,4:6) - Xd(:,4:6);
plot(t,vel_error(:,1),'r',...
     t,vel_error(:,2),'g',...
     t,vel_error(:,3),'b','linewidth',1);
xlim([t(1) t(end)]);
title(['Velocity Error [m/s] - ' gaitName]);
legend('e_{v_x}','e_{v_y}','e_{v_z}','Location','northeast');
grid on;

subplot(4,1,3);
angvel_error = X(:,16:18) - Xd(:,16:18);
plot(t,angvel_error(:,1),'r',...
     t,angvel_error(:,2),'g',...
     t,angvel_error(:,3),'b','linewidth',1);
xlim([t(1) t(end)]);
title(['Angular Velocity Error [rad/s] - ' gaitName]);
legend('e_{\omega_x}','e_{\omega_y}','e_{\omega_z}','Location','northeast');
grid on;

subplot(4,1,4);
control_error = [U(:,3)-Ud(:,3), U(:,6)-Ud(:,6), U(:,9)-Ud(:,9), U(:,12)-Ud(:,12)];
plot(t,control_error(:,1),'r',...
     t,control_error(:,2),'g',...
     t,control_error(:,3),'b',...
     t,control_error(:,4),'k','linewidth',1);
xlim([t(1) t(end)]);
title(['Control Forces Error [N] - ' gaitName]);
legend('e_{F_{z1}}','e_{F_{z2}}','e_{F_{z3}}','e_{F_{z4}}','Location','northeast');
grid on;

% Convert desired rotation matrices to Euler angles
n = size(Xd,1);
euler_d = zeros(n,3); % columns: [roll pitch yaw]
for i = 1:n
    R_d = reshape(Xd(i,7:15), [3,3])';  % reshape and transpose to get 3x3
    euler_d(i,:) = rotm2eul(R_d, 'XYZ'); % MATLAB function
end


% Convert actual rotation matrices to Euler angles
euler_real = zeros(n,3);
for i = 1:n
    R = reshape(X(i,7:15), [3,3])';
    euler_real(i,:) = rotm2eul(R, 'XYZ');
end

% Compute angle errors
euler_error = euler_real - euler_d;

% Wrap angle errors to [-pi, pi]
euler_error = mod(euler_error + pi, 2*pi) - pi;
euler_d = rad2deg(euler_d);


%% Plot Euler angle errors
euler_error=rad2deg(euler_error);
figure('Name',['Euler Angle Errors - ' gaitName]);
plot(t, euler_error(:,1), 'r', ...
     t, euler_error(:,2), 'g', ...
     t, euler_error(:,3), 'b', 'LineWidth', 1);
xlim([t(1) t(end)]);
title(['Euler Angle Errors [rad] - ' gaitName]);
legend('e_{ϕ}','e_{θ}','e_{ψ}', 'Location','northeast');
xlabel('Time [s]');
ylabel('Angle Error [deg]');
grid on;


%% Figure 1: Desired Values Only
% Create main figure with 2x2 layout for kinematics
figure('Name',['Desired States Overview - ' gaitName]);

% Top-left: Desired Euler Angles
subplot(2,2,1);
plot(t, euler_d(:,1), 'r', ...
     t, euler_d(:,2), 'g', ...
     t, euler_d(:,3), 'b', 'LineWidth', 1);
xlim([t(1) t(end)]);
title(['Desired Euler Angles ' gaitName]); % No dash, no units
legend({'R ($\phi$)','P ($\theta$)','yaw ($\psi$)'}, ...
       'Location','northeast', 'FontSize', 7, 'Interpreter', 'latex');
ylabel('[deg]'); % Only unit
grid on;

% Top-right: Desired Position
subplot(2,2,2);
plot(t, Xd(:,1), 'r', ...
     t, Xd(:,2), 'g', ...
     t, Xd(:,3), 'b', 'LineWidth', 1);
xlim([t(1) t(end)]);
pos_all = Xd(:,1:3);
ymin = min(pos_all,[],'all');
ymax = max(pos_all,[],'all');
yrange = ymax - ymin;
ylim([ymin - 0.1*yrange, ymax + 0.1*yrange]);
title(['Desired Position ' gaitName]); % No dash, no units
legend('x_d','y_d','z_d','Location','northeast', 'FontSize', 6);
ylabel('[m]'); % Only unit
grid on;

% Bottom-left: Desired Angular Velocity
subplot(2,2,3);
plot(t, Xd(:,16), 'r', ...
     t, Xd(:,17), 'g', ...
     t, Xd(:,18), 'b', 'LineWidth', 1);
xlim([t(1) t(end)]);
title(['Desired Angular Velocity ' gaitName]); % No dash, no units
legend('\omega_{x_d}','\omega_{y_d}','\omega_{z_d}','Location','northeast', 'FontSize', 6);
xlabel('Time [s]');
ylabel('[rad/s]'); % Only unit
grid on;

% Bottom-right: Desired Linear Velocity
subplot(2,2,4);
plot(t, Xd(:,4), 'r', ...
     t, Xd(:,5), 'g', ...
     t, Xd(:,6), 'b', 'LineWidth', 1);
xlim([t(1) t(end)]);
vel_all = Xd(:,4:6);
ymin = min(vel_all,[],'all');
ymax = max(vel_all,[],'all');
yrange = ymax - ymin;
ylim([ymin - 0.1*yrange, ymax + 0.1*yrange]);
title(['Desired Velocity ' gaitName]); % No dash, no units
legend('v_{x_d}','v_{y_d}','v_{z_d}','Location','northeast', 'FontSize', 6);
xlabel('Time [s]');
ylabel('[m/s]'); % Only unit
grid on;
exportgraphics(gcf, 'figure1Es3.pdf', 'ContentType', 'vector');
% Create separate figure for forces
figure('Name',['Desired Control Forces - ' gaitName]);
plot(t, Ud(:,3), 'r', ...
     t, Ud(:,6), 'g', ...
     t, Ud(:,9), 'b', ...
     t, Ud(:,12), 'k', 'LineWidth', 1);
xlim([t(1) t(end)]);
Fz_all = [Ud(:,3), Ud(:,6), Ud(:,9), Ud(:,12)];
ymin = min(Fz_all, [], 'all');
ymax = max(Fz_all, [], 'all');
yrange = ymax - ymin;
ylim([ymin - 0.1*yrange, ymax + 0.1*yrange]);
title(['Desired Control Forces F_z ' gaitName]); % No dash, no units
legend('F_{z1_d}','F_{z2_d}','F_{z3_d}','F_{z4_d}','Location','northeast', 'FontSize', 8);
xlabel('Time [s]');
ylabel('[N]'); % Only unit
grid on;



end
