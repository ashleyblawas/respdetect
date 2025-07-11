function make_metadata(taglist, dataPath)
    arguments
        taglist (1, :) cell
        dataPath (1,:) char
    end
    % Loops over taglist and creates metadata files if not present.
    %
    % Inputs:
    %   taglist  - Cell array of tag names
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %
    % Outputs:
    %   Saves a file in the data path under the species of interest in the "metadata" folder. 
    %   This function saves no variables to the workspace. 
    %
    % Usage:
    %   make_metadata(taglist, dataPath)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    
    for k = 1:length(taglist);
        
        % Save tag name
        if exist('k','var') == 1
            tag = taglist{k};
        else
            tag = taglist{1};
        end
        
        speciesCode = tag(1:2);
        
        % Make metadata file
        metadata_fname = strcat(dataPath, speciesCode, "\metadata\", tag, "md.mat");
        
        % If it already exists don't make it again
        if isfile(metadata_fname) == 1
            fprintf("A metadatafile exists for %s - go the next section!\n", tag)
        else % Otherwise, make and save the metadata file
            fprintf("No metadata file exists for %s.\n", tag)
            str = input("Do you want to make a metadata file now? (y/n)\n",'s');
            if strcmp(str, "y") == 1
                
                %Set path for prh files
                settagpath('prh',strcat(dataPath, speciesCode,'\prh'));
                
                % Load the tag's prh file
                loadprh(tag);
                
                %Print out the fs so you can check it's what you expect
                fprintf('fs = %i Hz\n', fs);
                
                % Calculate time variables from full duration of tag deployment
                [time_sec, time_min, time_hour] = calc_time(fs, p);
                
                % Print out duration of tag
                totalSeconds = max(time_sec); % Convert to total seconds
                
                % Convert to hours, minutes, seconds
                hours    = floor(totalSeconds / 3600);
                minutes  = floor(mod(totalSeconds, 3600) / 60);
                sec  = round(mod(totalSeconds, 60));
                
                % Display formatted record duration
                fprintf('Record duration (hh:mm:ss): %.0f:%2.0f:%02d.\n', ...
                    hours, minutes, sec);
                
                % Designate tag on and off time
                [tag_on] = get_tag_on(time_sec, p, fs);
                [tag_off] = get_tag_off(time_sec, p, fs);
                
                % Calculate tag on duration
                tag_dur = datestr(seconds(tag_off-tag_on),'HH:MM:SS');
                
                % Display formatted tag on duration
                fprintf('Tag on duration (hh:mm:ss): %s.\n', ...
                    tag_dur);
                
                % Designate the tag version
                prompt = {'Enter DTAG version (D2 or D3 or CATS):'};
                dlgtitle = 'Input';
                dims = [1 35];
                definput = {'CATS'};
                answer = inputdlg(prompt,dlgtitle,dims,definput);
                tag_ver = answer{1};
                clear prompt dlgtitle dims definput answer
                
                % Setup directories
                [recdir, prefix, acousaud_filename] = setup_dirs(tag, tag_ver, dataPath);
                
                metadata.tag = tag;
                metadata.recdir = recdir;
                metadata.prefix = prefix;
                metadata.fs = fs; 
                metadata.tag_ver = tag_ver; 
                metadata.tag_on = tag_on;
                metadata.tag_off = tag_off;
                metadata.tag_dur = tag_dur;
                metadata.acousaud_filename = acousaud_filename;
                
                % Make a metadata file
                save(strcat(dataPath, speciesCode, "\metadata\", tag, "md"), "metadata")
                fprintf("Made and saved a tag metadata file\n")
            end
        end
    end 
    
end