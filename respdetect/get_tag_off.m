function [est_time_tagoff] = get_tag_off(time_sec, p, fs)
    arguments
        time_sec (1,:) double
        p (:, 1) double
        fs (1, 1) double
    end
    % Selects the tag time off
    %
    % Inputs:
    %   time_sec - The vector containing time in seconds at which each
    %   sample was recorded
    %   p - The vector of depth values
    %   fs - The sampling rate
    %
    % Usage:
    %   [est_time_tagoff] = get_tag_off(time_sec, p, fs)
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
    
    % Automatically estimate tag-off time
    clear est_time_tagoff
    
    % Threshold settings
    depthThreshold = 0.2;        % Assuming tag is safely at surface within 0.2 m of 0 m
    consecSamples = fs*300;      % Number of consecutive points within threshold to count as reliable tag off (for at least 5 minutes)
    underwaterThreshold = 2 ;    % Asumming tag is safely underwater iif reading is 2 m
   
    % Detect where depth stays close to zero (surface)
    atSurface = abs(p) <= depthThreshold;
    
    % Look for long runs of surface depth
    runLength = conv(double(atSurface), ones(consecSamples, 1), 'valid');
    idx = find(runLength == consecSamples, 1, 'first');  % First long flat sequence
    
    if p(end) > underwaterThreshold
        % Tag still on at end of record
        est_time_tagoff = time_sec(end);
        fprintf('Tag off assumed at end of recording as last depth measurement is %.2f m.\n', p(end));
    else
        
        if ~isempty(idx)
            est_time_tagoff = time_sec(idx);
            fprintf('Estimated tag off time based on flat depth: %.2f seconds\n', est_time_tagoff);
        else
            % Ask user to select tag-off manually
            disp('Unable to determine tag-off time automatically.');
            disp('Please click the estimated tag off point on the plot...');
            
            [x, ~] = ginput(1);
            est_time_tagoff = x;
            
            fprintf('User-selected tag off time: %.2f seconds\n', est_time_tagoff);
        end
        
        % Plot the tag-off time
        xline(est_time_tagoff, 'g--', 'Tag Off', 'LabelVerticalAlignment', 'bottom');
    end
    
    % Optional: plot estimated tag-on point
    xline(est_time_tagoff, 'g--', 'Tag Off', 'LabelVerticalAlignment', 'bottom');
    
end