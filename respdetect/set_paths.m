function set_paths(dataPath)
    arguments
        dataPath (1,:) char
    end
    % Adds respdetect, dtagtools, and user-defined data path by taking in only
    % data path.
    %
    % Inputs:
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %
    % Usage:
    %   set_paths('C:/Users/YourName/Documents/data')
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
    
    % Find 'respdetect' root
    respdetectPath = locate_folder_up(currentDir, 'respdetect');
    if isempty(respdetectPath)
        error('Could not locate the "respdetect" root folder.');
    end
    
    % Define dtagtools path relative to respdetect
    dtagtoolsPath = fullfile(respdetectPath, 'dtagtools');
    
    % Check if folders exist
    if ~isfolder(dtagtoolsPath)
        error('The dtagtools path does not exist at: %s. Please move dtagtools here.', dtagtoolsPath);
    end
    if ~isfolder(dataPath)
        error('The data path does not exist here: %s', dataPath);
    end
    
    % Add paths to MATLAB
    addpath(genpath(respdetectPath));
    addpath(genpath(dtagtoolsPath));
    addpath(dataPath);  % Flat add for data
    
    % Display status
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
