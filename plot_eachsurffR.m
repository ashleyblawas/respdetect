function [] = plot_eachsurffR(dive_dur, breath_idx, si_breathtimes, si_fR)
    fig=figure;
    clear h
    
    if iscell(dive_dur)
    % Plot fR's during each surface interval
    for k = 1:length(dive_dur)
        h(k) = subplot(ceil(length(dive_dur)/5), ceil(length(dive_dur)/(ceil(length(dive_dur)/5))), k)
        for i = 1:length(dive_dur{k})-1
            if i < length(dive_dur{k})-1
                scatter(si_breathtimes{k}{i}, si_fR{k}{i}, 24, ones(length(si_fR{k}{i}), 1).*dive_dur{k}(i),'filled', 'MarkerFaceAlpha',0.5,'MarkerEdgeAlpha', 0.5);
                hold on; box on; axis square;
            elseif i == length(dive_dur{k})-1
                scatter(si_breathtimes{k}{i}, si_fR{k}{i}, 24, ones(length(si_fR{k}{i}), 1).*dive_dur{k}(i),'filled', 'MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',0.5);
                hold on; box on; axis square;
            end
            
        end
        set(h,'CLim', [min(cell2mat(dive_dur')) max(cell2mat(dive_dur'))]);
    end
    else 
        for i = 1:length(dive_dur)-1
            if i < length(dive_dur)-1
                scatter(si_breathtimes(breath_idx(i):breath_idx(i+1)-1), si_fR(breath_idx(i):breath_idx(i+1)-1), 24, ones(length(si_fR(breath_idx(i):breath_idx(i+1)-1)), 1).*dive_dur(i),'filled', 'MarkerFaceAlpha',0.5,'MarkerEdgeAlpha', 0.5);
                hold on; box on; axis square;
            elseif i == length(dive_dur)-1
                scatter(si_breathtimes(breath_idx(i):end), si_fR(breath_idx(i):end), 24, ones(length(si_fR(breath_idx(i):end)), 1).*dive_dur(i),'filled', 'MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',0.5);
                hold on; box on; axis square;
            end
            
        end
        
    end
    
    %Make colorbar
    cb = colorbar;  cb.Label.String = 'Dive Duration'; 
    
    % Give common xlabel, ylabel
    han=axes(fig,'visible','off');
    han.XLabel.Visible='on';
    han.YLabel.Visible='on';
    ylabel(han,'{\it f}_R (breaths min^{-1})');
    xlabel(han,'Time at Surface (min)');
end

