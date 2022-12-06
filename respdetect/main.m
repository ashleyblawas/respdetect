%%% The main script for running respdetect

%%% Author: Ashley Blawas
%%% Date: July 6, 2022
%%% Duke University

%% Step 1: Set paths and tag variables
% Clear workspace and command window and close all figures
clear; clc; close all

% Have user direct to paths.txt
[file, path] = uigetfile('*.txt', 'Select the paths.txt file from respdetect');

% Import information from paths.txt
fileID = fopen(strcat(path, file));
formatSpec = '%s';
txt = textscan(fileID,'%s','delimiter','\n'); txt = txt{1};
fclose(fileID);

clear fileID formatSpec file path

hdrlines = [];
strtemp = strfind(txt, "##");
for i = 1:length(strtemp)
    if strtemp{i} == 1
        hdrlines = [hdrlines, i];
    end
end

% Identify paths to tools and data - EDIT THIS FOR YOUR MACHINE
tools_path = txt{hdrlines(1)+1};
mat_tools_path = txt{hdrlines(2)+1};
data_path = txt{hdrlines(3)+1};
clear strtemp hdrlines txt i

% Add folders to path
cd(tools_path)
addpath(genpath(tools_path)); 
addpath(genpath(mat_tools_path)); 
addpath(genpath(data_path)); 

% Save tag names to variable
[file] = uigetfile(strcat(data_path, '\prh\*.mat'),...
   'Select one or more prh files for tags to analyze', ...
   'MultiSelect', 'on');

if iscell(file)==1
    for i = 1:length(file)
        taglist{i} = file{i}(1:9);
    end
    clear i file
else
    taglist = {file(1:9)};
end


