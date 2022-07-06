%findbreaths

function []=findbreaths(breathaud_filename, metadata, time_sec, time_min, jerk_smooth, T, marker)
    % Load in previous audit
    if isfile(breathaud_filename)
        R = loadauditbreaths(metadata.tag);
    else 
        R.cue = [] ;
        R.stype = [] ;
    end
    
    for i=1:height(T)-1
        start_plot = find(abs(time_sec-T{i, 5})==min(abs(time_sec-T{i, 5}))); 
        end_plot = find(abs(time_sec-T{i+1, 4})==min(abs(time_sec-T{i+1, 4})));
        
        % Select threshold for detection
        fig1 = figure
        ax1 = plot(time_min(start_plot:end_plot), jerk_smooth(start_plot:end_plot)); grid; hold on;
        [x,auto_thres] = ginput(1); clear x
        close(fig1)
        
         if length(start_plot:end_plot)<2*metadata.fs
            MPD = length(start_plot:end_plot)-2;
        else
            MPD = 2*metadata.fs;
        end
        
        [auto_breath_vals, auto_breath_locs] = findpeaks(jerk_smooth(start_plot:end_plot), 'MinPeakDistance', MPD , 'MinPeakHeight', auto_thres);
        clear auto_breath_vals
        
        fig2 = figure
        ax2 = plot(time_min(start_plot:end_plot), jerk_smooth(start_plot:end_plot), 'k'); grid; hold on;
        scatter(time_min(auto_breath_locs+start_plot), jerk_smooth(auto_breath_locs+start_plot), 'r*')
        
     
%     % Find and plot all local maxes
%     j_max_locs = islocalmax(jerk_smooth, 'MinProminence', 0.0025, 'MinSeparation', 2*metadata.fs);
%     j_max_locs = find(j_max_locs == 1);
%     
%     s_max_locs = islocalmax(surge_jerk_smooth, 'MinProminence', 0.0025, 'MinSeparation', 2*metadata.fs);
%     s_max_locs = find(s_max_locs == 1);
    
%     figure
%     subplot(211)
%     plot(time_sec, jerk_smooth, 'k'); grid; hold on;
%     scatter(time_sec(j_max_locs), jerk_smooth(j_max_locs), 'r*');
%     
%     subplot(212)
%     plot(time_sec, surge_jerk_smooth, 'k'); grid; hold on;
%     scatter(time_sec(s_max_locs), surge_jerk_smooth(s_max_locs), 'b*');
%     
%     R_temp.cue = [time_sec(j_max_locs)', zeros(length(j_max_locs), 1)];
%     for a = 1:length(j_max_locs)
%         R_temp.stype{a}= string(marker);
%     end
%     
%     for i=1:height(T)-1
%         start_plot = find(abs(time_sec-T{i, 5})==min(abs(time_sec-T{i, 5}))); 
%         end_plot = find(abs(time_sec-T{i+1, 4})==min(abs(time_sec-T{i+1, 4})));
%         
%         peaks_in_range_R = find(R_temp.cue(:, 1)>time_sec(start_plot) & R_temp.cue(:, 1)<time_sec(end_plot));
%         for b = 1:length(peaks_in_range_R)
%             peaks_in_range_idx(b) = find(abs(time_sec-R_temp.cue(peaks_in_range_R(b), 1))==min(abs(time_sec-R_temp.cue(peaks_in_range_R(b), 1))));
%         end
%         % Select threshold for detection
%         fig1 = figure;
%         ax1 = axes('Parent',fig1);
%         p1 = plot(time_sec(start_plot:end_plot), jerk_smooth(start_plot:end_plot), 'k'); grid; hold on;
%         s1 = scatter(time_sec(peaks_in_range_idx), jerk_smooth(peaks_in_range_idx), 'r*');
%         xlabel('Time (s)'); ylabel('Normalized smooth jerk SE');
%         
%         if length(start_plot:end_plot)<2*metadata.fs
%             MPD = length(start_plot:end_plot);
%         else
%             MPD = 2*metadata.fs;
%         end
%         
%         
%         txt = input("Do you want to manually edit these peaks (y/n)?\n", "s");
%         if strcmp(txt, "n")==1
%             %Do nothing and move on
%         elseif strcmp(txt, "y")==1 % If yes, they want to give the person the option to delete and mark peaks
%             % control buttons
%         done = 0 ;
%         while done == 0,
%             axes(ax1) ; 
%             pause(0) ;
%             [gx gy button] = ginput(1)
%             if button>='A',
%                 button = lower(setstr(button)) ;
%             end
%             if button==3 | button=='q', %Quit out of program
%                 break;
%                 
%             elseif button=='c', %Insert a comment
%                 R_temp.cue = [R_temp.cue;[gx 0]] ;
%                 R_temp.stype{size(R_temp.cue,1)} = strcat(marker, '-m');
%                 scatter(gx, jerk_smooth(find(abs(time_sec-gx)==min(abs(time_sec-gx)))), 'r*');
% 
%             elseif button=='x', %Delete a comment
%                 kres = min(find(gx>=(R_temp.cue(:,1))-1 & gx<(R_temp.cue(:,1))+1)) ; %-1 and +1 allow for a 1 second cushino on either side, adding fs because doing this in samples
%                 if ~isempty(kres),
%                     kkeep = setxor(1:size(R_temp.cue,1),kres) ;
%                     R_temp.cue = R_temp.cue(kkeep,:) ;
%                     R_temp.stype = {R_temp.stype{kkeep}} ;
% 
%                     %Reidentify peak detections in surfacing range since
%                     %removing bad detection 
%                     delete(s1)
%                     clear peaks_in_range_sec peaks_in_range_idx
%                     peaks_in_range_R = find(R_temp.cue(:, 1)>time_sec(start_plot) & R_temp.cue(:, 1)<time_sec(end_plot));
%                     for b = 1:length(peaks_in_range_R)
%                         peaks_in_range_idx(b) = find(abs(time_sec-R_temp.cue(peaks_in_range_R(b), 1))==min(abs(time_sec-R_temp.cue(peaks_in_range_R(b), 1))));
%                     end
%                     s1 = scatter(time_sec(peaks_in_range_idx), jerk_smooth(peaks_in_range_idx), 'r*');
%                 else
%                     fprintf(' No saved cue at cursor\n') ;
%                 end
%                                 
%             elseif button==1,
%                 if gx<start_plot | gx>end_plot
%                     fprintf('Invalid click: commands are f b s l p x q\n')
%                 else
%                     current = [current(2) gx] ;
%                     set(hhh,'XData',current) ;
%                     fprintf('Time = %5.2f s\n', gx);
%                 end
%             end
%         end
%         else
%             txt = input("Enter 'y' for yes or 'n' for no:\n", "s");
%         end
%            
        
        fprintf('Surface interval %i of %i\n', i,height(T)-1)
      
        for j = 1:length(auto_breath_locs)
            R.cue = [R.cue;[time_sec(auto_breath_locs(j)+start_plot) 0]] ;
            R.stype{size(R.cue,1)} = marker ;
        end
        %R.cue = [R.cue; R_temp.cue] ;
        %R.stype{size(R.cue,1)+1:size(R.cue,1)+size(R_temp.cue,1)} = marker ;

    %close(fig2)
    clear auto_breath_locs
    end
    
    saveauditbreaths(metadata.tag, R); % Save audit
end