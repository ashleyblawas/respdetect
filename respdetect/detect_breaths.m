function detect_breaths(taglist, dataPath, n_sec, min_sec_apart, win_sec)
    arguments
        taglist (1, :) cell
        dataPath (1,:) char
        n_sec (1, 1) double
        min_sec_apart (1, 1) double
        win_sec (1, 1) double
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
        
        % Load in metadata, movement, and diving data
        load(strcat(dataPath, speciesCode, "\metadata\", tag, "md")); clear tag;
        load(strcat(dataPath, speciesCode, "\movement\", metadata.tag, "movement.mat"));
        load(strcat(dataPath, speciesCode, "\diving\", metadata.tag, "dives.mat"));
        load(strcat(dataPath, speciesCode, "\diving\", metadata.tag, "divetable.mat"));
              
        %Set path for prh files
        settagpath('prh',strcat(dataPath, speciesCode, '\prh'));
        
        % Load the existing prh file
        loadprh(metadata.tag);
        
        % Calculate time variables for full tag deployment
        [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
        
        %% Step 5b: Subset deployment to tag on time only
        
        [p_tag, start_idx, end_idx] = subset_p(metadata, p, time_sec);
        
        %% Step 5c: Identify surface periods & classify them
        
        [p_shallow_ints, p_shallow_idx, p_shallow, p_smooth_tag] = get_shallowints(metadata, p, p_tag);
        
        % If these periods are less than 10 seconds then we say they are a "single
        % breath surfacing" otherwise they are a "logging surfacings"
        [single_breath_surf_rows, logging_surf_rows, logging_start_idxs, logging_end_idxs, logging_ints_s, p_shallow_ints, all_breath_locs] = ...
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
        figfile = strcat(dataPath, metadata.tag(1:2) , '/figs/', metadata.tag, '_surfacedetections.fig');
        savefig(figfile);
        
        %% Step 5g: Pre-process movement data for logging period breath detections
        
        [jerk_smooth, surge_smooth, pitch_smooth] = ...
            process_move(jerk_smooth, surge_smooth, pitch_smooth, p, p_smooth_tag, ...
            start_idx, end_idx, logging_start_idxs, logging_end_idxs, metadata);
    
        %% Step 5h: Peak detection of movement signals
       
        set_ksdensity();
        
        %% Peak detection: Jerk
        
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
        
        %  Generate overlapping event windows for jerk, surge, and pitch.
        [val3, temp_diff_break,...
            j_wins, s_wins, p_wins,...
            j_wins_breaks, s_wins_breaks, p_wins_breaks] = ...
            get_windows(j_locs, s_locs, p_locs, p_shallow_idx, win_sec, metadata.fs);
        
        %% Step 5j: Detect breaths during logging periods
        
        [all_breath_locs] = get_logbreaths( ...
            val3, temp_diff_break, j_wins, s_wins, p_wins, ...
            j_wins_breaks, s_wins_breaks, p_wins_breaks, ...
            p_smooth_tag, metadata.fs, start_idx, all_breath_locs);
        
        %% Step 5k: Plot breath detections for logging periods
        
        ax(4) = subplot(3, 5, [4, 5, 9, 10, 14, 15]);
        p1 = plot(time_min(start_idx:end_idx), p_smooth_tag, 'k');
        set(gca, 'ydir', 'reverse')
        hold on
        p_smooth_p2 = p_smooth_tag;
        idx_temp = ismember(1:numel(p_smooth_p2),val3); % idx is logical indices
        p_smooth_p2(~idx_temp) = NaN;
        p2 = plot(time_min(start_idx:end_idx), p_smooth_p2, 'm-', 'LineWidth', 2);
        p3 = scatter(time_min(all_breath_locs.breath_idx(all_breath_locs.type == "log")-1), p_smooth_tag(all_breath_locs.breath_idx(all_breath_locs.type == "log")-start_idx), 80, 'k*', 'LineWidth', 1);
        title('Breath IDs during logging')
        ylabel('Depth (m)'); xlabel('Time (min)'); ylim([-5, max(p_smooth_tag)]);
        
        legend([p1 p2, p3],{'Dive depth' , 'Breath IDs - all three conditions', 'Breaths'}, 'Location', 'south')%, 'Breath IDs - surge jerk + pitch'}, 'Location', 'best')
        
        linkaxes(ax, 'x')
        
        save_fig(dataPath, speciesCode, metadata, 'loggingdetections')
    
        %% Step 5l: Write breaths to audit
        
        fs = metadata.fs;
        
        % Write to mat file
        save(strcat(dataPath, speciesCode, "\breaths\", metadata.tag, "breaths"), 'tag', 'p_tag','p_smooth_tag', 'start_idx', 'end_idx', 'all_breath_locs', 'logging_ints_s', 'fs');
        
        % Write to text file
        if strcmp(metadata.tag_ver, "CATS") == 1
            date = datetime(DN, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
            breath_datetime = date(all_breath_locs.breath_idx);
            writematrix(breath_datetime, strcat(dataPath, speciesCode, '/breaths/', INFO.whaleName, 'breaths.txt'),'Delimiter',',')
        else
            breaths = all_breath_locs.breath_idx;
            writematrix(breaths, strcat(dataPath, speciesCode, '/breaths/', metadata.tag, 'breaths.txt'),'Delimiter',',')
        end
                
    end 
    
end