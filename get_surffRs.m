%get_surffRs

function [si_breathtimes_z, si_breathtimes, si_fR]=get_surffRs(breath_cue, dive_start, dive_end, dive_dur)
    
    
    
    if iscell(dive_dur)==1 
        % Get fR's during each surface interval
        for k = 1:length(dive_dur)
        si_breathtimes_z{k} = {}; si_breathtimes{k} = {}; si_fR{k} = {};
            for i = 1:length(dive_dur{k})-1
                surf_int_breaths = breath_cue{k}(find(breath_cue{k}<dive_start{k}(i+1) & breath_cue{k}>dive_end{k}(i)));
                surf_int_fR = diff(surf_int_breaths);
                if isempty(surf_int_fR) ~=1
                    si_breathtimes_z{k} = [si_breathtimes_z{k}; (surf_int_breaths(1:end-1)-surf_int_breaths(1))./60];
                    si_breathtimes{k} = [si_breathtimes{k}; (surf_int_breaths(1:end-1)-dive_end{k}(i))./60];
                    si_fR{k} = [si_fR{k}; 60./surf_int_fR];
                else
                    si_breathtimes_z{k} = [si_breathtimes_z{k}; 0];
                    si_breathtimes{k} = [si_breathtimes{k}; 0];
                    si_fR{k} = [si_fR{k}; NaN];
                end
            end
        end
    else
si_breathtimes_z = []; si_breathtimes = []; si_fR = [];
        for i = 1:length(dive_dur)-1
            surf_int_breaths = breath_cue(find(breath_cue<dive_start(i+1) & breath_cue>dive_end(i)));
            surf_int_fR = diff(surf_int_breaths);
            
            if isempty(surf_int_fR) ~=1
                si_breathtimes_z = [si_breathtimes_z; (surf_int_breaths(1:end-1)-surf_int_breaths(1))./60];
                si_breathtimes = [si_breathtimes; (surf_int_breaths(1:end-1)-dive_end(i))./60];
                si_fR = [si_fR; 60./surf_int_fR];
            else
                si_breathtimes_z = [si_breathtimes_z; 0];
                si_breathtimes = [si_breathtimes; 0];
                si_fR = [si_fR; NaN];
            end
        end
    end
    

end