function [p1, p2, p3, p4, p5] = plot_surfs(time_min, p_tag,  p_smooth_tag, start_idx, end_idx, ...
        p_shallow_idx, p_shallow_ints, p_shallow, ...
        logging_surf_rows, single_breath_surf_rows, metadata)
    arguments
        time_min (1, :) double
        p_tag (:, 1) double
        p_smooth_tag (:, 1) double
        start_idx (1, 1) double
        end_idx (1, 1) double
        p_shallow_idx (:, 1) double
        p_shallow_ints (:, 4) double
        p_shallow (:, 1) double
        logging_surf_rows (:, 1) double
        single_breath_surf_rows (:, 1) double
        metadata (1, 1) struct
    end
    % Plots surfacings of the two different types
    %
    % Inputs:
    %
    % Outputs:
    %   p1 - main depth plot
    %   p2 - logging surfacings
    %   p3 - single-breath surfacings
    %   p4 - surfacing start markers
    %   p5 - surfacing end markers
    %
    % Usage:
    %   [p1, p2, p3, p4, p5] = plot_surfs(time_min, p_tag, start_idx, end_idx, ...
    %    p_shallow_idx, p_shallow_ints, p_shallow, ...
    %    logging_surf_rows, single_breath_surf_rows)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
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
