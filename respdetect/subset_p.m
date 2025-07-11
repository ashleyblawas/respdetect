function [p_tag, start_idx, end_idx] = subset_p(metadata, p, time_sec)
    arguments
        metadata (1, 1) struct
        p (:, 1) double
        time_sec (1, :) double
    end
    % Subsets depth to only time on animal
    %
    % Inputs:
    %   metadata - The imported data from the metadata file
    %   p - The depth vector
    %   time_sec - Time of the record in seconds
    %
    % Outputs:
    %   p_tag - Depth vector only during tag on
    %   start_idx - Start of tag on
    %   end_idx - End of tag on
    %
    % Usage:
    %   [p_tag, start_idx, end_idx] = subset_p(metadata, p, time_sec)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    
    start_idx = find(abs(time_sec-metadata.tag_on)==min(abs(time_sec-metadata.tag_on)));
    end_idx = find(abs(time_sec-metadata.tag_off)==min(abs(time_sec-metadata.tag_off)));
    
    if end_idx == length(time_sec)
        end_idx = end_idx-1;
    end
    
    % If the tag on time is when the tag is near the surface, we are going to
    % redefine the start idx as the first time the tag goes to a depth of 5 m
    % the reason for this being that the tag on
    % result in a big jerk spike that will interfere with peak detection
    % for breaths
    
    if p(start_idx)<5
        start_idx = find(p(start_idx:end_idx)>=5, 1)+start_idx;
    end
    
    % Subset p to only when tag is on
    p_tag = p(start_idx:end_idx);
    
end