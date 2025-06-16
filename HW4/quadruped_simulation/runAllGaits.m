%% runAllGaits.m
% Calls main_iterated once per gait (0 through 5) and stores the results.

clearvars; close all; clc
addpath fcns fcns_MPC

gait_names = {'Trot','Bound','Pacing','Gallop','Trot Run','Crawl'};
N = numel(gait_names);

% Pre-allocate cell arrays
tout_all  = cell(N,1);
Xout_all  = cell(N,1);
Uout_all  = cell(N,1);
Xdout_all = cell(N,1);
Udout_all = cell(N,1);
Uext_all  = cell(N,1);
FSMout_all= cell(N,1);
p= cell(N,1);

for g = 0:5
    fprintf('Running gait %d…\n', g);

    % completely wipe anything that might persist
    clearvars -except gait_names tout_all Xout_all Uout_all Xdout_all Udout_all Uext_all FSMout_all g p
    clear functions

    [tout_all{g+1},...
     Xout_all{g+1},...
     Uout_all{g+1},...
     Xdout_all{g+1},...
     Udout_all{g+1},...
     Uext_all{g+1},...
     FSMout_all{g+1},...
     p{g+1}] = main_iterated(g);
end


fprintf('All gaits completed!\n');


%% Plot

% Step 1: Compute the minimum common length
min_len = min(cellfun(@length, tout_all));  % find the smallest time vector length

% Step 2: Create t_unif with uniformly trimmed time vectors
t_unif = cell(1, 6);
for i = 1:6
    t_i = tout_all{i};
    
    % Uniformly sample min_len points from the middle of the time vector
    % You can also choose 'head' (first min_len samples) or 'tail'
    total_len = length(t_i);
    start_idx = floor((total_len - min_len)/2) + 1;
    end_idx = start_idx + min_len - 1;
    
    t_unif{i} = t_i(start_idx:end_idx);
end

% Step 3: Use t_unif{i} inside your loop
for i = 1:6
    % unpack the i-th run
    t   = tout_all{i};
    X   = Xout_all{i};
    U   = Uout_all{i};
    Xd  = Xdout_all{i};
    Ud  = Udout_all{i};
    Ue  = Uext_all{i};
    p_i = p{i};  % optional
    
    % call with corresponding gait name
    myplot_iterated(t, X, U, Xd, Ud, Ue, p_i, gait_names{i});
    
    % Save with both number and gait name
    clean_gait_name = regexprep(gait_names{i}, '[^\w]', '_');
    filename = sprintf('figure3Es3_run%d_%s.pdf', i, clean_gait_name);
    %exportgraphics(gcf, filename, 'ContentType', 'vector');

    % Use the new uniform time vector
    t_uniformed = t_unif{i};  % uniform timeline
    [t_uniformed, EA, EAd] = fig_animate_iterated(t_uniformed, X, U, Xd, Ud, Ue, p_i,t, gait_names{i});
end

%% Gait Diagram
% Create a single figure with a 3×2 grid of gait‐diagrams
figure('Name','All Gait Diagrams','Color','w','Position',[100 100 1200 800]);
for i = 1:6
    subplot(3,2,i);
    plotGaitDiagram(tout_all{i}, Udout_all{i});
    title(gait_names{i}, 'FontSize', 14, 'FontWeight','bold');
   if i == 5 || i == 6
    xlabel('Time [s]', 'FontSize', 12);
end

end
sgtitle('Comparison of All Six Gaits', ...
    'FontSize', 14, ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial');
%exportgraphics(gcf, 'figure0Es3.pdf', 'ContentType', 'vector');
