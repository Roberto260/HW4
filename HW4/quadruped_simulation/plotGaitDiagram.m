function plotGaitDiagram(t, Ud)
% plotGaitDiagram  Draws a 4-row gait diagram (LF, RF, LH, RH)
%                  based on non-zero vertical GRFs, with clear row
%                  separators and a legend indicating stance/swing.
%
% Inputs:
%   t  - [n×1] time vector
%   Ud - [n×m] control forces (columns 3,6,9,12 are Fz for FL,FR,HL,HR)

    % extract vertical GRFs for each leg: FL, FR, HL, HR
    Fz = Ud(:,[3,6,9,12]);
    legNames = {'LF','RF','LH','RH'};
    epsVal = 1e-3;

    % create figure
    %figure('Name','Gait Diagram','Color','w');
    %hold on

    % plot stance (green) blocks for each leg
    for i = 1:4
        isStance = abs(Fz(:,i)) > epsVal;
        d = diff([0; isStance; 0]);
        starts = find(d == 1);
        ends   = find(d == -1) - 1;

        y = 5 - i;  % row index from top to bottom (LF to RH)

        for k = 1:numel(starts)
            x0 = t(starts(k));
            x1 = t(ends(k));
            patch([x0 x1 x1 x0], [y-0.4 y-0.4 y+0.4 y+0.4], ...
                  'g', 'EdgeColor','none');
        end
    end

    % draw horizontal black lines between rows
    for ylineVal = 1.5:1:3.5
        line([t(1) t(end)], [ylineVal ylineVal], ...
             'Color','k','LineWidth',1);
    end

    % dummy patches for legend
    p1 = patch(NaN, NaN, 'g', 'EdgeColor','none');
    p2 = patch(NaN, NaN, 'w', 'EdgeColor','k');

    % finalize plot
    xlim([t(1) t(end)]);
    ylim([0.5 4.5]);
    set(gca, ...
        'YTick', 1:4, ...
        'YTickLabel', legNames, ...
        'YDir', 'reverse', ...
        'FontSize', 12);

    
    title('Stance/Swing Gait Diagram', 'FontSize', 16);

    % legend([p1 p2], {'Stance', 'Swing'}, ...
    %        'Location','northeast','FontSize',12,'Box','off');
    hold off
end
