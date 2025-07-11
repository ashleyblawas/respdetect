function save_metadata(tag, recdir, prefix, fs, tag_ver, acousaud_filename, time_tagon, time_tagoff);
    arguments
        tag (1,:) char
        recdir
        prefix
        fs (1, 1) double
        tag_ver (1,:) char
        acousaud_filename
        time_tagon
        time_tagoff
    end
    % Create and save metadata structure so you don't have to deal with lots of variables
    %
    % Inputs:
    %    tag (1,:) char
    %    recdir
    %    prefix
    %    fs (1, 1) double
    %    tag_ver
    %    acousaud_filename
    %    time_tagon
    %    time_tagoff
    %
    % Usage:
    %   save_metadata(tag, recdir, prefix, fs, tag_ver, acousaud_filename, time_tagon, time_tagoff)
    %
    
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
    % Create metadata variable
    metadata.tag = tag;
    metadata.prefix = prefix;
    metadata.recdir = recdir;
    metadata.fs = fs;
    metadata.tag_ver = tag_ver;
    metadata.tagon_time = time_tagon;
    metadata.tagoff_time = time_tagoff;
    metadata.acousticaudit_filename = acousaud_filename;
    
    
