%findbreaths

function []=findbreaths(breathaud_filename, tag, fs, time_sec, time_min, j)
    if isfile(breathaud_filename)
        R = loadauditbreaths(tag);
    else 
        R.cue = [] ;
        R.stype = [] ;
    end
    
    NS = 15; % Number of seconds to display
    
    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
      
    % Load in movement data
    load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"));
    
    % Calculate time vars
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, surge);
    
    current = [0 0] ;
    figure(1),clf
    if ~isempty(p),
        kb = 1:floor(NS*fs) ;
        AXm = axes('position',[0.11,0.76,0.78,0.18]) ;
        AXc = axes('position',[0.11,0.70,0.78,0.05]) ;
        AXs = axes('position',[0.11,0.34,0.78,0.35]) ;
        AXp = axes('position',[0.11,0.11,0.78,0.2]) ;
    else
        AXm = axes('position',[0.11,0.60,0.78,0.34]) ;
        AXc = axes('position',[0.11,0.52,0.78,0.07]) ;
        AXs = axes('position',[0.11,0.11,0.78,0.38]) ;
    end
    
    bc = get(gcf,'Color') ;
    set(AXc,'XLim',[0 1],'YLim',[0 1]) ;
    set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
    cleanh = [] ;
    
    while 1,
   [x,afs] = tagwavread(tag,tcue,NS) ;
   if size(x,2)==1 & nargin>4 & ~isempty(DMON),
      [x,cleanh] = dmoncleanup(x,0.0001,[],cleanh) ;
   end
   if isempty(x), return, end    
     [B F T] = specgram(x(:,CH),BL,afs,hamming(BL),BL/2) ;
      xx = filter(pp,[1 -(1-pp)],abs(filter(bh,ah,x(:,CH)))) ;

   %kk = 1:5:length(j) ;
   ks = kb + round(tcue*fs) ;
   axes(AXm), plot(ks/fs,j(ks),'k') ; grid
   set(AXm,'XAxisLocation','top') ;
   %yl = get(gca,'YLim') ;
   ylabel ('Jerk (g/s)');
   %yl(2) = min([yl(2)]) ;
   axis([tcue tcue+NS get(gca,'YLim')]) ;
   
   plotRES(AXc,RES,[tcue tcue+NS]) ;

   if ~isempty(p),
      ks = kb + round(tcue*fs) ;
      axes(AXp),plot(ks/fs,p(ks)), grid
   	set(gca,'YDir','reverse') ;
      axis([tcue tcue+max(T) get(gca,'YLim')]) ;
      xlabel('Time, s')
      ylabel('Depth, m')
   end
   
   BB = adjust2Axis(20*log10(abs(B))) ;
   axes(AXs), imagesc(tcue+T,F/1000,BB,CLIM) ;
   axis xy, grid ;
   if ~isempty(p),
      set(AXs,'XTickLabel',[]) ;
   else
      xlabel('Time, s')
   end
   ylabel('Frequency, kHz')
   hold on
   hhh = plot([0 0],0.8*afs/2000*[1 1],'k*-') ;    % plot cursor
   hold off

   done = 0 ;
   while done == 0,
      axes(AXs) ; pause(0) ;
      [gx gy button] = ginput(1) ;
      if button>='A',
         button = lower(setstr(button)) ;
      end
      if button==3 | button=='q',
         save tagaudit_RECOVER RES
         return

      elseif button=='f',
            tcue = tcue+floor(NS)-0.5 ;
            done = 1 ;

      elseif button=='b',
            tcue = max([0 tcue-NS+0.5]) ;
            done = 1 ;
            
            elsei

      elseif button==1,
         if gy<0 | gx<tcue | gx>tcue+NS
            fprintf('Invalid click: commands are f b s l p x q\n')

         else
	         end
         end
      end
   end
end
    
    for i=1:height(Tab)-1
        start_plot = find(abs(time_sec-Tab{i, 5})==min(abs(time_sec-Tab{i, 5}))); 
        end_plot = find(abs(time_sec-Tab{i+1, 4})==min(abs(time_sec-Tab{i+1, 4})));
        
        % Select threshold for detection
        figure
        plot(time_min(start_plot:end_plot), j_clean(start_plot:end_plot)); grid; hold on;
        [x,auto_thres] = ginput(1); clear x
        close
        
        if length(start_plot:end_plot)/fs<2*fs
            MPD = 0;
        else
            MPD = 3*fs;
        end
        
        [auto_breath_vals, auto_breath_locs] = findpeaks(j_clean(start_plot:end_plot), 'MinPeakDistance', MPD , 'MinPeakHeight', auto_thres);
        clear auto_breath_vals
        plot(time_min(start_plot:end_plot), j_clean(start_plot:end_plot)); grid; hold on;
        scatter(time_min(auto_breath_locs+start_plot), j_clean(auto_breath_locs+start_plot), '*')
        
        fprintf('Surface interval %i of %i\n', i, height(Tab)-1)
        
        for i = 1:length(auto_breath_locs)
            R.cue = [R.cue;[time_sec(auto_breath_locs(i)+start_plot) 0]] ;
            R.stype{size(R.cue,1)} = 'b' ;
        end
        
        
    end
    
    saveauditbreaths(tag, R); % Save audit
end