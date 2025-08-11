function [est_time_tagoff] = get_tag_off(time_sec, p, fs)
    arguments
        time_sec (1,:) double
        p (:, 1) double
        fs (1, 1) double {mustBePositive}
    end
    % GET_TAG_OFF Estimate the tag off time based on depth and time data.
    %
    %   est_time_tagoff = get_tag_off(time_sec, p, fs)
    %
    %   Description:
    %       This function estimates the time at which a tag was removed or turned off
    %       by analyzing the depth signal (`p`) relative to the recorded time vector
    %       (`time_sec`). The tag off time is typically inferred from depth values or
    %       other criteria indicating the end of recording or detachment.
    %
    %   Inputs:
    %       time_sec - 1xN vector containing timestamps in seconds for each recorded sample.
    %       p        - Nx1 vector of depth values corresponding to the time samples.
    %       fs       - Sampling frequency in Hz (scalar, positive).
    %
    %   Output:
    %       est_time_tagoff - Estimated time (in seconds) when the tag was turned off or removed.
    %
    %   Usage:
    %       est_time_tagoff = get_tag_off(time_sec, p, fs);
    %
    %   Assumptions:
    %       - `time_sec` and `p` vectors must be of equal length.
    %       - Data are evenly sampled according to `fs`.
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    figure(11)
    
    % Plot dive profile
    plot(time_sec, p, 'b'); grid on; hold on;
    set(gca, 'YDir', 'reverse')
    title('Zoom in on detected tag off time... if incorrect hit "y" too choose.')
    xlabel('Time (s)'); ylabel('Depth (m)');
    ax = gca;
    ax.XRuler.Exponent = 0;
    
    % Automatically estimate tag-off time
    clear est_time_tagoff
    
    % Threshold settings
    depthThreshold = 0.5;        % Assuming tag is safely at surface within 0.2 m of 0 m
    consecSamples = fs*300;      % Number of consecutive points within threshold to count as reliable tag off (for at least 5 minutes)
    underwaterThreshold = 2 ;    % Asumming tag is safely underwater iif reading is 2 m
    
    % Detect where depth stays close to zero (surface)
    atSurface = abs(p) <= depthThreshold;
    
    % Look for long runs of surface depth
    runLength = conv(double(atSurface), ones(consecSamples, 1), 'valid');
    idx = find(runLength == consecSamples, 1, 'first');  % First long flat sequence
    
    
    % Case 1: Still underwater at end of record
    if p(end) > underwaterThreshold
        est_time_tagoff = time_sec(end);
        fprintf('[AUTO] Tag appears to still be on. Using end of recording (%.2f sec).\n', est_time_tagoff);
        % Case 2: Detected long period near surface
    elseif ~isempty(idx)
        est_time_tagoff = time_sec(idx);
        fprintf('[AUTO] Detected long surface period. Estimated tag off at %.2f sec.\n', est_time_tagoff);
        % Case 3: No clear tag-off - fallback to manual
    else
        fprintf('[MANUAL] Could not estimate tag-off automatically.\n');
        disp('Zoom/pan the plot. Then click the tag-off time manually...');
        pause;
        [x, ~] = ginput(1);
        est_time_tagoff = x;
        fprintf('User-selected tag off time: %.2f seconds\n', est_time_tagoff);
    end
    
    % Plot detected tag-off time
    xline(est_time_tagoff, 'g--', 'Tag Off', 'LabelVerticalAlignment', 'bottom');
    
    % Ask if user wants to override
    txt = input('Do you want to override the tag off time manually? (y/n): ', 's');
    if strcmpi(txt, 'y')
        disp('Click the new tag off time...');
        [x, ~] = ginput(1);
        est_time_tagoff = x;
        fprintf('New user-selected tag off time: %.2f seconds\n', est_time_tagoff);
        xline(est_time_tagoff, 'm--', 'Updated Tag Off', 'LabelVerticalAlignment', 'bottom');
    end
    
end