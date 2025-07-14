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
    
    figure(10)
    
    % Plot dive profile
    plot(time_sec, p, 'b'); grid on; hold on;
    set(gca, 'YDir', 'reverse')
    title('Zoom in on detected tag on time... if incorrect hit "y" too choose.')
    xlabel('Time (s)'); ylabel('Depth (m)');
    ax = gca;
    ax.XRuler.Exponent = 0;
    
    % Automatically estimate tag-on time
    clear est_time_tagon
    
    % Threshold settings
    depthThreshold = 2;        % Assuming tag is safely underwater at 2m
    consecSamples = fs*5;      % Number of consecutive points below threshold to count as reliable
    
    % Case 1: Already underwater at start
    if p(1) > depthThreshold
        est_time_tagon = time_sec(1);
        fprintf('[AUTO] Tag appears on at start (depth = %.2f m).\n', p(1));
    else
        % Case 2: Look for reliable submersion (N consecutive samples > threshold)
        belowSurface = p > depthThreshold;
        runLength = conv(double(belowSurface), ones(consecSamples, 1), 'valid');
        idx = find(runLength == consecSamples, 1, 'first');
        
        if ~isempty(idx)
            est_time_tagon = time_sec(idx);
            fprintf('[AUTO] Tag on estimated at %.2f seconds (submersion detected).\n', est_time_tagon);
        else
            % Case 3: Could not determine tag-on, ask user
            fprintf('[MANUAL] Unable to detect tag on time automatically.\n');
            disp('Zoom/pan and click to select tag-on time...');
            pause;
            [x, ~] = ginput(1);
            est_time_tagon = x;
            fprintf('User-selected tag on time: %.2f seconds\n', est_time_tagon);
        end
    end
    
    % Plot detected tag-on time
    xline(est_time_tagon, 'r--', 'Tag On', 'LabelVerticalAlignment', 'bottom');
    
    % Offer user to override
    txt = input('Do you want to override the tag on time manually? (y/n): ', 's');
    if strcmpi(txt, 'y')
        disp('Click the new tag on time...');
        [x, ~] = ginput(1);
        est_time_tagon = x;
        fprintf('New user-selected tag on time: %.2f seconds\n', est_time_tagon);
        xline(est_time_tagon, 'm--', 'Updated Tag On', 'LabelVerticalAlignment', 'bottom');
    end
    
    hold off;
    
end