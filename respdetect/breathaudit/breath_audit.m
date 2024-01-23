%% FUNCTION: d3audit
function     RES = breath_audit(prefix,tcue, RES, date_tagon, p, jerk, roll)
%
%     R = d3audit(recdir,prefix,tcue,R)
%     Audit tool for dtag 3.
%     tag is the tag deployment string e.g., 'sw03_207a'
%     tcue is the time in seconds-since-tag-on to start displaying from
%     R is an optional audit structure to edit or augment
%     Output:
%        R is the audit structure made in the session. Use saveaudit
%        to save this to a file.
%
%     OPERATION
%     Type or click on the display for the following functions:
%     - type 'f' to go to the next block
%     - type 'b' to go to the previous block
%     - click on the graph to get the time cue, depth, time-to-last
%       and frequency of an event. Time-to-last is the elapsed time 
%       between the current click point and the point last clicked. 
%       Results display in the matlab command window.
%     - type 's' to select the current segment and add it to the audit.
%       You will be prompted to enter a sound type on the matlab command
%       window. Enter a single word and type return when complete.
%     - type 'l' to select the currect cursor position and add it to the 
%       audit as a 0-length event. You will be prompted to enter a sound 
%       type on the matlab command window. Enter a single word and type 
%       return when complete.
%     - type 'x' to delete the audit entry at the cursor position.
%       If there is no audit entry at the cursor, nothing happens.
%       If there is more than one audit entry overlapping the cursor, one
%       will be deleted (the first one encountered in the audit structure).
%     - type 'p' to play the displayed sound segment 
%       through the computer speaker/headphone jack.
%     - type 'q' or press the right hand mouse button to finish auditing.
%     - type 'a' to report the angle of arrival of the selected segment
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified March 2005
%     added buttons and updated audit structure

NS = 30 ;          % number of seconds to display
BL = 512 ;         % specgram (fft) block size
CLIM = [-90 0] ;   % color axis limits in dB for specgram
CH = 1 ;           % which channel to display if multichannel audio
THRESH = 0 ;       % click detector threshold, 0 to disable
volume = 20 ;      % amplification factor for audio output - often needed to
                   % hear weak signals (if volume>1, loud transients will
                   % be clipped when playing the sound cut
SOUND_FH = 0 ;     % high-pass filter for sound playback - 0 for no filter
SOUND_FL = 0 ;     % low-pass filter for sound playback - 0 for no filter
SOUND_DF = 2 ;     % decimation factor for playing sound; change from 1 to 2 for HF
AOA_FH = 2e3 ;     % high-pass filter for angle-of-arrival measurement
AOA_SCF = 1500/0.025 ;     % v/h

MAXYONCLICKDISPLAY = 0.01 ;

% high-pass filter frequencies (Hz) for click detector 
switch prefix(1:2),
   case 'zc',      % for ziphius use:
      FH = 20000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
   case 'md',      % for mesoplodon use:
      FH = 20000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
   case 'pw',      % for pilot whale use:
      FH = 10000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
   case 'pm',      % for sperm whale use:
      FH = 3000 ;       
      TC = 2.5e-3 ;           % power averaging time constant in seconds
   otherwise,      % for others use:
      FH = 5000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
end

if nargin<4 | isempty(RES),
   RES.cue = datetime([],[],[], 'Format', 'yyyy-MM-dd HH:mm:ss.SS');
   RES.comment = [] ;
end

tt = date_tagon;

fs = round(1/(seconds(date_tagon(2) - date_tagon(1))));

% k = loadprh(prefix, 0,'p','fs') ;           % read p and fs from the sensor file
% if k==0,
%    fprintf('Unable to find a PRH file - continuing without\n') ;
%    p = [] ; fs = [] ;
% end

% % check sampling rate
% [x,afs] = d3wavread(tcue+[0 0.01],recdir,prefix) ;
% if SOUND_FH > 0,
%    [bs as] = butter(6,SOUND_FH/(afs/2),'high') ;
% elseif SOUND_FL > 0,
%    [bs as] = butter(6,SOUND_FL/(afs/2)) ;
% else
%    bs = [] ;
% end
% 
% % high pass filter for envelope
% [bh ah] = cheby1(6,0.5,FH/afs*2,'high') ;
% % envelope smoothing filter
% pp = 1/TC/afs ;
% 
% % angle-of-arrival filter
% [baoa aaoa] = butter(4,AOA_FH/(afs/2),'high') ;

current = [tt(tcue*fs+1) tt(tcue*fs+1)] ;
figure(1),clf
if ~isempty(p),
   kb = 1:floor(NS*fs) ;
   AXm = axes('position',[0.11,0.60,0.78,0.32]) ;
   AXc = axes('position',[0.11,0.53,0.78,0.07]) ;
   AXs = axes('position',[0.11,0.28,0.78,0.23]) ;
   AXr = axes('position',[0.11,0.11,0.78,0.15]) ;
else
  
end

bc = get(gcf,'Color') ;
set(AXc,'XLim',[0 1],'YLim',[0 1]) ;
set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
cleanh = [] ;

while 1,
%    [x,afs] = d3wavread(tcue+[0 NS],recdir,prefix) ;
%    if isempty(x), return, end    
%    x = x-repmat(mean(x),size(x,1),1) ;
%    [B F T] = specgram(x(:,CH),BL,afs,hamming(BL),BL/2) ;
%    xx = filter(pp,[1 -(1-pp)],abs(filter(bh,ah,x(:,CH)))) ;

   kk = 1:NS*fs; % does not need to be by 5, changed to by 1 on 5/2/21   
   % Plot depth information
   %ks = kb + round(tcue*fs) ;
   axes(AXm),plot(tt(tcue*fs+kk),p(tcue*fs+kk), 'b'), %grid
   set(AXm,'XAxisLocation','top') ;
   set(gca,'YDir','reverse') ;
   yl = get(gca,'YLim');
   xlim([tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end))])
   ylim([yl(1)-0.5 yl(2)+0.5]) ;
   %xlabel('Time, s')
   ylabel('Depth, m')
     
   % Plot jerk information
   axes(AXs), plot(tt(tcue*fs+kk),jerk(tcue*fs+kk), 'k')%grid
   ylabel('Jerk') 
   yl = get(gca,'YLim') ;
   xlim([tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end))])
   ylim([yl(1)-0.5 yl(2)+0.5]) ;
   set(gca, 'XTick', []);
   %xlabel('Date Time'); 
   
   % Plot roll
   axes(AXr); plot(tt(tcue*fs+kk),roll(tcue*fs+kk), '-r'); hold on%grid
   %plot(tt(tcue*fs+kk),pitch(tcue*fs+kk), '-o');
   yl = get(gca,'YLim') ;
   yline(0);
   fx = [tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end)) tt(tcue*fs + kk(end)) tt(tcue*fs+kk(1)) tt(tcue*fs+kk(1))];
   fy = [-45 -45 45 45 -45];
   fill( fx, fy, [0 0 0], 'FaceAlpha', 0.15); hold off
   xlim([tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end))])
   ylabel('Roll/Pitch (deg)') 
   xlabel('Date Time')
   legend('Roll', 'Pitch');
