function set_ksdensity()
    % SET_KSDENSITY Ensures the correct `ksdensity` function from MATLAB's Statistics Toolbox is used
    %
    % This function verifies that the `ksdensity` function in the current MATLAB path
    % originates from the official Statistics Toolbox and moves its folder to the top of the path
    % to avoid conflicts with custom or shadowed versions.
    %
    % Behavior:
    %   - Locates the path of the `ksdensity` function using `which`
    %   - Checks that the path includes the expected toolbox directory structure
    %     (i.e., it is from `toolbox/stats/stats`)
    %   - If found, it moves the folder containing `ksdensity.m` to the top of the MATLAB path
    %   - Throws an error if `ksdensity` is missing or not from the expected source
    %
    % Notes:
    %   - This is useful in environments where shadowed or custom versions of `ksdensity`
    %     may interfere with analysis scripts.
    %   - Requires the Statistics and Machine Learning Toolbox.
    %
    % Inputs:
    %   None
    %
    % Outputs:
    %   None (Modifies MATLAB path in session if applicable)
    %
    % Usage:
    %   set_ksdensity()
    %
    % Author: Ashley Blawas
    % Last Updated: August 11, 2025
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

