function calc_move(fs, Aw, p, pitch, roll, head, movement_fname)
    arguments
        fs (1, 1) double
        Aw (:, 3) double
        p (:, 1) double
        pitch (:, 1) double
        roll (:, 1) double
        head (:, 1) double
        movement_fname (1, :) string
    end
    % Calculates movement metrics and saves them into a movement file on
    % the data path
    %
    % Inputs:
    %   taglist  - Cell array of tag names
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %
    % Usage:
    %   calc_move(taglist, dataPath)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
       
    % Calculate filtered acceleration   
    % Rename Aw vector
    surge = Aw(:, 1);
    sway = Aw(:, 2);
    heave = Aw(:, 3);
    
    % Make temp variables without NaNs to work with and then add back to full
    % variables
    surge_temp = surge(~isnan(surge));
    sway_temp = sway(~isnan(sway));
    heave_temp = heave(~isnan(heave));
    
    % Filter all three accel vectors, 5th order butterworth, with
    % passband between 2 Hz and 15 Hz
    fny = fs/2;
    if fs/2 < 15
        pass = 2;
        [b,a]=butter(5,pass/fny,'high');
    else
        pass = [2, 15];
        [b,a]=butter(5,pass/fny,'bandpass');
    end
    
    surge_filt = filtfilt(b,a, surge_temp);
    sway_filt = filtfilt(b,a, sway_temp);
    heave_filt = filtfilt(b,a, heave_temp);
    
    % Get surge diff
    surge_diff = diff(surge_filt);
    sway_diff = diff(sway_filt);
    heave_diff = diff(heave_filt);
    
    % Get Shannon entropy
    surge_se = log(abs(surge_diff))*sum(abs(surge_diff));
    sway_se = log(abs(sway_diff))*sum(abs(sway_diff));
    heave_se = log(abs(heave_diff))*sum(abs(heave_diff));
    
    % Get smoothed Shannon entropy - over 5 second window
    surge_smooth = movmean(surge_se, 5*fs);
    sway_smooth = movmean(sway_se, 5*fs);
    heave_smooth = movmean(heave_se, 5*fs);
    
    % Calculate jerk using njerk
    jerk_filt = njerk([surge_filt, sway_filt, heave_filt], fs);
    
    % Get Shannon entropy of jerk
    jerk_se = log(abs(jerk_filt))*sum(abs(jerk_filt));
    
    % Get smoothed Shannon entropy
    jerk_smooth = movmean(jerk_se', 5*fs);
        
    % Make temp variables to work with and then add back to full
    % variables
    pitch_temp = pitch(~isnan(pitch));
    roll_temp = roll(~isnan(roll));
    head_temp = head(~isnan(head));
    
    % Calculate filtered prh signals
    pitch_filt = filtfilt(b, a, pitch_temp);
    roll_filt = filtfilt(b, a, roll_temp);
    head_filt = filtfilt(b, a, head_temp);
    
    % Get prh diff
    pitch_diff = diff(pitch_filt);
    roll_diff = diff(roll_filt);
    head_diff = diff(head_filt);
    
    % Get Shannon entropy
    pitch_se = log(abs(pitch_diff))*sum(abs(pitch_diff));
    roll_se = log(abs(roll_diff))*sum(abs(roll_diff));
    head_se = log(abs(head_diff))*sum(abs(head_diff));
    
    % Get smoothed Shannon entropy
    pitch_smooth = movmean(pitch_se, 5*fs);
    head_smooth = movmean(head_se, 5*fs);
    roll_smooth = movmean(roll_se, 5*fs);
    
    % Replace temp variables back into full length variables
    surge_smooth_temp = NaN(length(surge), 1);
    sway_smooth_temp = NaN(length(sway), 1);
    heave_smooth_temp = NaN(length(heave), 1);
    jerk_smooth_temp = NaN(length(surge), 1);
    jerk_filt_temp = NaN(length(surge), 1);
    pitch_smooth_temp = NaN(length(pitch), 1);
    head_smooth_temp = NaN(length(head), 1);
    roll_smooth_temp = NaN(length(roll), 1);
    
    % But smoothed variables back in, append last value again to
    % make same size. You could append a zero but it makes the
    % normalizing later a little wacky
    surge_smooth_temp(~isnan(surge)) = [surge_smooth; surge_smooth(end)];
    sway_smooth_temp(~isnan(sway)) = [sway_smooth; sway_smooth(end)];
    heave_smooth_temp(~isnan(heave)) = [heave_smooth; heave_smooth(end)];
    jerk_smooth_temp(~isnan(surge)) = [jerk_smooth, jerk_smooth(end)];
    jerk_filt_temp(~isnan(surge)) = [jerk_filt; jerk_filt(end)];
    pitch_smooth_temp(~isnan(pitch)) = [pitch_smooth; pitch_smooth(end)];
    head_smooth_temp(~isnan(head)) = [head_smooth; head_smooth(end)];
    roll_smooth_temp(~isnan(roll)) = [roll_smooth; roll_smooth(end)];
    
    % Rename variables
    surge_smooth = surge_smooth_temp;
    sway_smooth = sway_smooth_temp;
    heave_smooth = heave_smooth_temp;
    jerk_smooth = jerk_smooth_temp;
    jerk_filt = jerk_filt_temp;
    pitch_smooth = pitch_smooth_temp;
    head_smooth = head_smooth_temp;
    roll_smooth = roll_smooth_temp;
    
    % Save all movement variables to mat file
    save(movement_fname, 'p', 'Aw', 'surge', 'sway', 'heave',...
        'surge_filt', 'sway_filt', 'heave_filt',...
        'surge_diff', 'sway_diff', 'heave_diff',...
        'surge_se', 'sway_se', 'heave_se',...
        'surge_smooth', 'sway_smooth', 'heave_smooth',...
        'jerk_filt', 'jerk_se', 'jerk_smooth',...
        'pitch_filt', 'head_filt', 'roll_filt',...
        'pitch_diff', 'head_diff', 'roll_diff',...
        'pitch_se', 'head_se', 'roll_se',...
        'pitch_smooth', 'head_smooth', 'roll_smooth');
    
    disp('Movement information calculation complete!');
    
end