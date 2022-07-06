% Calculate movement metrics

function calc_mov(fs, Aw, data_path, tag, pitch, roll, head)
 %Calculate filtered acceleration
            %Rename Aw vector
            surge = Aw(:, 1);
            sway = Aw(:, 2);
            heave = Aw(:, 3);
            
            % Filter all three accel vectors, 5th order butterworth, with
            % passband between 2 Hz and 15 Hz
            fny = metadata.fs/2;
            pass = [2, 15];
            [b,a]=butter(5,pass/fny,'bandpass');
            
            surge_filt = filtfilt(b,a, surge);
            sway_filt = filtfilt(b,a, sway);
            heave_filt = filtfilt(b,a, heave);
           
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
            jerk_filt = njerk([surge_filt, sway_filt, heave_filt], metadata.fs);
            
            % Get Shannon entropy of jerk
            jerk_se = log(abs(jerk_filt))*sum(abs(jerk_filt));
 
            % Get smoothed Shannon entropy
            jerk_smooth = movmean(jerk_se', 5*fs); 
            
            % Build filter for prh
            fny = metadata.fs/2;
            pass = [2, 15]; % Change to [1 5] on 5/3/2022
            [b,a]=butter(5,pass/fny,'bandpass');

            % Calculate filtered prh signals
            pitch_filt = filtfilt(b, a, pitch);
            roll_filt = filtfilt(b, a, roll);
            head_filt = filtfilt(b, a, head);

            %Get prh diff
            pitch_diff = diff(pitch_filt);
            roll_diff = diff(roll_filt);
            head_diff = diff(head_filt);

            %Get Shannon entropy
            pitch_se = log(abs(pitch_diff))*sum(abs(pitch_diff));
            roll_se = log(abs(roll_diff))*sum(abs(roll_diff));
            head_se = log(abs(head_diff))*sum(abs(head_diff));

            %Get smoothed Shannon entropy
            pitch_smooth = movmean(pitch_se, 5*fs);
            head_smooth = movmean(head_se, 5*fs);
            roll_smooth = movmean(roll_se, 5*fs);

            % Save all movement variables to mat file
            save(strcat(data_path, "\movement\", metadata.tag, "movement.mat"), 'p', 'Aw', 'surge', 'sway', 'heave',...
                'surge_filt', 'sway_filt', 'heave_filt',...
                'surge_diff', 'sway_diff', 'heave_diff',...
                'surge_se', 'sway_se', 'heave_se',...
                'surge_smooth', 'sway_smooth', 'heave_smooth',...
                'jerk_filt', 'jerk_se', 'jerk_smooth',...
                'pitch_filt', 'head_filt', 'roll_filt',...
                'pitch_diff', 'head_diff', 'roll_diff',...
                'pitch_se', 'head_se', 'roll_se',...
                'pitch_smooth', 'head_smooth', 'roll_smooth');
          
            display('Movement information calculation complete!');
       
end