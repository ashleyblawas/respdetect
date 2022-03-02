function [] = plot_bynum(dive_dur, surf_dur, dive_thres)
    fig = figure;
    if iscell(dive_dur)
        for k = 1:length(dive_dur)
            subplot(ceil(length(dive_dur)/5), ceil(length(dive_dur)/(ceil(length(dive_dur)/5))), k)
            scatter(dive_dur{k}(1:end-1), 1:length(surf_dur{k})-1, 24, 'k','filled', 'MarkerFaceAlpha', 0.5); hold on; box on;
            y_lim = get(gca, 'ylim');
            area([0 dive_thres], [y_lim(2) y_lim(2)], 'edgecolor', 'none', 'facealpha', 0.3);
            xlim([0 max(cell2mat(dive_dur'))])
        end
    else
        scatter(dive_dur(1:end-1), 1:length(surf_dur)-1, 24, 'k','filled', 'MarkerFaceAlpha', 0.5); hold on; box on;
        y_lim = get(gca, 'ylim');
        area([0 dive_thres], [y_lim(2) y_lim(2)], 'edgecolor', 'none', 'facealpha', 0.3);
        xlim([0 max(dive_dur)])
    end
    
    % Give common xlabel, ylabel
    han=axes(fig,'visible','off');
    han.XLabel.Visible='on';
    han.YLabel.Visible='on';
    ylabel(han,'Dive Number');
    xlabel(han,'Dive Duration (min)');

%% Plot post dive surface interval duration
fig = figure;
if iscell(dive_dur)
    for k = 1:length(dive_dur)
        subplot(ceil(length(dive_dur)/5), ceil(length(dive_dur)/(ceil(length(dive_dur)/5))), k)
        scatter(surf_dur{k}(:), 1:length(surf_dur{k}), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5); hold on; box on;
        xlim([0 max(cell2mat(surf_dur'))])
    end
else
    scatter(surf_dur, 1:length(surf_dur), 24, 'k', 'filled', 'MarkerFaceAlpha', 0.5); hold on; box on;
    xlim([0 max(surf_dur)])
end

% Give common xlabel, ylabel
han=axes(fig,'visible','off'); 
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Surface Interval Number');
xlabel(han,'Surface Interval (min)');

end

