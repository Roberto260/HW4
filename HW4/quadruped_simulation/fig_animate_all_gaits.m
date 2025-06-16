function fig_animate_all_gaits_optimized(tout_all, Xout_all, Uout_all, Xdout_all, Udout_all, Uext_all, p_all, gait_names)
    arguments
        tout_all    % cell array of time vectors
        Xout_all    % cell array of state trajectories
        Uout_all    % cell array of control inputs
        Xdout_all   % cell array of desired states
        Udout_all   % cell array of desired controls
        Uext_all    % cell array of external forces
        p_all       % parameters (can be single p or cell array)
        gait_names  % cell array of gait names
    end
    
    % Handle parameters
    if iscell(p_all)
        p = p_all{1};
    else
        p = p_all;
    end
    
    % OPTIMIZATION 1: Reduce frame rate and increase playSpeed
    p.playSpeed = max(p.playSpeed * 3, 5); % Skip more frames
    
    flag_movie = p.flag_movie;
    if flag_movie
        try
            name = 'all_gaits_combined.mp4';
            vidfile = VideoWriter(name,'MPEG-4');
            vidfile.FrameRate = 15; % Reduce video frame rate
        catch ME
            name = 'all_gaits_combined';
            vidfile = VideoWriter(name,'Motion JPEG AVI');
            vidfile.FrameRate = 15;
        end
        open(vidfile);
    end
    
    % OPTIMIZATION 2: Downsample data more aggressively
    num_gaits = length(tout_all);
    t_interp = cell(num_gaits, 1);
    X_interp = cell(num_gaits, 1);
    U_interp = cell(num_gaits, 1);
    Xd_interp = cell(num_gaits, 1);
    Ud_interp = cell(num_gaits, 1);
    Ue_interp = cell(num_gaits, 1);
    
    % Use coarser time step for animation
    dt_anim = p.simTimeStep * 2; % Double the time step
    t_start = max(cellfun(@(x) x(1), tout_all));
    t_end = min(cellfun(@(x) x(end), tout_all));
    
    for i = 1:num_gaits
        t_interp{i} = (t_start:dt_anim:t_end);
        X_interp{i} = interp1(tout_all{i}, Xout_all{i}, t_interp{i});
        U_interp{i} = interp1(tout_all{i}, Uout_all{i}, t_interp{i});
        Xd_interp{i} = interp1(tout_all{i}, Xdout_all{i}, t_interp{i});
        Ud_interp{i} = interp1(tout_all{i}, Udout_all{i}, t_interp{i});
        Ue_interp{i} = interp1(tout_all{i}, Uext_all{i}, t_interp{i});
    end
    
    t = t_interp{1};
    nt = length(t);
    
    % OPTIMIZATION 3: Create figure with performance settings
    figure('Position', [100 50 1200 800], 'Name', 'All Gaits Combined Animation');
    set(gcf, 'Color', 'white');
    set(gcf, 'Renderer', 'opengl'); % Use hardware acceleration
    set(gcf, 'DoubleBuffer', 'on'); % Reduce flicker
    
    % OPTIMIZATION 4: Pre-allocate subplot handles and set properties once
    subplot_positions = [1, 2, 4, 5, 7, 8];
    h_subplots = cell(num_gaits, 1);
    
    for i = 1:num_gaits
        h_subplots{i} = subplot(3, 3, subplot_positions(i));
        hold on; grid on; axis equal;
        set(h_subplots{i}, 'NextPlot', 'replacechildren'); % Faster than cla
        title(gait_names{i}, 'FontSize', 11, 'FontWeight', 'bold');
        
        % Pre-set axis limits to avoid recalculation
        xlim([-1 1]); ylim([-1 1]); zlim([-0.15 0.5]);
        view([0.2, 0.5, 0.2]);
    end
    
    % OPTIMIZATION 5: Pre-allocate text handles for reuse
    h_time_text = cell(num_gaits, 1);
    h_vel_text = cell(num_gaits, 1);
    
    for i = 1:num_gaits
        subplot(h_subplots{i});
        h_time_text{i} = text(0, 0, 0.35, '', 'FontSize', 8);
        h_vel_text{i} = text(0, 0, 0.4, '', 'FontSize', 8);
    end
    
    % Create overall title handle
    h_sgtitle = sgtitle('', 'FontSize', 14, 'FontWeight', 'bold');
    
    % OPTIMIZATION 6: Animation loop with minimal operations
    fprintf('Starting optimized animation...\n');
    tic;
    
    for ii = 1:p.playSpeed:nt
        for gait_idx = 1:num_gaits
            % Select current subplot
            subplot(h_subplots{gait_idx});
            
            % Get current robot position
            pcom = X_interp{gait_idx}(ii, 1:3)';
            
            % OPTIMIZATION 7: Only update axis limits if robot moved significantly
            persistent prev_pcom;
            if isempty(prev_pcom) || norm(pcom - prev_pcom) > 0.1
                xlim([pcom(1)-0.4 pcom(1)+0.4]);
                ylim([pcom(2)-0.4 pcom(2)+0.4]);
                prev_pcom = pcom;
            end
            
            % Get current parameter set
            if iscell(p_all)
                p_current = p_all{gait_idx};
            else
                p_current = p_all;
            end
            
            % Clear and plot robot (this is the main bottleneck)
            cla;
            fig_plot_robot(X_interp{gait_idx}(ii,:)', U_interp{gait_idx}(ii,:)', Ue_interp{gait_idx}(ii,:)', p_current);
            fig_plot_robot_d(Xd_interp{gait_idx}(ii,:)', 0*Ud_interp{gait_idx}(ii,:)', p_current);
            
            % Update text efficiently
            set(h_time_text{gait_idx}, 'Position', [pcom(1), pcom(2), 0.35], ...
                'String', sprintf('t=%.1fs', t(ii)));
            set(h_vel_text{gait_idx}, 'Position', [pcom(1), pcom(2), 0.4], ...
                'String', sprintf('v=%.2fm/s', X_interp{gait_idx}(ii,4)));
        end
        
        % Update overall title
        set(h_sgtitle, 'String', sprintf('All Gaits Comparison - Time: %.2f s', t(ii)));
        
        % OPTIMIZATION 8: Control frame rate
        if flag_movie
            writeVideo(vidfile, getframe(gcf));
        end
        
        % OPTIMIZATION 9: Pause to control playback speed
        pause(0.05); % 20 FPS max
        drawnow limitrate; % Limit graphics updates
    end
    
    elapsed_time = toc;
    fprintf('Animation completed in %.2f seconds\n', elapsed_time);
    
    if flag_movie
        close(vidfile);
        fprintf('Combined animation saved as: %s\n', name);
    end
end