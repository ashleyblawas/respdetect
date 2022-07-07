%%  Function to setup directories and such

function [recdir, prefix, acousaud_filename] = setup_dirs(tag, tag_ver, data_path, mat_tools_path)
    %% Use tag name to assign directories and filenames
    sp_year = tag(1:4);
    % Set parent directory
    recdir = strcat(data_path, sp_year, '\', tag); 
    % Set deployment name, probably the same as the parent folder
    deploy_name = tag; 
    prefix = tag;
    
    % Set name of acoustic audit file
    acousaud_filename = strcat(data_path, '\audit\', tag, '_acousticaud.txt'); 
    
    if strcmp(tag_ver, 'D3') == 1
        addpath(genpath(strcat(mat_tools_path, '\d3'))); %Add all of your tools to the path
    elseif strcmp(tag_ver, 'D2') == 1
        addpath(genpath(strcat(mat_tools_path, '\dtag2'))); %Add all of your tools to the path
        settagpath('audio',data_path,'cal',strcat(data_path,'\cal'));
    end
    
    %% Set other paths
    %Set path for prh files
    settagpath('prh',strcat(data_path,'\prh')); 
    
     %Set path for audit files
    settagpath('audit',strcat(data_path,'\audit'));
    
end
