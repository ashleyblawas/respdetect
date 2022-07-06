%write2csv

function []=write2csv(tag, fs, dive_thres, surf_durs, dive_durs, breath_times, T)
    
    [fid, msg] = fopen(strcat(tag, '_resp.csv'), 'wt');
    if fid < 0
        error('Could not open file "%s" because "%s"', fid, msg);
    end
    fprintf(fid, 'tag, %s\n', tag); %Print the tag name
    fprintf(fid, 'fs (Hz), %i\n', fs); %Print the sampling frequency
    fprintf(fid, 'dive threshold (m), %i\n\n', dive_thres); %Print the dive threshold
    fprintf(fid, '%s, %s, %s, %s, %s\n', 'surface intervals (min)', 'dive durations (min)', 'dive start cue (s)', 'dive end cue (s)', 'breath cue (s)');
    
    fclose(fid);
    
    dive_start_cue = T(:, 1);
    dive_end_cue = T(:, 2);
    
    dive_durs = dive_durs./60;
    surf_durs = surf_durs./60;
    
    m1 = [[0 surf_durs]' [dive_durs]' dive_start_cue dive_end_cue];
    
    m2 = [breath_times];
    m3 = nan(length(m2), 5);
    m3([1:size(m1, 1)], [1:4]) = m1;
    m3(:, [5]) = m2;
    
    writematrix(m3,strcat(tag, '_resp.csv'),'WriteMode', 'append')
end
