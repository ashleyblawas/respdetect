function [filtered_acc] = filter_acc(acc, fs, upper)
    % Function to bandpass filter acceleration signal
    fny = fs/2;
    pass = [0.2, upper];
    [b,a]=butter(5,pass/fny,'bandpass');
    filtered_acc=filter(b,a,acc);  %filtered signal
end

