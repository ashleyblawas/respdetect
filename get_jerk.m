%get_jerk

function [j, jx, jy, jz, j_clean, up_clean]=(Aw, fs, p, pitch, est_time_tagoff, est_time_tagon, time_sec)
    %Rename Aw vector
    surge = Aw(:, 1);
    sway = Aw(:, 2);
    heave = Aw(:, 3);
    
    %Filter all three accel vectors
    surge_filt = filter_acc(surge, fs, 10);
    sway_filt = filter_acc(sway, fs, 10);
    heave_filt = filter_acc(heave, fs, 10);
    
    % Calculate jerk
    j=njerk(Aw,fs);
    jx = (9.81*fs)*sqrt(diff(Aw(:, 1)).^2);
    jy = (9.81*fs)*sqrt(diff(Aw(:, 2)).^2);
    jz = (9.81*fs)*sqrt(diff(Aw(:, 3)).^2);
    
    % Clean the jerk signal
    j_clean = j;
    for e = 1:length(pitch)
        if p(e)>0.5 || time_sec(e)>str2double(est_time_tagoff) || time_sec(e)<str2double(est_time_tagon)
            j_clean(e) = 0;
        end
    end
    
    % Low pass filter the cleaned jerk
    %j_clean = lowpass(j_clean, 2, fs); %Changed to fc = 12.5 Hz on
    %12.28.20
    j_clean = j;
    
    %Filter pitch
    filt_pitch = highpass(pitch*180/pi, 2, fs);
    [up, do] = envelope(filt_pitch);
    
    up_clean = up;
    for e = 1:length(up)
        if p(e)>0.5 || time_sec(e)>str2double(est_time_tagoff) || time_sec(e)<str2double(est_time_tagon)
            up_clean(e) = 0;
        end
    end
end