function set_paths(dataPath)
    arguments
        dataPath (1,:) char = ''  % Make input optional
    end
    % Adds respdetect, dtagtools, and user-defined data path by taking in
    % the data path and the tool path.
    %
    % Inputs:
    %   dataPath - Base path to data (e.g., 'C:\Documents\my_data\')
    %              If empty or not provided, defaults to ../tests from here
    %
    % Usage:
    %   set_paths();               % Uses default tests directory
    %   set_paths('');            % Same as above
    %   set_paths('path/to/data') % Uses user-specified path
    %
    % Assumptions:
    %   - This function is located somewhere inside the respdetect directory.
    %   - The dtagtools folder is at: respdetect/dtagtools/
    %   - dataPath is an absolute path provided by the user.
    
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Get the full path of this set_paths.m file
    currentFile = mfilename('fullpath');
    [currentDir, ~, ~] = fileparts(currentFile);
    
    % Go one level up to reach repo root
    repoRoot = fileparts(currentDir);             % .../ (repo root)
    
    % Define paths
    respdetectPath = fullfile(repoRoot, 'respdetect');
    dtagtoolsPath  = fullfile(respdetectPath, 'dtagtools');

    % Resolve data path
    if isempty(dataPath)
        dataPath = fullfile(repoRoot, 'tests');
    elseif ~isfolder(dataPath)
        % Assume it's a relative path, resolve it from current working dir
        dataPath = fullfile(pwd, dataPath);
    end
    
    % Define dtagtools path relative to respdetect
    dtagtoolsPath = fullfile(respdetectPath, 'dtagtools');
    
    % Validate paths
    if ~isfolder(respdetectPath)
        error('respdetect path not found at: %s', respdetectPath);
    end
    if ~isfolder(dtagtoolsPath)
        error('dtagtools path not found at: %s', dtagtoolsPath);
    end
    if ~isfolder(dataPath)
        error('The data path does not exist: %s', dataPath);
    end

    % Add paths to MATLAB
    addpath(genpath(respdetectPath));
    addpath(genpath(dtagtoolsPath));
    addpath(dataPath);  % Flat add for data

    % Display confirmation
    fprintf('Added respdetect path: %s\n', respdetectPath);
    fprintf('Added dtagtools path:  %s\n', dtagtoolsPath);
    fprintf('Added data path:       %s\n', dataPath);
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
