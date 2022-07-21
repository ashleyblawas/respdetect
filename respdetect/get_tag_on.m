function [est_time_tagon] = get_tag_on(time_sec, p) 

plot(time_sec, p, 'b'); grid; hold on;
set(gca,'Ydir','reverse')
title('Dive Profile')
xlabel('Time (s)'); ylabel('Depth (m)');
ax = gca;
ax.XRuler.Exponent = 0;

clear est_time_tagon
prompt = {'Enter time of TAG ON (in seconds):'};
dlgtitle = 'TAG ON time';
dims = [1 50]; opts.WindowStyle = 'normal'; opts.Resize = 'on';
est_time_tagon = inputdlg(prompt,dlgtitle,dims,{'0'}, opts);

close;

end