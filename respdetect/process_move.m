function [jerk_smooth, surge_smooth, pitch_smooth] = ...
        process_move(jerk_smooth, surge_smooth, pitch_smooth, ...
        p, p_smooth_tag, ...
        start_idx, end_idx, ...
        logging_start_idxs, logging_end_idxs, ...
        metadata)
    arguments
        jerk_smooth
        surge_smooth
        pitch_smooth
        p (:, 1) double
        p_smooth_tag (:, 1) double
        start_idx (1, 1) double
        end_idx (1, 1) double
        logging_start_idxs (:, 1) double
        logging_end_idxs (:, 1) double
        metadata (1, 1) struct
    end
    % Processes movement data within logging periods
    %
    % Inputs:
    %
    % Outputs:
    %   jerk_smooth
    %   surge_smooth
    %   pitch_smooth
    %
    % Usage:
    %   [jerk_smooth, surge_smooth, pitch_smooth] = process_move(jerk_smooth, surge_smooth, pitch_smooth, ...
    %   p, p_smooth_tag, ...
    %   start_idx, end_idx, ...
    %   logging_start_idxs, logging_end_idxs, ...
    %   metadata)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
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
    for d = 1:length(logging_start_idxs);
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