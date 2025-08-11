function [fR] = plot_breaths(dataPath, taglist, k)
    arguments
        dataPath (1,:) char
        taglist (1, :) cell
        k (1, 1) double {mustBePositive}
    end
    % PLOT_BREATHS Loads and visualizes breath detections and depth profile.
    %
    %   This function loads pre-processed data for a selected tag and plots both
    %   the continuous instantaneous respiration rate (`fR`) and the associated
    %   dive profile. Breath detections are overlaid for visual inspection of
    %   surfacing and breathing patterns.
    %
    %   Inputs:
    %     dataPath - Base path to data (character array). Should point to the root
    %                directory containing species folders (e.g., 'gm', 'tt', etc.)
    %
    %     taglist  - Cell array of tag names (e.g., {'gm01_001a', 'gm02_004b'})
    %
    %     k        - Index of the tag in taglist to process. This allows looping
    %                over multiple tags or selecting one at a time (e.g., `taglist{k}`).
    %
    %   Outputs:
    %     fR       - Instantaneous respiration rate (breaths per minute)
    %                Computed from breath timestamps using `get_contfR.m`.
    %
    %   Function Behavior:
    %     - Loads required data files:
    %         PRH data (e.g., Aw, pitch, roll, head, p)
    %         Metadata (e.g., fs, tag date)
    %         Breath detections (from surfacing classification)
    %
    %     - Calculates continuous respiration rate (`fR`) from breath times
    %
    %     - Plots:
    %         Instantaneous respiration rate over time (stairs plot)
    %         Depth profile with time-aligned breath events
    %
    %   Assumptions:
    %     - Tag data have been pre-processed using:
    %         `make_metadata`, `make_move`, `make_dives`, and `classify_surfs`
    %     - Files are organized in the standard folder structure under `dataPath`
    %     - Breath detections are stored in a file with the suffix `_breaths.mat`
    %
    %   Usage:
    %     [fR] = plot_breaths(dataPath, taglist, 1);
    %
    %   Example:
    %     taglist = {'gm01_001a', 'gm01_002a'};
    %     dataPath = 'D:\whaledata\';
    %     k = 1;
    %     fR = plot_breaths(dataPath, taglist, k);
    %
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    %% Load Data
    tag = taglist{k};
    speciesCode = tag(1:2);
    
    metadata = load(fullfile(dataPath, speciesCode, 'metadata', [tag, 'md']));
    metadata = metadata.metadata; % if stored in struct
    
    settagpath('prh', fullfile(dataPath, speciesCode, 'prh'));
    loadprh(metadata.tag);
    
    % Load movement data
    move_file = fullfile(dataPath, speciesCode, 'movement', [metadata.tag, 'movement.mat']);
    load(move_file, 'jerk_smooth', 'surge_smooth', 'pitch_smooth');
    
    % Load breath detection data
    breath_file = fullfile(dataPath, speciesCode, 'breaths', [metadata.tag, 'breaths.mat']);
    load(breath_file, 'all_breath_locs');
    
    % Recalculate time
    [time_sec, time_min, ~] = calc_time(metadata.fs, pitch);
    
    breath_idx = all_breath_locs.breath_idx;
    
    % Determine x-axis values
    if strcmp(metadata.tag_ver, "CATS")
        breath_times = datetime(DN(breath_idx), 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
        xval = datetime(DN, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    else
        breath_times = time_min(breath_idx);
        xval = time_min;
    end
    
    [breath_times, sortidx] = sort(breath_times);
    breath_type = all_breath_locs.type(sortidx, :);
    breath_idx = breath_idx(sortidx);
    
    %% Filter signals to tag-on/off
    start_idx = find(abs(time_sec - metadata.tag_on) == min(abs(time_sec - metadata.tag_on)), 1);
    end_idx = find(abs(time_sec - metadata.tag_off) == min(abs(time_sec - metadata.tag_off)), 1);
    
    p(start_idx:end_idx) = p(start_idx:end_idx);
    p([1:start_idx-1, end_idx+1:end]) = NaN;
    
    jerk_smooth([1:start_idx-1, end_idx+1:end]) = NaN;
    surge_smooth([1:start_idx-1, end_idx+1:end]) = NaN;
    pitch_smooth([1:start_idx-1, end_idx+1:end]) = NaN;
    
    %% Plot signals with breath annotations
    figure;
    
    ax(1) = subplot(4, 1, 1);
    plot(xval, p, 'k', 'LineWidth', 1.5); hold on
    set(gca, 'YDir', 'reverse');
    ylabel('Depth (m)'); title(metadata.tag, 'Interpreter', 'none');
    scatter(breath_times(breath_type == "ss"), p(breath_idx(breath_type == "ss")), ...
        60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    scatter(breath_times(breath_type == "log"), p(breath_idx(breath_type == "log")), ...
        60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    legend('Depth', 'Single surface breaths', 'Log breaths');
    
    ax(2) = subplot(4, 1, 2);
    plot(xval, surge_smooth, 'r', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == "ss"), surge_smooth(breath_idx(breath_type == "ss")), ...
        60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    scatter(breath_times(breath_type == "log"), surge_smooth(breath_idx(breath_type == "log")), ...
        60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    ylabel('Smoothed Surge SE');
    
    ax(3) = subplot(4, 1, 3);
    plot(xval, jerk_smooth, 'b', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == "ss"), jerk_smooth(breath_idx(breath_type == "ss")), ...
        60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    scatter(breath_times(breath_type == "log"), jerk_smooth(breath_idx(breath_type == "log")), ...
        60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    ylabel('Smoothed Jerk SE');
    
    ax(4) = subplot(4, 1, 4);
    plot(xval, pitch_smooth, 'g', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == "ss"), pitch_smooth(breath_idx(breath_type == "ss")), ...
        60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    scatter(breath_times(breath_type == "log"), pitch_smooth(breath_idx(breath_type == "log")), ...
        60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);
    ylabel('Smoothed Pitch SE');
    xlabel('Time');
    linkaxes(ax, 'x');
    
    save_fig(dataPath, speciesCode, metadata, 'allbreaths');
    
    %% Plot respiration rate
    fR = get_contfR(breath_times, p, xval, metadata);
    save_fig(dataPath, speciesCode, metadata, 'resprate');
    
end
