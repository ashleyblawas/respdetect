function [single_breath_surf_rows, logging_surf_rows, ...
        logging_start_idxs, logging_end_idxs, logging_ints_s, ...
        p_shallow_ints, all_breath_locs] = ...
        classify_surfs(p_shallow_ints, p_shallow_idx, p_shallow, time_sec, ...
        start_idx, n_sec, fs)
    arguments
        p_shallow_ints (:,3) double {mustBeNonempty, mustBeFinite}   % [Nx3] matrix of shallow intervals
        p_shallow_idx (:,1) double {mustBeNonnegative, mustBeInteger} % Indices into depth array
        p_shallow (:,1) double                                       % Logical vector for shallow positions
        time_sec (:,1) double {mustBeNonempty, mustBeFinite}         % Time in seconds
        start_idx (1,1) double {mustBeNonnegative, mustBeInteger}    % Offset index (e.g., tag-on index)
        n_sec (1,1) double {mustBePositive, mustBeFinite}            % Threshold duration for logging
        fs (1,1) double {mustBePositive, mustBeFinite}               % Sampling rate in Hz
    end
    % CLASSIFY_SURFS Classifies shallow surfacings into single-breath or logging types.
    %
    %   This function takes shallow interval data and separates surfacing events
    %   into short, single-breath surfacings or longer logging bouts based on a
    %   duration threshold (n_sec). It also detects breath cues for single-breath
    %   surfacings and records timing for all logging events.
    %
    %   Inputs:
    %     p_shallow_ints  - [Nx3] matrix of shallow intervals; columns are:
    %                         [start_idx, end_idx, duration_in_samples]
    %     p_shallow_idx   - [Mx1] vector of indices into depth data (e.g., p)
    %     p_shallow       - Logical vector indicating shallow positions in p
    %     time_sec        - Time vector (in seconds)
    %     start_idx       - Index offset corresponding to tag-on point
    %     n_sec           - Duration threshold in seconds for logging classification
    %     fs              - Sampling frequency in Hz
    %
    %   Outputs:
    %     single_breath_surf_rows - Indices of rows in p_shallow_ints for single-breath surfacings
    %     logging_surf_rows       - Indices of rows in p_shallow_ints for logging surfacings
    %     logging_start_idxs      - Start indices (into p) of logging bouts
    %     logging_end_idxs        - End indices (into p) of logging bouts
    %     logging_ints_s          - [Nx2] matrix of logging intervals in seconds [start, end]
    %     p_shallow_ints          - Updated p_shallow_ints with 4th column indicating
    %                               depth minima index for single-breath surfacings
    %     all_breath_locs         - Struct with:
    %                                 - breath_idx: indices of detected single breaths
    %                                 - type: surfacing type ("ss" = single surfacing)
    %
    %   Example:
    %     [sbs_rows, log_rows, log_starts, log_ends, log_ints, psi_out, breaths] = ...
    %         classify_surfs(p_ints, p_idx, p_shallow, t_sec, start_idx, 10, 50);
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
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
