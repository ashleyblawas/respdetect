function [dive_type, dive_thres] = assign_divetype(dive_dur)
    % Assign, short or long dive
    
    % Get threshold
    prompt = {'Enter threshold to designate short vs. long dive (min):'};
    dlgtitle = 'Dive threshold';

    dims = [1 50]; opts.WindowStyle = 'normal'; opts.Resize = 'on';
    dive_thres = inputdlg(prompt,dlgtitle,dims,{'5'}, opts);
    dive_thres = str2num(cell2mat(dive_thres));
    
    if iscell(dive_dur)==1
        for k = 1:length(dive_dur)
            %Find dive indexs in si_breathtimes
            for i = 1:length(dive_dur{k})
                if dive_dur{k}(i)<=dive_thres
                    dive_type{k}(i) = 's';
                else
                    dive_type{k}(i) = 'l';
                end
            end
        end
    else
        %Find dive indexs in si_breathtimes
        for i = 1:length(dive_dur)
            if dive_dur(i)<=dive_thres
                dive_type(i) = 's';
            else
                dive_type(i) = 'l';
            end
        end
    end
end

