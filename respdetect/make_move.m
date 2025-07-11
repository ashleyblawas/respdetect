function make_move(taglist, dataPath)
    arguments
        taglist (1, :) cell
        dataPath (1,:) char
    end
    % Calculates and saves movement variables used for breath detections
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
    %   make_dives(taglist, dataPath)
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
        
        if isfile(movement_fname) == 1 %Should be 1 for actual function
            fprintf("A movement table exists for %s - go the next section!\n", metadata.tag)
        else
            fprintf("No movement table  exists for %s.\n", metadata.tag)
            str = input("Do you want to make a movement table now? (y/n)\n",'s');
            
            if strcmp(str, "y") == 1
                
                % Setup directories
                [recdir, prefix, breathaud_filename] = setup_dirs(metadata.tag, metadata.tag_ver, dataPath);
                
                % Load the existing prh file
                loadprh(metadata.tag);
                
                %Calculate other vars
                [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
                
                % Calculate and save movement data
                calc_move(metadata.fs, Aw, p, dataPath, metadata.tag, pitch, roll, head)
            end
        end
    end
    
end