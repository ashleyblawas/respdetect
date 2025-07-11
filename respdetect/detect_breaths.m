function detect_breaths(taglist, dataPath)
    arguments
        taglist (1, :) cell
        dataPath (1,:) char
    end
    % Uses previously calculated information to identify breaths
    %
    % Inputs:
    %   taglist  - Cell array of tag names
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %
    % Outputs:
    %   Saves a file in the data path under the species of interest in the "breaths" folder.
    %   This function saves no variables to the workspace.
    %
    % Usage:
    %   detect_breaths(taglist, dataPath)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    for k = 1:length(taglist)
        
        %% Step 5a: Import tag data
        tag = taglist{k}; speciesCode = tag(1:2);
        
        % Load in metadata
        metadata = load(strcat(dataPath, speciesCode, "\metadata\", tag, "md"));
        clear tag
        
        %Set path for prh files
        settagpath('prh',strcat(dataPath, speciesCode, '\prh'));
        
        % Load the existing prh file
        loadprh(metadata.tag);
        
        % Load in movement data
        load(strcat(dataPath, speciesCode, "\movement\", metadata.tag, "movement.mat"));
        
        % Load in diving data
        load(strcat(dataPath, speciesCode, "\diving\", metadata.tag, "dives.mat"));
        load(strcat(dataPath, speciesCode, "\diving\", metadata.tag, "divetable.mat"));
        
        % Calculate time variables for full tag deployment
        [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
        
        %% Step 5b: Subset deployment to tag on time only
        
        [p_tag, start_idx, end_idx] = subset_p(metadata, p, time_sec);
        
        %% Step 5c: Identify surface periods
        
        [p_shallow_ints, p_shallow_idx, p_shallow] = get_shallowints(metadata, p, p_tag);
        
        % If these periods are less than 10 seconds then we say they are a "single
        % breath surfacing" otherwise they are a "logging surfacings"
        n_sec = 10;
        [single_breath_surf_rows, logging_surf_rows, logging_start_idxs, logging_end_idxs, logging_ints_s, p_shallow_ints] = ...
            classify_surfs(p_shallow_ints, p_shallow_idx, p_shallow, time_sec, start_idx, n_sec, metadata.fs);
        
        %% Step 5d: Start plot of surfacing periods
       
        [p1, p2, p3, p4, p5] = plot_surfs(time_min, p_tag, p_smooth_tag, start_idx, end_idx, ...
            p_shallow_idx, p_shallow_ints, p_shallow, ...
            logging_surf_rows, single_breath_surf_rows, metadata);
        
        %% Step 5e: Got dropped out... now obsolete
        
        %% Step 5f: Plot breath detections for single breath surfacing
        
        p6 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4)-1)), p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4))), 'k*');
        
        legend([p1 p2 p3 p4 p5 p6], {'Dive depth' , 'Logging', 'Single-breath surfacing', 'Start of surfacing', 'End of surfacing', 'Breaths'}, 'Location', 'northeastoutside')
        
        % Save surface detections figure
        figfile = strcat(data_path, metadata.tag(1:2) , '/figs/', metadata.tag, '_surfacedetections.fig');
        savefig(figfile);
        
        %% Step 5g: Pre-process movement data for logging period breath detections
        
        % Want pitch to be positive for peak detect, so adding min
        pitch_smooth = pitch_smooth + abs(min(pitch_smooth(~isinf(pitch_smooth))));
        
        % Remove underwater portions of movement data
        for i = 1:length(jerk_smooth)
            if p(i)>5 % The higher this threshold is the better for promience detections
                jerk_smooth(i) = NaN;
                surge_smooth(i) = NaN;
                pitch_smooth(i) = NaN;
            end
        end
        
        % Subset tag on to tag off of pressure
        jerk_smooth=jerk_smooth(start_idx:end_idx);
        surge_smooth=surge_smooth(start_idx:end_idx);
        pitch_smooth=pitch_smooth(start_idx:end_idx);
        
        % Get indexes of p_smooth that are are logging with 5s window on each side
        idx_temp = zeros(length(p_smooth_tag), 1);
        for d = 1:length(logging_start_idxs);
            idx_temp(logging_start_idxs(d)-5*metadata.fs:logging_end_idxs(d)+5*metadata.fs) = 1;
        end
        
        % Remove jerk measurements for non-logging surfacing periods
        jerk_smooth(idx_temp==0) = NaN;
        surge_smooth(idx_temp==0) = NaN;
        pitch_smooth(idx_temp==0) = NaN;
        
        % Pitch good until here
        
        % Normalize pitch and jerk section-by-section
        % Divide signal into continue sections to rescale
        cont_sections_jerk = regionprops(~isnan(jerk_smooth), jerk_smooth, 'PixelValues');
        cont_sections_surge = regionprops(~isnan(surge_smooth), surge_smooth, 'PixelValues');
        cont_sections_pitch = regionprops(~isnan(pitch_smooth), pitch_smooth, 'PixelValues');
        cont_sections_idx = regionprops(~isnan(jerk_smooth), jerk_smooth, 'PixelList');
        
        for i = 1:length(cont_sections_idx)
            % Assign jerk for this section to variables and indexes of section
            jerk_temp = cont_sections_jerk(i).PixelValues;
            surge_temp = cont_sections_surge(i).PixelValues;
            pitch_temp = cont_sections_pitch(i).PixelValues;
            
            temp_idx = cont_sections_idx(i).PixelList(:, 2);
            
            % Rescale the jerk in this section
            jerk_temp = rescale(jerk_temp);
            surge_temp = rescale(surge_temp);
            pitch_temp = rescale(pitch_temp);
            
            jerk_smooth(temp_idx) = jerk_temp;
            surge_smooth(temp_idx) = surge_temp;
            pitch_smooth(temp_idx) = pitch_temp;
        end
        
        %% Step 5h: Peak detection of movement signals
        
        % Add this path to make sure using the right ksdensity
        addpath('C:\Program Files\MATLAB\R2020a\toolbox\stats\stats')
        
        min_sec_apart = 3;
        
        %% %% Peak detection: Jerk
        
        % Plot jerk signal
        fig1 = figure('units','normalized','outerposition',[0 0 1 1]);
        ax(1) = subplot(3, 5, [1 2]);
        plot(time_min(start_idx:end_idx), jerk_smooth, 'k-'); grid; hold on;
        xlabel('Time (min)'); ylabel('Jerk SE Smooth'); ylim([0 1.2])
        
        % Peak detection
        [j_locs, j_width, j_prom, idx, rm_group] = detect_peaks(metadata.fs, jerk_smooth, 3, min_sec_apart);
        
        % Plot jerk peaks
        subplot(3, 5, [1 2]);
        scatter(time_min(j_locs+start_idx), jerk_smooth(j_locs), 'r*')
        
        %% %% Peak detection: Surge
        ax(2) = subplot(3, 5, [6 7]);
        plot(time_min(start_idx:end_idx), surge_smooth, 'k'); grid; hold on;
        xlabel('Time (min)'); ylabel('Surge SE Smooth'); ylim([0 1.2])
        
        % Peak detection
        [s_locs, s_width, s_prom, idx, rm_group] = detect_peaks(metadata.fs, surge_smooth, 8, min_sec_apart);
        
        % Plot surge peaks
        subplot(3, 5, [6 7]);
        scatter(time_min(s_locs+start_idx), surge_smooth(s_locs), 'b*')
        
        %% %% Peak detection: Pitch
        ax(3) = subplot(3, 5, [11 12]);
        plot(time_min(start_idx:end_idx), pitch_smooth, 'k'); grid; hold on;
        xlabel('Time (min)'); ylabel('Pitch SE Smooth');
        
        % Peak detection
        [p_locs, p_width, p_prom, idx, rm_group] = detect_peaks(metadata.fs, pitch_smooth, 13, min_sec_apart);
        
        % Plot surge peaks
        subplot(3, 5, [11 12]);
        scatter(time_min(p_locs+start_idx), pitch_smooth(p_locs), 'g*')
        
        %% Step 5i: Detect windows for breaths during logging periods
        
        % Identify 5 second windows around peaks
        win_sec = 5;
        
        j_wins = [];
        for a = 1:length(j_locs)
            j_temp_win = (j_locs(a)-floor((win_sec/2)*metadata.fs)):1:(j_locs(a)+ceil((win_sec/2)*metadata.fs));
            j_wins = [j_wins, j_temp_win];
        end
        
        s_wins = [];
        for b = 1:length(s_locs)
            s_temp_win = (s_locs(b)-floor((win_sec/2)*metadata.fs)):1:(s_locs(b)+ceil((win_sec/2)*metadata.fs));
            s_wins = [s_wins, s_temp_win];
        end
        
        p_wins = [];
        for c = 1:length(p_locs)
            p_temp_win = (p_locs(c)-floor((win_sec/2)*metadata.fs)):1:(p_locs(c)+ceil((win_sec/2)*metadata.fs));
            p_wins = [p_wins, p_temp_win];
        end
        
        % Identify where one window stops and the next starts
        if length(j_wins)>0
            j_wins_breaks = [j_wins(diff(j_wins)>1), j_wins(end)];
        end
        if length(s_wins)>0
            s_wins_breaks = [s_wins(diff(s_wins)>1), s_wins(end)];
        end
        if length(p_wins)>0
            p_wins_breaks = [p_wins(diff(p_wins)>1), p_wins(end)];
        end
        
        % Places where all three conditions are met
        [val3] = intersect(intersect(intersect(p_shallow_idx, p_wins), j_wins), s_wins);
        
        % Places where only two conditions are met
        [val2_js] = intersect(intersect(p_shallow_idx, j_wins), s_wins);
        [val2_jp] = intersect(intersect(p_shallow_idx, j_wins), p_wins);
        [val2_sp] = intersect(intersect(p_shallow_idx, s_wins), p_wins);
        
        diff_vals_js = setdiff(val2_js, val3);
        diff_vals_jp = setdiff(val2_jp, val3);
        diff_vals_sp = setdiff(val2_sp, val3);
        
        val3 = sort([val3; diff_vals_js; diff_vals_jp; diff_vals_sp]);
        
        % Find where there is a break in where these conditions are met
        temp_diff_break = find(diff(val3)>1);
        
        % Save ranges of continuous periods where conditions are met
        log_breath_locs = [];
        
        %% Step 5j: Detect breaths during logging periods
        
        % Go through continuous periods where conditions are met one by one
        if length(temp_diff_break)>0
            for c = 1:length(temp_diff_break)+1
                
                % If the first period...
                if c == 1
                    j_win_count = 0; s_win_count = 0; p_win_count = 0;
                    cont_val3_prev = -3*fs;
                    % Save the indexes of the continuous range that meets all three
                    % conditions
                    cont_range = [1:temp_diff_break(1)];
                    % If this period is greater than 1 second
                    if length(cont_range)>1*fs
                        % Save this range of indices
                        cont_val3 = val3(cont_range);
                    else
                        cont_val3 =  -3*fs;
                    end
                elseif c == length(temp_diff_break)+1 % If the last period...
                    % Assign last cont_val3 to this variable to compare later
                    cont_val3_prev = cont_val3;
                    cont_range = [(temp_diff_break(c-1)+1):length(val3)];
                    if length(cont_range)>1*fs
                        cont_val3 = val3(cont_range);
                    end
                elseif c > 1 && c < length(temp_diff_break)+1 % If a period between the first and last
                    % Assign last cont_val3 to this variable to compare later
                    cont_val3_prev = cont_val3;
                    cont_range = [(temp_diff_break(c-1)+1):temp_diff_break(c)];
                    if length(cont_range)>1*fs
                        cont_val3 = val3(cont_range);
                    end
                end
                
                % Filter out instances where a peak region of one signal overlaps
                % with two peak regions from another signal - only allow one of
                % these to be marked for breath ID
                % Find the indexes where this window overlaps with peak regions
                if length(cont_val3)>1*fs
                    cond = 0;
                    % Save the old window
                    j_win_count_prev = j_win_count;
                    % Find where this period intersects with the jerk windows
                    j_temp_int = intersect(cont_val3, j_wins);
                    % Find which window (count-wise) this period came from
                    if isempty(j_temp_int)==0
                        j_win_count = find(j_temp_int(end)<=j_wins_breaks, 1, 'first');
                        cond = 1;
                    end
                    
                    s_win_count_prev = s_win_count;
                    s_temp_int = intersect(cont_val3, s_wins);
                    if isempty(s_temp_int)==0
                        s_win_count = find(s_temp_int(end)<=s_wins_breaks, 1, 'first');
                        cond = 1;
                    end
                    
                    p_win_count_prev = p_win_count;
                    p_temp_int = intersect(cont_val3, p_wins);
                    if isempty(p_temp_int)==0
                        p_win_count = find(p_temp_int(end)<=p_wins_breaks, 1, 'first');
                        cond = 1;
                    end
                    
                    % If the same window as last time for any of these then keep first,
                    % skip second instance
                    if length(cont_range)>1*fs && (j_win_count>j_win_count_prev && s_win_count>s_win_count_prev && p_win_count>p_win_count_prev || cond == 1)
                        if cont_val3(1)>cont_val3_prev(length(cont_val3_prev))+fs/10 || max(p_smooth_tag(cont_val3_prev))>0.5 || max(p_smooth_tag(cont_val3))>0.5 %If the first value of the range is less than 150 indices away from the last value of the last range...
                            % Mark breath at halfway point of each period
                            log_breath_locs = [log_breath_locs; cont_val3(floor(length(cont_val3)/2))];
                        end
                    end
                end
            end
        end
        
        % If a breath detection from a single surfacing is closer than 3 seconds
        % (e.g. 20 breaths/min) to a breath detection from
        % logging, then the ss breath trumps and we remove the logging breath
        temp_all_breaths= [all_breath_locs.breath_idx; log_breath_locs];
        temp_all_breaths_type = [repmat("ss", length(all_breath_locs.breath_idx), 1); repmat("log", length(log_breath_locs), 1)];
        
        [temp_all_breaths_s, sortidx] = sort(temp_all_breaths);
        temp_all_breaths_type_s = temp_all_breaths_type(sortidx, :);
        
        sim_breaths = find(diff(temp_all_breaths_s)<3*fs);
        rm_rows = [];
        if isempty(sim_breaths) == 0
            for i = 1:length(sim_breaths)
                temp_row = find(temp_all_breaths_type_s(sim_breaths(i):sim_breaths(i)+1) == "log");
                rm_rows = [rm_rows; sim_breaths(i)+temp_row-1];
            end
        end
        
        temp_all_breaths_s(rm_rows, :) = [];
        temp_all_breaths_type_s(rm_rows, :) = [];
        
        % Changing these to be in full range of "p"
        all_breath_locs.breath_idx = temp_all_breaths_s + start_idx;
        all_breath_locs.type = temp_all_breaths_type_s;
        
        %% Step 5k: Plot breath detections for logging periods
        
        ax(4) = subplot(3, 5, [4, 5, 9, 10, 14, 15]);
        p1 = plot(time_min(start_idx:end_idx), p_smooth_tag, 'k');
        set(gca, 'ydir', 'reverse')
        hold on
        p_smooth_p2 = p_smooth_tag;
        idx_temp = ismember(1:numel(p_smooth_p2),val3); % idx is logical indices
        p_smooth_p2(~idx_temp) = NaN;
        p2 = plot(time_min(start_idx:end_idx), p_smooth_p2, 'm-', 'LineWidth', 2);
        p3 = scatter(time_min(start_idx+log_breath_locs-1), p_smooth_tag(log_breath_locs), 80, 'k*', 'LineWidth', 1);
        title('Breath IDs during logging')
        ylabel('Depth (m)'); xlabel('Time (min)');
        
        legend([p1 p2, p3],{'Dive depth' , 'Breath IDs - all three conditions', 'Breaths'}, 'Location', 'south')%, 'Breath IDs - surge jerk + pitch'}, 'Location', 'best')
        
        linkaxes(ax, 'x')
        
        % Save figure
        figfile = strcat(dataPath, '/figs/', metadata.tag, '_loggingdetections.fig');
        if isfile(figfile) == 1
            txt = input("A figure with this name already exists - do you want to append a custom suffix? (y/n) \n","s");
            if strcmp(txt, "y") == 1
                txt = input("What suffix? do you want to append (e.g. _examplesection) \n","s");
                savefig(strcat(dataPath, '/figs/', metadata.tag, '_loggingdetections', txt, '.fig'));
            else
                savefig(figfile);
            end
        end
        
        %% Step 5l: Write breaths to audit
        
        % Write to mat file
        save(strcat(dataPath, "\breaths\", metadata.tag, "breaths"), 'tag', 'p_tag', 'p_smooth', 'p_smooth_tag', 'start_idx', 'end_idx', 'all_breath_locs', 'logging_ints_s', 'fs');
        
        % Write to text file
        if strcmp(metadata.tag_ver, "CATS") == 1
            date = datetime(DN, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
            breath_datetime = date(all_breath_locs.breath_idx);
            writematrix(breath_datetime, strcat(dataPath, '/breaths/', INFO.whaleName, 'breaths.txt'),'Delimiter',',')
        else
            breaths = all_breath_locs.breath_idx;
            writematrix(breaths, strcat(dataPath, '/breaths/', metadata.tag, 'breaths.txt'),'Delimiter',',')
        end
        
        clearvars -except taglist tools_path mat_tools_path dataPath; clc; close all
        
    end 
    
end