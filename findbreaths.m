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
        fig1 = figure
        ax1 = plot(time_min(start_plot:end_plot), j_clean(start_plot:end_plot)); grid; hold on;
        [x,auto_thres] = ginput(1); clear x
        close fig1
        
        if length(start_plot:end_plot)<2*fs
            MPD = length(start_plot:end_plot);
        else
            MPD = 2*fs;
        end
        
        [auto_breath_vals, auto_breath_locs] = findpeaks(j_clean(start_plot:end_plot), 'MinPeakDistance', MPD , 'MinPeakHeight', auto_thres);
        clear auto_breath_vals
        fig2 = figure
        ax2 = plot(time_min(start_plot:end_plot), j_clean(start_plot:end_plot), 'k'); grid; hold on;
        scatter(time_min(auto_breath_locs+start_plot), j_clean(auto_breath_locs+start_plot), 'r*')
        
        txt = input("Do you want to manually edit these peaks (y/n)?\n", "s");
        if strcmp(txt, "n")==1
            %Do nothing and move on
        elseif strcmp(txt, "y")==1 % If yes, they want to give the person the option to delete and mark peaks
            % control buttons
        done = 0 ;
        while done == 0,
            axes(ax2) ; pause(0) ;
            [gx gy button] = ginput(1) ;
            if button>='A',
                button = lower(setstr(button)) ;
            end
            if button==3 | button=='q', %Quit out of program
                return
                
            elseif button=='c', %Insert a comment
                ss = input(' Enter comment... ','s') ;
                R.cue = [R.cue;[gx 0]] ;
                R.stype{size(R.cue,1)} = ss ;
                plotR(AXm,R,[tcue tcue+NS]) ;
                
            elseif button=='x', %Delete a comment
                kres = min(find(gx>=R.cue(:,1)-1 & gx<sum(R.cue')'+1)) ;
                if ~isempty(kres),
                    kkeep = setxor(1:size(R.cue,1),kres) ;
                    R.cue = R.cue(kkeep,:) ;
                    R.stype = {R.stype{kkeep}} ;
                    plotR(AXm,R,[tcue tcue+NS]) ;
                else
                    fprintf(' No saved cue at cursor\n') ;
                end
                
            elseif button=='f', %Go forward
                tcue = tcue+floor(NS);
                done = 1 ;
                if tcue+NS>tt(end)
                    display('Too close to end, zoom in to proceed')
                    tcue = tcue-floor(NS);
                end
                
            elseif button=='i', %Zooming in 
                NS = NS/2;
                done = 1 ;
                
            elseif button=='o', %Zooming out
                NS = NS*2;
                done = 1 ;
                if tcue+NS>tt(end)
                    display('Too close to end, zoom in to proceed')
                    NS = NS/2;
                end
                
            elseif button=='b', %Go back
                tcue = max([0 tcue-NS]) ;
                done = 1 ;
                
              
            elseif button=='t', %Set a threshold for the ptich signal and find peaks 
                if gx<tcue | gx>tcue+NS
                    fprintf('Click inside the flow plot to select a threshold\n') ;
                else
                    display('Attempting threshold')
                    % Adding 1 to time because lose one data point for
                    % diff, this is consistent with findbreaths
                    time_sec = tt((floor(tcue)*ffs)+1:(floor(tcue)*ffs+NS*ffs)+1);
                    pitch_sec = pitch_smooth((floor(tcue)*ffs):(floor(tcue)*ffs+NS*ffs));
                    gy
                    [pks, locs] = findpeaks(pitch_smooth((floor(tcue)*ffs):(floor(tcue)*ffs+NS*ffs)), ffs, 'MinPeakDistance', 2, 'MinPeakHeight', gy);
                    for i = 1:length(locs)
                        R.cue = [R.cue;[locs(i)+floor(tcue) 0]] ;
                        R.stype{size(R.cue,1)} = 'b' ;
                        %save labchartaudit_RECOVER R
                        plotR(AXm,R,[tcue tcue+NS]) ;
                    end
                end
                done = 1 ;  
                
                elseif button=='z', %Mark a zero-crossing in the pitch signal
                if gx<tcue | gx>tcue+NS
                fprintf('Click inside the flow plot to select an approximate zero crossing\n') ;
                else
                % find first crossing of the relative threshold
                display('Attempting zero crossing')
                gx
                time_sec = tt((floor(tcue)*ffs)+1:(floor(tcue)*ffs+NS*ffs)+1);
                pitch_sec = pitch((floor(tcue)*ffs)+1:(floor(tcue)*ffs+NS*ffs)+1)';
                [locs] = time_sec(find(time_sec(1:end-1) > gx & pitch_sec(1:end-1) >=0 & pitch_sec(2:end) < 0, 1, 'first'));
                if isempty(locs)
                    done = 1;
                else
                gx
                R.cue = [R.cue;[locs 0]] ;
                R.stype{size(R.cue,1)} = 'b' ;
                %save labchartaudit_RECOVER R
                plotR(AXm,R,[tcue tcue+NS]) ;
                end
            end
            done = 1 ;
                                      
            elseif button==1,
                if gx<tcue | gx>tcue+NS
                    fprintf('Invalid click: commands are f b s l p x q\n')
                else
                    current = [current(2) gx] ;
                    set(hhh,'XData',current) ;
                    fprintf('Time = %5.2f s\n', gx);
                end
            end
        end
        else
            txt = input("Enter 'y' for yes or 'n' for no:\n", "s");
        end
           
        
        fprintf('Surface interval %i of %i\n', i,height(T)-1)
        close fig2
        
        for i = 1:length(auto_breath_locs)
            R.cue = [R.cue;[time_sec(auto_breath_locs(i)+start_plot) 0]] ;
            R.stype{size(R.cue,1)} = marker ;
        end
        
        
    end
    
    saveauditbreaths(tag, R); % Save audit
end