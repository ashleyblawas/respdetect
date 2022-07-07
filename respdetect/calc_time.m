% Calculate time variables
function [time_sec, time_min, time_hour] =calc_time(fs, p)
    % Get times
    time_sec = 0: 1/fs: (1/fs)*length(p)-(1/fs); %Get time in seconds
    time_min = time_sec./60; %Get time in minutes
    time_hour = time_min./60; %Get time in hours
    

end