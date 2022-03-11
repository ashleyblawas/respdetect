function RES = auditbreaths(tcue, jerk_smooth, pitch, roll, heading, p, fs, pitch_smooth, RES)
    
    %     OPERATION
    %     Type or click on the display for the following functions:
    %     - type 'f' to go to the next block
    %     - type 'b' to go to the previous block
    %     - type 'i' to zoom in by a factor of 2
    %     - type 'o' to zoom out by a factor of 2
    %     - type 's' to move to the beginning of the next surfacing
    %       interval (uses a threshold of 10 m)
    %     - type 'z' to mark a zero-crossing in the pitch signal (this may
    %       be useful in cases were a breath event is approximated by pitch
    %     changes)
    %     - type 'd' to select the current segment and add it to the audit.
    %       You will be prompted to enter a sound type on the matlab command
    %       window. Enter a single word and type return when complete.
    %     - type 'c' to select the currect cursor position and add it to the
    %       audit as a 0-length event. You will be prompted to enter a sound
    %       type on the matlab command window. Enter a single word and type
    %       return when complete.
    %     - type 'x' to delete the audit entry at the cursor position.
    %       If there is no audit entry at the cursor, nothing happens.
    %       If there is more than one audit entry overlapping the cursor, one
    %       will be deleted (the first one encountered in the audit structure).
    %     - type 'q' or press the right hand mouse button to finish auditing. 
    %      This code was adapted from Mark Johnson's d3audit
    
    tt = 0:1/fs:length(p)-(1/fs);
    
    % Clean the filtered pitch
    
    NS = 20;            % number of seconds to display
    fs = fs;           % sampling frequency
    ffs = fs;           % sampling rate of the flow
    
    current = [0 0];
    figure(1),clf
    AXtt = axes('position',[0.11,0.68,0.78,0.28]) ; % axes for top plot
    AXt = axes('position',[0.11,0.50,0.78,0.14]) ; % axes for top plot
    AXm = axes('position',[0.11,0.45,0.78,0.05]) ; % axes for middle plot
    AXb = axes('position',[0.11,0.25,0.78,0.14]) ; % axes for bottom plot
    AXbb = axes('position',[0.11,0.08,0.78,0.14]) ; % axes for bottom bottom plot
    
    for i = 1:length(jerk_smooth)
        if p(i)>1
            jerk_smooth(i) = NaN;
            pitch_smooth(i) = NaN;
        end
    end
    
    bc = get(gcf,'Color') ;
    set(AXm,'XLim',[0 1],'YLim',[0 1]) ;
    set(AXm,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
    cleanh = [] ;
    
    if nargin<3 | isempty(RES),
        RES.cue = [] ;
        RES.comment = [] ;
        RES.value = [];
        RES.row = [];
    end

    
    
    % control data streams
    while 1

       
        kk = 1:5:NS*fs;
        % plot PR
        
        if max(tcue*fs+kk)>length(pitch)
          display('Too close to end, zoom in to proceed')
          tcue = tcue-floor(NS);
        end
                
        
        axes(AXtt), plot(tt(tcue*fs+kk),pitch(tcue*fs+kk)*180/pi,'-', 'Color', [0, 0.4470, 0.7410]); grid; hold on
        plot(tt(tcue*fs+kk),roll(tcue*fs+kk)*180/pi,'-', 'Color', [0.8500, 0.3250, 0.0980]);
        plot(tt(tcue*fs+kk),heading(tcue*fs+kk)*180/pi,'-', 'Color',[0.9290, 0.6940, 0.1250]);
        legend('Pitch', 'Roll', 'Heading');
        set(AXtt,'XAxisLocation','top') ;
        %yl = get(gca,'YLim') ;
        xlim([tcue tcue+NS]) ;
        ylim auto
        ylabel('Degrees');
        
        % plot dive profile
        kk = 1:5:NS*fs;
        axes(AXt), plot(tt(tcue*fs+kk),p(tcue*fs+kk),'k-') ; grid
        set(gca,'xtick',[]);
        set(gca,'Ydir','reverse');
        yl = get(gca,'YLim') ;
        axis([tcue tcue+NS yl]) ;
        ylabel('Depth (m)');
        
        plotRES(AXm,RES,[tcue tcue+NS]) ;
                
        % plot jerk
        axes(AXb), plot(tt(tcue*fs+kk),jerk_smooth(tcue*fs+kk), 'k-') ; hold on;
        set(gca,'xtick',[]);
        yl = get(gca,'YLim') ;
        xlim([tcue tcue+NS]) ;
        ylabel('Jerk Smooth');
        
        % plot pitch.
        axes(AXbb), plot(tt(tcue*fs+kk),pitch_smooth(tcue*fs+kk)) ; hold on
        yl = get(gca,'YLim') ;
        %yl(2) = min([yl(2) MAXYONOXYGENDISPLAY]) ;
        axis([tcue tcue+NS yl]) ;
        axis xy, grid ;
        xlabel('Time, s')
        ylabel('Pitch Smooth')
        hold on
        hhh = plot([0 0],[0 0],'k*-') ;    % plot cursor
        hold off
        
        
        
        % control buttons
        done = 0 ;
        while done == 0,
            axes(AXbb) ; pause(0) ;
            [gx gy button] = ginput(1) ;
            if button>='A',
                button = lower(setstr(button)) ;
            end
            if button==3 | button=='q', %Quit out of program
                %save labchartaudit_RECOVER RES
                return
                
            elseif button=='d', %Insert a comment with a duration
                ss = input(' Enter comment with duration... ','s') ;
                cc = sort(current) ;
                RES.cue = [RES.cue;[cc(1) diff(cc)]] ;
                RES.stype{size(RES.cue,1)} = ss ;
                %save labchartaudit_RECOVER RES
                plotRES(AXm,RES,[tcue tcue+NS]) ;
                
            elseif button=='c', %Insert a comment
                ss = input(' Enter comment... ','s') ;
                RES.cue = [RES.cue;[gx 0]] ;
                RES.stype{size(RES.cue,1)} = ss ;
                %save labchartaudit_RECOVER RES
                plotRES(AXm,RES,[tcue tcue+NS]) ;
                
            elseif button=='x', %Delete a comment
                kres = min(find(gx>=RES.cue(:,1)-1 & gx<sum(RES.cue')'+1)) ;
                if ~isempty(kres),
                    kkeep = setxor(1:size(RES.cue,1),kres) ;
                    RES.cue = RES.cue(kkeep,:) ;
                    RES.stype = {RES.stype{kkeep}} ;
                    plotRES(AXm,RES,[tcue tcue+NS]) ;
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
                
            elseif button=='s', %Go to next surface interval
                startidx = max(tcue*fs+kk);
                endidx = length(p);
                val = find(p(startidx:endidx)<10, 1);
                next_surf = startidx+val;
                tcue = floor(tt(next_surf));
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
                        RES.cue = [RES.cue;[locs(i)+floor(tcue) 0]] ;
                        RES.stype{size(RES.cue,1)} = 'b' ;
                        %save labchartaudit_RECOVER RES
                        plotRES(AXm,RES,[tcue tcue+NS]) ;
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
                RES.cue = [RES.cue;[locs 0]] ;
                RES.stype{size(RES.cue,1)} = 'b' ;
                %save labchartaudit_RECOVER RES
                plotRES(AXm,RES,[tcue tcue+NS]) ;
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
   
    end
    
