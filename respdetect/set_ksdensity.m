function set_ksdensity()
    % Adds ksdensity path from the Statistics Toolbox to the top of the
    % path
    %
    % Author: Ashley Blawas
    % Last Updated: 7/11/2025
    % Stanford University
    
     % Add this path to make sure using the right ksdensity
    % Get the full path to the official ksdensity.m
    ksPath = which('ksdensity');
    
    % Check if function exists
    if isempty(ksPath)
        error('ksdensity is not found on the MATLAB path.');
    end
    
    % Check that it comes from the stats toolbox
    if contains(ksPath, fullfile('toolbox', 'stats', 'stats'))
        ksFolder = fileparts(ksPath);
        
        % Move it to top of path (optional but ensures priority)
        addpath(ksFolder, '-begin');
        
        %fprintf('ksdensity confirmed from Statistics Toolbox: %s\n', ksPath);
    else
        error(['The ksdensity function is not from the expected Statistics Toolbox.\n' ...
            'Found at: %s\nPlease check your MATLAB path or reinstall the toolbox.'], ksPath);
    end
end

