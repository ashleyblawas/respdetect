function    subplot_zoom(xlim)
%
%    subplot_zoom(xlim)
%

if nargin==0,
   xlim = get(gca,'XLim') ;
end

ax = get(gcf,'Children') ;
k = strcmp(get(ax,'Type'),'axes') ;
set(ax(k),'XLim',xlim)
set(ax(k),'YLimMode','auto')
