function [t,EA,EAd] = fig_animate_iterated(tout,Xout,Uout,Xdout,Udout,Uext,p,treal,gait_name)
    arguments
        tout
        Xout
        Uout
        Xdout
        Udout
        Uext
        p
        treal
        gait_name = ''
        
    end
    flag_movie = p.flag_movie;
    if flag_movie
        try
            name = [gait_name '_animation.mp4'];
            vidfile = VideoWriter(name,'MPEG-4');
        catch ME
            name = [gait_name '_animation'];
            vidfile = VideoWriter(name,'Motion JPEG AVI');
        end
        open(vidfile);
    end
    
    %% smoothen for animation
    t = (tout(1):p.simTimeStep:tout(end));
    X = interp1(treal,Xout,t);
    U = interp1(treal,Uout,t);
    Xd = interp1(treal,Xdout,t);
    Ud = interp1(treal,Udout,t);
    Ue = interp1(treal,Uext,t);
    
    %% loop through frames
    figure('Position',[200 100 800 600], 'Name', ['Animation - ' gait_name]);
    set(0, 'DefaultFigureRenderer', 'opengl');
    set(gcf, 'Color', 'white')
    
    nt = length(t);
    EA = zeros(nt,3);
    EAd = zeros(nt,3);
    for ii = 1:nt
        EA(ii,:) = fcn_X2EA(X(ii,:));
        EAd(ii,:) = fcn_X2EA(Xd(ii,:));
    end
    
          % Before loop: setup video file if flag_movie is on
if flag_movie
    filename = [gait_name, '.mp4'];  % dynamic file name
    vidfile = VideoWriter(filename, 'MPEG-4');
    open(vidfile);
end

    for ii = 1:p.playSpeed:nt
        %% The main animation
        % plot setting
        pcom = X(ii,1:3)';
        hold on; grid on; axis square; axis equal;
        xlim([pcom(1)-0.5 pcom(1)+0.5]);
        ylim([pcom(2)-0.5 pcom(2)+0.5]);
        zlim([-0.2 0.6]);
        viewPt = [0.2,0.5,0.2];
        view(viewPt);
        
        % plot robot & GRF
        % real
        fig_plot_robot(X(ii,:)',U(ii,:)',Ue(ii,:)',p)
        % desired
        fig_plot_robot_d(Xd(ii,:)',0*Ud(ii,:)',p)
        
        % Add gait title at the top
        title(['Gait: ' gait_name], 'FontSize', 14, 'FontWeight', 'bold');
        
        % text
        txt_time = ['t = ',num2str(t(ii),2),'s'];
        text(pcom(1),pcom(2),0.4,txt_time)
        txt_vd = ['vd = ',num2str(Xd(ii,4),2),'m/s'];
        text(pcom(1),pcom(2),0.5,txt_vd)
        txt_v = ['v = ',num2str(X(ii,4),2),'m/s'];
        text(pcom(1),pcom(2),0.45,txt_v)
        
        %% make movie

    
    drawnow;  % ensure plot is rendered before capturing
    
    % Capture and write frame
    if flag_movie
        frame = getframe(gcf);  % or getframe(h_main) if using specific axis
        writeVideo(vidfile, frame);
    end
        if ii < nt
        cla;
        end

end

% After loop: close video file
if flag_movie
    close(vidfile);
end

end