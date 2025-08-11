function save_fig(dataPath, speciesCode, metadata, fig_suffix)
    arguments
        dataPath (1,:) char                            % Base path to data directory
        speciesCode (1,2) char                         % Two-letter species code (e.g., 'gm', 'zc')
        metadata (1,1) struct                          % Metadata struct with at least a 'tag' field
        fig_suffix (1,:) char                          % Suffix to append to figure file name
    end
    % SAVE_FIG Save a figure with overwrite or rename options
    %
    % Saves the current active figure (.fig format) to a specified directory
    % structure based on species code and tag name. If a file with the same
    % name already exists, the user is prompted to:
    %   - Overwrite the existing file
    %   - Append a custom suffix to rename the file
    %   - Cancel the save operation
    %
    % Inputs:
    %   dataPath     - Base path to your data directory (e.g., 'C:\data\')
    %   speciesCode  - Two-letter species subfolder name (e.g., 'GM', 'ZC')
    %   metadata     - Struct with field `tag` (e.g., 'gm14_123a')
    %   fig_suffix   - Suffix string to append to filename (e.g., 'surfacings')
    %
    % File Path Structure:
    %   The figure is saved in: [dataPath]/[speciesCode]/figs/
    %   with filename: [tag]_[fig_suffix].fig
    %
    % Example:
    %   save_fig('C:\data\', 'gm', metadata, 'breaths_detected')
    %   → Saves: C:\data\gm\figs\gm14_123a_breaths_detected.fig
    %
    % Behavior:
    %   - If directory [dataPath/speciesCode/figs] does not exist, it is created
    %   - If figure file already exists, prompts user to choose overwrite, rename, or cancel
    %   - Saves current active figure using MATLAB's `savefig` function
    %
    % Outputs:
    %   None (saves file to disk; does not return to workspace)
    %
    % Author: Ashley Blawas
    % Last Updated: August 11, 2025
    % Stanford University
    
    % Construct full figure file path
    figDir = fullfile(dataPath, speciesCode, 'figs');
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end
    
    figfile = fullfile(figDir, strcat(metadata.tag, '_', fig_suffix, '.fig'));
    
    fprintf("Figure filename: %s\n", figfile);
    
    % Check if file already exists
    if isfile(figfile)
        prompt = sprintf(['A figure with this name already exists.\n' ...
            'Options:\n' ...
            '  [o] Overwrite existing file\n' ...
            '  [a] Append custom suffix\n' ...
            '  [c] Cancel save\n' ...
            'Choose an option (o/a/c): ']);
        txt = input(prompt, "s");
        
        switch lower(txt)
            case 'a'
                suffix = input("Enter suffix to append (e.g. _examplesection): ", "s");
                figfile = fullfile(figDir, strcat(metadata.tag, '_', fig_suffix, suffix, '.fig'));
                savefig(figfile);
                fprintf("Figure saved as: %s\n", figfile);
                
            case 'o'
                savefig(figfile);
                fprintf("Figure overwritten at: %s\n", figfile);
                
            otherwise
                disp("Figure was not saved.");
        end
        
    else
        % Save the figure if it doesn’t exist
        savefig(figfile);
        fprintf("Figure saved to: %s\n", figfile);
    end
    
end