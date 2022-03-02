function [breathing_dur] = get_breathdur(dive_dur, si_breathtimes, breath_idx)
    if iscell(dive_dur)==1
        for k = 1:length(dive_dur)
        si_breathtimes_mat = cell2mat(si_breathtimes{k});
            for i = 1:length(dive_dur{k})-1
                if i < length(dive_dur{k})-1
                    breathing_dur{k}(i) = si_breathtimes_mat(breath_idx{k}(i+1)-1);
                elseif i == length(dive_dur{k})-1
                    breathing_dur{k}(i) = si_breathtimes_mat(end);
                end
            end
        end
    else
        for i = 1:length(dive_dur)-1
            if i < length(dive_dur)-1
                breathing_dur(i) = si_breathtimes(breath_idx(i+1)-1);
            elseif i == length(dive_dur)-1
                breathing_dur(i) = si_breathtimes(end);
            end
        end
    end
    
end

