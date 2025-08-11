function [recdir, prefix, acousaud_filename] = setup_dirs(tag, tag_ver, dataPath)
    arguments
        tag (1, :) char
        tag_ver (1, :) char
        dataPath (1,:) char
    end
    % SETUP_DIRS Configures standard data and tool paths for a given tag deployment.
    %
    % This function sets up the necessary paths for working with a specific
    % deployment tag by assigning paths to recording directories, audit files,
    % and loading the appropriate dtagtools version (D2 or D3).
    %
    % Inputs:
    %   tag         - Tag name in standard format (e.g., 'gm08_143b')
    %   tag_ver     - Tag version ('D2', 'D3', or other)
    %   dataPath    - Base path to your data repository (e.g., 'C:\my_data\')
    %
    % Outputs:
    %   recdir             - Full path to the recording directory for the tag
    %   prefix             - Tag prefix used for naming outputs
    %   acousaud_filename  - Full path to the acoustic audit file for the tag
    %
    % Usage:
    %   [recdir, prefix, acousaud_filename] = setup_dirs('gm08_143b', 'D2', 'C:\my_data\')
    %
    % Behavior:
    %   - Constructs full path to the recording folder using species/year from tag.
    %   - Constructs path to the acoustic audit file.
    %   - Adds appropriate dtagtools version (D2 or D3) to MATLAB path.
    %   - Uses `settagpath` to configure 'prh' and 'audit' paths for Dtag tools.
    %
    % Assumptions:
    %   - Function is located within the 'respdetect' directory tree.
    %   - The `dtagtools` folder exists inside 'respdetect' and contains both D2 and D3 versions.
    %   - The `settagpath` function is available and in the path.
    %
    % Errors:
    %   - Throws an error if 'respdetect' directory cannot be found upward from current file.
    %
    % Author: Ashley Blawas
    % Last Updated: August 11, 2025
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

