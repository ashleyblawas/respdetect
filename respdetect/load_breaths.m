function [breath_times, breath_type, xval, metadata, time_sec, time_min, time_hour] = load_breaths(tag, dataPath)
    arguments
        tag (1, :) char
        dataPath (1,:) char
    end
    % Determines the prh files that will be loaded for analysis
    %
    % Inputs:
    %   tag        - String, the tag name (e.g., 'tt01_123a')
    %   dataPath   - SBase path to data (e.g., 'C:\my_data\')
    %
    % Outputs:
    %   breath_times - Vector of breath event timestamps (in datetime or minutes)
    %   breath_type  - Categorical or string array of breath types ('log', 'ss', etc.)
    %   xval         - Full time vector for plotting (datetime or numeric time)
    %   metadata     - Struct loaded from the tag's metadata file
    %   time_sec     - Time in seconds (relative to start)
    %   time_min     - Time in minutes
    %   time_hour    - Time in hours
    %
    % Usage:
    %   [breath_times, breath_type, xval, metadata, time_sec, time_min, time_hour] = load_breaths(tag, dataPath)
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Get species code from tag name
    speciesCode = tag(1:2);
    
    % Load metadata
    metadataFile = fullfile(data_path, speciesCode, 'metadata', strcat(tag, 'md.mat'));
    metadataStruct = load(metadataFile);
    metadata = metadataStruct.metadata;
    
    % Set path for PRH files
    settagpath('prh', fullfile(data_path, speciesCode, 'prh'));
    
    % Load PRH data
    loadprh(metadata.tag);  % loads pitch, p, fs, etc.
    
    % Load movement data
    moveFile = fullfile(data_path, speciesCode, 'movement', strcat(metadata.tag, 'movement.mat'));
    load(moveFile, jerk_smooth', 'surge_smooth', 'pitch_smooth');
    
    % Load breathing data
    breathsFile = fullfile(data_path, speciesCode, 'breaths', strcat(metadata.tag, 'breaths.mat'));
    load(breathsFile, 'all_breath_locs');
    
    % Recalculate time from pitch signal
    [time_sec, time_min, time_hour] = calc_time(metadata.fs, pitch);
    
    % Extract breath index
    breath_idx = all_breath_locs.breath_idx;
    
    % Determine output time format based on tag version
    if strcmp(metadata.tag_ver, "CATS")
        % Load absolute date numbers from workspace (must exist)
        breath_times = datetime(DN(breath_idx), 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
        xval = datetime(DN, 'ConvertFrom', 'datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    else
        breath_times = time_min(breath_idx);
        xval = time_min;
    end
    
    % Sort breath times and apply same order to breath types
    [breath_times, sortidx] = sort(breath_times);
    breath_type = all_breath_locs.type(sortidx, :);
end
