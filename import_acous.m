function [startcom, comdur, com, acous_start_idx, acous_end_idx] = import_acous(acousaud_filename)
    delimiter = '\t';
    formatSpec = '%f%f%C%[^\n\r]';
    
    fileID = fopen(acousaud_filename,'r');
    if fileID == -1
        display('There is no acoustic audit file');
        startcom = NaN;
        comdur = NaN;
        com = NaN;
        acous_start_idx = NaN;
        acous_end_idx = NaN;
    else
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
        fclose(fileID);
        
        startcom = dataArray{:, 1};
        comdur = dataArray{:, 2};
        com = dataArray{:, 3};
        
        clearvars delimiter formatSpec fileID dataArray ans;
        
        disp('Loaded acoustic audit...');
        
        for b = 1:length(com)
            [acous_start_val(b), acous_start_idx(b)] = min(abs(startcom(b) - time_sec));
            [acous_end_val(b), acous_end_idx(b)] = min(abs(startcom(b)+ comdur(b) - time_sec));
        end
        clear acous_start_val acous_end_val
    end
end
