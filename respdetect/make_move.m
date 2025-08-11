function make_move(taglist, dataPath)
    arguments
        taglist (1, :) cell
        dataPath (1,:) char
    end
    % MAKE_MOVE Computes and saves movement features used in breath detection.
    %
    %   This function loops over a list of tag deployments and generates movement-related
    %   metrics (e.g., jerk, entropy, orientation derivatives) from tri-axial accelerometer
    %   and orientation signals. These metrics are essential for detecting breaths during
    %   shallow surfacings.
    %
    %   For each tag, this function loads the PRH file, computes movement metrics, and
    %   saves the results in the appropriate "movement" folder for later analysis.
    %
    %   Inputs:
    %     taglist   - Cell array of tag names (e.g., {'gm01_001a', 'mn02_003b'})
    %                 Each tag must correspond to a valid PRH file under the species-specific
    %                 folder in the provided data path.
    %
    %     dataPath  - Base directory where tag data are stored (character array).
    %                 Must include species folders (e.g., 'gm', 'mn') containing:
    %                   /prh/      - PRH sensor data (.mat files)
    %                   /movement/ - Output folder for movement metrics (auto-created if missing)
    %
    %   Outputs:
    %     - Saves a .mat file for each tag to:
    %         [dataPath / speciesCode / 'movement' / tagname '_movement.mat']
    %
    %     - The saved file includes variables such as:
    %         filtered acceleration (2–15 Hz bandpass or >2 Hz highpass)
    %         orientation derivatives (pitch, roll, heading)
    %         Shannon entropy and smoothed entropy
    %         jerk (acceleration derivative magnitude)
    %
    %     - No variables are returned to the MATLAB workspace.
    %
    %   Assumptions:
    %     - PRH files are correctly formatted and contain required fields:
    %         Aw (acceleration), pitch, roll, head, p (depth), fs (sampling rate)
    %     - NaNs in sensor signals represent missing or invalid data and are handled internally
    %     - The movement folder will be created if it does not already exist
    %
    %   Usage:
    %     make_move(taglist, dataPath)
    %
    %   Example:
    %     taglist = {'tt01_001a', 'tt01_002a'};
    %     dataPath = 'D:\whaledata\';
    %     make_move(taglist, dataPath);
    %
    %   See also: calc_move, make_metadata, load_data
    %
    %   Author: Ashley Blawas
    %   Last Updated: August 11, 2025
    %   Stanford University
    
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