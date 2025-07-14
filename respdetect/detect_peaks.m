%% Find peaks in movement data for breath detections

function [locs, width, prom, idx, rm_group] = detect_peaks(fs, move_sig, val, min_sec_apart)
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
    
