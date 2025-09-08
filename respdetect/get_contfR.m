function fR = get_contfR(breath_times, p, date, metadata)
    arguments
        breath_times (:,1) {mustBeNonempty}
        p (:,1) double {mustBeNonempty}
        date (:,1) {mustBeNonempty}  % Can be datetime or numeric
        metadata struct
    end
    %GET_CONTF_R Computes instantaneous respiration rate from breath times.
    %
    %   This function calculates the instantaneous respiration rate (`fR`) based
    %   on the timing of detected breaths. It supports both CATS and DTAG tag formats
    %   and plots the continuous breathing rate alongside the depth profile.
    %
    %   Inputs:
    %     breath_times - Nx1 vector of breath times (datetime or numeric, depending on tag type)
    %     p            - Depth vector (same length as deployment duration)
    %     date         - Time vector (same length as `p`) used for plotting
    %     metadata     - Struct containing tag metadata, including the field 'tag_ver'
    %
    %   Output:
    %     fR - Instantaneous respiration rate in breaths per minute
    %
    %   Example:
    %     fR = get_contfR(breath_times, breath_idx, p, date, metadata);
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    if strcmp(metadata.tag_ver, "CATS") == 1
        fR = 1./minutes(diff(breath_times)); % Take diff of all breath time
    else
        fR = 1./diff(breath_times); % Take diff of all breath time
    end
    
    % Plot continuous fR with dive profile
    figure;
    ax(1) = subplot(311);
    stairs(breath_times(2:end), fR, 'ko','MarkerSize', 8, 'MarkerFaceColor', 'yellow');
    set(gca,'Xticklabel',[])
    ylabel('{\it f}_R (breaths min^{-1})');
    POS1 = get(ax(1), 'Position');
    POS1(2) = POS1(2)+0.05;
    set(ax(1), 'Position', POS1);
    title(metadata.tag, 'Interpreter', 'none');
    
    hold on;
    ax(2) = subplot(3, 1, [2 3]);
    plot(date, p, 'k', 'LineWidth', 1.5); xlabel('Date Time'); ylabel('Depth (m)');
    set(gca, 'Ydir', 'reverse');
    linkaxes(ax, 'x'); ylim([-1 max(p)]);
    POS = get(ax(2), 'Position');
    POS(4) = POS(4)+0.1;
    set(ax(2), 'Position', POS) ;
    
end