function [breath_idx] = get_breathidx(dive_dur, si_breathtimes_z)
    % Get the index of the first breath of each surface interval 
    if iscell(dive_dur)==1
        for k = 1:length(dive_dur)
            breath_idx{k} = find(cell2mat(si_breathtimes_z{k})==0);
        end
    else
        breath_idx= find(si_breathtimes_z==0);
        
    end
    
end

