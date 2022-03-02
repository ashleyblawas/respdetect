%fRbwdivetypes

function []=fRbwdivetypes(T, surf_int_breaths, surf_int_fR, dive_durs)
    
    figure;
    c_ss = 0; c_sl = 0;
    c_ls = 0; c_ll = 0;
    
    h(1) = subplot(2, 2, 1); h(2) = subplot(2, 2, 2);
    h(3) = subplot(2, 2, 3); h(4) = subplot(2, 2, 4);
    
    for k = 1:length(T(:, 1))-1
        if isempty(surf_int_breaths{k}) == 0
            %Find short to short dives
            if dive_durs(k)/60<10 && dive_durs(k+1)/60<10
                h(1) = subplot(2, 2, 1); c_ss = c_ss+1;
                scatter((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60, 60./surf_int_fR{k}, 20, ones(length(surf_int_fR{k}), 1)*dive_durs(k)./60, 'MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7); hold on; box on;
                title('short-short');  xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
                %Find long to short dives
            elseif dive_durs(k)/60>10 && dive_durs(k+1)/60<10
                h(2) = subplot(2, 2, 2); c_ls = c_ls+1;
                scatter((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60, 60./surf_int_fR{k}, 20, ones(length(surf_int_fR{k}), 1)*dive_durs(k)./60, 'MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7); hold on; box on;
                title('long-short'); xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
                %Find long to long dives
            elseif dive_durs(k)/60>10 && dive_durs(k+1)/60>10
                h(3) = subplot(2, 2, 4); c_ll = c_ll+1;
                scatter((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60, 60./surf_int_fR{k}, 20, ones(length(surf_int_fR{k}), 1)*dive_durs(k)./60, 'MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7); hold on; box on;
                title('long-long'); xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
                %Find short to long dives
            elseif dive_durs(k)/60<10 && dive_durs(k+1)/60>10
                h(4) = subplot(2, 2, 3); c_sl = c_sl+1;
                scatter((surf_int_breaths{k}(1:end-1)-surf_int_breaths{k}(1))./60, 60./surf_int_fR{k}, 20, ones(length(surf_int_fR{k}), 1)*dive_durs(k)./60, 'MarkerFaceAlpha',.7,'MarkerEdgeAlpha',.7); hold on; box on;
                title('short-long'); xlabel('Surface Time (min)'); ylabel('f_R (breaths min^{-1}');
            end
        end
    end
    colorbar; colormap copper
    set(h,'CLim', [min(dive_durs/60) max(dive_durs/60)]);
    
    %Markov chain
    P = [c_ss/(c_ss+c_ls)  c_ls/(c_ss+c_ls);...
        c_sl/(c_sl++c_ll) c_ll/(c_sl+c_ll)];
    mc = dtmc(P','StateNames',  ["short"  "long"]);
    figure
    graphplot(mc,'ColorEdges',true);
end
