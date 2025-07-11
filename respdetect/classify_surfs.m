function [single_breath_surf_rows, logging_surf_rows, ...
        logging_start_idxs, logging_end_idxs, logging_ints_s, p_shallow_ints, all_breath_locs] = ...
        classify_surfs(p_shallow_ints, p_shallow_idx, p_shallow, time_sec, ...
        start_idx, n_sec, fs)
    % Classifies surfacings into single-breath and logging types.
    %
    % Inputs:
    %   p_shallow_ints   - [Nx3] matrix where column 3 contains duration in samples
    %   p_shallow_idx    - [Mx1] vector of indices into the depth array
    %   p_shallow        - Logical vector to say wether p is shallow or not
    %   time_sec         - Time vector in seconds
    %   start_idx        - Index offset for tag-on period
    %   n_sec            - Threshold duration (in seconds) for logging surfacing
    %   fs               - Sampling frequency (Hz)
    %
    % Outputs:
    %   single_breath_surf_rows - Row indices of short surfacings (<= n_sec)
    %   logging_surf_rows       - Row indices of longer logging surfacings
    %   logging_start_idxs      - Indices of logging start points (into depth array)
    %   logging_end_idxs        - Indices of logging end points (into depth array)
    %   logging_ints_s          - [Nx2] matrix of logging intervals in seconds (start, end)
    %   p_shallow_ints          - New column for index of depth minima for
    %   single surfacing breaths
    %   all_breath_locs         - Info with time and cue for each breath
    
    % Classify surfacings
    sample_threshold = n_sec * fs;
    single_breath_surf_rows = find(p_shallow_ints(:, 3) <= sample_threshold);
    logging_surf_rows = find(p_shallow_ints(:, 3) > sample_threshold);
    
    % Get index ranges for logging surfacings
    logging_start_idxs = p_shallow_idx(p_shallow_ints(logging_surf_rows, 1));
    logging_end_idxs   = p_shallow_idx(p_shallow_ints(logging_surf_rows, 2));
    
    % Convert to time in seconds using start_idx offset
    logging_start_s = time_sec(start_idx + logging_start_idxs);
    logging_end_s   = time_sec(start_idx + logging_end_idxs);
    logging_ints_s  = [logging_start_s', logging_end_s'];
    
    %% Step 5e: Detect breaths for single breath surfacings
    for r = length(single_breath_surf_rows):-1:1
        % Column four is the index of the minima
        p_shallow_ints(single_breath_surf_rows(r), 4) = p_shallow_ints(single_breath_surf_rows(r), 1) - 1 + find(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))) == min(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2)))), 1);
    end
    p_shallow_ints(logging_surf_rows, 4) = NaN;
    
    % Get the indicies of breaths associated with single surfacings from
    sbs_idxs = p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4));
    
    % Assign singel surfacing breath information to all_breath_locs
    all_breath_locs.breath_idx = sbs_idxs;
    all_breath_locs.type = repmat("ss", length(sbs_idxs), 1);
    
end
