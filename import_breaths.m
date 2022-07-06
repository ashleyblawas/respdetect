% import_breaths
function [breath_times, bp, breath_idx]=import_breaths(breathaud_filename, time_sec)
    delimiter = '\t';
    formatSpec = '%f%*s%C%[^\n\r]';
    
    fileID = fopen(breathaud_filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
    fclose(fileID);
    
    breath_times = dataArray{:, 1};
    bp = dataArray{:, 2};
    
    clearvars delimiter formatSpec fileID dataArray ans;
    
    for i = 1:length(breath_times)
        [minValue(i), breath_idx(i)] = min(abs(breath_times(i) - time_sec));
        %plot(time_sec(breath_idx(i)), p(breath_idx(i)), '*', 'Color', 'r'); hold on;
    end
    
    fprintf('Loaded %i breaths\n', length(breath_idx));
end