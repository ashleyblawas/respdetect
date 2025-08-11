function [p_shallow_ints, p_shallow_idx, p_shallow, p_smooth_tag] = get_shallowints(metadata, p_tag)
    arguments
        metadata (1, 1) struct
        p_tag (:, 1) double
    end
    % GET_SHALLOWINTS Identify shallow surfacing intervals from depth data.
    %
    %   Description:
    %       Processes a depth (pressure) time series recorded by an animal-borne tag to identify intervals
    %       when the animal is at or near the surface. It smooths the raw depth data, thresholds to identify
    %       shallow depths, and extracts contiguous shallow intervals. Very short surfacings and noisy
    %       detections are filtered out by duration and by comparing minimum depths to those of neighboring surfacings.
    %
    %   Inputs:
    %       metadata    - Struct containing tag metadata, including sampling frequency `fs` (Hz).
    %       p_tag       - Nx1 vector of depth measurements (e.g., pressure in meters).
    %
    %   Outputs:
    %       p_shallow_ints - Mx3 matrix with detected shallow intervals. Each row contains
    %                        [start_idx, end_idx, duration_samples], indices refer to positions within
    %                        the vector of shallow depth indices.
    %       p_shallow_idx  - Px1 vector of indices in `p_tag` corresponding to shallow depths (≤ 0.5 m).
    %       p_shallow      - Nx1 vector with shallow depths retained and others set to NaN.
    %       p_smooth_tag   - Nx1 smoothed depth vector using moving mean filter over a 1-second window.
    %
    %   Behavior:
    %       1. Smooths raw depth data with moving mean filter (window = fs samples).
    %       2. Replaces depth values > 0.5 m with NaN to identify shallow depths.
    %       3. Finds contiguous shallow intervals by detecting gaps in shallow indices.
    %       4. Removes intervals shorter than 1 second duration.
    %       5. Compares interval minima to neighboring intervals and removes outliers based on a 0.15 m threshold.
    %
    %   Usage example:
    %       metadata.fs = 50; % Sampling frequency in Hz
    %       [p_shallow_ints, p_shallow_idx, p_shallow, p_smooth_tag] = get_shallowints(metadata, p_tag);
    %
    %   Notes:
    %       - Assumes `p_tag` is a column vector.
    %       - The 0.5 m threshold and 1 second minimum duration could be adjusted in the function.
    %       - The smoothing window length is set to `fs` to smooth over 1 second.
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    fs = metadata.fs;
    
    % Smooth depth signal
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
    delete_rows = p_shallow_ints(:, 3) < 1*metadata.fs;
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