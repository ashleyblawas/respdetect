function [est_time_tagoff] = get_tag_off(time_sec, p) 

plot(time_sec, p, 'b'); grid; hold on;
set(gca,'Ydir','reverse')
title('Dive Profile')
xlabel('Time (s)'); ylabel('Depth (m)');
ax = gca;
ax.XRuler.Exponent = 0;

clear est_time_tagoff
prompt = {'Enter time of TAG OFF (in seconds):'};
dlgtitle = 'TAG OFF time';
dims = [1 50]; opts.WindowStyle = 'normal'; opts.Resize = 'on';
est_time_tagoff = inputdlg(prompt,dlgtitle,dims,{'0'}, opts);

close;

end