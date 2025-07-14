function [recdir, prefix, acousaud_filename] = setup_dirs(tag, tag_ver, dataPath)
    arguments
        tag (1, :) char
        tag_ver (1, :) char
        dataPath (1,:) char
    end
    % Sets up the typical Matlab directories for a given record including
    % audit, cal, and prh
    %
    % Inputs:
    %   tag - In the usual tag form "gm08_143b"
    %   tag_ver - Either D2, D3, or other to know which Matlab tools to use
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %
    % Usage:
    %  [recdir, prefix, acousaud_filename] = setup_dirs('gm08_143b', 'D2', 'C:\my_data\'))
    %
    % Assumptions:
    %   - This function is located somewhere inside the respdetect directory.
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
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
    recdir = strcat(dataPath, sp_year, '\', tag);
    % Set deployment name, probably the same as the parent folder
    deploy_name = tag;
    prefix = tag;
    speciesCode = tag(1:2);
    
    % Set name of acoustic audit file
    acousaud_filename = strcat(dataPath, speciesCode, '\audit\', tag, '_acousticaud.txt');
    
    if strcmp(tag_ver, 'D3') == 1
        addpath(genpath(strcat(mat_tools_path, '\d3'))); %Add all of your tools to the path
    elseif strcmp(tag_ver, 'D2') == 1
        addpath(genpath(strcat(mat_tools_path, '\dtag2'))); %Add all of your tools to the path
    end
    
    %% Set other paths
    %Set path for prh files
    settagpath('prh',strcat(dataPath, speciesCode, '\prh'));
    
    %Set path for audit files
    settagpath('audit',strcat(dataPath, speciesCode,'\audit'));
    
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

