%% Find peaks in movement data for breath detections

function [locs, width, prom, idx, rm_group] = detect_peaks(fs, move_sig)
    % Peak detect jerk, defining here that the max breath rate is 20 breaths/min
    % given 3 second separation
    [height, locs, width, prom] = findpeaks(move_sig, 'MinPeakDistance', 3*fs);
    
    % Rescale to between (0, 1)
    height = rescale(height); width = rescale(width); prom = rescale(prom);
    
    if length(locs)>1
        % Calculate distance for max peaks
        dist = sqrt((max(height)-height).^2 + (max(width)-width).^2 + (max(prom)-prom).^2);
        [f_d,xi_d] = ksdensity(dist);
        thres_d = max(xi_d(find(islocalmin(f_d,2)>0)));
        % If there is not a clear multimodal distribution, use clustering
        % instead
        if isempty(thres_d) == 1
            X = [width', prom'];
            Z = linkage(X, 'ward');
            idx = cluster(Z,'MAXCLUST', 2);
            g1_mean = mean(X(idx==1), 1); g2_mean = mean(X(idx==2), 1);
        % Otherwise label groups of points that are on both sides of
        % distribution
        else
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
end
