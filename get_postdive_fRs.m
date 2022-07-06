function [post_dive_breaths, post_dive_fR, post_win]=get_postdive_fRs(si_breathtimes, dive_dur, dive_end, breath_cue)
   
    % Get desired window
    prompt = {'Enter post-dive window in minutes:'};
    dlgtitle = 'Post-dive breathing rate';
    dims = [1 50]; opts.WindowStyle = 'normal'; opts.Resize = 'on';
    win = inputdlg(prompt,dlgtitle,dims,{'0'}, opts);
    post_win = str2num(cell2mat(win));
    
    if iscell(dive_dur)==1
        % Get breaths some window post-dive
        for k = 1:length(dive_dur)
            post_dive_breaths{k}{length(dive_dur{k})}=NaN;
            post_dive_fR{k}{length(dive_dur{k})}=NaN;

            for i = 1:length(dive_dur{k})-1 % Don't include the first dive because don't know if captured the entire prior surface interval
                win_end = dive_end{k}(i)+post_win*60; %Where the pre-dive window starts in seconds
                %Look for breaths in this time
                post_dive_breaths{k}{i} = breath_cue{k}(find(breath_cue{k}<win_end & breath_cue{k}>dive_end{k}(i)));
                post_dive_fR{k}{i} = diff(post_dive_breaths{k}{i});
            end
        end
    else
        post_dive_breaths{length(dive_dur)}=NaN;
        post_dive_fR{length(dive_dur)}=NaN;

        for i = 1:length(dive_dur)-1 % Don't include the first dive because don't know if captured the entire prior surface interval
            win_end = dive_end(i)+post_win*60; %Where the pre-dive window starts in seconds
            %Look for breaths in this time
            post_dive_breaths{i} = breath_cue(find(breath_cue<win_end & breath_cue>dive_end(i)));
            post_dive_fR{i} = diff(post_dive_breaths{i});
        end
    end
end