function [est_time_tagon] = get_tag_on(time_sec, p, fs)
    arguments
        time_sec (1,:) double
        p (:, 1) double
        fs (1, 1) double
    end
    % Selects the tag time on
    %
    % Inputs:
    %   time_sec - The vector containing time in seconds at which each
    %   sample was recorded
    %   p - The vector of depth values
    %   fs - The sampling rate
    %
    % Usage:
    %   [est_time_tagon] = get_tag_on(time_sec, p, fs)
    %
    % Assumptions:
    %   - time_sec and p are the same length
    %
    
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Plot dive profile
    plot(time_sec, p, 'b'); grid on; hold on;
    set(gca, 'YDir', 'reverse')
    title('Dive Profile')
    xlabel('Time (s)'); ylabel('Depth (m)');
    ax = gca;
    ax.XRuler.Exponent = 0;
    
    % Automatically estimate tag-on time
    clear est_time_tagon
    
    % Threshold settings
    depthThreshold = 2;        % Assuming tag is safely underwater at 2m 
    consecSamples = fs*5;      % Number of consecutive points below threshold to count as reliable
    
    if p(1) > depthThreshold
        % Tag already on at start
        est_time_tagon = time_sec(1);
        fprintf('Tag on assumed at start of recording (first depth value is %.2f m).\n', p(1));
    else
        % Search for N consecutive samples below depthThreshold
        belowZero = p > depthThreshold;
        runLength = conv(double(belowZero), ones(consecSamples, 1), 'valid');
        idx = find(runLength == consecSamples, 1, 'first');
        
        if ~isempty(idx)
            est_time_tagon = time_sec(idx);
            fprintf('Tag on time (s) using first reliable submersion is: %.2f seconds\n', est_time_tagon);
        else
            % Unable to detect tag-on — prompt user to click
            disp('Unable to automatically determine tag on time.');
            disp('Please click the estimated tag on point on the plot...');
            
            [x, ~] = ginput(1);  % Get one click from user
            est_time_tagon = x;
            
            fprintf('User-selected tag on time: %.2f seconds\n', est_time_tagon);
        end
    end
        
    % Optional: plot estimated tag-on point
    xline(est_time_tagon, 'r--', 'Tag On', 'LabelVerticalAlignment', 'bottom');
    
end