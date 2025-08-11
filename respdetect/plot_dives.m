function plot_dives(T, time_sec, p)
    arguments
        T (:, 3) double           % Dive matrix with 3 columns: [start, end, max depth]
        time_sec (1, :) double    % Time vector (row vector)
        p (:, 1) double           % Depth vector (column vector)
    end
    % PLOT_DIVES Visualizes dive events and summary dive metrics.
    %
    %   This function plots dive start and end times on the full depth record,
    %   along with summary metrics including dive durations and maximum depths.
    %   It provides a quick overview of dive structure and surfacing behavior.
    %
    %   Inputs:
    %     T         - [Nx3] matrix of dive events where:
    %                   Column 1 = dive start time (in seconds)
    %                   Column 2 = dive end time (in seconds)
    %                   Column 3 = maximum depth of the dive (in meters)
    %
    %     time_sec  - Time vector (in seconds), corresponding to each sample of the
    %                 depth data `p`
    %
    %     p         - Depth vector (in meters), same length as `time_sec`
    %
    %   Outputs:
    %     None (Generates a figure for visual inspection)
    %
    %   Function Behavior:
    %     - Computes dive duration (`end - start`) for each dive
    %     - Computes surfacing durations between dives
    %     - Plots:
    %         Full time-depth profile with dive start/end markers
    %         Scatter plot of dive durations across the record
    %         Scatter plot of dive maximum depths
    %
    %   Assumptions:
    %     - Dive events in `T` are extracted using a prior dive classification function
    %     - The vectors `time_sec` and `p` are aligned and evenly sampled
    %     - All time inputs are in seconds
    %
    %   Usage:
    %     plot_dives(T, time_sec, p)
    %
    %   Example:
    %     % Load a dive matrix and plot the dives:
    %     load('diving/gm01_001a_dives.mat');  % Loads variable `T`
    %     load('prh/gm01_001a.mat', 'p', 'time_sec');
    %     plot_dives(T, time_sec, p);
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    n_dives = size(T, 1);  % Number of dive rows
    
    % Preallocate
    dive_durs = zeros(n_dives, 1);       % One duration per dive
    surf_durs = zeros(n_dives - 1, 1);   % One surface duration between dives
    
    % Compute dive durations
    for k = 1:n_dives
        dive_durs(k) = T(k, 2) - T(k, 1);
    end
    
    % Compute surface durations
    for k = 1:(n_dives - 1)
        surf_durs(k) = T(k + 1, 1) - T(k, 2);
    end
    
    figure
    subplot(2, 3, [1 2 4 5])
    plot(time_sec, p); hold on
    plot(T(:, 1), zeros(length(T(:, 1)), 1), 'g*');
    plot(T(:, 2), zeros(length(T(:, 2)), 1), 'r*');
    set(gca, 'ydir', 'reverse')
    xlabel('Time (s)'); ylabel('Depth (m)');
    legend('Depth', 'Start of dive', 'End of dive');
    
    % Plot summary dive metrics
    subplot(2, 3, 3)
    for k = 1:length(T(:, 1))
        scatter(k, dive_durs(k)./60, 20,'k'); hold on
    end
    ylabel('Dive Duration (min)'); box on;
    box on; axis square
    
    subplot(2, 3, 6)
    for k = 1:length(T(:, 1))
        scatter(k, T(k, 3), 20, 'k'); hold on
    end
    xlabel('Dive Number'); ylabel('Dive Depth (m)');
    set(gca, 'ydir', 'reverse');
    box on; axis square
end