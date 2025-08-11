function [all_breath_locs] = get_logbreaths( ...
        val3, temp_diff_break, j_wins, s_wins, p_wins, ...
        j_wins_breaks, s_wins_breaks, p_wins_breaks, ...
        p_smooth_tag, fs, start_idx, all_breath_locs)
    arguments
        val3 (:, 1) double
        temp_diff_break (:, 1) double
        j_wins (1, :) double
        s_wins (1, :) double
        p_wins (1, :) double
        j_wins_breaks (1, :) double
        s_wins_breaks (1, :) double
        p_wins_breaks (1, :) double
        p_smooth_tag (1, :) double
        fs (1, 1) double {mustBePositive}
        start_idx (1, 1) double {mustBeInteger, mustBeNonnegative}
        all_breath_locs struct
    end
    %GET_LOGBREATHS Identifies breath events during logging periods.
    %
    %   This function refines breath detections by identifying candidate breath
    %   locations within logging periods, where at least two out of three kinematic
    %   signals (jerk, surge, pitch) show peak activity. The detections are validated
    %   using smoothed depth to reduce false positives, and duplicate or overlapping
    %   detections across signals are consolidated.
    %
    %   Inputs:
    %     val3             - Nx1 vector of indices where ≥2 of 3 movement signals (jerk, surge, pitch) overlap
    %     temp_diff_break  - Nx1 vector of breakpoints separating distinct detection events in `val3`
    %     j_wins           - 1xM vector of candidate jerk window indices
    %     s_wins           - 1xM vector of candidate surge window indices
    %     p_wins           - 1xM vector of candidate pitch window indices
    %     j_wins_breaks    - 1xM vector of jerk window endpoint indices
    %     s_wins_breaks    - 1xM vector of surge window endpoint indices
    %     p_wins_breaks    - 1xM vector of pitch window endpoint indices
    %     p_smooth_tag     - 1xN vector of smoothed depth or pressure signal (used to filter false detections)
    %     fs               - Scalar sampling frequency (Hz)
    %     start_idx        - Scalar index offset relative to the full tag deployment start
    %     all_breath_locs  - Struct with existing breath detections containing fields:
    %                           - breath_idx : vector of breath indices
    %                           - type       : categorical array ('ss', 'log', etc.)
    %
    %   Output:
    %     all_breath_locs  - Updated struct with new breath detections added:
    %                           - breath_idx : appended with logging breath indices
    %                           - type       : updated to include 'log' for these detections
    %
    %   Notes:
    %     - Only breaths with valid overlap between movement windows are retained.
    %     - This function does not remove breaths already in the struct; it appends new ones.
    %     - Breath types are labeled as `"log"` for logging-associated detections.
    %
    %   Example:
    %     all_breath_locs = get_logbreaths(val3, temp_diff_break, ...
    %         j_wins, s_wins, p_wins, ...
    %         j_wins_breaks, s_wins_breaks, p_wins_breaks, ...
    %         p_smooth_tag, fs, start_idx, all_breath_locs);
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    log_breath_locs = [];
    if ~isempty(temp_diff_break)
        for c = 1:(length(temp_diff_break)+1)
            % Initialize for first loop
            if c == 1
                j_win_count = 0; s_win_count = 0; p_win_count = 0;
                cont_val3_prev = -3 * fs; % Set pre-window for breath separation
                cont_range = 1:temp_diff_break(1);
            elseif c == length(temp_diff_break)+1
                cont_val3_prev = cont_val3;
                cont_range = temp_diff_break(end)+1:length(val3);
            else
                cont_val3_prev = cont_val3;
                cont_range = temp_diff_break(c-1)+1:temp_diff_break(c);
            end
            
            if length(cont_range) > 1 * fs
                cont_val3 = val3(cont_range);
                
                % Track window overlap with jerk, surge, and pitch
                cond = 0;
                
                % Jerk
                j_temp_int = intersect(cont_val3, j_wins);
                j_win_count_prev = j_win_count;
                if ~isempty(j_temp_int)
                    j_win_count = find(j_temp_int(end) <= j_wins_breaks, 1);
                    cond = 1;
                end
                
                % Surge
                s_temp_int = intersect(cont_val3, s_wins);
                s_win_count_prev = s_win_count;
                if ~isempty(s_temp_int)
                    s_win_count = find(s_temp_int(end) <= s_wins_breaks, 1);
                    cond = 1;
                end
                
                % Pitch
                p_temp_int = intersect(cont_val3, p_wins);
                p_win_count_prev = p_win_count;
                if ~isempty(p_temp_int)
                    p_win_count = find(p_temp_int(end) <= p_wins_breaks, 1);
                    cond = 1;
                end
                
                % Only add breath if all 3 windows incremented and spacing is valid
                if j_win_count > j_win_count_prev && ...
                        s_win_count > s_win_count_prev && ...
                        p_win_count > p_win_count_prev || cond == 1
                    if cont_val3(1) > cont_val3_prev(end) + fs/10 || ...
                            max(p_smooth_tag(cont_val3_prev)) > 0.5 || ...
                            max(p_smooth_tag(cont_val3)) > 0.5
                        log_breath_locs(end+1, 1) = cont_val3(floor(length(cont_val3)/2));
                    end
                end
            end
        end
    end
    
    %% Remove duplicate breaths (ss vs. log < 3 s apart)
    temp_all_breaths = [all_breath_locs.breath_idx; log_breath_locs];
    temp_all_breaths_type = [repmat("ss", length(all_breath_locs.breath_idx), 1); ...
        repmat("log", length(log_breath_locs), 1)];
    
    [temp_all_breaths_s, sortidx] = sort(temp_all_breaths);
    temp_all_breaths_type_s = temp_all_breaths_type(sortidx, :);
    
    sim_breaths = find(diff(temp_all_breaths_s) < 3 * fs);
    rm_rows = [];
    
    for i = 1:length(sim_breaths)
        range = sim_breaths(i):sim_breaths(i)+1;
        to_remove = find(temp_all_breaths_type_s(range) == "log");
        rm_rows = [rm_rows; sim_breaths(i) + to_remove - 1];
    end
    
    temp_all_breaths_s(rm_rows) = [];
    temp_all_breaths_type_s(rm_rows) = [];
    
    % Offset indices to full-length pressure series
    all_breath_locs.breath_idx = temp_all_breaths_s + start_idx;
    all_breath_locs.type = temp_all_breaths_type_s;
    
end

