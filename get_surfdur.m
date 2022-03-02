function [surf_dur] = get_divedur(surf_durs)

   %% Get dive durations
if iscell(surf_durs)==1
    for k = 1:length(surf_durs)
        surf_dur{k} =  surf_durs{k}(~isnan(surf_durs{k}));
    end
else
    for k = 1:length(surf_durs)
        if ~isnan(surf_durs(k))
            surf_dur(k) =  surf_durs(k);
        end
    end
end
end
