function [time_sec, time_min, time_hour] = calc_time(fs, p)
    % CALC_TIME Generates time vectors corresponding to pressure (or sensor) data.
    %
    %   This function calculates time vectors in seconds, minutes, and hours
    %   based on the sampling rate and the length of the input signal.
    %
    %   Inputs:
    %     fs - Sampling rate in Hz (scalar)
    %     p  - Nx1 vector (e.g., pressure or depth data), used to determine duration
    %
    %   Outputs:
    %     time_sec  - Time vector in seconds (1 x N)
    %     time_min  - Time vector in minutes (1 x N)
    %     time_hour - Time vector in hours (1 x N)
    %
    %   Example:
    %     [t_sec, t_min, t_hr] = calc_time(50, p);
    %
    %   Notes:
    %     - Assumes evenly sampled data.
    %     - Time vector length is equal to the length of `p`.
    %
    %   Author: Ashley Blawas
    %   Last Updated: 8/11/2025
    %   Stanford University
    
    time_sec = 0: 1/fs: (1/fs)*length(p)-(1/fs); %Get time in seconds
    time_min = time_sec./60; %Get time in minutes
    time_hour = time_min./60; %Get time in hours
    
end