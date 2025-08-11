function [p1, p2, p3, p4, p5] = plot_surfs(time_min, p_smooth_tag, start_idx, end_idx, ...
        p_shallow_idx, p_shallow_ints, p_shallow, ...
        logging_surf_rows, single_breath_surf_rows, metadata)
    arguments
        time_min (1, :) double                             % Time vector in minutes (row vector)
        p_smooth_tag (:, 1) double                         % Smoothed depth data
        start_idx (1, 1) double {mustBeInteger, mustBePositive}  % Start index for plotting
        end_idx (1, 1) double {mustBeInteger, mustBePositive}    % End index for plotting
        p_shallow_idx (:, 1) double {mustBeInteger}        % Indices of shallow depth points
        p_shallow_ints (:, 4) double                       % Matrix of shallow interval start/end indices and metrics
        p_shallow (:, 1) double                            % Vector with shallow depths (NaNs elsewhere)
        logging_surf_rows (:, 1) double {mustBeInteger}    % Row indices in `p_shallow_ints` marking logging surfacings
        single_breath_surf_rows (:, 1) double {mustBeInteger} % Row indices in `p_shallow_ints` marking single-breath surfacings
        metadata (1, 1) struct                             % Metadata struct containing tag info
    end
    
    % PLOTS_SURFS Visualizes shallow surfacing intervals on a smoothed depth trace.
    %
    % This function generates a figure showing smoothed depth data and overlays
    % two types of surfacing events (logging and single-breath) along with their
    % start and end points.
    %
    % Inputs:
    %   time_min                - Time vector in minutes
    %   p_smooth_tag            - Smoothed depth signal
    %   start_idx               - Start index for plotting window
    %   end_idx                 - End index for plotting window
    %   p_shallow_idx           - Indices where the animal was considered shallow
    %   p_shallow_ints          - Nx4 matrix of shallow interval information
    %   p_shallow               - Depth signal with NaNs outside shallow intervals
    %   logging_surf_rows       - Indices of logging surfacing rows in `p_shallow_ints`
    %   single_breath_surf_rows - Indices of single-breath surfacing rows in `p_shallow_ints`
    %   metadata                - Struct with tag metadata (e.g., metadata.tag for title)
    %
    % Outputs:
    %   p1 - Line object for smoothed depth plot
    %   p2 - Line object for logging surfacings (magenta)
    %   p3 - Line object for single-breath surfacings (cyan)
    %   p4 - Marker object for surfacing start points (green asterisks)
    %   p5 - Marker object for surfacing end points (red asterisks)
    %
    % Usage:
    %   [p1, p2, p3, p4, p5] = plot_surfs(time_min, p_smooth_tag, start_idx, end_idx, ...
    %       p_shallow_idx, p_shallow_ints, p_shallow, ...
    %       logging_surf_rows, single_breath_surf_rows, metadata)
    %
    % Notes:
    %   - This function is purely for visualization and does not return any data
    %     beyond figure handle outputs.
    %   - Assumes p_shallow_ints contains valid intervals with start/end indices.
    %
    % Author: Ashley Blawas
    % Last Updated: 8/11/2025
    % Stanford University
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    % Plot main smoothed depth trace
    p1 = plot(time_min(start_idx:end_idx), p_smooth_tag, 'k', 'LineWidth', 1); hold on;
    set(gca, 'YDir', 'reverse');
    xlabel('Time (min)'); ylabel('Depth (m)'); title(metadata.tag, 'Interpreter', 'none')
    
    % Plot logging surfacings (magenta)
    if ~isempty(logging_surf_rows)
        for r = 1:length(logging_surf_rows)
            idx1 = p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 1));
            idx2 = p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 2));
            t_range = time_min(start_idx + idx1 - 1 : start_idx + idx2 - 1);
            p_range = p_shallow(idx1:idx2);
            p2 = plot(t_range, p_range, 'm-', 'LineWidth', 2);
        end
    else
        p2 = plot(NaN, NaN, 'm-', 'LineWidth', 2); % dummy for legend
    end
    
    % Plot single breath surfacings (cyan)
    if ~isempty(single_breath_surf_rows)
        for r = 1:length(single_breath_surf_rows)
            idx1 = p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1));
            idx2 = p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2));
            t_range = time_min(start_idx + idx1 - 1 : start_idx + idx2 - 1);
            p_range = p_shallow(idx1:idx2);
            p3 = plot(t_range, p_range, 'c-', 'LineWidth', 2);
        end
    else
        p3 = plot(NaN, NaN, 'c-', 'LineWidth', 2);
    end
    
    % Plot surfacing start and end markers
    start_times = time_min(start_idx + p_shallow_idx(p_shallow_ints(:, 1)) - 1);
    end_times = time_min(start_idx + p_shallow_idx(p_shallow_ints(:, 2)) - 1);
    start_depths = p_shallow(p_shallow_idx(p_shallow_ints(:, 1)));
    end_depths = p_shallow(p_shallow_idx(p_shallow_ints(:, 2)));
    
    p4 = plot(start_times, start_depths, 'g*');
    p5 = plot(end_times, end_depths, 'r*');