display('You have selected:')
display(cell2mat(taglist'))

% Make new folders in data path if they don't already exist
flds = ["metadata", "diving", "movement", "breaths", "figs", "audit"];
for i = 1:length(flds)
    if not(isfolder(strcat(data_path, '\', flds(i))))
        mkdir(strcat(data_path, '\', flds(i)));
    end
end
clear flds i

%% Step 2: Make metadata file

for k = 1:length(taglist);
    
    % Save tag name
    if exist('k','var') == 1
        tag = taglist{k};
    else
        tag = taglist{1};
    end
    
    % Make metadata file
    metadata_fname = strcat(data_path, "\metadata\", tag, "md.mat");
    if isfile(metadata_fname) == 1
        fprintf("A metadatafile exists for %s - go the next section!\n", tag)
    else
        fprintf("No metadata file exists for %s.\n", tag)
        str = input("Do you want to make a metadata file now? (y/n)\n",'s');
        if strcmp(str, "y") == 1
            
            %Set path for prh files
            settagpath('prh',strcat(data_path,'\prh'));
            
            % Load the tag's prh file
            loadprh(tag);
            
            %Print out the fs so you can check it's what you expect
            fprintf('fs = %i Hz\n', fs);
            
            % Calculate time variables from full duration of tag deployment
            [time_sec, time_min, time_hour] =calc_time(fs, p);
            
            % Print out duration of tag
            fprintf('The full tag record is %i hours, %i minutes, %2.0f seconds\n', floor(max(time_hour)),...
            floor(max(time_min)-floor(max(time_hour))*60), floor(max(time_sec))-floor(max(time_hour))*60*60-60*(floor(max(time_min)-floor(max(time_hour))*60)));
            
            % Designate tag on and off time
            [time_tagon] = get_tag_on(time_sec, p);
            [time_tagoff] = get_tag_off(time_sec, p);
            tag_on = str2num(cell2mat(time_tagon));
            tag_off = str2num(cell2mat(time_tagoff));
            
            % Designate the tag version
            prompt = {'Enter DTAG version (D2 or D3):'};
            dlgtitle = 'Input';
            dims = [1 35];
            definput = {'D2'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            tag_ver = answer{1};
            clear prompt dlgtitle dims definput answer
            
            % Calculate tag on duration
            tag_dur = datestr(seconds(tag_off-tag_on),'HH:MM:SS');
            
            % Setup directories
            [recdir, prefix, acousaud_filename] = setup_dirs(tag, tag_ver, data_path, mat_tools_path);
            
            % Make a metadata file
            [metadata] = make_metadata(tag, recdir, prefix, fs, tag_ver, acousaud_filename, tag_on, tag_off);
            save(strcat(data_path, "\metadata\", tag, "md"), 'tag', 'recdir', 'prefix', 'fs', 'tag_ver', 'tag_on', 'tag_off', 'tag_dur', 'acousaud_filename')
            fprintf("Made and saved a tag metadata file\n")
        end
        
    end
end

% Clear variables that are now saved in the metadata structure
clear tag prefix recdir fs tag_ver acousaud_filename tag_on tag_off tag_dur metadata_fname str

%% Step 3: Find dives
for k = 1:length(taglist);
    
    % Load in tag
    tag = taglist{k};
    
    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
    
    %Set path for prh files
    settagpath('prh',strcat(data_path,'\prh'));
            
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
    p_tag = p(start_idx:end_idx);
    
    % Calculate time for entire tag deployment
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, p_tag);
    
    % Make a diving file
    diving_fname = strcat(data_path, "\diving\", metadata.tag, "dives.mat");
    if isfile(diving_fname) == 1
        fprintf("A diving table exists for %s - go the next section!\n", metadata.tag)
    else
        fprintf("No diving table  exists for %s.\n", metadata.tag)
        str = input("Do you want to make a diving table now? (y/n)\n",'s');
        if strcmp(str, "y") == 1
            
            % Set dive threshold and find dives
            prompt = {'Enter a dive threshold in meters:'};
            dlgtitle = 'Input';
            dims = [1 35];
            definput = {'5'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            dive_thres = str2num(answer{1});
            clear prompt dlgtitle dims definput answer
            
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
                    
                    % Calculate ODBA for each dive
                    if length(Aw(start_idx_dive:end_idx_dive, :)) > 5*round(fs/fh)
                        [e,w,Ah] = obda(Aw(start_idx_dive:end_idx_dive, :), metadata.fs, 0.25);
                    else
                        w = NaN;
                    end
                
                    dive_odba(i) = mean(w);
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
                save(strcat(data_path, "\diving\", metadata.tag, "dives"), 'tag', 'depth_thres', 'dive_num', 'dive_start', 'dive_end', 'dive_odba', 'max_depth', 'time_maxdepth', 'dive_dur', 'surf_num', 'surf_start', 'surf_end', 'surf_dur');
                
                % Save dive variables as a table (analog to typical T
                % variable)
                Tab = table(tag', depth_thres', dive_num', dive_start', dive_end', dive_odba', max_depth', time_maxdepth', dive_dur', surf_num', surf_start', surf_end', surf_dur');
                Tab.Properties.VariableNames = {'tag', 'depth_thres', 'dive_num', 'dive_start', 'dive_end', 'dive_odba', 'max_depth', 'time_maxdepth', 'dive_dur', 'surf_num', 'surf_start', 'surf_end', 'surf_dur'};
                save(strcat(data_path, "\diving\", metadata.tag, "divetable"), 'Tab')
                beep on; beep
                
                display('Dive detection complete!');
            end
            
            figfile = strcat(data_path, '/figs/', metadata.tag, '_dives.fig');
            savefig(figfile);
            
            clear tag depth_thres dive_num dive_start dive_end dive_odba w max_depth time_maxdepth dive_dur surf_num surf_start surf_end surf_dur
        end
    end
end

%% Step 4: Process movement data

% Load in metadata and prh 
for k = 1:length(taglist)
    
    % Load in tag
    tag = taglist{k};
    
    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
    
    % Make movement filename
    movement_fname = strcat(data_path, "\movement\", metadata.tag, "movement.mat");
    
     if isfile(movement_fname) == 1 %Should be 1 for actual function
        fprintf("A movement table exists for %s - go the next section!\n", metadata.tag)
    else
        fprintf("No movement table  exists for %s.\n", metadata.tag)
        str = input("Do you want to make a movement table now? (y/n)\n",'s');
        
        if strcmp(str, "y") == 1

            % Setup directories
            [recdir, prefix, breathaud_filename] = setup_dirs(metadata.tag, metadata.tag_ver, data_path, mat_tools_path);

            % Load the existing prh file
            loadprh(metadata.tag);

            %Calculate other vars
            [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);

            % Calculate and save movement data
            calc_move(metadata.fs, Aw, p, data_path, metadata.tag, pitch, roll, head)
        end
     end
end

%% Step 5: Detect breaths

for k = 1:length(taglist)
    
    %% Step 5a: Import tag data
    tag = taglist{k};

    % Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
    
    %Set path for prh files
    settagpath('prh',strcat(data_path,'\prh'));  
            
    % Load the existing prh file
    loadprh(metadata.tag);
    
    % Load in movement data
    load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"));
    
    % Load in diving data
    load(strcat(data_path, "\diving\", metadata.tag, "dives.mat"));
    load(strcat(data_path, "\diving\", metadata.tag, "divetable.mat"));
    
    % Calculate time variables for full tag deployment
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, p);
       
    %% Step 5b: Subset deployment to tag on time only
    
    start_idx = find(abs(time_sec-metadata.tag_on)==min(abs(time_sec-metadata.tag_on)));
    end_idx = find(abs(time_sec-metadata.tag_off)==min(abs(time_sec-metadata.tag_off)));
    
    if end_idx == length(time_sec)
        end_idx = end_idx-1;
    end
    
    % If the tag on time is when the tag is near the surface, we are going to
    % redefine the start idx as 10 seconds after the time the person
    % inputted to be safe  the reason for this being that the tag on 
    % result in a big jerk spike that will interfere with peak detection 
    % for breaths
    
    if p(start_idx)<5
        start_idx = find(p(start_idx:end_idx)>=5, 1)+start_idx;
    end
    
    % Subset p to only when tag is on
    p_tag = p(start_idx:end_idx);

    %% Step 5c: Identify surface periods
    % Smooth depth signal
    p_smooth = smoothdata(p, 'movmean', fs);
    p_smooth_tag = smoothdata(p_tag, 'movmean', fs);
    p_shallow = p_smooth_tag;
    
    % Remove any pressure data that is greater than 0.5 m and get indexes
    % of shallow periods
    p_shallow(p_smooth_tag>0.5) = NaN;
    p_shallow_idx = find(~isnan(p_shallow));
    
    % Plot smoothed depth for only time when tag is on
    figure('units','normalized','outerposition',[0 0 1 1]);
    p1 = plot(time_min(start_idx:end_idx), p_smooth_tag, 'k', 'LineWidth', 1); hold on
    set(gca, 'YDir', 'reverse');
    xlabel('Time (min)'); ylabel('Depth (m)');
    
    % Find start and end of surface periods
    p_shallow_breaks_end = find(diff(p_shallow_idx)>1);
    p_shallow_breaks_start = find(diff(p_shallow_idx)>1)+1;
    
    % Define variable to store surfacings
    p_shallow_ints = [[1; p_shallow_breaks_start], [p_shallow_breaks_end; length(p_shallow_idx)]];
    
    % Make third column which is duration of surfacing in indices
    p_shallow_ints(:, 3) = p_shallow_ints(:, 2) - p_shallow_ints(:, 1);
    
    % If surfacing is less than 1 second then remove it - likely not a surfacing anyway but a period
    % where depth briefly crosses above 0.25m
    delete_rows = find(p_shallow_ints(:, 3) < 1*metadata.fs);
    p_shallow_ints(delete_rows, :) = [];
    
    % If minima of a surfacing is not at least within a reasonable range of the
    % neighborhood (surrounding 4) of surfacings then remove it
    for r = length(p_shallow_ints):-1:1 % Go backwards so can delete as you go
        if r == length(p_shallow_ints)
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min1;
            min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
            min4 = min3;
        elseif r == length(p_shallow_ints)-1
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
            min4 = min3;
        elseif r == 2
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
            min3 = min4;
        elseif r == 1
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min1 = min2;
            min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
            min3 = min4;
        else
            min1 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-1, 1):p_shallow_ints(r-1, 2))),0));
            min2 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+1, 1):p_shallow_ints(r+1, 2))),0));
            min3 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r-2, 1):p_shallow_ints(r-2, 2))),0));
            min4 = min(max(p_shallow(p_shallow_idx(p_shallow_ints(r+2, 1):p_shallow_ints(r+2, 2))),0));
        end
        temp_sort = sort([min1, min2, min3, min4]);
        if min(p_shallow(p_shallow_idx(p_shallow_ints(r, 1):p_shallow_ints(r, 2))))>mean(temp_sort(1:2))+0.15
            p_shallow_ints(r, :) = [];
        end
    end
    
    % If these periods are less than 10 seconds then we say they are a "single
    % breath surfacing" otherwise they are a "logging surfacings"
    single_breath_surf_rows = find(p_shallow_ints(:, 3) <= 10*metadata.fs);
    logging_surf_rows = find(p_shallow_ints(:, 3) > 10*metadata.fs);
    
    % Define logging starts and ends
    logging_start_idxs = p_shallow_idx(p_shallow_ints(logging_surf_rows, 1));
    logging_end_idxs = p_shallow_idx(p_shallow_ints(logging_surf_rows, 2));
    
    logging_start_s = time_sec(start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows, 1)));
    logging_end_s = time_sec(start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows, 2)));
    logging_ints_s = [logging_start_s', logging_end_s'];
    
    %% Step 5d: Start plot of surfacing periods
    % Plot logging surfacings in pink
    if length(logging_surf_rows)>0
        for r = 1:length(logging_surf_rows)
            p2 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 1))-1:start_idx+p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 2))-1), p_shallow(p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(logging_surf_rows(r), 2))), 'm-', 'LineWidth', 2);
        end
        % Need this condition in case there is no logging
    else
        p2 = plot(NaN, NaN, 'm-', 'LineWidth', 2);
    end
    
    % Plot single breath surfacings in cyan
    for r = 1:length(single_breath_surf_rows)
        p3 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1))-1:start_idx+p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))-1), p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))), 'c-', 'LineWidth', 2);
    end
    
    % Plot start and end of surfacings with asteriks
    p4 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(:, 1))-1), p_shallow(p_shallow_idx(p_shallow_ints(:, 1))), 'g*');
    p5 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(:, 2))-1), p_shallow(p_shallow_idx(p_shallow_ints(:, 2))), 'r*');
    
    %% Step 5e: Detect breaths for single breath surfacings
    for r = length(single_breath_surf_rows):-1:1
        % Column four is the index of the minima
        p_shallow_ints(single_breath_surf_rows(r), 4) = p_shallow_ints(single_breath_surf_rows(r), 1) - 1 + find(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2))) == min(p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 1)):p_shallow_idx(p_shallow_ints(single_breath_surf_rows(r), 2)))), 1);
    end
    p_shallow_ints(logging_surf_rows, 4) = NaN;
    
    % Get the indicies of breaths assoicated with single surfacings from
    sbs_idxs = p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4));
    
    all_breath_locs.breath_idx = sbs_idxs;
    all_breath_locs.type = repmat("ss", length(sbs_idxs), 1);
    
    %% Step 5f: Plot breath detections for single breath surfacing
    p6 = plot(time_min(start_idx+p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4)-1)), p_shallow(p_shallow_idx(p_shallow_ints(single_breath_surf_rows, 4))), 'k*');
    
    legend([p1 p2 p3 p4 p5 p6],{'Dive depth' , 'Logging', 'Single-breath surfacing', 'Start of surfacing', 'End of surfacing', 'Breaths'}, 'Location', 'northeastoutside')
    
    % Save surface detections figure
    figfile = strcat(data_path, '/figs/', metadata.tag, '_surfacedetections.fig');
    savefig(figfile);
    
    %% Step 5g: Pre-process movement data for logging period breath detections
    
    % Want pitch to be positive for peak detect, so adding min
    pitch_smooth = pitch_smooth + abs(min(pitch_smooth));
    
    % Remove underwater portions of movement data
    for i = 1:length(jerk_smooth)
        if p(i)>5 % The higher this threshold is the better for promience detections
            jerk_smooth(i) = NaN;
            surge_smooth(i) = NaN;
            pitch_smooth(i) = NaN;
        end
    end
    
    % Subset tag on to tag off of pressure
    jerk_smooth=jerk_smooth(start_idx:end_idx);
    surge_smooth=surge_smooth(start_idx:end_idx);
    pitch_smooth=pitch_smooth(start_idx:end_idx);
    
    % Get indexes of p_smooth that are are logging with 5s window on each side
    idx_temp = zeros(length(p_smooth_tag), 1);
    for d = 1:length(logging_start_idxs);
        idx_temp(logging_start_idxs(d)-5*metadata.fs:logging_end_idxs(d)+5*metadata.fs) = 1;
    end
    
    % Remove jerk measurements for non-logging surfacing periods
    jerk_smooth(idx_temp==0) = NaN;
    surge_smooth(idx_temp==0) = NaN;
    pitch_smooth(idx_temp==0) = NaN;
    
    % Normalize pitch and jerk section-by-section
    % Divide signal into continue sections to rescale
    cont_sections_jerk = regionprops(~isnan(jerk_smooth), jerk_smooth, 'PixelValues');
    cont_sections_surge = regionprops(~isnan(surge_smooth), surge_smooth, 'PixelValues');
    cont_sections_pitch = regionprops(~isnan(pitch_smooth), pitch_smooth, 'PixelValues');
    cont_sections_idx = regionprops(~isnan(jerk_smooth), jerk_smooth, 'PixelList');
    
    for i = 1:length(cont_sections_idx)
        % Assign jerk for this section to variables and indexes of section
        jerk_temp = cont_sections_jerk(i).PixelValues;
        surge_temp = cont_sections_surge(i).PixelValues;
        pitch_temp = cont_sections_pitch(i).PixelValues;
        
        temp_idx = cont_sections_idx(i).PixelList(:, 1);
        
        % Rescale the jerk in this section
        jerk_temp = rescale(jerk_temp);
        surge_temp = rescale(surge_temp);
        pitch_temp = rescale(pitch_temp);
        
        jerk_smooth(temp_idx) = jerk_temp;
        surge_smooth(temp_idx) = surge_temp;
        pitch_smooth(temp_idx) = pitch_temp;
    end
    
    %% Step 5h: Peak detection of movement signals
    
    %% %% Peak detection: Jerk
    % Plot jerk signal
    fig1 = figure('units','normalized','outerposition',[0 0 1 1]);
    ax(1) = subplot(3, 5, [1 2]);
    plot(time_min(start_idx:end_idx), jerk_smooth, 'k-'); grid; hold on;
    xlabel('Time (min)'); ylabel('Jerk SE Smooth'); ylim([0 1.2])
    
    % Peak detection
    [j_locs, j_width, j_prom, idx, rm_group] = detect_peaks(metadata.fs, jerk_smooth', 3);
    
    % Plot jerk peaks
    subplot(3, 5, [1 2]);
    scatter(time_min(j_locs+start_idx), jerk_smooth(j_locs), 'r*')
    
    %% %% Peak detection: Surge
    ax(2) = subplot(3, 5, [6 7]);
    plot(time_min(start_idx:end_idx), surge_smooth, 'k'); grid; hold on;
    xlabel('Time (min)'); ylabel('Surge SE Smooth'); ylim([0 1.2])
    
    % Peak detection
    [s_locs, s_width, s_prom, idx, rm_group] = detect_peaks(metadata.fs, surge_smooth, 8);
    
    % Plot surge peaks
    subplot(3, 5, [6 7]);
    scatter(time_min(s_locs+start_idx), surge_smooth(s_locs), 'b*')
    
        %% %% Peak detection: Pitch
    ax(3) = subplot(3, 5, [11 12]);
    plot(time_min(start_idx:end_idx), pitch_smooth, 'k'); grid; hold on;
    xlabel('Time (min)'); ylabel('Pitch SE Smooth');
    
    % Peak detection
    [p_locs, p_width, p_prom, idx, rm_group] = detect_peaks(metadata.fs, pitch_smooth, 13);
    
    % Plot surge peaks
    subplot(3, 5, [11 12]);
    scatter(time_min(p_locs+start_idx), pitch_smooth(p_locs), 'g*')

    %% Step 5i: Detect windows for breaths during logging periods
    
    % Identify 5 second windows around peaks
    j_wins = [];
    for a = 1:length(j_locs)
        j_temp_win = (j_locs(a)-floor(2.5*metadata.fs)):1:(j_locs(a)+ceil(2.5*metadata.fs));
        j_wins = [j_wins, j_temp_win];
    end
    
    s_wins = [];
    for b = 1:length(s_locs)
        s_temp_win = (s_locs(b)-floor(2.5*metadata.fs)):1:(s_locs(b)+ceil(2.5*metadata.fs));
        s_wins = [s_wins, s_temp_win];
    end
    
    p_wins = [];
    for c = 1:length(p_locs)
        p_temp_win = (p_locs(c)-floor(2.5*metadata.fs)):1:(p_locs(c)+ceil(2.5*metadata.fs));
        p_wins = [p_wins, p_temp_win];
    end
    
    % Identify where one window stops and the next starts
    if length(j_wins)>0
        j_wins_breaks = [j_wins(diff(j_wins)>1), j_wins(end)];
    end
    if length(s_wins)>0
        s_wins_breaks = [s_wins(diff(s_wins)>1), s_wins(end)];
    end
    if length(p_wins)>0
        p_wins_breaks = [p_wins(diff(p_wins)>1), p_wins(end)];
    end
    
    % Places where all three conditions are met
    [val3] = intersect(intersect(intersect(p_shallow_idx, p_wins), j_wins), s_wins);
    
    % Places where only two conditions are met
    [val2_js] = intersect(intersect(p_shallow_idx, j_wins), s_wins);
    [val2_jp] = intersect(intersect(p_shallow_idx, j_wins), p_wins);
    [val2_sp] = intersect(intersect(p_shallow_idx, s_wins), p_wins);
    
    diff_vals_js = setdiff(val2_js, val3);
    diff_vals_jp = setdiff(val2_jp, val3);
    diff_vals_sp = setdiff(val2_sp, val3);
    
    val3 = sort([val3; diff_vals_js; diff_vals_jp; diff_vals_sp]);
    
    % Find where there is a break in where these conditions are met
    temp_diff_break = find(diff(val3)>1);
    
    % Save ranges of continuous periods where conditions are met
    log_breath_locs = [];
    
    %% Step 5j: Detect breaths during logging periods
    
    % Go through continuous periods where conditions are met one by one
    if length(temp_diff_break)>0
        for c = 1:length(temp_diff_break)+1
            
            % If the first period...
            if c == 1
                j_win_count = 0; s_win_count = 0; p_win_count = 0;
                cont_val3_prev = -3*fs;
                % Save the indexes of the continuous range that meets all three
                % conditions
                cont_range = [1:temp_diff_break(1)];
                % If this period is greater than 1 second
                if length(cont_range)>1*fs
                    % Save this range of indices
                    cont_val3 = val3(cont_range);
                else
                    cont_val3 =  -3*fs;
                end
            elseif c == length(temp_diff_break)+1 % If the last period...
                % Assign last cont_val3 to this variable to compare later
                cont_val3_prev = cont_val3;
                cont_range = [(temp_diff_break(c-1)+1):length(val3)];
                if length(cont_range)>1*fs
                    cont_val3 = val3(cont_range);
                end
            elseif c > 1 && c < length(temp_diff_break)+1 % If a period between the first and last
                % Assign last cont_val3 to this variable to compare later
                cont_val3_prev = cont_val3;
                cont_range = [(temp_diff_break(c-1)+1):temp_diff_break(c)];
                if length(cont_range)>1*fs
                    cont_val3 = val3(cont_range);
                end
            end
            
            % Filter out instances where a peak region of one signal overlaps 
            % with two peak regions from another signal - only allow one of
            % these to be marked for breath ID
            % Find the indexes where this window overlaps with peak regions
            if length(cont_val3)>1*fs
                cond = 0;
                % Save the old window
                j_win_count_prev = j_win_count;
                % Find where this period intersects with the jerk windows
                j_temp_int = intersect(cont_val3, j_wins);
                % Find which window (count-wise) this period came from
                if isempty(j_temp_int)==0
                    j_win_count = find(j_temp_int(end)<=j_wins_breaks, 1, 'first');
                    cond = 1;
                end
                
                s_win_count_prev = s_win_count;
                s_temp_int = intersect(cont_val3, s_wins);
                if isempty(s_temp_int)==0
                    s_win_count = find(s_temp_int(end)<=s_wins_breaks, 1, 'first');
                    cond = 1;
                end
                
                p_win_count_prev = p_win_count;
                p_temp_int = intersect(cont_val3, p_wins);
                if isempty(p_temp_int)==0
                    p_win_count = find(p_temp_int(end)<=p_wins_breaks, 1, 'first');
                    cond = 1;
                end
                
                % If the same window as last time for any of these then keep first,
                % skip second instance
                if length(cont_range)>1*fs && (j_win_count>j_win_count_prev && s_win_count>s_win_count_prev && p_win_count>p_win_count_prev || cond == 1)
                    if cont_val3(1)>cont_val3_prev(length(cont_val3_prev))+fs/10 || max(p_smooth_tag(cont_val3_prev))>0.5 || max(p_smooth_tag(cont_val3))>0.5 %If the first value of the range is less than 150 indices away from the last value of the last range...
                        % Mark breath at halfway point of each period
                        log_breath_locs = [log_breath_locs; cont_val3(floor(length(cont_val3)/2))];
                    end
                end
            end
        end
    end
    
    % If a breath detection from a single surfacing is closer than 3 seconds
    % (e.g. 20 breaths/min) to a breath detection from
    % logging, then the ss breath trumps and we remove the logging breath
    temp_all_breaths= [all_breath_locs.breath_idx; log_breath_locs];
    temp_all_breaths_type = [repmat("ss", length(all_breath_locs.breath_idx), 1); repmat("log", length(log_breath_locs), 1)];%; diff_vals_ps]), 1)];
    
    [temp_all_breaths_s, sortidx] = sort(temp_all_breaths);
    temp_all_breaths_type_s = temp_all_breaths_type(sortidx, :);
    
    sim_breaths = find(diff(temp_all_breaths_s)<3*fs);
    rm_rows = [];
    if isempty(sim_breaths) == 0
        for i = 1:length(sim_breaths)
            temp_row = find(temp_all_breaths_type_s(sim_breaths(i):sim_breaths(i)+1) == "log");
            rm_rows = [rm_rows; sim_breaths(i)+temp_row-1];
        end
    end
    
    temp_all_breaths_s(rm_rows, :) = [];
    temp_all_breaths_type_s(rm_rows, :) = [];
    
    % Changing these to be in full range of "p"
    all_breath_locs.breath_idx = temp_all_breaths_s + start_idx;
    all_breath_locs.type = temp_all_breaths_type_s;
    
    %% Step 5k: Plot breath detections for logging periods
    
    ax(4) = subplot(3, 5, [4, 5, 9, 10, 14, 15]);
    p1 = plot(time_min(start_idx:end_idx), p_smooth_tag, 'k');
    set(gca, 'ydir', 'reverse')
    hold on
    p_smooth_p2 = p_smooth_tag;
    idx_temp = ismember(1:numel(p_smooth_p2),val3); % idx is logical indices
    p_smooth_p2(~idx_temp) = NaN;
    p2 = plot(time_min(start_idx:end_idx), p_smooth_p2, 'k-', 'LineWidth', 2);
    p3 = scatter(time_min(start_idx+log_breath_locs-1), p_smooth_tag(log_breath_locs), 80, 'm*', 'LineWidth', 2);
    title('Breath IDs during logging')
    ylabel('Depth (m)'); xlabel('Time (min)');
    
    legend([p1 p2],{'Dive depth' , 'Breath IDs - all three conditions'}, 'Location', 'south')%, 'Breath IDs - surge jerk + pitch'}, 'Location', 'best')
    
    linkaxes(ax, 'x')
    
    % Save figure
    figfile = strcat(data_path, '/figs/', metadata.tag, '_loggingdetections.fig');
    if isfile(figfile) == 1
        txt = input("A figure with this name already exists - do you want to append a custom suffix? (y/n) \n","s");
        if strcmp(txt, "y") == 1
            txt = input("What suffix? do you want to append (e.g. _examplesection) \n","s");
            savefig(strcat(data_path, '/figs/', metadata.tag, '_loggingdetections', txt, '.fig'));
        else
            savefig(figfile);
        end
    end 
    
    %% Step 5l: Write breaths to audit
    
    if isfile(strcat(data_path, "\breaths\", metadata.tag, "breaths.mat")) == 1
        txt = input("A breath detections file already exists - do you want to append a custom suffix? (y/n) \n","s");
        if strcmp(txt, "y") == 1
            txt = input("What suffix? do you want to append (e.g. _examplesection) \n","s");
            save(strcat(data_path, "\breaths\", metadata.tag, "breaths", txt), 'tag', 'p_tag', 'p_smooth', 'p_smooth_tag', 'start_idx', 'end_idx', 'all_breath_locs', 'logging_ints_s', 'fs');
        end
     else
            save(strcat(data_path, "\breaths\", metadata.tag, "breaths"), 'tag', 'p_tag', 'p_smooth', 'p_smooth_tag', 'start_idx', 'end_idx', 'all_breath_locs', 'logging_ints_s', 'fs');
    end    
    
    clearvars -except taglist tools_path mat_tools_path data_path; clc; close all
    
end

%% Step 6: Plot all breaths

for k = 1:length(taglist)
    %% Step 6a: Load in tag data
    tag = taglist{k};
    
    %Load in metadata
    metadata = load(strcat(data_path, "\metadata\", tag, "md"));
    clear tag
    
    %Set path for prh files
    settagpath('prh',strcat(data_path,'\prh'));
    
    % Load the existing prh file
    loadprh(metadata.tag);
       
    % Load in movement data
    load(strcat(data_path, "\movement\", metadata.tag, "movement.mat"), 'jerk_smooth', 'surge_smooth', 'pitch_smooth');
    
    % Load in breathing information
    load(strcat(data_path, "\breaths\", metadata.tag, "breaths.mat"));
    
    [time_sec, time_min, time_hour] =calc_time(metadata.fs, pitch); %Recalculate time
    
    % Load in breaths
    breath_idx = all_breath_locs.breath_idx;
    breath_times = time_sec(all_breath_locs.breath_idx);
    
    [breath_times, sortidx]  = sort(breath_times);
    breath_type = all_breath_locs.type(sortidx, :);
    
    %% Step 6b: Plot all breaths
    figure
    title(metadata.tag, 'Interpreter', 'none');
    ax(1)=subplot(4, 1, 1);
    plot(time_min, p_smooth, 'k', 'LineWidth', 1.5); hold on
    set(gca,'Ydir','reverse')
    ylabel('Depth (m)');
    
    hold on
    scatter(breath_times(breath_type == 'ss')/60, p_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, p_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    
    legend('Depth', 'Single surface breaths', 'Log breaths');
    
    ax(2)=subplot(4, 1, 2);
    plot(time_min(2:end), surge_smooth, 'r', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == 'ss')/60, surge_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, surge_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    ylabel('Smoothed Surge SE');
    
    ax(3)=subplot(4, 1, 3);
    plot(time_min(2:end), jerk_smooth, 'b', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == 'ss')/60, jerk_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, jerk_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    ylabel('Smoothed Jerk SE');
    
    ax(4)=subplot(4, 1, 4);
    plot(time_min(2:end), pitch_smooth, 'g', 'LineWidth', 1.5); hold on
    scatter(breath_times(breath_type == 'ss')/60, pitch_smooth(breath_idx(breath_type == 'ss')), 60, 'cs', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    scatter(breath_times(breath_type == 'log')/60, pitch_smooth(breath_idx(breath_type == 'log')), 60, 'ms', 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', .75, 'MarkerEdgeAlpha', .75)
    linkaxes(ax, 'x');
    ylabel('Smoothed Pitch SE');
    xlabel('Time (min)');
    
    figfile = strcat(data_path, '/figs/', metadata.tag, '_allbreaths.fig');
    savefig(figfile);
    
    %Calculate and plot fR
    [fR] = get_contfR(breath_times, breath_idx, p, time_min, metadata.tag);
    
    figfile = strcat(data_path, '/figs/', metadata.tag, '_resprate.fig');
    savefig(figfile);
    
    clearvars -except taglist tools_path mat_tools_path data_path; clc; close all
    
end

%% Step 7: Test detections for gm08_143b

% Load in validation breathing information
load(strcat(tools_path, "\tests\gm\breaths\gm08_143bbreaths_val.mat"));

% Load in breaths
true_breath_idx = all_breath_locs.breath_idx;
true_breath_s = true_breath_idx/fs;

% Load in breathing information generated by user
load(strcat(tools_path, "\tests\gm\breaths\gm08_143bbreaths.mat"));

% Load in breaths
breath_idx = all_breath_locs.breath_idx;
breath_s = breath_idx/fs;

% Calculate similarity between true and users detections
breath_idx_diff = true_breath_s - breath_s;

% Print out similarity metrics
fprintf('The mean difference between your detections and the true detections is: %0.1f seconds\n', mean(breath_idx_diff)); 
fprintf('The max difference between your detections and the true detections is: %0.1f seconds\n', max(breath_idx_diff)); 

 

%% Step S1: Save all breath information for analysis in  R
clearvars -except taglist tools_path mat_tools_path data_path; clc; close all

for k = 1:length(taglist);
tag = taglist{k};

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));
clear tag

% Load in dives
load(strcat(data_path, "\diving\", metadata.tag, "dives"))

% Load in dive table
load(strcat(data_path, "\diving\", metadata.tag, "divetable"))

% Load in breathing information
load(strcat(data_path, "\breaths\", metadata.tag, "breaths.mat"));

% Load full p from prh file - this will replace appended p from breathing
% file
load(strcat(data_path, "\prh\", metadata.tag, "prh.mat"),'p');

[time_sec, time_min, time_hour] =calc_time(metadata.fs, p); %Recalculate time

depth{k} = p;
fs_temp{k} = metadata.fs;
dive_start_s{k} = dive_start;
dive_end_s{k} = dive_end;
odba{k} = dive_odba;
logging_intervals_s{k} = logging_ints_s;

% Load in breaths
[temp_all_breaths_s, sortidx] = sort(all_breath_locs.breath_idx);
temp_all_breaths_type_s = all_breath_locs.type(sortidx, :);

breath_idx{k} = temp_all_breaths_s;
breath_type{k} = temp_all_breaths_type_s;
breath_type{k}(breath_type{k}=="ss") = 1;
breath_type{k}(breath_type{k}=="log") = 2;

breath_type{k} = str2double(breath_type{k});

end

fs = fs_temp;

% Save data to bring into R
save(strcat(data_path, '\all_breath_data.mat'),'dive_start_s', 'dive_end_s', 'taglist', 'breath_idx', 'breath_type', 'depth', 'fs', 'odba', 'logging_intervals_s')

%% Step S2: Acoustic audits

%% %% Step S2a: Acoustic auditing for D2s
settagpath('audit', strcat(data_path, '\audit\'));
settagpath('prh', strcat(data_path, '\prh\'));
settagpath('audio', 'D:\gm', 'cal', strcat('D:\gm', '\cal\'));

tag = 'gm08_143a';
tcue = 192



%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));

R = loadaudit(tag);
R = tagaudit(tag, tcue, R);
saveaudit(tag, R);

%% %% Step S2b: Acoustic auditing for D3s
settagpath('audit', strcat(data_path, '\audit\'));
settagpath('prh', strcat(data_path, '\prh\'));
settagpath('audio', data_path, 'cal', strcat(data_path, '\cal\'));

tag = 'gm15_153a';
recdir = stracat(data_path, '\gm15\gm15_153a');
tcue = 0;

%Load in metadata
metadata = load(strcat(data_path, "\metadata\", tag, "md"));

R = loadaudit(tag);
R = d3audit(recdir, tag,  tcue, R);
saveaudit(tag, R);