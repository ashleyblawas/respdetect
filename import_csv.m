function [file_info, surf_durs, dive_durs, dive_start, dive_end, breath_cue]=import_csv()
    % Import tag information
    [filename,pathloc] = uigetfile('*.csv', 'MultiSelect', 'on');
    delimiter = ',';
    endRow = 3;
    
    formatSpec = '%s%s%s%s%*s%[^\n\r]';
    file_info= [];
    
    if iscell(filename) ==1
        for i = 1:size(filename, 2)
            fileID = fopen(filename{i},'r');
            dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
            fclose(fileID);
            
            file_info(i).tag = [dataArray{1, 2}(1)];
            file_info(i).fs = [dataArray{1, 2}(2)];
            file_info(i).dive_thres = [dataArray{1, 2}(3)];
        end
        
    else
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
        fclose(fileID);
        
        file_info.tag = [dataArray{1, 2}(1)];
        file_info.fs = [dataArray{1, 2}(2)];
        file_info.dive_thres = [dataArray{1, 2}(3)];
    end
    %% Clear temporary variables
    clearvars delimiter endRow formatSpec fileID dataArray ans i path;
    
    % Now need to import actual data
    opts = delimitedTextImportOptions("NumVariables", 5);
    opts.DataLines = [6, Inf];
    opts.Delimiter = ",";
    
    opts.VariableNames = ["surf_durs", "dive_durs", "dive_start", "dive_end", "breath_cue"];
    opts.VariableTypes = ["double", "double", "double", "double", "double"];
    
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    
    %% Convert to output type
    if iscell(filename) == 0 
        tbl = readtable(strcat(pathloc, filename), opts);
        surf_durs = tbl.surf_durs;
        dive_durs = tbl.dive_durs;
        dive_start = tbl.dive_start;
        dive_end = tbl.dive_end;
        breath_cue = tbl.breath_cue;
    else
        for i = 1:length(filename)
            tbl = readtable(strcat(pathloc, filename{i}), opts);
            surf_durs{i} = tbl.surf_durs;
            dive_durs{i} = tbl.dive_durs;
            dive_start{i} = tbl.dive_start;
            dive_end{i} = tbl.dive_end;
            breath_cue{i} = tbl.breath_cue;
        end
    end
    
    %% Clear temporary variables
    clear opts tbl filename pathloc
end