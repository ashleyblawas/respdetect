function [] = plot_maxmeanminfR(dive_dur, si_fR, breath_idx, surf_breath_count, c)
    figure;
    
    if iscell(dive_dur) ==1
        for k = 1:length(dive_dur)
            max_fR{k} = []; mean_fR{k} = []; min_fR{k} = []; dive_dur_mat{k} = []; breath_num_mat{k} = [];
            for i = 1:length(dive_dur{k})-1
                dive_dur_mat{k}= [dive_dur_mat{k}; dive_dur{k}(i)];
                breath_num_mat{k} = [breath_num_mat{k}; surf_breath_count{k}(i)];
                if i < length(dive_dur{k})-1
                    max_fR{k} =    [max_fR{k};  max(si_fR{k}{i})];
                    mean_fR{k} =   [mean_fR{k}; mean(si_fR{k}{i})];
                    min_fR{k} =    [min_fR{k};  min(si_fR{k}{i})];
                elseif i == length(dive_dur{k})-1
                    max_fR{k} =    [max_fR{k}; max(si_fR{k}{i})];
                    mean_fR{k} =   [mean_fR{k}; mean(si_fR{k}{i})];
                    min_fR{k} =    [min_fR{k}; min(si_fR{k}{i})];
                end
            end
        end
    else
        max_fR = []; mean_fR = []; min_fR = []; dive_dur_mat = []; breath_num_mat = [];
        for i = 1:length(dive_dur)-1
            dive_dur_mat = [dive_dur_mat; dive_dur(i)];
            breath_num_mat = [breath_num_mat; surf_breath_count(i)];
            if i < length(dive_dur)-1
                max_fR =    [max_fR;  max(si_fR(breath_idx(i):breath_idx(i+1)-1))];
                mean_fR =   [mean_fR; mean(si_fR(breath_idx(i):breath_idx(i+1)-1))];
                min_fR =    [min_fR;  min(si_fR(breath_idx(i):breath_idx(i+1)-1))];
            elseif i == length(dive_dur)-1
                max_fR =    [max_fR; max(si_fR(breath_idx(i):end))];
                mean_fR =   [mean_fR; mean(si_fR(breath_idx(i):end))];
                min_fR =    [min_fR; min(si_fR(breath_idx(i):end))];
            end
        end
    end
    
    
    if iscell(dive_dur) == 1
        for k = 1:length(dive_dur)
            subplot(221)
            scatter(dive_dur_mat{k}, max_fR{k}, 24, c(k, :), 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
            xlabel('Dive Duration(min)'); ylabel('Maximum {\it f}_R (breaths min^{-1})');
            axis square; box on;
            subplot(222)
            scatter(dive_dur_mat{k}, mean_fR{k}, 24, c(k, :), 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
            xlabel('Dive Duration(min)'); ylabel('Mean {\it f}_R (breaths min^{-1})');
            axis square; box on;
            subplot(223)
            scatter(dive_dur_mat{k}, min_fR{k}, 24, c(k, :), 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
            xlabel('Dive Duration(min)'); ylabel('Minimum {\it f}_R (breaths min^{-1})');
            axis square; box on;
            subplot(224)
            scatter(dive_dur_mat{k}, breath_num_mat{k}, 24, c(k, :), 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
            xlabel('Dive Duration(min)'); ylabel('Post-dive # of breaths');
            axis square; box on;
        end
    else
        subplot(221)
        scatter(dive_dur_mat, max_fR, 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
        xlabel('Dive Duration(min)'); ylabel('Maximum {\it f}_R (breaths min^{-1})');
        axis square; box on;
        subplot(222)
        scatter(dive_dur_mat, mean_fR, 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
        xlabel('Dive Duration(min)'); ylabel('Mean {\it f}_R (breaths min^{-1})');
        axis square; box on;
        subplot(223)
        scatter(dive_dur_mat, min_fR, 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
        xlabel('Dive Duration(min)'); ylabel('Minimum {\it f}_R (breaths min^{-1})');
        axis square; box on;
        subplot(224)
        scatter(dive_dur_mat, breath_num_mat, 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5); hold on;
        xlabel('Dive Duration(min)'); ylabel('Post-dive # of breaths');
        axis square; box on;
    end
end

