function [val3, temp_diff_break, j_wins, s_wins, p_wins, j_wins_breaks, s_wins_breaks, p_wins_breaks] = ...
        get_windows(j_locs, s_locs, p_locs, p_shallow_idx, win_sec, fs)
    arguments
        j_locs (:, 1) double
        s_locs (:, 1) double
        p_locs (:, 1) double
        p_shallow_idx (:, 1) double
        win_sec (1, 1) double
        fs (1, 1) double
    end
    %  Generate overlapping event windows for jerk, surge, and pitch.
    %
    % Inputs:
    %   j_locs         - Indices of jerk peaks
    %   s_locs         - Indices of surge peaks
    %   p_locs         - Indices of pitch peaks
    %   p_shallow_idx  - Indices for shallow points
    %   win_sec        - Window duration in seconds (symmetric around peak)
    %   fs             - Sampling rate (Hz)
    %
    % Outputs:
    %   val3              - Sorted indices where at least 2 of 3 conditions are met
    %   temp_diff_break   - Index breaks where continuous regions in val3 are interrupted
    %   j_wins            - Jerk event window indices
    %   s_wins            - Surge event window indices
    %   p_wins            - Pitch event window indices
    %   j_wins_breaks     - End indices of each jerk window (used to detect duplicates)
    %   s_wins_breaks     - End indices of each surge window
    %   p_wins_breaks     - End indices of each pitch window
    %
    % Usage:
    %   [val3, temp_diff_break, log_breath_locs, j_wins, s_wins, p_wins, j_win_breaks, s_win_breaks, p_win_breaks] = ...
    %   get_windows(j_locs, s_locs, p_locs, p_shallow_idx, win_sec, fs)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Initialize window arrays
    % Preallocate cell array
    j_wins_cell = cell(length(j_locs), 1);
    
    for a = 1:length(j_locs)
        j_temp_win = (j_locs(a) - floor((win_sec / 2) * fs)) : ...
            (j_locs(a) + ceil((win_sec / 2) * fs));
        j_wins_cell{a} = j_temp_win;
    end
    % Concatenate all into one vector
    j_wins = [j_wins_cell{:}];
    
    % Preallocate cell array
    s_wins_cell = cell(length(s_locs), 1);
    
    for b = 1:length(s_locs)
        s_temp_win = (s_locs(b) - floor((win_sec / 2) * fs)) : ...
            (s_locs(b) + ceil((win_sec / 2) * fs));
        s_wins_cell{a} = s_temp_win;
    end
    % Concatenate all into one vector
    s_wins = [s_wins_cell{:}];
    
    % Preallocate cell array
    p_wins_cell = cell(length(p_locs), 1);
    
    for c = 1:length(p_locs)
        p_temp_win = (p_locs(c) - floor((win_sec / 2) * fs)) : ...
            (p_locs(c) + ceil((win_sec / 2) * fs));
        p_wins_cell{a} = p_temp_win;
    end
    % Concatenate all into one vector
    p_wins = [p_wins_cell{:}];
    
    % Optional: find breakpoints in windows (not used but calculated)
    if ~isempty(j_wins)
        j_wins_breaks = [j_wins(diff(j_wins) > 1), j_wins(end)];
    end
    if ~isempty(s_wins)
        s_wins_breaks = [s_wins(diff(s_wins) > 1), s_wins(end)];
    end
    if ~isempty(p_wins)
        p_wins_breaks = [p_wins(diff(p_wins) > 1), p_wins(end)];
    end
    
    % Find indices where all three windows overlap
    val3_all = intersect(intersect(intersect(p_shallow_idx, p_wins), j_wins), s_wins);
    
    % Find where only two windows overlap
    val2_js = intersect(intersect(p_shallow_idx, j_wins), s_wins);
    val2_jp = intersect(intersect(p_shallow_idx, j_wins), p_wins);
    val2_sp = intersect(intersect(p_shallow_idx, s_wins), p_wins);
    
    % Exclude full-overlap from 2-condition results
    diff_vals_js = setdiff(val2_js, val3_all);
    diff_vals_jp = setdiff(val2_jp, val3_all);
    diff_vals_sp = setdiff(val2_sp, val3_all);
    
    % Combine all overlaps (at least 2 conditions)
    val3 = sort([val3_all; diff_vals_js; diff_vals_jp; diff_vals_sp]);
    
    % Find discontinuities (breaks between segments)
    temp_diff_break = find(diff(val3) > 1);
end