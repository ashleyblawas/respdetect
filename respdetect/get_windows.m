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
    % GET_WINDOWS Generate overlapping detection windows for jerk, surge, and pitch peaks.
    %
    %   This function creates symmetric time windows around peak indices for three types
    %   of movement signals: jerk (j_locs), surge (s_locs), and pitch (p_locs). It identifies
    %   regions where at least two of the three signals overlap and fall within shallow
    %   depth periods, and returns both these overlapping indices and their breakpoints.
    %
    %   Inputs:
    %       j_locs         - Nx1 vector of indices where jerk peaks were detected.
    %       s_locs         - Nx1 vector of indices where surge peaks were detected.
    %       p_locs         - Nx1 vector of indices where pitch peaks were detected.
    %       p_shallow_idx  - Indices within the signal that are considered shallow (e.g., near surface).
    %       win_sec        - Duration (in seconds) of each window around a peak. Window is symmetric.
    %       fs             - Sampling rate (Hz).
    %
    %   Outputs:
    %       val3              - Sorted indices where at least two of the three event windows overlap
    %                           and intersect with shallow regions.
    %       temp_diff_break   - Indices where there are discontinuities (gaps > 1 sample) in `val3`.
    %       j_wins            - Vector of indices included in all jerk-centered windows.
    %       s_wins            - Vector of indices included in all surge-centered windows.
    %       p_wins            - Vector of indices included in all pitch-centered windows.
    %       j_wins_breaks     - Endpoints of discontinuous jerk windows.
    %       s_wins_breaks     - Endpoints of discontinuous surge windows.
    %       p_wins_breaks     - Endpoints of discontinuous pitch windows.
    %
    %   Example:
    %       [val3, breaks, jw, sw, pw, jwb, swb, pwb] = get_windows(j_locs, s_locs, p_locs, ...
    %           p_shallow_idx, 1.5, 50);
    %
    %   Notes:
    %       - All windows are generated symmetrically around each peak index using the
    %         specified `win_sec` duration and `fs` sampling frequency.
    %       - val3 includes all indices that are part of overlapping jerk/surge/pitch events
    %         (at least two out of three).
    %       - The function can be used to identify candidate breathing events or logging behavior.
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    % Calculate window size (samples per window)
    win_size = floor((win_sec / 2) * fs) + ceil((win_sec / 2) * fs) + 1;
    
    % Preallocate j_wins
    j_wins = NaN(1, win_size * length(j_locs));
    for a = 1:length(j_locs)
        idx_start = (a - 1) * win_size + 1;
        idx_end = a * win_size;
        j_wins(idx_start:idx_end) = (j_locs(a) - floor((win_sec / 2) * fs)) : ...
            (j_locs(a) + ceil((win_sec / 2) * fs));
    end
    
    % Preallocate s_wins
    s_wins = NaN(1, win_size * length(s_locs));
    for b = 1:length(s_locs)
        idx_start = (b - 1) * win_size + 1;
        idx_end = b * win_size;
        s_wins(idx_start:idx_end) = (s_locs(b) - floor((win_sec / 2) * fs)) : ...
            (s_locs(b) + ceil((win_sec / 2) * fs));
    end
    
    % Preallocate p_wins
    p_wins = NaN(1, win_size * length(p_locs));
    for c = 1:length(p_locs)
        idx_start = (c - 1) * win_size + 1;
        idx_end = c * win_size;
        p_wins(idx_start:idx_end) = (p_locs(c) - floor((win_sec / 2) * fs)) : ...
            (p_locs(c) + ceil((win_sec / 2) * fs));
    end
    
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