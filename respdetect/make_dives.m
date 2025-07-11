function make_dives(taglist, dataPath, dive_thres)
    arguments
        taglist (1, :) cell
        dataPath (1,:) char
        dive_thres (1,:) double
    end
    % Identifies all dives in the record and saves this information to dive
    % table and to individual variables that will be useful for breath
    % detection later
    % 
    % Inputs:
    %   taglist  - Cell array of tag names
    %   dataPath - Base path to data (e.g., 'C:\my_data\')
    %   dive_thres - The minimum depth a dive must reach to be recorded as
    %   a dive
    %
    % Outputs:
    %   Saves a file in the data path under the species of interest in the "diving" folder. 
    %   This function saves no variables to the workspace. 
    %
    % Usage:
    %   make_dives(taglist, dataPath, dive_thres)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    
for k = 1:length(taglist);
    
    % Load in tag
    tag = taglist{k};
    
    speciesCode = tag(1:2);
    
    % Load in metadata
    load(strcat(dataPath, speciesCode, "\metadata\", tag, "md"));
    clear tag
    
    %Set path for prh files
    settagpath('prh',strcat(dataPath, speciesCode, '\prh'));
            
    % Load the existing prh file
    loadprh(metadata.tag);
    
    % Calculate time for entire tag deployment
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
    
    % Subset p to tag on and off times
    start_idx = find(abs(time_sec-metadata.tag_on)==min(abs(time_sec-metadata.tag_on)));
    end_idx = find(abs(time_sec-metadata.tag_off)==min(abs(time_sec-metadata.tag_off)));
    
    if end_idx == length(time_sec)
        end_idx = end_idx-1;
    end
    
    % Truncate p to just be tag on times
    p_tag = p(start_idx:end_idx);
    
    % Calculate time for tag on
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, p_tag);
    
    % Make a diving file
    diving_fname = strcat(dataPath, speciesCode, "\diving\", metadata.tag, "dives.mat");
    if isfile(diving_fname) == 1
        fprintf("A diving table exists for %s - go the next section!\n", metadata.tag)
    else
        fprintf("No diving table  exists for %s.\n", metadata.tag)
        str = input("Do you want to make a diving table now? (y/n)\n",'s');
        if strcmp(str, "y") == 1
            
            % Find dives
            T = finddives(p_tag,fs, [dive_thres, 1, 0]);
            
            if size(T, 1) <= 1
                display('Only 1 deep dive! Not continuing analysis...')
                
            else
                
                % Plot dives
                plot_dives(T, time_sec, p_tag);
                
                % Add back start index if needed to time variables
                if metadata.tag_on ~=0
                    T(:, [1:2, 4]) = T(:, [1:2, 4]) + metadata.tag_on;
                end
                
                % Calculate time for entire tag deployment
                [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
                               
                % Extract dive information from T
                for i = 1:size(T, 1)
                    
                    tag{i} = metadata.tag;
                    depth_thres(i) = dive_thres;
                    dive_num(i) = i;
                    dive_start(i) = T(i, 1);
                    dive_end(i) = T(i, 2);
                    max_depth(i) = T(i, 3);
                    time_maxdepth(i) = T(i, 4);
                    dive_dur(i) = dive_end(i) - dive_start(i);
                    
                    % Get dive start and end in indices
                    start_idx_dive = find(abs(time_sec-dive_start(i))==min(abs(time_sec-dive_start(i))));
                    end_idx_dive = find(abs(time_sec-dive_end(i))==min(abs(time_sec-dive_end(i))));

                end
                
                % Extract surface information from dive information
                for i = 1:size(T, 1)-1
                    surf_num(i) = i';
                    surf_start(i) = dive_end(i)';
                    surf_end(i) = dive_start(i+1)';
                    surf_dur(i) = surf_end(i)-surf_start(i);
                end
                surf_num(size(T, 1)) = NaN;
                surf_start(size(T, 1)) = NaN';
                surf_end(size(T, 1)) = NaN';
                surf_dur(size(T, 1)) = NaN';
                
                % Save dive variables to mat file
                save(strcat(dataPath, speciesCode, "\diving\", metadata.tag, "dives"), 'tag', 'depth_thres', 'dive_num', 'dive_start', 'dive_end', 'max_depth', 'time_maxdepth', 'dive_dur', 'surf_num', 'surf_start', 'surf_end', 'surf_dur');
                
                % Save dive variables as a table (analog to typical T
                % variable)
                Tab = table(tag', depth_thres', dive_num', dive_start', dive_end', max_depth', time_maxdepth', dive_dur', surf_num', surf_start', surf_end', surf_dur');
                Tab.Properties.VariableNames = {'tag', 'depth_thres', 'dive_num', 'dive_start', 'dive_end', 'max_depth', 'time_maxdepth', 'dive_dur', 'surf_num', 'surf_start', 'surf_end', 'surf_dur'};
                save(strcat(dataPath, speciesCode, "\diving\", metadata.tag, "divetable"), 'Tab')
                beep on; beep
                
                display('Dive detection complete!');
            end
            
            figfile = strcat(dataPath, speciesCode, '/figs/', metadata.tag, '_dives.fig');
            savefig(figfile); 
       end
    end
end

end