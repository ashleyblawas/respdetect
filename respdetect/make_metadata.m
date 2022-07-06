%%  Function to create metadata structure so you don't have to deal with lots of variables

function [metadata] = make_metadata(tag, recdir, prefix, fs, tag_ver, acousaud_filename, time_tagon, time_tagoff);

% Create metadata variable
metadata.tag = tag;
metadata.prefix = prefix;
metadata.recdir = recdir;
metadata.fs = fs;
metadata.tag_ver = tag_ver;
metadata.tagon_time = time_tagon;
metadata.tagoff_time = time_tagoff;
metadata.acousticaudit_filename = acousaud_filename;


