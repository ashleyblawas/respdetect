function [jerk_smooth, surge_smooth, pitch_smooth] = ...
    process_move(jerk_smooth, surge_smooth, pitch_smooth, ...
    p, p_smooth_tag, ...
    start_idx, end_idx, ...
    logging_start_idxs, logging_end_idxs, ...
    metadata)
    arguments
        jerk_smooth (:,1) double                      % Smoothed jerk signal
        surge_smooth (:,1) double                     % Smoothed surge signal
        pitch_smooth (:,1) double                     % Smoothed pitch signal
        p (:,1) double                                % Raw depth vector
        p_smooth_tag (:,1) double                     % Smoothed depth vector
        start_idx (1,1) double {mustBeInteger, mustBeNonnegative} % Start index for tag on
        end_idx (1,1) double {mustBeInteger, mustBeNonnegative}   % End index for tag off
        logging_start_idxs (:,1) double {mustBeInteger}           % Start indices of logging surfacings
        logging_end_idxs (:,1) double {mustBeInteger}             % End indices of logging surfacings
        metadata (1,1) struct                            % Struct containing sampling rate and metadata info
    end
    % PROCESS_MOVE Filters and normalizes movement signals during logging surfacings
    %
    % This function preprocesses movement variables (jerk, surge, and pitch)
    % by filtering out underwater periods, trimming to the tag-on/tag-off window,
    % and keeping only the values within logging surfacings (±5 seconds). It then
    % normalizes each continuous segment of the signal.
    %
    % Inputs:
    %   jerk_smooth           - Smoothed jerk signal (vector)
    %   surge_smooth          - Smoothed surge signal (vector)
    %   pitch_smooth          - Smoothed pitch signal (vector)
    %   p                     - Raw depth vector
    %   p_smooth_tag          - Smoothed depth vector
    %   start_idx             - Index of tag-on in the data
    %   end_idx               - Index of tag-off in the data
    %   logging_start_idxs    - Vector of start indices for logging surfacings
    %   logging_end_idxs      - Vector of end indices for logging surfacings
    %   metadata              - Struct containing metadata fields (e.g., fs)
    %
    % Outputs:
    %   jerk_smooth           - Cleaned and normalized jerk signal
    %   surge_smooth          - Cleaned and normalized surge signal
    %   pitch_smooth          - Cleaned and normalized pitch signal
    %
    % Behavior:
    %   - Values deeper than 5 m are NaN'd (movement during deeper dives removed)
    %   - Data outside tag-on/tag-off is trimmed
    %   - Only logging surfacings (±5 seconds) are retained
    %   - Remaining sections are normalized (rescaled to [0, 1])
    %
    % Usage:
    %   [jerk_smooth, surge_smooth, pitch_smooth] = process_move( ...
    %       jerk_smooth, surge_smooth, pitch_smooth, ...
    %       p, p_smooth_tag, ...
    %       start_idx, end_idx, ...
    %       logging_start_idxs, logging_end_idxs, ...
    %       metadata);
    %
    % Author: Ashley Blawas  
    % Last Updated: August 11, 2025  
    % Stanford University
    
    % Want pitch to be positive for peak detect, so adding min
    pitch_smooth = pitch_smooth + abs(min(pitch_smooth(~isinf(pitch_smooth))));
    
    % Remove underwater portions of movement data
    for i = 1:length(jerk_smooth)
        if p(i)>5 % The higher this threshold is the better for promience detections
            jerk_smooth(i) = NaN;
            surge_smooth(i) = NaN;
            pitch_smooth(i) = NaN;
        end
    end
    
    % Subset tag on to tag off of pressure
    jerk_smooth=jerk_smooth(start_idx:end_idx);
    surge_smooth=surge_smooth(start_idx:end_idx);
    pitch_smooth=pitch_smooth(start_idx:end_idx);
    
    % Get indexes of p_smooth that are are logging with 5s window on each side
    idx_temp = zeros(length(p_smooth_tag), 1);
    for d = 1:length(logging_start_idxs)
        idx_temp(logging_start_idxs(d)-5*metadata.fs:logging_end_idxs(d)+5*metadata.fs) = 1;
    end
    
    % Remove jerk measurements for non-logging surfacing periods
    jerk_smooth(idx_temp==0) = NaN;
    surge_smooth(idx_temp==0) = NaN;
    pitch_smooth(idx_temp==0) = NaN;
    
    % Pitch good until here
    
    % Normalize pitch and jerk section-by-section
    % Divide signal into continue sections to rescale
    cont_sections_jerk = regionprops(~isnan(jerk_smooth), jerk_smooth, 'PixelValues');
    cont_sections_surge = regionprops(~isnan(surge_smooth), surge_smooth, 'PixelValues');
    cont_sections_pitch = regionprops(~isnan(pitch_smooth), pitch_smooth, 'PixelValues');
    cont_sections_idx = regionprops(~isnan(jerk_smooth), jerk_smooth, 'PixelList');
    
    for i = 1:length(cont_sections_idx)
        % Assign jerk for this section to variables and indexes of section
        jerk_temp = cont_sections_jerk(i).PixelValues;
        surge_temp = cont_sections_surge(i).PixelValues;
        pitch_temp = cont_sections_pitch(i).PixelValues;
        
        temp_idx = cont_sections_idx(i).PixelList(:, 2);
        
        % Rescale the jerk in this section
        jerk_temp = rescale(jerk_temp);
        surge_temp = rescale(surge_temp);
        pitch_temp = rescale(pitch_temp);
        
        jerk_smooth(temp_idx) = jerk_temp;
        surge_smooth(temp_idx) = surge_temp;
        pitch_smooth(temp_idx) = pitch_temp;
    end
    
end