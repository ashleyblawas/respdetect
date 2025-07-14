function taglist = load_data(dataPath, speciesCode)
    arguments
        dataPath (1,:) char
        speciesCode (1, 2) char
    end
    % Determines the prh files that will be loaded for analysis
    %
    % Inputs:
    %   speciesCode  - Two-letter species code (e.g., 'gm', 'mn', 'tt')
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %
    % Usage:
    %   load_data('C:\my_data\','gm')
    %
    % Assumptions:
    %   - This function is located somewhere inside the respdetect directory.
    %   - SpeciesCode is a two letter code that exists as a subfolder within
    %   the datapath and within this folder is a prh folder with your records
    %   of interest
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Build full path to prh files for the given species
    prhFolder = fullfile(dataPath, speciesCode, 'prh');
    
    % Check if folder exists
    if ~isfolder(prhFolder)
        error('The prh folder does not exist: %s', prhFolder);
    end
    
    % Look for .mat files in the prh folder
    filePattern = fullfile(prhFolder, '*.mat');
    theFiles = dir(filePattern);
    
    if isempty(theFiles)
        error('No prh .mat files found in %s', prhFolder);
    end
    
    % Extract file names and remove 'prh.mat' suffix
    fileNames = {theFiles.name};
    taglistFull = erase(fileNames, 'prh.mat');
    
    % Ask the user to select which tags to load
    [selectedIdx, ok] = listdlg(...
        'PromptString', sprintf('Select prh files for species: %s', speciesCode), ...
        'SelectionMode', 'multiple', ...
        'ListString', taglistFull);
    
    if ~ok || isempty(selectedIdx)
        error('No prh files selected. Exiting.');
    end
    
    % Return selected tag names (without .mat)
    taglist = taglistFull(selectedIdx);
    
    % Display the result
    disp('You have selected the following files to analyze:');
    disp(string(taglist'));
    
    % Make new folders in data path if they don't already exist
    flds = ["metadata", "diving", "movement", "breaths", "figs", "audit"];
    for i = 1:length(flds)
        if not(isfolder(strcat(dataPath, speciesCode, '\', flds(i))))
            mkdir(strcat(dataPath, speciesCode, '\', flds(i)));
        end
    end
    
    
end