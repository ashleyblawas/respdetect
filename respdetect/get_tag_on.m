function [est_time_tagon] = get_tag_on(time_sec, p, fs)
    arguments
        time_sec (1,:) double
        p (:, 1) double
        fs (1, 1) double {mustBePositive}
    end
    % GET_TAG_ON Estimate the tag on time based on depth and time data.
    %
    %   est_time_tagon = get_tag_on(time_sec, p, fs)
    %
    %   Description:
    %       This function estimates the time at which a tag was attached or turned on
    %       by analyzing the depth signal (`p`) relative to the recorded time vector
    %       (`time_sec`). The tag on time is typically inferred from depth values or
    %       other criteria indicating the start of recording or deployment.
    %
    %   Inputs:
    %       time_sec - 1xN vector containing timestamps in seconds for each recorded sample.
    %       p        - Nx1 vector of depth values corresponding to the time samples.
    %       fs       - Sampling frequency in Hz (scalar, positive).
    %
    %   Output:
    %       est_time_tagon - Estimated time (in seconds) when the tag was turned on or attached.
    %
    %   Usage:
    %       est_time_tagon = get_tag_on(time_sec, p, fs);
    %
    %   Assumptions:
    %       - `time_sec` and `p` vectors must be of equal length.
    %       - Data are evenly sampled according to `fs`.
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
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