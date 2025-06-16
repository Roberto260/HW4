function [] = myplot_iterated(t,X,U,Xd,Ud,Ue,p,gaitName)
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
    % myplot Static plots for quadruped simulation (no animation)
    % t, X, U, Xd, Ud, Ue, p -- data from simulation
    % gaitName -- string, name of current gait
    
    % Convert desired rotation matrices to Euler angles
    n = size(Xd,1);
    euler_d = zeros(n,3); % columns: [roll pitch yaw]
    for i = 1:n
        R_d = reshape(Xd(i,7:15), [3,3])'; % reshape and transpose to get 3x3
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
    % Convert to degrees
    euler_error = rad2deg(euler_error);
    
   % Create single figure with 5 subplots
figure('Name',['Error Values - ' gaitName]);

% Row 1: Position Error
subplot(5,1,1);
pos_error = X(:,1:3) - Xd(:,1:3);
plot(t,pos_error(:,1),'r',...
     t,pos_error(:,2),'g',...
     t,pos_error(:,3),'b','LineWidth',1);
xlim([t(1) t(end)]);
title(['Position Error [m] - ' gaitName]);
lh = legend({'$e_{x}$','$e_{y}$','$e_{z}$'}, 'Location','eastoutside', 'Interpreter','latex');
shrinkLegend(lh);
grid on;

% Row 2: Velocity Error
subplot(5,1,2);
vel_error = X(:,4:6) - Xd(:,4:6);
plot(t,vel_error(:,1),'r',...
     t,vel_error(:,2),'g',...
     t,vel_error(:,3),'b','LineWidth',1);
xlim([t(1) t(end)]);
title(['Velocity Error [m/s] - ' gaitName]);
lh = legend({'$e_{v,x}$','$e_{v,y}$','$e_{v,z}$'}, 'Location','eastoutside', 'Interpreter','latex');
shrinkLegend(lh);
grid on;

% Row 3: Euler Angle Errors
subplot(5,1,3);
plot(t, euler_error(:,1), 'r', ...
     t, euler_error(:,2), 'g', ...
     t, euler_error(:,3), 'b', 'LineWidth', 1);
xlim([t(1) t(end)]);
title(['Euler Angle Errors [deg] - ' gaitName]);
lh = legend({'$e_{\phi}$','$e_{\theta}$','$e_{\psi}$'}, 'Location','eastoutside', 'Interpreter','latex');
shrinkLegend(lh);
grid on;

% Row 4: Angular Velocity Error
subplot(5,1,4);
angvel_error = X(:,16:18) - Xd(:,16:18);
plot(t,angvel_error(:,1),'r',...
     t,angvel_error(:,2),'g',...
     t,angvel_error(:,3),'b','LineWidth',1);
xlim([t(1) t(end)]);
title(['Angular Velocity Error [rad/s] - ' gaitName]);
lh = legend({'$e_{\omega,x}$','$e_{\omega,y}$','$e_{\omega,z}$'}, 'Location','eastoutside', 'Interpreter','latex');
shrinkLegend(lh);
grid on;

% Row 5: Control Forces Error
subplot(5,1,5);
control_error = [U(:,3)-Ud(:,3), U(:,6)-Ud(:,6), U(:,9)-Ud(:,9), U(:,12)-Ud(:,12)];
plot(t,control_error(:,1),'r',...
     t,control_error(:,2),'g',...
     t,control_error(:,3),'b',...
     t,control_error(:,4),'k','LineWidth',1);
xlim([t(1) t(end)]);
title(['Control Forces Error [N] - ' gaitName]);
lh = legend({'$e_{F_z,1}$','$e_{F_z,2}$','$e_{F_z,3}$','$e_{F_z,4}$'}, 'Location','eastoutside', 'Interpreter','latex');
shrinkLegend(lh);
xlabel('Time [s]');
grid on;

% Helper function to shrink legend font and line length
function shrinkLegend(lh)
    set(lh, 'FontSize', 8, 'ItemTokenSize', [10, 10]); % shorten line length
    for i = 1:length(lh.EntryContainer.Children)
        try
            lh.EntryContainer.Children(i).Icon.Transform.Children.LineWidth = 0.5;
        catch
            % For compatibility with older MATLAB versions
        end
    end
end

    
end


% Helper function to shrink legend font and line width
function shrinkLegend(lh)
    set(lh, 'FontSize', 6, 'ItemTokenSize', [5, 5]);
    for i = 1:length(lh.EntryContainer.Children)
        try
            lh.EntryContainer.Children(i).Icon.Transform.Children.LineWidth = 0.5;
        catch
            % Ignore errors for incompatible objects
        end
    end
end
