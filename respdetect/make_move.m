function make_move(taglist, dataPath)
    arguments
        taglist (1, :) cell
        dataPath (1,:) char
    end
    % Calculates and saves movement variables used for breath detections.
    %
    % Inputs:
    %   taglist  - Cell array of tag names
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %
    % Outputs:
    %   Saves a file in the data path under the species of interest in the "movement" folder.
    %   This function saves no variables to the workspace.
    %
    % Usage:
    %   make_moves(taglist, dataPath)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Load in metadata and prh
    for k = 1:length(taglist)
        
        % Load in tag
        tag = taglist{k};
        
        speciesCode = tag(1:2);
        
        % Load in metadata
        load(strcat(dataPath, speciesCode, "\metadata\", tag, "md"));
        clear tag
        
        % Make movement filename
        movement_fname = strcat(dataPath, speciesCode, "\movement\", metadata.tag, "movement.mat");
        
        if isfile(movement_fname)
            fprintf("A movement file already exists for %s.\n", metadata.tag);
            
            % Prompt user for action
            disp("Choose what you want to do:");
            disp("1. Overwrite existing movement file [o]");
            disp("2. Append custom suffix and save as new file [a]");
            disp("3. Skip and continue [c]");
            
            choice = lower(input("Enter 'o', 'a', or 'c': ", 's'));
            
            switch choice
                case 'c'
                    fprintf("Skipping movement file creation for %s.\n", metadata.tag);
                    return
                case 'a'
                    % Append suffix to filename
                    suffix = input("Enter a suffix to append (e.g., _v2): ", 's');
                    movement_fname = strcat(dataPath, speciesCode, "\movement\", metadata.tag, suffix, "movement.mat");
                case 'o'
                    % Overwrite: continue without changes
                otherwise
                    warning("Invalid input. Skipping movement file creation.");
                    return
            end
        else
            fprintf("No movement file exists for %s.\n", metadata.tag);
            str = input("Do you want to make movement files now? (y/n): ", 's');
            if ~strcmpi(str, "y")
                return
            end
        end
        
        % Setup directories
        [~, ~, ~] = setup_dirs(metadata.tag, metadata.tag_ver, dataPath);
        
        % Load the existing prh file
        loadprh(metadata.tag);
        
        % Calculate and save movement data
        calc_move(metadata.fs, Aw, p, pitch, roll, head, movement_fname)
    end
end