function taglist = load_data(dataPath, speciesCode)
    arguments
        dataPath (1,:) char
        speciesCode (1, 2) char
    end
    % LOAD_DATA Retrieves a list of PRH (sensor) files for a specified species.
    %
    %   This function searches the data directory for PRH `.mat` files corresponding to a
    %   specific species and returns a list of tag names for use in subsequent analyses.
    %
    %   Inputs:
    %       dataPath    - Character array specifying the base path to the data directory.
    %                     Example: 'C:\my_data\' or '/Users/username/data/'
    %       speciesCode - Two-letter species code (character array) used to identify the
    %                     subfolder within `dataPath`. This should match a folder name within
    %                     the base path that contains the species-specific data.
    %                     Example: 'gm' (pilot whale), 'mn' (humpback whale), 'tt' (bottlenose dolphin)
    %
    %   Output:
    %       taglist     - Cell array of strings or character vectors representing the tag IDs
    %                     or file names (without the `.mat` extension) found in the PRH folder.
    %
    %   Example:
    %       taglist = load_data('C:\my_data\', 'gm');
    %
    %   Assumptions:
    %       - The `dataPath` contains a subfolder named with the given `speciesCode`.
    %       - Inside that species folder, there is a `prh` subfolder containing `.mat` files.
    %       - The PRH files contain processed tag data with naming convention: <tag>.mat
    %       - This function is used within the context of the RespDetect pipeline.
    %
    %   See also: load, dir, fullfile
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
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