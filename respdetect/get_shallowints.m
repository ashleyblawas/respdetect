function [p_shallow_ints,  p_shallow_idx,  p_shallow, p_smooth_tag] = get_shallowints(metadata, p, p_tag)
    arguments
        metadata (1, 1) struct
        p (:, 1) double
        p_tag (:, 1) double
    end
    % Subsets depth to only time on animal
    %
    % Inputs:
    %   metadata - The imported data from the metadata file
    %   p - The depth vector
    %   p - The depth vector when the tag is on
    %   time_sec - Time of the record in seconds
    %
    % Outputs:
    %   p_shallow_ints - Intervals when animal is at the surface
    %
    % Usage:
    %   [p_shallow_ints,  p_shallow_idx,  p_shallow, p_smooth_tag] = get_shallowints(metadata, p, p_tag)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    fs = metadata.fs;
    
    % Smooth depth signal
    p_smooth = smoothdata(p, 'movmean', fs);
    p_smooth_tag = smoothdata(p_tag, 'movmean', fs);
    p_shallow = p_smooth_tag;
    
    % Remove any pressure data that is greater than 0.5 m and get indexes
    % of shallow periods
    p_shallow(p_smooth_tag>0.5) = NaN;
    p_shallow_idx = find(~isnan(p_shallow));

    % Find start and end of surface periods
    p_shallow_breaks_end = find(diff(p_shallow_idx)>1);
    p_shallow_breaks_start = find(diff(p_shallow_idx)>1)+1;
    
    % Define variable to store surfacings
    p_shallow_ints = [[1; p_shallow_breaks_start], [p_shallow_breaks_end; length(p_shallow_idx)]];
    
    % Make third column which is duration of surfacing in indices
    p_shallow_ints(:, 3) = p_shallow_ints(:, 2) - p_shallow_ints(:, 1);
    
    % If surfacing is less than 1 second then remove it - likely not a surfacing anyway but a period
    % where depth briefly crosses above 0.25m
    delete_rows = find(p_shallow_ints(:, 3) < 1*metadata.fs);
    p_shallow_ints(delete_rows, :) = [];
    
    % If minima of a surfacing is not at least within a reasonable range of the
    % neighborhood (surrounding 4) of surfacings then remove it
    for r = length(p_shallow_ints):-1:1 % Go backwards so can delete as you go
        if r == length(p_shallow_ints)
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min1;
            min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
            min4 = min3;
        elseif r == length(p_shallow_ints)-1
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
            min4 = min3;
        elseif r == 2
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
            min3 = min4;
        elseif r == 1
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min1 = min2;
            min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
            min3 = min4;
        else
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
            min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
        end
        temp_sort = sort([min1, min2, min3, min4]);
        % Filter out detected breaths that are not within 0.15 meters of
        % the 2 shallowest detections with a neighborhood of 4
        if min(p_shallow(p_shallow_idx(p_shallow_ints(r, 1):p_shallow_ints(r, 2))))>mean(temp_sort(1:2))+0.15
            p_shallow_ints(r, :) = [];
        end
    end
    
end