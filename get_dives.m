%get_dives

function [dive_thres, T]=get_dives(p, fs, dive_thres)
    prompt = {'Enter dive threshold (in meters):'};
    dlgtitle = 'Dive threshold';
    dims = [1 50]; opts.WindowStyle = 'normal'; opts.Resize = 'on';
    %dive_thres = inputdlg(prompt,dlgtitle,dims,{'5'}, opts);
    %dive_thres = str2double(dive_thres);
    
    T = finddives(p,fs, [dive_thres, 1, 0]);
end