%    
   % Plot comments
   plotRES(AXc,RES,[tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end))],AXs); hold on

   hold on
   hhh = plot([tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end))],[0 0],'k*-') ;    % plot cursor
   hold off

   done = 0 ;
   while done == 0,
      axes(AXm) ; pause(0) ;
      [gx gy button] = ginput(1);
      ax = get(gca);
      gx = datetime(num2ruler(gx ,ax.XAxis), 'Format', 'yyyy-MM-dd HH:mm:ss.SS');
      gy = num2ruler(gy, ax.YAxis);
      if button>='A',
         button = lower(setstr(button)) ;
      end
      if button==3 | button=='q',
         save d3audit_RECOVER RES
         return

      elseif button=='c', %Insert a comment
          ss = input('Enter comment... ','s') ;
          RES.cue = [RES.cue;[gx]] ;
          RES.stype{size(RES.cue,1)} = ss ;
          plotRES(AXc,RES,[tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end))],AXs) ;

      elseif button=='x',
          gx
         kres = min(find(gx>=RES.cue(:,1)-seconds(1) & gx<RES.cue(:,1)+seconds(1))) ;
         if ~isempty(kres),
            kkeep = setxor(1:size(RES.cue,1),kres) ;
            RES.cue = RES.cue(kkeep,:) ;
            RES.stype = {RES.stype{kkeep}} ;
            plotRES(AXc,RES,[tt(tcue*fs+kk(1)) tt(tcue*fs + kk(end))],AXs) ;
         else
            fprintf(' No saved cue at cursor\n') ;
         end
         
      elseif button=='f',
          if tcue+floor(NS)-0.5>(length(tt)/fs)-NS
              display('Too close to end, zoom in or stop here')
              tcue = tcue;
          else
              tcue = tcue+floor(NS)-0.5 ;
          end
          done = 1 ;          
          
      elseif button=='b',
          tcue = max([0 tcue-NS+0.5]) ;
          done = 1 ;
          
      elseif button=='i', %Zooming in
          NS = NS/2;
          done = 1 ;
          
      elseif button=='o', % Zooming out
          if tcue+floor(NS)-0.5>(length(tt)/fs)-NS
              display('Too close to end, zoom in to proceed')
              NS = NS;
          else
              NS = NS*2;
          end
          done = 1 ;
                   
      elseif button=='d', %Go to next dive
          startidx = max(tcue*fs+kk(end));
          endidx = length(p);
          val = find(p(startidx:endidx)>0, 1);
          next_dive = startidx+val;
          tcue = next_dive/fs;
          done = 1 ;
          
      elseif button=='s', %Go to next surface interval
          startidx = max(tcue*fs+kk(end));  % start in samples
          endidx = length(p);               % end in samples
          val = find(p(startidx:endidx)<5, 1);  % find start of surfacings in samples
          next_surf = startidx+val;             % create next surf value in samples
          if isempty(next_surf) | (next_surf/fs)+floor(NS)-0.5>(length(tt)/fs)-NS
              display('Too close to end, zoom in to proceed')
              tcue = tcue;
          else
              tcue = next_surf/fs;
          end
          done = 1 ;          
          
      elseif button==1,
          if gy<0 | gx<tt(tcue*fs+kk(1)) | gx>tt(tcue*fs + kk(end))
              fprintf('Invalid click: commands are f b c i o d z x q\n')
              
          else
              current = [current(2) gx] ;
              gx
              set(hhh,'XData',current) ; % This builds a lines from last x to current x
              if ~isempty(p),
                  fprintf(' -> Start of segement is: %0.2f seconds \n' , seconds(tt(tcue*fs+kk(1))-tt(1)));
              else
                  fprintf(' -> Start of segement is: %0.2f seconds \n' , seconds(tt(tcue*fs+kk(1))-tt(1)));
              end
          end
      end
   end
end
end

