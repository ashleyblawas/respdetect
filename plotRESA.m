function []= plotRESA(AXc,RES,XLIMS,col)
    
    % Adapted from Mark Johnson's plotRES
    marker = strcat(col, '*-');
 
    axes(AXc)
    if ~isempty(RES.cue),
        kk = find(sum(RES.cue')' > XLIMS(1) & RES.cue(:,1)<=XLIMS(2)) ;
        if ~isempty(kk),
            plot([RES.cue(kk,1) sum(RES.cue(kk,:)')']',0.2*ones(2,length(kk)), marker) ;
            for k=kk',
                text(max([XLIMS(1) RES.cue(k,1)+0.01]),0.6,RES.stype{k},'FontSize',10, 'Color', col) ;
            end
        else
            %plot(0,0,'k*-') ;
        end
    else
        %plot(0,0,'k*-') ;
    end
    
    set(AXc,'XLim',XLIMS,'YLim',[0 1]) ;
    bc = get(gcf,'Color') ;
    set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
    return
end