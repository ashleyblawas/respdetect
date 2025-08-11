function [p_tag, start_idx, end_idx] = subset_p(metadata, p, time_sec)
    arguments
        metadata (1, 1) struct
        p (:, 1) double
        time_sec (1, :) double
    end
    % SUBSET_P Subsets depth data to time between tag-on and tag-off.
    %
    % This function identifies the indices corresponding to tag-on and tag-off
    % times based on the `metadata` struct, and subsets the depth vector `p` to
    % only include samples while the tag is on the animal.
    %
    % Inputs:
    %   metadata  - Struct containing deployment metadata, including fields:
    %               tag_on  - Tag-on time in seconds
    %               tag_off - Tag-off time in seconds
    %   p         - Depth vector (in meters), as a column vector
    %   time_sec  - Time vector corresponding to the depth samples, in seconds
    %
    % Outputs:
    %   p_tag     - Subset of the depth vector from tag-on to tag-off
    %   start_idx - Index in `p` where tag-on occurs
    %   end_idx   - Index in `p` where tag-off occurs
    %
    % Behavior:
    %   - The tag-on and tag-off times are matched to the nearest values in
    %     the `time_sec` vector.
    %   - If tag-on occurs near the surface (<5 m), the start index is redefined
    %     to the first time the tag reaches a depth of ≥5 m to avoid early
    %     artifacts (e.g., jerk spikes at tag deployment).
    %   - Ensures end_idx does not point to the very last sample (if it does,
    %     it is shifted one index earlier).
    %
    % Usage:
    %   [p_tag, start_idx, end_idx] = subset_p(metadata, p, time_sec)
    %
    % Author: Ashley Blawas  
    % Last Updated: August 11, 2025  
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