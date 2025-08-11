function set_paths(dataPath)
    arguments
        dataPath (1,:) char = ''  % Make input optional
    end
    % SET_PATHS Adds core directories (respdetect, dtagtools, and data path) to MATLAB path.
    %
    % This function sets up the working environment by adding the necessary toolboxes and
    % user data directory to the MATLAB path. It assumes the script is located within
    % the `respdetect` directory and the `dtagtools` toolbox is within it.
    %
    % Inputs:
    %   dataPath - (Optional) Absolute or relative path to the user’s data directory.
    %              If not provided or empty, it defaults to a 'tests' directory located
    %              one level above the respdetect folder.
    %
    % Behavior:
    %   - Adds the full `respdetect` directory and its subfolders to the MATLAB path.
    %   - Adds the `dtagtools` folder to the MATLAB path.
    %   - Adds the user-specified or default data directory to the path (non-recursive).
    %
    % Usage:
    %   set_paths();                    % Uses default ../tests directory
    %   set_paths('');                 % Same as above
    %   set_paths('C:\my_data\')       % Adds specified absolute data path
    %   set_paths('relative_data')     % Resolves and adds relative path from current folder
    %
    % Assumptions:
    %   - This function resides somewhere within the `respdetect` directory.
    %   - The `dtagtools` folder exists inside `respdetect` (e.g., respdetect/dtagtools).
    %   - The data directory exists and is accessible.
    %
    % Errors:
    %   - Throws an error if the respdetect or dtagtools folders are not found.
    %   - Throws an error if the specified or default data directory does not exist.
    %
    % Author: Ashley Blawas
    % Last Updated: August 11, 2025
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