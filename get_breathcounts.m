function [surf_breath_count] = get_breathcounts(dive_dur, si_breathtimes, breath_idx)
    if iscell(dive_dur)==1
        for k = 1:length(dive_dur)
            %Find dive indexs in si_breathtimes
            for i = 1:length(dive_dur{k})-1
                if i < length(dive_dur{k})-1
                    si_breathtimes_mat = cell2mat(si_breathtimes{k});
                    surf_breath_count{k}(i) = length(si_breathtimes_mat(breath_idx{k}(i):breath_idx{k}(i+1)-1));
                elseif i == length(dive_dur{k})-1
                    surf_breath_count{k}(i) = length(si_breathtimes_mat(breath_idx{k}(i):end));
                end
            end
        end
    else
        for i = 1:length(dive_dur)-1
            if i < length(dive_dur)-1
                surf_breath_count(i) = length(si_breathtimes(breath_idx(i):breath_idx(i+1)-1));
            elseif i == length(dive_dur)-1
                surf_breath_count(i) = length(si_breathtimes(breath_idx(i):end));
            end
            
        end
    end
end

