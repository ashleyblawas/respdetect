%findbreaths

function []=findbreaths(breathaud_filename, tag, fs, time_sec, time_min, j_clean, T, marker)
    if isfile(breathaud_filename)
        R = loadauditbreaths(tag);
    else 
        R.cue = [] ;
        R.stype = [] ;
    end
    
    for i=1:height(T)-1
        start_plot = find(abs(time_sec-T{i, 5})==min(abs(time_sec-T{i, 5}))); 
        end_plot = find(abs(time_sec-T{i+1, 4})==min(abs(time_sec-T{i+1, 4})));
        
        % Select threshold for detection
        figure
        plot(time_min(start_plot:end_plot), j_clean(start_plot:end_plot)); grid; hold on;
        [x,auto_thres] = ginput(1); clear x
        close
        
        if length(start_plot:end_plot)<2*fs
            MPD = length(start_plot:end_plot);
        else
            MPD = 2*fs;
        end
        
        [auto_breath_vals, auto_breath_locs] = findpeaks(j_clean(start_plot:end_plot), 'MinPeakDistance', MPD , 'MinPeakHeight', auto_thres);
        clear auto_breath_vals
        plot(time_min(start_plot:end_plot), j_clean(start_plot:end_plot), 'k'); grid; hold on;
        scatter(time_min(auto_breath_locs+start_plot), j_clean(auto_breath_locs+start_plot), 'r*')
        
        txt = input("Do you want to manually edit these peaks (y/n)?\n", "s");
        if strcmp(txt, "n")==1
            %Do nothing and move on
        else
            
            
        
        
        fprintf('Surface interval %i of %i\n', i,height(T)-1)
        
        for i = 1:length(auto_breath_locs)
            R.cue = [R.cue;[time_sec(auto_breath_locs(i)+start_plot) 0]] ;
            R.stype{size(R.cue,1)} = marker ;
        end
        
        
    end
    
    saveauditbreaths(tag, R); % Save audit
end