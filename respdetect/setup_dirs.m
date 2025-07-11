%%  Function to setup directories and such

function [recdir, prefix, acousaud_filename] = setup_dirs(tag, tag_ver, data_path)
    
    % Get the full path of this setup_dirs.m file
    currentFile = mfilename('fullpath');
    [currentDir, ~, ~] = fileparts(currentFile);
    
    % Find 'respdetect' root
    respdetectPath = locate_folder_up(currentDir, 'respdetect');
    if isempty(respdetectPath)
        error('Could not locate the "respdetect" root folder.');
    end
    
    % Define dtagtools path relative to respdetect
    mat_tools_path = fullfile(respdetectPath, 'dtagtools');
    
    %% Use tag name to assign directories and filenames
    sp_year = tag(1:4);
    % Set parent directory
    recdir = strcat(data_path, sp_year, '\', tag); 
    % Set deployment name, probably the same as the parent folder
    deploy_name = tag; 
    prefix = tag;
    speciesCode = tag(1:2);
    
    % Set name of acoustic audit file
    acousaud_filename = strcat(data_path, speciesCode, '\audit\', tag, '_acousticaud.txt'); 
    
    if strcmp(tag_ver, 'D3') == 1
        addpath(genpath(strcat(mat_tools_path, '\d3'))); %Add all of your tools to the path
    elseif strcmp(tag_ver, 'D2') == 1
        addpath(genpath(strcat(mat_tools_path, '\dtag2'))); %Add all of your tools to the path
        settagpath('audio',strcat(data_path, speciesCode),'cal',strcat(data_path, speciesCode,'\cal'));
    end
    
    %% Set other paths
    %Set path for prh files
    settagpath('prh',strcat(data_path, speciesCode, '\prh')); 
    
     %Set path for audit files
    settagpath('audit',strcat(data_path, speciesCode,'\audit'));
    
end

function folderPath = locate_folder_up(startPath, targetFolder)
    % Move up to find a folder named targetFolder
    folderPath = '';
    currentPath = startPath;
    while true
        [parentPath, currentName, ~] = fileparts(currentPath);
        if strcmpi(currentName, targetFolder)
            folderPath = currentPath;
            return;
        end
        if strcmp(parentPath, currentPath)
            return;  % Reached root
        end
        currentPath = parentPath;
    end
end

