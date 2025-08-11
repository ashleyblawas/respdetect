function [locs, width, prom, idx, rm_group] = detect_peaks(fs, move_sig, val, min_sec_apart)
    arguments
        fs (1,1) double {mustBePositive, mustBeFinite}                     % Sampling rate in Hz
        move_sig (:,1) double {mustBeNonempty, mustBeFinite}              % Movement signal (e.g., jerk or surge entropy)
        val (1,1) double {mustBeInteger, mustBePositive}                  % Plot index value for subplot
        min_sec_apart (1,1) double {mustBePositive, mustBeFinite}         % Minimum seconds between peaks
    end
    % DETECT_PEAKS Identifies and filters peaks from a movement signal based on spacing and shape.
    %
    %   This function detects peaks in a movement signal (e.g., jerk, surge, or pitch)
    %   that are separated by at least `min_sec_apart` seconds, then filters them using
    %   a shape-based clustering or heuristic method depending on the distribution.
    %   It optionally visualizes peak characteristics for interpretation.
    %
    %   Inputs:
    %     fs             - Sampling frequency (Hz)
    %     move_sig       - Input movement signal (e.g., jerk or pitch time series)
    %     val            - Integer subplot index for visualization (1–15)
    %     min_sec_apart  - Minimum allowable time between peaks (in seconds)
    %
    %   Outputs:
    %     locs       - Indices of accepted peak locations in the signal
    %     width      - Normalized widths of detected peaks
    %     prom       - Normalized prominences of detected peaks
    %     idx        - Cluster or group labels for each peak (1 or 2)
    %     rm_group   - Identifier of the removed group (1 or 2), based on width comparison
    %
    %   Methodology:
    %     - Uses `findpeaks()` to detect local maxima spaced by at least `min_sec_apart`
    %     - Normalizes peak height, width, and prominence to range [0, 1]
    %     - If multiple peaks exist:
    %         Attempts to separate meaningful vs. noisy peaks using:
    %             - Heuristic method via kernel density estimate (KDE), or
    %             - Agglomerative clustering (`linkage` + `cluster`)
    %         Removes the group with smaller average peak widths
    %     - If only one peak or no peaks are found, returns empty outputs
    %
    %   Notes:
    %     - Produces diagnostic plots for visual validation using `subplot(3, 5, val)`
    %     - Requires the Statistics and Machine Learning Toolbox (for `linkage`, `cluster`)
    %
    %   Example:
    %     [locs, width, prom] = detect_peaks(50, jerk_signal, 3, 2);
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
    
    % Peak detect jerk, defining here that the max breath rate is 20 breaths/min
    % given 3 second separation
    [height, locs, width, prom] = findpeaks(move_sig, 'MinPeakDistance', min_sec_apart*fs);
    fprintf('Detecting peaks at least %0.1f seconds apart...\n', min_sec_apart);
    
    % Rescale to between (0, 1)
    height = rescale(height); width = rescale(width); prom = rescale(prom);
    
    if length(locs)>1
        % Calculate distance for max peaks
        dist = sqrt((max(height)-height).^2 + (max(width)-width).^2 + (max(prom)-prom).^2);
        [f_d,xi_d] = ksdensity(dist);
        [pks_heights, pks_locs] = findpeaks(f_d, xi_d, 'MinPeakProminence', 0.2);
        if length(pks_locs)>1
            mins = xi_d(find(islocalmin(f_d,2)>0));
            thres_d = max(mins(mins > pks_locs(1) & mins < pks_locs(2)));
        else
            thres_d =[];
        end
        % If there is not a clear multimodal distribution, use clustering
        % instead
        if isempty(thres_d) == 1
            display('Using clustering peak finding method...');
            type = "c";
            X = [width, prom];
            Z = linkage(X, 'ward');
            idx = cluster(Z,'MAXCLUST', 2);
            g1_mean = mean(X(idx==1), 1); g2_mean = mean(X(idx==2), 1);
        else
            display('Using heuristic peak finding method...');
            type = "h";
            idx = [dist<thres_d];
            idx = double(idx); idx(idx==0)=2;
            g1_mean = mean(width(idx==1)); g2_mean = mean(width(idx==2));
        end
        
        % Remove peaks that are in small group
        rm_idx = [];
        if length(height)>0
            % Remove the group that has smaller widths
            rm_group = (find(min([g1_mean, g2_mean]) == [g1_mean, g2_mean]));
            for c = 1:length(locs)
                if idx(c) == rm_group
                    rm_idx = [rm_idx, c];
                end
            end
            locs(rm_idx) = [];
        end
        
        % Plotting
        if type == "c"
            subplot(3, 5, val)
            plot(width(idx==rm_group), prom(idx==rm_group), '.', 'MarkerSize', 12, 'Color', [0.7 0.7 0.7])
            hold on
            plot(width(idx~=rm_group), prom(idx~=rm_group), 'k.', 'MarkerSize', 12)
            xlabel('Peak Width'); ylabel('Peak Prominence');
        elseif type == "h"
            subplot(3, 5, val)
            plot(xi_d, f_d); xline(thres_d, '--');
            xlabel('Distance'); ylabel('Density');
        end
        
    else
        locs = [];
        width = [];
        prom = [];
        idx = [];
        rm_group = [];
    end
    
