%% FUNCTION:plotRES
function plotRES(AXc,RES,XLIMS,AXs)

% Plot comments
axes(AXc)
if ~isempty(RES.cue),
    kk = find(RES.cue(:, 1) > XLIMS(1) & RES.cue(:,1)<=XLIMS(2)) ;
    if ~isempty(kk),
        plot([RES.cue(kk,1)]',0.2*ones(2,length(kk)),'k*') ;
        for k=kk',
            text(max([XLIMS(1) RES.cue(k,1)+0.01]),0.6,RES.stype{k},'FontSize',10) ;
        end
    else
        %plot(0,0,'k*-') ;
        plot(XLIMS(1), NaN, 'k'),
    end
else
    plot(XLIMS(1), NaN, 'k'),
end

xlim([XLIMS(1) XLIMS(2)]),
set(AXc,'YLim',[0 1]) ;
bc = get(gcf,'Color') ;
set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;

% Plot events
axes(AXs)
yl = get(gca,'YLim') ; % Get current y axis limits before plotting
if ~isempty(RES.cue),
    kk = find(RES.cue(:, 1) > XLIMS(1) & RES.cue(:,1)<=XLIMS(2)) ; % Find events that start and end within bounds of plot
    if ~isempty(kk),
        arrayfun(@(a)xline(a, 'k:'),RES.cue(kk,1)); % Plot lines
        ylim([yl]) ; % Reset axis limits
    else
        %plot(0,0,'k*-') ;
    end
else
    %plot(0,0,'k*-') ;
end


return

end

