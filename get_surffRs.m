%get_surffRs

function [si_breathtimes, si_fR, surf_int_breaths, surf_int_fR]=get_surffRs(T, breath_times, dive_durs)
    si_breathtimes = []; si_fR = [];
    % Get fR's during each surface interval
    for k = 1:height(T(:, 1))-1
        surf_int_breaths{k} = breath_times(find(breath_times<T{k+1, 4} & breath_times>T{k, 5}));
        surf_int_fR{k} = diff(surf_int_breaths{k});
        if isempty(surf_int_fR{k}) ~=1
            si_breathtimes = [si_breathtimes; ((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60)'];
            si_fR = [si_fR; (60./surf_int_fR{k})'];
        else 
            si_breathtimes = [si_breathtimes; 0];
            si_fR = [si_fR; NaN];
        end
    end
    
    
    
    figure;
    clear h
    % Plot fR's during each surface interval
    h(1)=subplot(2, 3, [1 2 4 5]);
    for k = 1:height(T(:, 1))-1
        if isempty(surf_int_fR{k}) == 0
            scatter((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60, 60./surf_int_fR{k}, 20, ones(length(surf_int_fR{k}), 1)*dive_durs(k)./60, 'filled', 'MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7); hold on
        end
    end
    xl1 = xlim; yl1= ylim;
    xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1})');
    box on; axis square;
    
    %Make colorbar
    a = colorbar ; a.Label.String = 'Dive Duration'; colormap copper
    
    % Divide surface interval fR plots bimodally
    h(2)=subplot(2, 3, 3);
    for k = 1:height(T(:, 1))-1
        if isempty(surf_int_fR{k}) == 0 && (dive_durs(k)/60)<=5
            scatter((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60, 60./surf_int_fR{k}, 24, ones(length(surf_int_fR{k}), 1)*dive_durs(k)./60,'filled', 'MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7); hold on
        end
    end
    xl2 = xlim; yl2= ylim;
    xlabel('Surface Time after Dives <= 5 min (min)'); ylabel('f_R (breaths min^{-1})');
    box on; axis square; hold on;
    
    h(3)=subplot(2, 3, 6);
    for k = 1:height(T(:, 1))-1
        if isempty(surf_int_fR{k}) == 0 && (dive_durs(k)/60)>5
            scatter((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60, 60./surf_int_fR{k}, 24, ones(length(surf_int_fR{k}), 1)*dive_durs(k)./60,'filled', 'MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7); hold on
        end
    end
    xl3 = xlim; yl3= ylim;
    xlabel('Surface Time after Dives > 5 min (min)');  ylabel('f_R (breaths min^{-1})');
    box on; axis square;
    
    set(h,'CLim', [min(dive_durs/60) max(dive_durs/60)]);
    % Find rightmost xRight
    
    xRight = max([xl1(2), xl2(2), xl3(2)]);
    yUpper = max([yl1(2), yl2(2), yl3(2)]);
    
    subplot(2,3,3);
    xlim([0, xRight]); ylim([0, yUpper]);
    subplot(2,3,6);
    xlim([0, xRight]); ylim([0, yUpper]);
    
    clear xRight yUpper xl1 xl2 xl3 xl4 xl5 xl6 yl1 yl2 yl3 yl4 yl5 yl6
end