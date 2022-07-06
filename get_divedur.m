function [dive_dur] = get_divedur(dive_durs)

   %% Get dive durations
if iscell(dive_durs)==1
    for k = 1:length(dive_durs)
        dive_dur{k} =  dive_durs{k}(~isnan(dive_durs{k}));
    end
else
    for k = 1:length(dive_durs)
        if ~isnan(dive_durs(k))
            dive_dur(k) =  dive_durs(k);
        end
    end
end
end

