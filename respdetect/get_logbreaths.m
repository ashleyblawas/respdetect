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
    % Detects breath locations during logging surfacings.
    %
    % Inputs:
    %   val3              - Vector of indices where at least 2 of 3 peak signals overlap
    %   temp_diff_break   - Indices where continuous regions in val3 are interrupted
    %   j_wins            - Jerk event window indices
    %   s_wins            - Surge event window indices
    %   p_wins            - Pitch event window indices
    %   j_wins_breaks     - End indices of each jerk window (used to detect duplicates)
    %   s_wins_breaks     - End indices of each surge window
    %   p_wins_breaks     - End indices of each pitch window
    %   p_smooth_tag      - Smoothed pressure signal used to filter valid breathing events
    %   fs                - Sampling frequency (Hz)
    %   start_idx         - Offset from beginning of full pressure signal
    %   all_breath_locs   - Struct with previous breath detections (.breath_idx and .type)
    %
    % Output:
    %   all_breath_locs   - Updated struct with new logging breath detections added and cleaned
    %
    % Usage:
    %   all_breath_locs = identify_logging_breaths(val3, temp_diff_break, ...
    %       j_wins, s_wins, p_wins, ...
    %       j_wins_breaks, s_wins_breaks, p_wins_breaks, ...
    %       p_smooth_tag, fs, start_idx, all_breath_locs)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
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

