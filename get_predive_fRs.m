function [pre_dive_breaths, pre_dive_fR, pre_win]=get_predive_fRs(si_breathtimes, dive_dur, dive_start, dive_end, breath_cue)
   
    % Get desired window
    prompt = {'Enter pre-dive window in minutes:'};
    dlgtitle = 'Pre-dive breathing rate';
    dims = [1 50]; opts.WindowStyle = 'normal'; opts.Resize = 'on';
    win = inputdlg(prompt,dlgtitle,dims,{'0'}, opts);
    pre_win = str2num(cell2mat(win));
    
    if iscell(dive_dur)==1
        % Get breaths some window pre-dive
        for k = 1:length(dive_dur)
            pre_dive_breaths{k}{1}=NaN;
            pre_dive_fR{k}{1}=NaN;
            for i = 2:length(dive_dur{k}) % Don't include the first dive because don't know if captured the entire prior surface interval
                win_start = dive_start{k}(i)-pre_win*60; %Where the pre-dive window starts in seconds
                %Look for breaths in this time
                pre_dive_breaths{k}{i} = breath_cue{k}(find(breath_cue{k}>win_start & breath_cue{k}<dive_start{k}(i)));
                pre_dive_fR{k}{i} = diff(pre_dive_breaths{k}{i});
            end
        end
    else
        pre_dive_breaths{1}=NaN;
        pre_dive_fR{1}=NaN;
        for i = 2:length(dive_dur) % Don't include the first dive because don't know if captured the entire prior surface interval
            win_start = dive_start(i)-pre_win*60; %Where the pre-dive window starts in seconds
            %Look for breaths in this time
            pre_dive_breaths{i} = breath_cue(find(breath_cue>win_start & breath_cue<dive_start(i)));
            pre_dive_fR{i} = diff(pre_dive_breaths{i});
        end
    end
end
